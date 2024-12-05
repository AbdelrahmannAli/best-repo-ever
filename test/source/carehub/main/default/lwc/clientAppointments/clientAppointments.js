import { api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { EnclosingTabId, getTabInfo, openSubtab } from 'lightning/platformWorkspaceApi';
import UtilityLWC from "c/utils";
import getClientAppoinments from "@salesforce/apex/ClientCasesController.getClientAppoinments";
import getExternalSystems from "@salesforce/apex/ClientCasesController.getExternalSystems";
import getCaseContactId from "@salesforce/apex/ClientCasesController.getCaseContactId";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import careCircle_NoUpcomingAppointments from "@salesforce/label/c.careCircle_NoUpcomingAppointments";
import { getRecord } from "lightning/uiRecordApi";

export default class ClientAppointments extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("clientAppointments");
	}
	@api recordId;
	@track contactId;
	@track events = [];
	@track noEvents = false;
	@track isLoading = false;

	labels = {
		careCircle_NoUpcomingAppointments
	}
	@wire(getRecord, { recordId: "$recordId", fields: ["Case.ContactId"] })
	recordUpdated({ data }) {
		if (!this.recordId || !data) {
			return;
		}
		if (data.apiName !== "Case") {
			this.checkRecordType();
			return;
		}
		let contactId = data.fields.ContactId;
		if (this.contactId !== contactId) {
			this.checkRecordType();
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.checkRecordType();
		this.isLoading = true;
		this.setUpChatButton();
	}
	handleButtonClick() {
		this.isLoading = true;
		this.checkRecordType();
	}
	

	async checkRecordType() {
		try {
			let result = await getSobjectFromId({ sObjectId: this.recordId });
			this.recordType = result;
			if (this.recordType.toLowerCase() === "contact") {
				this.contactId = this.recordId;
				this.getAppointments();
			} else {
				this.getContactId();
			}
		} catch (error) {
			this.logException(error, "checkRecordType");
		}
	}

	async getContactId() {
		try {
			let contact = await getCaseContactId({
				caseId: this.recordId
			});
			const contactData = JSON.parse(contact);
			this.contactId = contactData.ContactId;
			this.getAppointments();
		} catch (error) {
			this.isLoading = false;
			this.logException(error, "getContactId");
		}
	}

	async getAppointments() {
		try {
			if(!this.contactId){
				this.noEvents = true
				this.isLoading = false;
				return;
			}
			let result = await getClientAppoinments({ clientId: this.contactId });
			result = result.sort((a, b) => new Date(a.StartDateTime) - new Date(b.StartDateTime));
			this.isLoading = false;
			this.events = result;
			this.processEvents(result);
		} catch (error) {
			this.isLoading = false;
			this.logException(error, "getAppointments");
		}
	}

	processEvents(events) {
		if (this.events.length === 0){
			this.noEvents = true
		}
		else{
			this.noEvents = false
		}
		this.events = events.map((event) => {
			let location = "";
			let description = event.Description || "";
			let StartTime = "";
			let EndTime = "";
			let Time = "";
			let DescriptionAvailable = true;

			if (event.EndDateTime) {
				let endParts = event.EndDateTime.split(" ");
				let endTimePart = endParts[1] ? endParts[1].slice(0, 5) : "00:00"; 
				let [endHours, endMinutes] = endTimePart.split(":");
				EndTime = `${endHours}:${endMinutes}`;
			} else if (event.totalDuration && event.StartDateTime) {
				let startParts = event.StartDateTime.split(" ");
				let datePart = startParts[0];
				let timePart = startParts[1] ? startParts[1].slice(0, 5) : "00:00"; 
				let [startHours, startMinutes] = timePart.split(":");
		
				let startDateTime = new Date(datePart.replace(/-/g, '/'));
				startDateTime.setHours(parseInt(startHours));
				startDateTime.setMinutes(parseInt(startMinutes));
		
				startDateTime.setSeconds(startDateTime.getSeconds() + event.totalDuration);
				let endHours = String(startDateTime.getHours()).padStart(2, '0');
				let endMinutes = String(startDateTime.getMinutes()).padStart(2, '0');
				EndTime = `${endHours}:${endMinutes}`;
			}

			if (event.StartDateTime) {
				let parts = event.StartDateTime.split(" ");
				let date = new Date(parts[0]);
				let day = date.getDate();
				let month = date.toLocaleString("default", { month: "long" });
				let weekday = date.toLocaleString("default", { weekday: "long" });
				event.StartDateTime = `${weekday} ${day} ${month}`;	
				if (parts[1]){
					let timeParts = parts[1].split('.')[0];
					let [hours, minutes] = timeParts.split(":");
					StartTime = `${hours}:${minutes}`;
				}
			}
			if((EndTime || StartTime) == ''){
				StartTime = 'NA'
				EndTime = 'NA'
				Time = 'Nog niet bekend'
			}
			else {
				Time = StartTime + '-' + EndTime
			}

			if(description.length === 0){
				DescriptionAvailable = false
			}
		
			return {
				...event,
				Location: location,
				Description: description,
				Time: Time,
				DescriptionAvailable:DescriptionAvailable
			};
		});
	}
	@track chatAvailable = false;
	@track chatUrl = null;
	@track moreThanOneExternalSystem = null;
	async setUpChatButton() {
		try{
		let externalSystems = await getExternalSystems();
		externalSystems= externalSystems.filter((r) => r.Syntilio__ChatUrl__c );
		if (externalSystems.length == 1) {
			this.chatUrl = externalSystems[0].Syntilio__ChatUrl__c ;
			this.chatAvailable = true
		}
		else if (externalSystems.length > 1){
			this.chatAvailable = true
			this.moreThanOneExternalSystem = true
		}
		else{
			this.logException("There are no external systems");
			this.chatAvailable = false
		}
		}
		catch(error){
			this.logException(error, "setUpChatButton");
		}
	}
	get isChatDisabled(){
		return ! this.chatAvailable;
	}
	@wire(EnclosingTabId) tabId;
	async handleChatClick() {
		try{
		if (this.chatUrl) {
			window.open(this.chatUrl, '_blank');
		}
		else if (this.moreThanOneExternalSystem){
			if (!this.tabId) {
				return;
			}
			const tabInfo = await getTabInfo(this.tabId);
			const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
			await openSubtab(primaryTabId, { url: '/apex/multipleChatSystems', focus: true });
		}
		else{
			this.logException("The chat URL is unavailable");
		}
		}
		catch(error){
			this.logException(error, "handleChatClick");
		}

	}
			
		
}
