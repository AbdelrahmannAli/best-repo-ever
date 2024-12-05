import { api, track } from "lwc";
import UtilityLWC from "c/utils";
import getContactsGroup from "@salesforce/apex/ContactGroupController.getContactsGroup";
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import contactGroup_ContactWithinSameGroup from "@salesforce/label/c.contactGroup_ContactWithinSameGroup";

export default class ContactGroup extends UtilityLWC {
	constructor() {
		super("contactGroup");
	}

	@api recordIdInput;
	@api recordIdOutput;
	@track contacts;
	@track selectedContactId;

	labels = {
		contactGroup_ContactWithinSameGroup
	};

	async getContactsGroup() {
		try {
			let result = await getContactsGroup({ caseId: this.recordIdInput });
			const parsedResult = JSON.parse(result);
			this.contacts = parsedResult.data;
		} catch (error) {
			this.logException(error, "getContactsGroup");
		}
	}

	handleContactSelection(event) {
		try {
			this.selectedContactId = event.target.dataset.contactId;
			const attributeChangeEventFirstOutput = new FlowAttributeChangeEvent(
				"recordIdOutput",
				this.selectedContactId
			);
			this.dispatchEvent(attributeChangeEventFirstOutput);
		} catch (error) {
			this.logException(error, "handleContactSelection");
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.getContactsGroup();
	}
}
