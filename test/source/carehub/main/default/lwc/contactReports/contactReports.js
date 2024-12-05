import getContactReport from "@salesforce/apex/CareHubUtilities.getContactReport";
import { api, track, wire } from "lwc";
import UtilityLWC from "c/utils";
import { subscribe } from "lightning/empApi";
import { NavigationMixin } from "lightning/navigation";
import getUserId from "@salesforce/apex/CareHubUtilities.getUserId";
import { getRecord } from "lightning/uiRecordApi";
import contactReports_UpdatingContactReportsFailed from "@salesforce/label/c.contactReports_UpdatingContactReportsFailed";
import contactReports_ReportsMayBeOutdated from "@salesforce/label/c.contactReports_ReportsMayBeOutdated";
import contactReports_searchForContactReport from "@salesforce/label/c.contactReports_searchForContactReport";
import manualSyncReports from "@salesforce/apex/ReportHandler.manualSyncReports";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import getCaseContactId from "@salesforce/apex/ClientCasesController.getCaseContactId";
export default class ContactReports extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("contactReports");
	}

	@api recordId;
	@track contactReports = [];
	@track libInitialized = false;
	@track channelName = "/event/Syntilio__Notification__e";
	@track userId;
	@track subscribed = false;
	@track contactId;
	@track manualSync = false;
	@track searchTerm = "";
	@track filteredContactReports = [];
	@track showFilteredReports = false;

	labels = {
		contactReports_UpdatingContactReportsFailed,
		contactReports_ReportsMayBeOutdated,
		contactReports_searchForContactReport
	};

	@track isLoading = false;

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

	handleAccountClick(event) {
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: event.target.dataset.id,
				objectApiName: "Account",
				actionName: "view"
			}
		});
	}

	handleExternalSystemClick(event) {
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: event.target.dataset.id,
				objectApiName: "Syntilio__ExternalSystem__c",
				actionName: "view"
			}
		});
	}

	handleButtonClick() {
		this.manualSync = true;
		if (this.recordType.toLowerCase() === "contact") {
			this.syncContactReports();
		} else {
			this.syncContactReports();
		}
	}
	async syncContactReports() {
		try {
			this.isLoading = true;
			if(!this.contactId){
				this.isLoading = false;
				return;
			}
			await manualSyncReports({
				clientId: this.contactId
			});
		} catch (error) {
			this.logException(error, "syncContactReports");
			this.isLoading = false;
			this.notifyUser("", "Failed to sync contact client notes", this.toastTypes.Error);
		}
	}

	async getClientReports() {
		try {
			let serializedResponseData = await getContactReport({
				caseId: this.recordId
			});
			const responseData = JSON.parse(serializedResponseData);
			this.handleApexReportResponse(responseData);
		} catch (error) {
			this.logException(error, "getClientReports");
		}
	}

	handleApexReportResponse(responseData) {
		if (!responseData || !responseData.data) {
			throw new Error(
				"Falsy response coming from getContactReport, responseValue -> " +
					responseData +
					"reponseData" +
					responseData.data
			);
		}
		const reports = responseData.data;
		reports.sort((a, b) => {
			let dateA = new Date(a.Syntilio__ExternalUpdatedAt__c);
			let dateB = new Date(b.Syntilio__ExternalUpdatedAt__c);
			return dateB - dateA;
		});
		this.contactReports = Array.isArray(reports)
			? reports.map((report) => {
					if (report.Syntilio__AuthorRole__c) {
						let roleSplit = report.Syntilio__AuthorRole__c.split(/,/g);
						report.firstRole = roleSplit[0];
						report.hasMore = roleSplit.length > 1;
						report.Syntilio__AuthorRole__c = report.Syntilio__AuthorRole__c.replace(
							/,/g,
							" |"
						);
					}
					if (report.Syntilio__Comments__c?.includes("  : ")) {
						let colonIndex = report.Syntilio__Comments__c.indexOf(":");
						if (!report.Syntilio__Author__c || report.Syntilio__Author__c.length === 0) {
							report.Syntilio__Author__c = report.Syntilio__Comments__c.substring(
								0,
								colonIndex
							);
						}
						report.Syntilio__Comments__c = report.Syntilio__Comments__c.substring(
							colonIndex + 1
						).trimStart();
					}
					if (!report.Syntilio__Author__c || report.Syntilio__Author__c.length === 0) {
						report.Syntilio__Author__c = report.CreatedByName;
					}
					if (report.Syntilio__ExternalUpdatedAt__c) {
						report.Syntilio__ExternalUpdatedAt__c = new Date(
							report.Syntilio__ExternalUpdatedAt__c
						)
							.toLocaleString("en-GB", {
								year: "numeric",
								month: "2-digit",
								day: "2-digit",
								hour: "2-digit",
								minute: "2-digit"
							})
							.replace(/\//g, "-");
					}
					return report;
			  })
			: [];
	}

	receiveProgress(response) {
		if (!response) return;
		if (
			response.data.payload.Syntilio__Target__c === "ReportHandler" &&
			response.data.payload.Syntilio__TargetUserId__c === this.userId
		) {
			this.checkRecordType();
			if (response.data.payload.Syntilio__Status__c === "Failure") {
				this.notifyUser(
					"",
					this.labels.contactReports_UpdatingContactReportsFailed,
					this.toastTypes.Error
				);
			}if (response.data.payload.Syntilio__Status__c === 'NewReportCreated') {
				this.getClientReports();
			}
			this.isLoading = false;
		}
	}

	async checkRecordType() {
		try {
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
	async getContactId() {
		try {
			let contact = await getCaseContactId({
				caseId: this.recordId
			});
			const contactData = JSON.parse(contact);
			this.contactId = contactData.ContactId;
			if(this.contactId){
				this.getClientReports();
			}
		} catch (error) {
			this.logException(error, "getContactId");
		}
	}

	renderedCallback() {
		if (!this.subscribed) {
			this.handleSubscribe();
		}
	}

	async handleSubscribe() {
		try {
			await subscribe(this.channelName, -1, (response) =>
				this.receiveProgress(response)
			);
			this.subscribed = true;
			let userId = await getUserId();
			this.userId = userId;
		} catch (error) {
			this.logException(error, "handleSubscribe");
		}
	}

	handleSearch(event) {
		try {
			this.searchTerm = event.target.value.trim().toLowerCase();
			const searchPhrase = this.searchTerm;
			this.filteredContactReports =
				this.searchTerm !== ""
					? this.contactReports.filter((report) => {
							return (
								(report.Syntilio__Comments__c &&
									report.Syntilio__Comments__c.toLowerCase().includes(searchPhrase)) ||
								(report.Syntilio__ExternalUpdatedAt__c &&
									report.Syntilio__ExternalUpdatedAt__c.toLowerCase().includes(
										searchPhrase
									)) ||
								(report.Syntilio__Author__c &&
									report.Syntilio__Author__c.toLowerCase().includes(searchPhrase)) ||
								(report.Syntilio__AuthorRole__c &&
									report.Syntilio__AuthorRole__c.toLowerCase().includes(searchPhrase))
							);
					  })
					: [];

			this.filteredContactReports = this.filteredContactReports.map((report) => {
				const highlightedReport = { ...report };

				if (searchPhrase) {
					if (highlightedReport.Syntilio__Comments__c) {
						highlightedReport.Syntilio__Comments__c = this.highlightText(
							highlightedReport.Syntilio__Comments__c,
							searchPhrase
						);
					}
					if (highlightedReport.Syntilio__ExternalUpdatedAt__c) {
						highlightedReport.Syntilio__ExternalUpdatedAt__c = this.highlightText(
							highlightedReport.Syntilio__ExternalUpdatedAt__c,
							searchPhrase
						);
					}

					if (highlightedReport.Syntilio__Author__c) {
						highlightedReport.Syntilio__Author__c = this.highlightText(
							highlightedReport.Syntilio__Author__c,
							searchPhrase
						);
					}
					if (highlightedReport.Syntilio__AuthorRole__c) {
						highlightedReport.Syntilio__AuthorRole__c = this.highlightText(
							highlightedReport.Syntilio__AuthorRole__c,
							searchPhrase
						);
					}
				}

				return highlightedReport;
			});

			this.showFilteredReports = this.searchTerm.length !== 0;
		} catch (error) {
			this.logException(error, "handleSearch");
		}
	}

	highlightText(text, phrase) {
		if (!text) return text;

		const regex = new RegExp(`(${phrase})`, "gi");
		return text.replace(
			regex,
			(match) =>
				`<span style='background-color: yellow; font-weight: bold;'>${match}</span>`
		);
	}

	get displayedReports() {
		return this.showFilteredReports ? this.filteredContactReports : this.contactReports;
	}
}
