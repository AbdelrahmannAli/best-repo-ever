// eslint-disable @lwc/lwc/no-async-operation
// eslint-disable consistent-return 
import { api, track, wire } from "lwc";
import getClients from "@salesforce/apex/ClientCasesController.getClients";
import getCaseSuggested from "@salesforce/apex/ClientCasesController.getCaseSuggested";
import UtilityLWC from "c/utils";
import getCaseContactCallerId from "@salesforce/apex/ClientCasesController.getCaseContactId";
import { NavigationMixin } from "lightning/navigation";
import updateCaseContactId from "@salesforce/apex/ClientCasesController.updateCaseContactId";
import updateCaseCaller from "@salesforce/apex/ClientCasesController.updateCaseCaller";
import {
	openSubtab,
	EnclosingTabId,
	getTabInfo,
	getFocusedTabInfo,
	refreshTab
} from "lightning/platformWorkspaceApi";
import searchForClient_WhoAreYouCallingFor from "@salesforce/label/c.searchForClient_WhoAreYouCallingFor";
import searchForClient_HelpText from "@salesforce/label/c.searchForClient_HelpText";
import searchForClient_SearchForPatient from "@salesforce/label/c.searchForClient_SearchForPatient";
import searchForClient_SearchForCaller from "@salesforce/label/c.searchForClient_SearchForCaller";
import searchForClient_Caller from "@salesforce/label/c.searchForClient_Caller";
import searchForClient_Client from "@salesforce/label/c.searchForClient_Client";
import searchForClient_CheckBox from "@salesforce/label/c.searchForClient_CheckBox";
import { getRecord } from "lightning/uiRecordApi";
import getAllContacts from "@salesforce/apex/ClientCasesController.getAllContacts";
import getCaseContactCareCircleMembers from "@salesforce/apex/ClientCasesController.getCaseContactCareCircleMembers";
import getAllGroups from "@salesforce/apex/ClientCasesController.getAllGroups";
import updateCaseCallerGroup from "@salesforce/apex/ClientCasesController.updateCaseCallerGroup";

