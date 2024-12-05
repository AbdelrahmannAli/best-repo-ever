import { NavigationMixin } from "lightning/navigation";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import getCaseEmergencyContacts from "@salesforce/apex/ContactContactRelationshipHandler.getCaseEmergencyContacts";
import UtilityLWC from "c/utils";
import { api, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import style from "@salesforce/resourceUrl/staticStyles";
import general_New from "@salesforce/label/c.general_New";
import general_Close from "@salesforce/label/c.general_Close";
import general_Name from "@salesforce/label/c.general_Name";
import general_Contact from "@salesforce/label/c.general_Contact";
import general_RelatedContact from "@salesforce/label/c.general_RelatedContact";
import general_Phone from "@salesforce/label/c.general_Phone";
import general_Relationship from "@salesforce/label/c.general_Relationship";
import general_Order from "@salesforce/label/c.general_Order";
import caseEmergencyContacts_EmergencyContacts from "@salesforce/label/c.caseEmergencyContacts_EmergencyContacts";
import caseEmergencyContacts_NewEmergencyContact from "@salesforce/label/c.caseEmergencyContacts_NewEmergencyContact";

export default class CaseEmergencyContacts extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("caseEmergencyContacts");
	}
	@api recordId;
	@track isComponentVisible;
	@track emergencyContacts;
	@track isNewModalOpen = false;

	labels = {
		general_New,
		general_Close,
		general_Name,
		general_Contact,
		general_RelatedContact,
		general_Phone,
		general_Relationship,
		general_Order,
		caseEmergencyContacts_EmergencyContacts,
		caseEmergencyContacts_NewEmergencyContact
	};

	@track emergencyContactsColumns = [
		{
			label: this.labels.general_Name,
			fieldName: "Name",
			type: "button",
			typeAttributes: {
				label: { fieldName: "Name" },
				name: "emergency-contact-details"
			},
			cellAttributes: { class: "button-style-no-border" }
		},
		{
			label: this.labels.general_Contact,
			fieldName: "ContactName",
			type: "button",
			typeAttributes: {
				label: { fieldName: "ContactName" },
				name: "contact-details"
			},
			cellAttributes: { class: "button-style-no-border" }
		},
		{
			label: this.labels.general_RelatedContact,
			fieldName: "RelatedContactName",
			type: "button",
			typeAttributes: {
				label: { fieldName: "RelatedContactName" },
				name: "related-contact-details"
			},
			cellAttributes: { class: "button-style-no-border" }
		},
		{
			label: this.labels.general_Phone,
			fieldName: "RelatedContactPhone",
			type: "customTypePhone"
		},
		{
			label: this.labels.general_Relationship,
			fieldName: "Relationship",
			type: "text"
		},
		{
			label: this.labels.general_Order,
			fieldName: "Order",
			type: "text"
		}
	];

	async checkCurrentRecordType() {
		try {
			const result = await getSobjectFromId({
				sObjectId: this.recordId
			});
			let resultLowerCase = result.toLowerCase();
			this.isComponentVisible = resultLowerCase === "case";
		} catch (error) {
			this.logException(error, "checkCurrentRecordType");
		}
	}

	async getEmergencyContactsWrapper() {
		try {
			let result = await getCaseEmergencyContacts({ caseId: this.recordId });
			this.emergencyContacts = this.prepareEmergencyContactsData(result);
		} catch (error) {
			this.notifyUser(
				"Submission Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "getEmergencyContactsWrapper");
		}
	}

	prepareEmergencyContactsData(result) {
		return result.map((emergencyContact) => {
			return {
				Id: emergencyContact.Id,
				Name: emergencyContact.Name,
				ContactId: emergencyContact.Syntilio__ContactId__r.Id,
				ContactName: emergencyContact.Syntilio__ContactId__r.Name,
				RelatedContactId: emergencyContact.Syntilio__RelatedContactId__r.Id,
				RelatedContactName: emergencyContact.Syntilio__RelatedContactId__r.Name,
				RelatedContactPhone: emergencyContact.Syntilio__RelatedContactId__r.Phone,
				Relationship: emergencyContact.Syntilio__Relationship__c,
				Order: emergencyContact.Syntilio__Order__c
			};
		});
	}

	handleRowAction(event) {
		let actionName = event.detail.action.name;
		let row = event.detail.row;
		if (!actionName.includes("details")) {
			return;
		}
		let recordId =
			actionName === "emergency-contact-details"
				? row.Id
				: actionName === "contact-details"
				? row.ContactId
				: row.RelatedContactId;
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: recordId,
				objectApiName:
					actionName === "emergency-contact-details"
						? "Syntilio__ContactContactRelationship__c"
						: "Contact",
				actionName: "view"
			}
		});
	}

	toggleIsNewModalOpen() {
		this.isNewModalOpen = !this.isNewModalOpen;
	}

	handleSuccess() {
		this.isNewModalOpen = false;
		this.getEmergencyContactsWrapper();
	}

	async connectedCallback() {
		await this.checkCurrentRecordType();
		if (this.isComponentVisible) {
			loadStyle(this, style);
			this.getEmergencyContactsWrapper();
		}
	}
}
