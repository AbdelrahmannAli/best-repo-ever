import { api, track, wire } from "lwc";
import UtilityLWC from "c/utils";
import getCaseContactId from "@salesforce/apex/ClientCasesController.getCaseContactId";
import { getRecord } from "lightning/uiRecordApi";

export default class ClientInfo extends UtilityLWC {
	constructor() {
		super("clientInfo");
	}

	@api recordId;
	@track contactId;
	@track caseContactId;

	@wire(getRecord, { recordId: "$recordId", fields: ["Case.ContactId"] })
	recordUpdated({ data }) {
		if (!this.recordId || !data) {
			return;
		}
		if (data.apiName !== "Case") {
			this.getContactId();
			return;
		}
		let contactId = data.fields.ContactId;
		if (this.contactId !== contactId) {
			this.getContactId();
		}
	}

	async getContactId() {
		try {
			let contact = await getCaseContactId({
				caseId: this.recordId
			});
			const contactInfo = JSON.parse(contact);
			this.contactId = contactInfo.ContactId;
		} catch (error) {
			this.logException(error, "getContactId");
		}
	}
}
