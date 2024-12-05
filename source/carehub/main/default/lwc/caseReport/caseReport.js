import { api, track, wire } from "lwc";
import UtilityLWC from "c/utils";
import sendCaseReport from "@salesforce/apex/SendCaseReportHandler.sendCaseReport";
import getExpertiseGroup from "@salesforce/apex/ReportHandler.getExpertiseGroup";
import getExpertiseProfiles from "@salesforce/apex/ReportHandler.getExpertiseProfiles";
import getCaseContactExternalSystem from "@salesforce/apex/ClientCasesController.getCaseContactExternalSystem";
import { getRecord } from "lightning/uiRecordApi";
import general_New from "@salesforce/label/c.general_New";
import general_History from "@salesforce/label/c.general_History";
import general_Send from "@salesforce/label/c.general_Send";
import caseReport_ActionFor from "@salesforce/label/c.caseReport_ActionFor";
import caseReport_VisibilityFor from "@salesforce/label/c.caseReport_VisibilityFor";
import caseReport_ActionForPlaceholder from "@salesforce/label/c.caseReport_ActionForPlaceholder";
import caseReport_VisibilityForPlaceholder from "@salesforce/label/c.caseReport_VisibilityForPlaceholder";
import general_Optional from "@salesforce/label/c.general_Optional";

export default class CaseReport extends UtilityLWC {
	constructor() {
		super("caseReport");
	}
	@api recordId;
	@track isLoading = false;
	@track newTab = {};
	@track historyTab = {};
	@track activeTab = {
		aria_selected: "true",
		tabindex: "0",
		class: "slds-tabs_default__item slds-is-active",
		content_class: "slds-tabs_default__content slds-show"
	};
	@track staleTab = {
		aria_selected: "false",
		tabindex: "-1",
		class: "slds-tabs_default__item",
		content_class: "slds-tabs_default__content slds-hide"
	};
	@track externalSystem = "";
	@track contactId;
	@track expertise = [];
	@track expertiseGroups = [];
	@track expertiseProfiles = [];
	@track actionValue = "";
	@track visibilityValue = "";
	@track actionFor;
	@track visibilityFor;
	@track favIconName = "utility:favorite_alt";
	@track flagged = false;

	labels = {
		general_New,
		general_History,
		general_Send,
		general_Optional,
		caseReport_ActionFor,
		caseReport_VisibilityFor,
		caseReport_ActionForPlaceholder,
		caseReport_VisibilityForPlaceholder
	};

	@wire(getRecord, {
		recordId: "$recordId",
		fields: ["Case.ContactId", "Case.AccountId"]
	})
	recordUpdated({ data }) {
		if (!this.recordId || !data) {
			return;
		}
		if (data.apiName !== "Case") {
			this.getExternalSystem();
			return;
		}
		let contactId = data.fields.ContactId.value;
		let accountId = data.fields.AccountId.value;
		if (this.contactId !== contactId) {
			this.contactId = contactId;
			this.getExternalSystem().then(() => {
				this.GetExpertise(accountId);
			});
		}
	}

	handleTabSwitch(event) {
		if (event.target.dataset.name === "New") {
			this.newTab = this.activeTab;
			this.historyTab = this.staleTab;
		} else if (event.target.dataset.name === "History") {
			this.newTab = this.staleTab;
			this.historyTab = this.activeTab;
		}
	}

	handleActionChange(event) {
		this.actionFor = [];
		const expertiseGroupsString = JSON.stringify(this.expertiseGroups);
		const expertiseProfilesString = JSON.stringify(this.expertiseProfiles);
		event.detail.forEach((element) => {
			let actionForObject;
			if (expertiseGroupsString.includes(`"value":${element}`)) {
				actionForObject = { expertiseGroupObjectId: element };
			} else if (expertiseProfilesString.includes(`"value":${element}`)) {
				actionForObject = { expertiseProfileId: element };
			}
			this.actionFor.push(actionForObject);
		});
		this.actionFor = JSON.stringify(this.actionFor);
	}

	handleVisibilityChange(event) {
		this.visibilityFor = [];
		const expertiseGroupsString = JSON.stringify(this.expertiseGroups);
		const expertiseProfilesString = JSON.stringify(this.expertiseProfiles);
		event.detail.forEach((element) => {
			let visibilityForObject;
			if (expertiseGroupsString.includes(`"value":${element}`)) {
				visibilityForObject = { expertiseGroupObjectId: element };
			} else if (expertiseProfilesString.includes(`"value":${element}`)) {
				visibilityForObject = { expertiseProfileId: element };
			}
			this.visibilityFor.push(visibilityForObject);
		});
		this.visibilityFor = JSON.stringify(this.visibilityFor);
	}

	handleFav() {
		if (this.favIconName == "utility:favorite_alt") {
			this.favIconName = "utility:favorite";
		} else {
			this.favIconName = "utility:favorite_alt";
		}
		this.flagged = !this.flagged;
	}

	async handleSend() {
		try {
			let comments = this.template.querySelector("lightning-textarea").value;
			if (!comments) {
				return;
			}
			let report = {
				Syntilio__CaseId__c: this.recordId,
				Syntilio__Comments__c: comments,
				Syntilio__Flagged__c: this.flagged,
				Syntilio__ActionFor__c: this.actionFor,
				Syntilio__VisibilityFor__c: this.visibilityFor
			};
			this.isLoading = true;
			await sendCaseReport({ report: report });

			this.template.querySelector("lightning-textarea").value = "";
			const actionCombobox = this.template.querySelectorAll('c-multi-select-combobox');
			actionCombobox.forEach(combobox => {
				combobox.clearSelectedOptions();
			});
			this.favIconName = "utility:favorite_alt";
			this.flagged = false;
	
			this.notifyUser(
				"",
				"Thank you, the report has been successfully sent to " + this.externalSystem,
				this.toastTypes.Success
			);
			this.isLoading = false;
		} catch (error) {
			this.notifyUser("", "Failed to send case report", this.toastTypes.Error);
			this.logException(error, "handleSend");
		}
	}
	

	async getExternalSystem() {
		try {
			let result = await getCaseContactExternalSystem({
				caseId: this.recordId
			});
			this.externalSystem = result;
		} catch (error) {
			this.logException(error, "getExternalSystem");
		}
	}

	async GetExpertise(accountId) {
		this.isLoading = true;
		if(!accountId){
			this.isLoading = false;
			return;	
		}
		await this.getExpertiseGroups(accountId);
		await this.getExpertiseProfiles(accountId);
		this.expertise = this.expertiseGroups.concat(this.expertiseProfiles);
		this.isLoading = false;
	}

	async getExpertiseGroups(accountId) {
		try {
			let result = await getExpertiseGroup({
				accountId: accountId,
				externalSystem: this.externalSystem
			});
			let opts = result.map((opt) => ({
				value: opt.id,
				label: opt.name,
				selected: false
			}));
			this.expertiseGroups = opts;
		} catch (error) {
			this.logException(error, "getExpertiseGroups");
		}
	}

	async getExpertiseProfiles(accountId) {
		try {
			let result = await getExpertiseProfiles({
				accountId: accountId,
				externalSystem: this.externalSystem
			});
			let opts = result.map((opt) => ({
				value: opt.id,
				label: opt.name,
				selected: false
			}));
			this.expertiseProfiles = opts;
		} catch (error) {
			this.logException(error, "getExpertiseProfiles");
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.newTab = this.activeTab;
		this.historyTab = this.staleTab;
	}
}
