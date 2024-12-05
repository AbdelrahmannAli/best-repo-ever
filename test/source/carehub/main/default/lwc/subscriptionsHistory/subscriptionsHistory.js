import { api, track } from "lwc";
import listClientsSubscriptionsUtilisation from "@salesforce/apex/SubscriptionUtilisationController.listClientsSubscriptionsUtilisation";
import getContactsOrderItemsMap from "@salesforce/apex/SubscriptionUtilisationController.getContactsOrderItemsMap";
import getSubscriptions from "@salesforce/apex/SubscriptionHandler.getSubscriptions";
import endOrderItem from "@salesforce/apex/SubscriptionHandler.endOrderItem";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import UtilityLWC from "c/utils";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import { loadStyle } from "lightning/platformResourceLoader";
import style from "@salesforce/resourceUrl/staticStyles";
import subscriptionsHistory_EnterClientID from "@salesforce/label/c.subscriptionsHistory_EnterClientID";
import subscriptionsHistory_ClientNumber from "@salesforce/label/c.subscriptionsHistory_ClientNumber";
import subscriptionsHistory_EndSubscription from "@salesforce/label/c.subscriptionsHistory_EndSubscription";
import general_SelectLocations from "@salesforce/label/c.general_SelectLocations";
import general_Status from "@salesforce/label/c.general_Status";
import general_SelectStatus from "@salesforce/label/c.general_SelectStatus";
import general_SubscriptionType from "@salesforce/label/c.general_SubscriptionType";
import general_SelectSubscriptionType from "@salesforce/label/c.general_SelectSubscriptionType";
import general_Close from "@salesforce/label/c.general_Close";
import general_EndDate from "@salesforce/label/c.general_EndDate";
import general_Cancel from "@salesforce/label/c.general_Cancel";
import general_Submit from "@salesforce/label/c.general_Submit";
import general_Subscriptions from "@salesforce/label/c.general_Subscriptions";
import general_Contact from "@salesforce/label/c.general_Contact";
import general_MinutesPerWeek from "@salesforce/label/c.general_MinutesPerWeek";
import general_StartDate from "@salesforce/label/c.general_StartDate";
import general_Subscription from "@salesforce/label/c.general_Subscription";
import general_ChangedOn from "@salesforce/label/c.general_ChangedOn";
import general_ChangedBy from "@salesforce/label/c.general_ChangedBy";
import general_OrderNumber from "@salesforce/label/c.general_OrderNumber";
import general_OrderStatus from "@salesforce/label/c.general_OrderStatus";
import general_OrderActivationDate from "@salesforce/label/c.general_OrderActivationDate";
import general_Action from "@salesforce/label/c.general_Action";
import general_End from "@salesforce/label/c.general_End";
import general_All from "@salesforce/label/c.general_All";
import general_Draft from "@salesforce/label/c.general_Draft";
import general_Activated from "@salesforce/label/c.general_Activated";
import general_CancellationInProgress from "@salesforce/label/c.general_CancellationInProgress";
import general_Cancelled from "@salesforce/label/c.general_Cancelled";
import general_Active from "@salesforce/label/c.general_Active";
import general_Inactive from "@salesforce/label/c.general_Inactive";
import general_SubmissionError from "@salesforce/label/c.general_SubmissionError";