// Unknown contact
// Suggested Care Circle members and the relation 
// decrease the space
export default class searchForClient extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("safetyBadges");
	}

	@api recordId;
	@track showClientsOptions = false;
	@track searchTerm = "";
	@track searchTermCaller = "";
	@track contactId;
	@track callerId;
	@track clientId;
	@track callerGroupId;

	@track listOfPatients = [];
	@track selectedClient;
	@track selectedCaller;
	@track showPatientOptions = false;
	@track isUpdating = false;
	@wire(EnclosingTabId) tabId;
	@track filteredData = []
	@track filteredCareCircleData = []
	@track allGroups = []
	@track initialContact =""
	@track initialCaller =""
	@track suggestedCareCircleMembers = []
	@track isCallerClient = false;
	@track suggestedLength = 0;
	@track openComboboxId = null;

	@wire(getRecord, { recordId: "$recordId", fields: ["Case.ContactId"] })
	recordUpdated({ data }) {
			if (!this.recordId || !data) {
				return;
			}
			this.getCaseContact();
		}

	labels = {
		searchForClient_WhoAreYouCallingFor,
		searchForClient_HelpText,
		searchForClient_SearchForPatient,
		searchForClient_SearchForCaller,
		searchForClient_Caller,
		searchForClient_Client,
		searchForClient_CheckBox
	};

	connectedCallback() {
		super.connectedCallback();
		this.getCaseContact();
	}

	get disabledButton(){
		return !(this.selectedCaller || this.selectedClient);
	}

	get suggestedTemp(){
		return !(this.clientId == null);
	}

	async getCaseContact() {
		try {
			let contact = await getCaseContactCallerId({
				caseId: this.recordId
			});
			const contactData = JSON.parse(contact);
			this.clientId = contactData.ContactId;
			this.initialContact = this.clientId;
			this.callerId = contactData.Syntilio__Caller__c;
			this.callerGroupId = contactData.Syntilio__CallerGroup__c;
			// this.initialCaller = (this.callerId||this.callerGroupId)
			if(this.callerId){
				this.initialCaller = this.callerId;
			} else if(this.callerGroupId){
				this.initialCaller = this.callerGroupId;
			}		
			let suggestedCallers = await getCaseSuggested({
					clientId: this.clientId
			});
				this.suggestedCareCircleMembers = suggestedCallers;
			this.getClientsFromApex();
		} catch (error) {
			this.logException(error, "getCareCircleData");
		}
	}

	async getClientsFromApex() {
		try {
			let data = await getClients();

			if (!data) return;
			const returnedPatients = JSON.parse(data.contacts);
			const returnedExternalIds = JSON.parse(data.externalIds);
			const updatedPatients = returnedPatients.map((patient) => {
				if (patient.Birthdate) {
					const [year, month, day] = patient.Birthdate.split("-");
					patient.Birthdate = `${day}-${month}-${year}`;
				}
				const externalIdRecord = returnedExternalIds.find(
					ext => ext.Syntilio__ContactId__c === patient.Id
				);
				if (externalIdRecord) {
					patient.externalId = externalIdRecord.Syntilio__Id__c;
				}
				return patient;
			});
			this.listOfPatients = updatedPatients;
			this.filteredData = returnedPatients;
			this.showClientsOptions = true;
			this.filteredData = this.filteredData.map(item => {
				const firstName = item.FirstName ? item.FirstName : "";
				const lastName = item.LastName ? item.LastName : "";
				const birthdate = item.Birthdate ? item.Birthdate : "";
				const postalCode = item.MailingPostalCode ? item.MailingPostalCode : "";
				const externalId = item.externalId? item.externalId : "";
			
				const labelParts = [firstName, lastName, birthdate, postalCode, externalId].filter(part => part !== "");
			    const label = labelParts.join(" "); 
				return {
					value: item.Id,
					label: label,
					selected: item.Id === this.clientId
				};
			});
				this.getCareCircleFromApex();	
		} catch (error) {
			this.logException(error, "getClientsFromApex");
		}
	}

	async getCareCircleFromApex() {
		try {
			let data = await getAllContacts();
			let result = await getCaseContactCareCircleMembers({
				clientId: this.clientId
			});
			let allCareCircleMembers = this.prepareCareCircleMembersData(result);
			await this.getGroupsFromApex();
			
			if (!data) return;
			const careCircle = JSON.parse(data);
			const careCircleMemberIds = new Set(
				allCareCircleMembers.map(member => member.ContactId)
			);
			const updatedCareCircle = careCircle.map((patient) => {
				if (patient.Birthdate) {
					const [year, month, day] = patient.Birthdate.split("-");
					patient.Birthdate = `${day}-${month}-${year}`;
				}
				return patient;
			});
			this.listOfPatients = updatedCareCircle;
			const contactData = careCircle
            .filter(item => !careCircleMemberIds.has(item.Id))
			.map(item => {
				const firstName = item.FirstName ? item.FirstName : "";
				const lastName = item.LastName ? item.LastName : "";
				const birthdate = item.Birthdate ? item.Birthdate : "";
				const postalCode = item.MailingPostalCode ? item.MailingPostalCode : "";
			
				const labelParts = [firstName, lastName, birthdate, postalCode].filter(part => part !== "");
			    const label = labelParts.join(" "); 
				return {
					value: item.Id,
					label: label,
					selected: item.Id === this.callerId,
					category: "Contacts"
				};
			});

			let careCircleMemberData = [];
			if (allCareCircleMembers?.length > 0) {
				allCareCircleMembers.sort((a, b) => {
					const indexA = a.index !== undefined && a.index !== "" ? parseInt(a.index) : Number.MAX_SAFE_INTEGER;
					const indexB = b.index !== undefined && b.index !== "" ? parseInt(b.index) : Number.MAX_SAFE_INTEGER;
					return indexA - indexB;
				});
				careCircleMemberData = allCareCircleMembers.map(member => {
					const index = member.index !== undefined && member.index !== "" ? `${member.index}:` : "";
					const relationship = member.Relationship ? `(${member.Relationship})` : "";
					const name = member.Name || "";
			
					const labelParts = [index, name, relationship].filter(part => part !== "");
					const label = labelParts.join(" ");
					return {
						value: member.ContactId,
						label: label,
						selected: false,
						category: "Care Circle"
					};
				});
				if(allCareCircleMembers.length>3){
					this.suggestedLength = 3;
				} else{
					this.suggestedLength = allCareCircleMembers.length;
				}
			}
			
			let groupData = [];
			if (this.allGroups?.length > 0) {
				groupData = this.allGroups.map(group => ({
					value: group.value,
					label: group.label,
					selected: group.selected,
					category: "Groups"
				}));
				
			}
			this.filteredCareCircleData = [...groupData, ...careCircleMemberData, ...contactData];
			this.filteredCareCircleData = this.filteredCareCircleData.sort((a, b) => {
				if (a.label === 'Unknown Caller') return 1;
				if (b.label === 'Unknown Caller') return -1;
				return 0;
			});
			this.showClientsOptions = true;
		} catch (error) {
			this.logException(error, "getClientsFromApex");
		}
	}

	async getGroupsFromApex(){
		let data = await getAllGroups();
		if (!data) return;
		const parsedData = JSON.parse(data);
		this.allGroups = parsedData.map(item => {
			const Name = item.Name ? item.Name : "";
			return {
				value: item.Id,
				label: Name,
				selected: item.Id === this.callerId
			};
		});
	}

	handleCallerChange(event) {
		const selectedValue = event.detail[0];
		const options = this.filteredCareCircleData.find(item => item.value === selectedValue);
		if (options) {	
			const id = options.value;
			const category = options.category;
			this.selectedCaller = id;
			if(category === 'Groups' && this.selectedCaller != this.callerGroupId){
				this.updateGroupId();
				this.callerGroupId = id;
			}else if(this.selectedCaller != this.callerId){
				this.updateCallerId();
				this.callerId = id;
			}
		}
	}
	removeCaller() {
		this.selectedCaller = null;
		if(this.callerId){
			this.callerId = null;
			this.updateCallerId();
		} else if(this.callerGroupId){
			this.callerGroupId = null;
			this.updateGroupId();
		}
		this.isCallerClient = false;
		const checkbox = this.template.querySelector('.callerisclient');
		if (checkbox) {
			checkbox.checked = false;
		}
	}
	removeContact() {
		this.selectedClient = null;
		this.clientId = null
		this.isCallerClient = false;
		this.updateContactId();
		const checkbox = this.template.querySelector('.callerisclient');
		if (checkbox) {
			checkbox.checked = false;
		}
		this.suggestedLength = 0;
	}
	handleClientChange(event) {
		event.detail.forEach((element) => {
		this.selectedClient = element;
				});
		if(this.selectedClient && this.selectedClient != this.clientId){
			this.updateContactId();
			this.clientId = this.selectedClient;
		}
	}
	async handleCheckboxChange(event){
		this.isCallerClient = event.target.checked;
		if (this.isCallerClient) {
			if(!this.selectedClient){
				await this.updateContactId();
			}else{
				this.isUpdating = true;
				this.filteredCareCircleData = []
				await this.updateCallerId();
				await this.getCaseContact();
				this.isUpdating = false;
			}
        }
	}
	async updateGroupId(){
		try {
			if(this.isCallerClient){
				await updateCaseCaller({
					caseId: this.recordId,
					callerId: this.clientId
				});
			}
			else{
				await updateCaseCallerGroup({
					caseId: this.recordId,
					callerGroupId: this.selectedCaller
				});
			}
		} catch (error) {
			this.logException(error, "updateGroupId");
		}
	}
	async updateCallerId() {
		try {
			if(this.isCallerClient){
				await updateCaseCaller({
					caseId: this.recordId,
					callerId: this.clientId
				});
			}
			else{
				await updateCaseCaller({
					caseId: this.recordId,
					callerId: this.selectedCaller
				});
			}
		} catch (error) {
			this.logException(error, "updateContactId");
		} 
	}
	async updateContactId() {
		try {
			this.isUpdating = true;
			if(this.isCallerClient){
				await updateCaseContactId({
					caseId: this.recordId,
					clientId: this.selectedCaller
				});
			}
			else{
				await updateCaseContactId({
					caseId: this.recordId,
					clientId: this.selectedClient
				});
			}
			let tabInfo = await getFocusedTabInfo();
			refreshTab(tabInfo.tabId);
			
			this[NavigationMixin.GenerateUrl]({
				type: "standard__recordPage",
				attributes: {
					recordId: this.selectedClient,
					objectApiName: "Contact",
					actionName: "view"
				}
			}).then(async (url) => {
				const tabInfo = await getTabInfo(this.tabId);
				const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
				await openSubtab(primaryTabId, { url: url, focus: false });
			});
		} catch (error) {
			this.logException(error, "updateContactId");
		} finally {
			this.isUpdating = false;
		}
	}

	handleComboboxToggle(event) {
        const comboboxId = event.detail;
        if (this.openComboboxId && this.openComboboxId !== comboboxId) {
            const allComboboxes = this.template.querySelectorAll('c-multi-select-combobox');
            allComboboxes.forEach(combobox => {
                if (combobox.comboboxId !== comboboxId) {
                    combobox.closeDropdown();
                }
            });
        }
        this.openComboboxId = comboboxId;
    }

	prepareCareCircleMembersData(result) {
		let index = 1;
		return result.map((careCircleMember) => {
			return {
				RelationshipType: careCircleMember.Syntilio__RelationshipType__c,
				Relationship: careCircleMember.Syntilio__Relationship__c,
				ContactId: careCircleMember.Syntilio__RelatedContactId__c,
				Name: careCircleMember.Syntilio__RelatedContactId__r.Salutation
					? careCircleMember.Syntilio__RelatedContactId__r.Salutation +
					" " +
					careCircleMember.Syntilio__RelatedContactId__r.Name
					: careCircleMember.Syntilio__RelatedContactId__r.Name,
				Phone: careCircleMember.Syntilio__RelatedContactId__r.Phone,
				Email: careCircleMember.Syntilio__RelatedContactId__r.Email,
				Available: careCircleMember.Syntilio__Order__c,
				index: careCircleMember.Syntilio__RelationshipType__c === "Informal" ? index++ : ''
			};
		});
	}
}
