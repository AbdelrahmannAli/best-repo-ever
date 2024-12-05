import { track, api, wire } from "lwc";
import UtilityLWC from "c/utils";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import CASE_OBJECT from "@salesforce/schema/Case";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import setCaseStatus from "@salesforce/apex/ClientCasesController.setCaseStatus";
import getCaseStatus from "@salesforce/apex/ClientCasesController.getCaseStatus";
import { getRecord } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import ProfileName from "@salesforce/schema/User.Profile.Name";
import caseProgressIndicator_NotCaseOwner from "@salesforce/label/c.caseProgressIndicator_NotCaseOwner";
import caseProgressIndicator_CaseAutomaticallyClosed from "@salesforce/label/c.caseProgressIndicator_CaseAutomaticallyClosed";
import caseProgressIndicator_AssignCase from "@salesforce/label/c.caseProgressIndicator_AssignCase";
import caseProgressIndicator_ConfirmClose from "@salesforce/label/c.caseProgressIndicator_ConfirmClose";
import { subscribe } from 'lightning/empApi';

export default class ProgressIndicatorComponent extends UtilityLWC {
	constructor() {
		super("caseProgressIndicator");
	}
	@api recordId;
	@track currentStep;
	@track statusOptions = [];
	@track showProgressBar = false;
	@track showProgressBarr = false;
	@track isModalOpen = false;
	userId = Id;
	userProfileName;
	subscription = {};
	channelName = '/event/Syntilio__Notification__e';

	labels = {
		caseProgressIndicator_NotCaseOwner,
		caseProgressIndicator_AssignCase,
		caseProgressIndicator_ConfirmClose
	};

	@wire(getRecord, { recordId: "$recordId", fields: ["Case.ContactId"] })

	connectedCallback() {
		this.getCaseStatus();
		this.subscribeToPlatformEvent();
	}

	@wire(getObjectInfo, { objectApiName: CASE_OBJECT })
	caseMetadata;

	@wire(getPicklistValues, {
		recordTypeId: "$caseMetadata.data.defaultRecordTypeId",
		fieldApiName: STATUS_FIELD
	})
	wiredPicklistValues({ error, data }) {
		if (data) {
			let options = data.values.filter(
				(item) => item.value !== "AutoClosed" && item.value !== "ClosedByDevice"
			);
			this.statusOptions = options;
		} else if (error) {
			this.notifyUser(
				"Error loading picklist values",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "wiredPicklistValues");
		}
	}

	async getCaseStatus() {
		try {
			const data = await getCaseStatus({ caseId: this.recordId });
			if (data) {
				if (data.status === "ClosedByDevice") {
					this.statusOptions = this.statusOptions.map((option) => {
						if (option.value === "Closed") {
							return {
								...option,
								label: "Closed By Device",
								value: "ClosedByDevice"
							};
						}
						return option;
					});
				}
				if (data.status === "AutoClosed") {
					this.statusOptions = this.statusOptions.map((option) => {
						if (option.value === "Closed") {
							return {
								...option,
								label: "Auto Closed",
								value: "AutoClosed"
							};
						}
						return option;
					});
				}
				this.currentStep = data.status;
				this.showProgressBar = true;
				return data;
			} else if (error) {
				this.notifyUser(
					"Error getting case Status.",
					error.body ? error.body.message : error.message,
					this.toastTypes.Error
				);
				this.logException(error, "getCaseStatus");
			}
		} catch (error) {
			this.logException(error, "getCaseStatus");
		}
	}

	async subscribeToPlatformEvent() {
        try {
            this.subscription = await subscribe(this.channelName, -1, (event) => {
                const message = event.data.payload.Syntilio__Message__c;
				if(message === 'Canceled'){
					this.refreshStatus();
				}
                if (message === 'Confirmed') {
                    this.refreshStatus();
                }
            });
        } catch (error) {
            this.notifyUser('Error', 'Failed to subscribe to platform events.', this.toastTypes.Error);
        }
    }

    async refreshStatus() {
        try {
			await new Promise(resolve => setTimeout(resolve, 1000));
            const caseData = this.getCaseStatus();
			this.currentStep = caseData.status;
			this.showProgressBar = true;
            this.notifyUser(
				"Success",
				"Record updated successfully",
				this.toastTypes.Success
			);
        } catch (error) {
            this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "updateCaseStatus");
        }
    }

	async handleStepClick(event) {
		try {
			const stepValue = event.target.value;
			const caseDetails = await getCaseStatus({ caseId: this.recordId });
			const caseOwner = caseDetails.owner;
			const caseStatus = caseDetails.status;
			const caseEvent = caseDetails.event;
			const caseClosureProfiles = caseDetails.customMetadata;
			const enableNonOwnerClosing = caseDetails.enableNonOwnerClosing;
			const enableEventClosing = caseDetails.enableEventClosing;
			let profileInRoles = false;
			if (caseClosureProfiles) {
				const rolesCloseCases = caseClosureProfiles.split(",");
				const filtered = rolesCloseCases.filter((value) =>
					value.trim().includes(this.userProfileName)
				);
				if (filtered.length > 0) {
					profileInRoles = true;
				}
				if (
					stepValue === "Closed" &&
					this.userId !== caseOwner &&
					profileInRoles === false
				) {
					this.notifyUser(
						"Error",
						caseProgressIndicator_NotCaseOwner,
						this.toastTypes.Error
					);
					return;
				}
			}
			if (caseStatus === "ClosedByDevice" || caseStatus === "AutoClosed") {
				this.notifyUser(
					"Error",
					caseProgressIndicator_CaseAutomaticallyClosed,
					this.toastTypes.Error
				);
				return;
			}
			this.updateCaseStatus(stepValue, caseOwner, caseEvent, enableNonOwnerClosing, enableEventClosing);
		} catch (error) {
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "handleStepClick");
		}
	}

	@wire(getRecord, { recordId: Id, fields: [ProfileName] })
	userDetails({ error, data }) {
		if (error) {
			this.error = error;
		} else if (data) {
			if (data.fields.Profile.value != null) {
				this.userProfileName = data.fields.Profile.value.fields.Name.value;
			}
		}
	}

	async updateCaseStatus(newStatus, caseOwner, caseEvent, enableNonOwnerClosing, enableEventClosing) {
		try {
			let result = await setCaseStatus({ caseId: this.recordId, status: newStatus });
			if ((enableNonOwnerClosing === 'true' || enableEventClosing === 'true') 
				&& newStatus === "Closed" && 
				(this.userId !== caseOwner || caseEvent==null)) {
					return;
			}
			this.currentStep = result;
			this.notifyUser(
				"Success",
				"Record updated successfully",
				this.toastTypes.Success
			);
		} catch (error) {
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "updateCaseStatus");
		}
	}
}
