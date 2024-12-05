import getContactMedicalNotes from "@salesforce/apex/MedicalNotesHandler.getContactMedicalNotes";
import { api, track, wire } from "lwc";
import UtilityLWC from "c/utils";
import { subscribe } from "lightning/empApi";
import getUserId from "@salesforce/apex/CareHubUtilities.getUserId";
import { getRecord } from "lightning/uiRecordApi";
import getCaseContactId from "@salesforce/apex/ClientCasesController.getCaseContactId";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import contactMedicalNotes_UpdatingMedicalNotesFailed from "@salesforce/label/c.contactMedicalNotes_UpdatingMedicalNotesFailed";
import careCircle_NoMedicalNotes from "@salesforce/label/c.careCircle_NoMedicalNotes";
import manualSyncMedicalNotes from "@salesforce/apex/MedicalNotesHandler.manualSyncMedicalNotes";
export default class MedicalNotes extends UtilityLWC {
	constructor() {
		super("contactMedicalNotes");
	}

	@api recordId;
	@track contactMedicalNotes = [];
	@track libInitialized = false;
	@track channelName = "/event/Syntilio__Notification__e";
	@track userId;
	@track contactId;
	@track manualSync = false;
	@track isLoading = false;
	@track showMedicalNotes = false;
	@track recordType;
	@track notes = [];


	labels = {
		contactMedicalNotes_UpdatingMedicalNotesFailed,
		careCircle_NoMedicalNotes
	};

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

	async getClientMedicalNotes() {
		try {
			this.showMedicalNotes = false;
			let serializedResponseData = await getContactMedicalNotes({
				contactId: this.contactId
			});
			const responseData = JSON.parse(serializedResponseData);
			this.handleApexMedicalNoteResponse(responseData);
		} catch (error) {
			this.logException(error, "getClientMedicalNotes");
		}
	}

	async syncContactMedicalNotes() {
		try {
			this.isLoading = true;
			if(!this.recordId){
				this.isLoading = false;
				return;
			}
			await manualSyncMedicalNotes({
				clientId: this.recordId
			});
		} catch (e) {
			this.notifyUser(
				"",
				"Failed to sync contact medical notes",
				this.toastTypes.Error
			);
			this.logException(error, "syncContactMedicalNotes");
		}
	}

	handleApexMedicalNoteResponse(responseData) {
		if (!responseData || !responseData.data) {
			throw new Error(
				"Falsy response coming from getContactMedicalNotes, responseValue -> " +
					responseData +
					"reponseData" +
					responseData.data
			);
		}
		let medicalNotes = responseData.data;
		medicalNotes.reverse();
		this.contactMedicalNotes = medicalNotes.map(note => {
            return note.Syntilio__Comments__c.split('\n').filter(line => line.trim() !== '');
        });
		if(this.contactMedicalNotes.length>0){
			this.showMedicalNotes = true;
		} else {
			this.showMedicalNotes = false;
		}
	}

	receiveProgress(response) {
		if (!response) return;
		if (
			response.data.payload.Syntilio__Target__c === "MedicalNotes" &&
			response.data.payload.Syntilio__TargetUserId__c === this.userId
		) {
			this.checkRecordType();
			if (response.data.payload.Syntilio__Status__c === "Failure") {
				this.notifyUser(
					"",
					this.labels.contactMedicalNotes_UpdatingMedicalNotesFailed,
					this.toastTypes.Error
				);
			}
			this.isLoading = false;
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.handleSubscribe();
	}

	async checkRecordType() {
		try {
			this.showMedicalNotes = false;
			let result = await getSobjectFromId({ sObjectId: this.recordId });
			this.recordType = result;
			if (this.recordType.toLowerCase() === "contact") {
				this.contactId = this.recordId;
				this.getClientMedicalNotes();
			} else {
				this.getContactId();
			}
		} catch (error) {
			this.logException(error, "checkRecordType");
		}
	}

	handleButtonClick() {
		this.manualSync = true;
		if (this.recordType.toLowerCase() === "contact") {
			this.syncContactMedicalNotes();
		} else {
			this.recordId = this.contactId;
			this.syncContactMedicalNotes();
		}
	}

	async getContactId() {
		try {
			let contact = await getCaseContactId({
				caseId: this.recordId
			});
			const contactData = JSON.parse(contact);
			this.contactId = contactData.ContactId;
			this.getClientMedicalNotes();
		} catch (error) {
			this.logException(error, "getContactId");
		}
	}

	async handleSubscribe() {
		try {
			await subscribe(this.channelName, -1, (response) =>
				this.receiveProgress(response)
			);
			let userId = await getUserId();
			this.userId = userId;
		} catch (error) {
			this.logException(error, "handleSubscribe");
		}
	}
}
