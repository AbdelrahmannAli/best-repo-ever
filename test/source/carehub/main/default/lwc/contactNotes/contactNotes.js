import getCaseContactNotes from "@salesforce/apex/ContactNotesHandler.getCaseContactNotes";
import { api, track, wire } from "lwc";
import UtilityLWC from "c/utils";
import { subscribe } from "lightning/empApi";
import getUserId from "@salesforce/apex/CareHubUtilities.getUserId";
import { getRecord } from "lightning/uiRecordApi";
import contactNotes_UpdatingContactNotesFailed from "@salesforce/label/c.contactNotes_UpdatingContactNotesFailed";
import manualSyncContactNotes from "@salesforce/apex/ContactNotesHandler.manualSyncContactNotes";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import getCaseContactId from "@salesforce/apex/ClientCasesController.getCaseContactId";
import careCircle_NoMedicalNotes from "@salesforce/label/c.careCircle_NoMedicalNotes";

export default class ContactNotes extends UtilityLWC {
    constructor() {
        super("contacNotes");
    }

    @api recordId;
    @track recordType;

    @track contactNotes = [];
    @track libInitialized = false;
    @track channelName = "/event/Syntilio__Notification__e";
    @track userId;
    @track contactId;
    @track manualSync = false;
    @track isLoading = false;
    @track showClientNotes = false;

    labels = {
        contactNotes_UpdatingContactNotesFailed,
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
    async syncClientNotes() {
        try {
            this.isLoading = true;
            if(!this.contactId){
				this.isLoading = false;
				return;
			}
            await manualSyncContactNotes({
                clientId: this.contactId
            });
        } catch (e) {
            this.notifyUser("", "Failed to sync contact client notes", this.toastTypes.Error);
            this.logException(error, "syncClientNotes");
        }
    }

    handleButtonClick() {
        this.manualSync = true;
        if (this.recordType.toLowerCase() === "contact") {
            this.syncClientNotes();
        } else {
            this.syncClientNotes();
        }
    }

    async getContactNotes() {
        try {
            this.showClientNotes = false;
            let serializedResponseData = await getCaseContactNotes({
                caseId: this.recordId
            });
            const responseData = JSON.parse(serializedResponseData);
            this.handleApexContactNoteResponse(responseData);
        } catch (error) {
            this.logException(error, "getContactNotes");
        }
    }

    handleApexContactNoteResponse(responseData) {
        if (!responseData || !responseData.data) {
            throw new Error(
                "Falsy response coming from getCaseContactNotes, responseValue -> " +
                    responseData +
                    "reponseData" +
                    responseData.data
            );
        }
        const contactNotes = responseData.data;
        this.contactNotes = Array.isArray(contactNotes) ? contactNotes : [];
        if(this.contactNotes.length>0){
            this.showClientNotes = true;
        } else {
            this.showClientNotes = false;
        }
    }

    receiveProgress(response) {
        if (!response) return;
        if (
            response.data.payload.Syntilio__Target__c === "ContactNotes" &&
            response.data.payload.Syntilio__TargetUserId__c === this.userId
        ) {
            this.checkRecordType();
            this.isLoading = false;
            if (response.data.payload.Syntilio__Status__c === "Failure") {
                this.notifyUser(
                    "",
                    this.labels.contactNotes_UpdatingContactNotesFailed,
                    this.toastTypes.Error
                );
            }
        }
    }

    connectedCallback() {
        super.connectedCallback();
        this.handleSubscribe();
    }

    async getContactId() {
        try {
            let contact = await getCaseContactId({
                caseId: this.recordId
            });
            const contactData = JSON.parse(contact);
            this.contactId = contactData.ContactId;
            this.getContactNotes();
        } catch (error) {
            this.logException(error, "getContactId");
        }
    }
    async checkRecordType() {
        try {
            this.showClientNotes = false;
            let result = await getSobjectFromId({ sObjectId: this.recordId });
            this.recordType = result;
            if (this.recordType.toLowerCase() === "contact") {
                this.contactId = this.recordId;
            } else {
                this.getContactId();
            }
        } catch (error) {
            this.logException(error, "checkRecordType");
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