export default class SubscriptionsHistory extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("subscriptionsHistory");
	}

	@api recordId;
	@api getValueFromParent;
	@track isAccount = false;

	labels = {
		subscriptionsHistory_EnterClientID,
		subscriptionsHistory_ClientNumber,
		subscriptionsHistory_EndSubscription,
		general_SelectLocations,
		general_Status,
		general_SelectStatus,
		general_SubscriptionType,
		general_SelectSubscriptionType,
		general_Close,
		general_EndDate,
		general_Cancel,
		general_Submit,
		general_Subscriptions,
		general_Contact,
		general_MinutesPerWeek,
		general_StartDate,
		general_Subscription,
		general_ChangedOn,
		general_ChangedBy,
		general_OrderNumber,
		general_OrderStatus,
		general_OrderActivationDate,
		general_Action,
		general_End,
		general_All,
		general_Draft,
		general_Activated,
		general_CancellationInProgress,
		general_Cancelled,
		general_Active,
		general_Inactive,
		general_SubmissionError
	};

	@track accountColumns = [
		{
			label: this.labels.general_Subscriptions,
			fieldName: "Subscriptions",
			type: "text"
		},
		{
			label: this.labels.general_Status,
			fieldName: "Status",
			type: "text"
		},
		{
			label: this.labels.general_Contact,
			fieldName: "ContactName",
			type: "text"
		},
		{
			label: this.labels.general_MinutesPerWeek,
			fieldName: "minutes",
			type: "text"
		}
	];

	@track contactColumns = [
		{ label: this.labels.general_StartDate, fieldName: "StartDate", type: "date" },
		{
			label: this.labels.general_EndDate,
			fieldName: "EndDate",
			type: "date"
		},
		{
			label: this.labels.general_Subscription,
			fieldName: "Subscription",
			type: "button",
			typeAttributes: {
				label: { fieldName: "Subscription" },
				name: "details"
			},
			cellAttributes: { class: "button-style-no-border" }
		},
		{
			label: this.labels.general_MinutesPerWeek,
			fieldName: "minutes",
			type: "text"
		},
		{
			label: this.labels.general_ChangedOn,
			fieldName: "ChangedOn",
			type: "date"
		},
		{
			label: this.labels.general_ChangedBy,
			fieldName: "ChangedBy",
			type: "text"
		},
		{
			label: this.labels.general_OrderNumber,
			fieldName: "OrderNumber",
			type: "number"
		},
		{
			label: this.labels.general_OrderStatus,
			fieldName: "Status",
			type: "text"
		},
		{
			label: this.labels.general_OrderActivationDate,
			fieldName: "ActivatedDate",
			type: "date"
		},
		{
			label: this.labels.general_Action,
			fieldName: "end",
			type: "button",
			typeAttributes: {
				label: this.labels.general_End,
				name: "end",
				disabled: { fieldName: "EndDisabled" }
			}
		}
	];

	@track subscriptionOptions = [{ label: this.labels.general_All, value: "All" }];
	@track subscriptionTypesLoading = false;

	@track statusOptions = [
		{ label: this.labels.general_All, value: "All" },
		{ label: this.labels.general_Draft, value: "Draft" },
		{ label: this.labels.general_Activated, value: "Activated" },
		{
			label: this.labels.general_CancellationInProgress,
			value: "cancellation in progress"
		},
		{ label: this.labels.general_Cancelled, value: "Cancelled" }
	];

	@track locationOptions = [
		{ label: this.labels.general_All, value: "All" },
		{ label: this.labels.general_Active, value: "Active" },
		{ label: this.labels.general_Inactive, value: "Inactive" }
	];

	@track filteredData;
	@track filters = {
		subscription: "All",
		status: "All",
		location: "All"
	};
	@track accountSubscriptionsData;
	@track contactSubscriptionsData;

	@track endModalOpen = false;
	@track endDate = null;
	@track selectedOrderItem = null;
	@track isComponentVisible = false;

	@api
	async checkCurrentRecordType() {
		try {
			const result = await getSobjectFromId({
				sObjectId: this.getValueFromParent
			});
			let resultLowerCase = result.toLowerCase();
			this.isComponentVisible =
				resultLowerCase === "account" || resultLowerCase === "contact";
			if (resultLowerCase === "account") {
				this.isAccount = true;
				this.getAccountSubscriptions();
			} else if (resultLowerCase === "contact") {
				this.isAccount = false;
				this.getContactSubscriptions();
			}
		} catch (error) {
			this.logException(error, "checkCurrentRecordType");
		}
	}

	handleModalOpen() {
		this.endModalOpen = true;
	}

	handleModalClose() {
		this.endModalOpen = false;
	}

	handleEndDateChange(event) {
		this.endDate = event.target.value;
	}

	async handleSubmit() {
		try {
			let value = await endOrderItem({
				orderItemId: this.selectedOrderItem,
				endDate: this.endDate
			});
			let parsedValue = JSON.parse(value);
			if (!parsedValue.isSuccess) {
				let errorSplit = parsedValue.message.split(",");
				const event = new ShowToastEvent({
					title: this.labels.general_SubmissionError,
					message: errorSplit[errorSplit.length - 1].split(":")[0],
					variant: "error"
				});
				this.dispatchEvent(event);
			} else {
				this.handleModalClose();
				this.checkCurrentRecordType();
			}
		} catch (error) {
			this.logException(error, "handleSubmit");
			this.notifyUser(
				this.labels.general_SubmissionError,
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
		}
	}

	handleSubscriptionRowAction(event) {
		try {
			if (event.detail.action.name === "end") {
				this.handleModalOpen();
				this.selectedOrderItem = event.detail.row.Id;
			} else if (event.detail.action.name === "details") {
				this[NavigationMixin.Navigate]({
					type: "standard__recordPage",
					attributes: {
						recordId: event.detail.row.Id,
						objectApiName: "OrderItem",
						actionName: "view"
					}
				});
			}
		} catch (error) {
			this.logException(error, "handleSubscriptionRowAction");
		}
	}

	mapupdateContactSubscriptionsData(data) {
		try {
			const values = Object.values(data);
			let resultList = [];
			values[0].forEach((record) => {
				let result = {};
				result.Id = record.Id;
				result.StartDate = record.ServiceDate;
				result.EndDate = record.EndDate;
				result.Subscription = record.Product2.Name;
				result.ChangedOn = record.LastModifiedDate;
				result.ChangedBy = record.Product2.LastModifiedBy.Name;
				result.Status = record.Order.Status;
				result.OrderNumber = record.Order.OrderNumber;
				result.ActivatedDate = record.Order.ActivatedDate;
				result.minutes = record.Product2.Syntilio__Minutes__c ?? "";
				result.EndDisabled =
					["Cancelled", "Ended", "Draft"].includes(record.Order.Status) ||
					(record.EndDate && new Date(record.EndDate) < new Date());
				resultList.push(result);
			});
			return resultList;
		} catch (error) {
			this.logException(error, "mapupdateContactSubscriptionsData");
			return {};
		}
	}

	mapupdateAccountSubscriptionsData(data) {
		try {
			let resultList = [];
			data.forEach((record) => {
				let contact = record.contact;
				let orderItems = record.orderItems;
				orderItems.forEach((orderItem) => {
					let result = {};
					result.ContactName = contact.Name;
					result.Status = orderItem.Order.Status;
					result.Subscriptions = orderItem.Product2.Name;
					result.minutes = orderItem.Product2.Syntilio__Minutes__c ?? "";

					resultList.push(result);
				});
			});
			return resultList;
		} catch (error) {
			this.logException(error, "mapupdateAccountSubscriptionsData");
			return {};
		}
	}

	handleFilter(event) {
		try {
			this.filters[event.target.name] = event.target.value;
			let allRecords = this.accountSubscriptionsData;
			if (this.filters.subscription !== "All") {
				let subscriptionLowerCase = this.filters.subscription.toLowerCase();
				allRecords = allRecords.filter(
					(record) => record.Subscriptions.toLowerCase() === subscriptionLowerCase
				);
			}
			if (this.filters.status !== "All") {
				let statusLowerCase = this.filters.status.toLowerCase();
				allRecords = allRecords.filter(
					(record) => record.Status.toLowerCase() === statusLowerCase
				);
			}
			if (this.filters.location !== "All") {
				let locationLowerCase = this.filters.location.toLowerCase();
				allRecords = allRecords.filter(
					(record) => record.Location.toLowerCase() === locationLowerCase
				);
			}
			this.filteredData = allRecords;
		} catch (error) {
			this.logException(error, "handleFilter");
		}
	}

	async getAccountSubscriptions() {
		try {
			let result = await listClientsSubscriptionsUtilisation({
				accountId: this.getValueFromParent
			});
			this.accountSubscriptionsData = this.mapupdateAccountSubscriptionsData(result);
			this.filteredData = this.accountSubscriptionsData;
		} catch (error) {
			this.logException(error, "getAccountSubscriptions");
		}
	}

	async getContactSubscriptions() {
		try {
			let result = await getContactsOrderItemsMap({
				accountId: null,
				contactId: this.getValueFromParent
			});
			this.contactSubscriptionsData = this.mapupdateContactSubscriptionsData(result);
		} catch (error) {
			this.logException(error, "getContactSubscriptions");
		}
	}

	async getSubscriptionTypes() {
		try {
			this.subscriptionTypesLoading = true;
			let result = await getSubscriptions({ subscriptionType: "all" });
			this.subscriptionTypesLoading = false;
			const parsedData = JSON.parse(result);

			if (parsedData.isSuccess) {
				parsedData.data.forEach((record) => {
					this.subscriptionOptions.push({
						label: record.Name,
						value: record.Name
					});
				});
			}
		} catch (error) {
			this.logException(error, "getSubscriptionTypes");
		}
	}

	async connectedCallback() {
		try {
			super.connectedCallback();
			await this.checkCurrentRecordType();
			if (this.isComponentVisible) {
				await loadStyle(this, style);
				this.getSubscriptionTypes();
			}
		} catch (error) {
			this.logException(error, "connectedCallback");
		}
	}
}
