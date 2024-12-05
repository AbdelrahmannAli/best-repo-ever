import { api, track } from "lwc";
import getClientCases from "@salesforce/apex/ClientCasesController.getClientCases";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import { NavigationMixin } from "lightning/navigation";
import UtilityLWC from "c/utils";
import general_ContactCases from "@salesforce/label/c.general_ContactCases";
import general_CaseNumber from "@salesforce/label/c.general_CaseNumber";
import general_Subject from "@salesforce/label/c.general_Subject";
import general_EventCode from "@salesforce/label/c.general_EventCode";
import general_Category from "@salesforce/label/c.general_Category";
import general_SessionsDuration from "@salesforce/label/c.general_SessionsDuration";
import general_CreatedBy from "@salesforce/label/c.general_CreatedBy";
import general_Action from "@salesforce/label/c.general_Action";
import general_Details from "@salesforce/label/c.general_Details";
export default class ContactCases extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("clientCases");
	}

	@api recordId;

	labels = {
		general_ContactCases,
		general_CaseNumber,
		general_Subject,
		general_EventCode,
		general_Category,
		general_SessionsDuration,
		general_CreatedBy,
		general_Action,
		general_Details
	};

	@track clientCases;
	@track isLoading;
	@track columns = [
		{ label: this.labels.general_CaseNumber, fieldName: "caseNumber", type: "text" },
		{ label: this.labels.general_Subject, fieldName: "subject", type: "text" },
		{ label: this.labels.general_EventCode, fieldName: "eventCode", type: "text" },
		{ label: this.labels.general_Category, fieldName: "category", type: "text" },
		{
			label: this.labels.general_SessionsDuration,
			fieldName: "duration",
			type: "text"
		},
		{
			label: this.labels.general_CreatedBy,
			fieldName: "createdBy",
			type: "text",
			wrapText: true
		},
		{
			label: this.labels.general_Action,
			type: "button",
			typeAttributes: { label: this.labels.general_Details, name: "view_details" }
		}
	];
	@track isContact = true;

	async fetchClientCases() {
		try {
			if (!this.isContact) {
				return;
			}
			this.isLoading = true;
			let result = await getClientCases({ clientId: this.recordId });
			this.isLoading = false;
			const parsedData = JSON.parse(result);
			this.clientCases = parsedData.data;
		} catch (error) {
			this.logException(error, "fetchClientCases");
			this.isLoading = false;
			this.notifyUser(
				"Error",
				error?.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
		}
	}

	handleRowAction(event) {
		try {
			const actionName = event.detail.action.name;
			const row = event.detail.row;

			if (actionName === "view_details") {
				this[NavigationMixin.Navigate]({
					type: "standard__recordPage",
					attributes: {
						recordId: row.caseId,
						objectApiName: "Case",
						actionName: "view"
					}
				});
			}
		} catch (error) {
			this.logException(error, "handleRowAction");
		}
	}

	async checkRecordType() {
		try {
			let result = await getSobjectFromId({ sObjectId: this.recordId });
			const recordType = result;
			if (recordType.toLowerCase() === "contact") {
				this.isContact = true;
				this.fetchClientCases();
			}
		} catch (error) {
			this.logException(error, "checkRecordType");
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.checkRecordType();
	}
}
