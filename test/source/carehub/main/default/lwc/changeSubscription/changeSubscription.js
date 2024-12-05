import { api, track, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import ChangeSubscriptionUtility from "./changeSubscriptionUtility";
import UtilityLWC from "c/utils";
import changeSubscription_OrderInfo from "@salesforce/label/c.changeSubscription_OrderInfo";
import changeSubscription_SelectProducts from "@salesforce/label/c.changeSubscription_SelectProducts";
import changeSubscription_EditOrderProducts from "@salesforce/label/c.changeSubscription_EditOrderProducts";
import changeSubscription_OrderWillEndOnSpecifiedDate from "@salesforce/label/c.changeSubscription_OrderWillEndOnSpecifiedDate";
import changeSubscription_OrderWillEndOn from "@salesforce/label/c.changeSubscription_OrderWillEndOn";
import changeSubscription_SelectOrderToEdit from "@salesforce/label/c.changeSubscription_SelectOrderToEdit";
import changeSubscription_SelectOneProduct from "@salesforce/label/c.changeSubscription_SelectOneProduct";
import changeSubscription_SelectOrder from "@salesforce/label/c.changeSubscription_SelectOrder";
import changeSubscription_NewOrder from "@salesforce/label/c.changeSubscription_NewOrder";
import changeSubscription_UpdateOrder from "@salesforce/label/c.changeSubscription_UpdateOrder";
import changeSubscription_OptionalReminderXDays from "@salesforce/label/c.changeSubscription_OptionalReminderXDays";
import general_Draft from "@salesforce/label/c.general_Draft";
import general_Activated from "@salesforce/label/c.general_Activated";
import general_Cancelled from "@salesforce/label/c.general_Cancelled";
import general_Name from "@salesforce/label/c.general_Name";
import general_Family from "@salesforce/label/c.general_Family";
import general_Code from "@salesforce/label/c.general_Code";
import general_Price from "@salesforce/label/c.general_Price";
import general_Quantity from "@salesforce/label/c.general_Quantity";
import general_StartDate from "@salesforce/label/c.general_StartDate";
import general_EndDate from "@salesforce/label/c.general_EndDate";
import general_Cancel from "@salesforce/label/c.general_Cancel";
import general_Next from "@salesforce/label/c.general_Next";
import general_Back from "@salesforce/label/c.general_Back";
import general_Submit from "@salesforce/label/c.general_Submit";
import general_SubmissionError from "@salesforce/label/c.general_SubmissionError";
import general_FillRequiredFields from "@salesforce/label/c.general_FillRequiredFields";
import general_Subscriptions from "@salesforce/label/c.general_Subscriptions";
import general_Update from "@salesforce/label/c.general_Update";
import general_Order2 from "@salesforce/label/c.general_Order2";
import general_PriceBook from "@salesforce/label/c.general_PriceBook";
import general_ActivationReminder from "@salesforce/label/c.general_ActivationReminder";
import general_New from "@salesforce/label/c.general_New";
import general_Close from "@salesforce/label/c.general_Close";
export default class ChangeSubscription extends UtilityLWC {
	constructor() {
		super("changeSubscription");
	}
	@api recordId;

	labels = {
		changeSubscription_OrderInfo,
		changeSubscription_SelectProducts,
		changeSubscription_EditOrderProducts,
		changeSubscription_OrderWillEndOnSpecifiedDate,
		changeSubscription_OrderWillEndOn,
		changeSubscription_SelectOrderToEdit,
		changeSubscription_SelectOneProduct,
		changeSubscription_SelectOrder,
		changeSubscription_NewOrder,
		changeSubscription_UpdateOrder,
		changeSubscription_OptionalReminderXDays,
		general_Draft,
		general_Activated,
		general_Cancelled,
		general_Name,
		general_Family,
		general_Code,
		general_Price,
		general_Quantity,
		general_StartDate,
		general_EndDate,
		general_Cancel,
		general_Next,
		general_Back,
		general_Submit,
		general_SubmissionError,
		general_FillRequiredFields,
		general_Subscriptions,
		general_Update,
		general_Order2,
		general_PriceBook,
		general_ActivationReminder,
		general_New,
		general_Close
	};

	@track steps = [
		{ label: this.labels.changeSubscription_OrderInfo, value: "orderInfo" },
		{ label: this.labels.changeSubscription_OrderInfo, value: "selectProducts" },
		{
			label: this.labels.changeSubscription_EditOrderProducts,
			value: "editOrderProducts"
		}
	];

	@track draftOrderSteps = [
		{ label: this.labels.general_Draft, value: "Draft" },
		{ label: this.labels.general_Activated, value: "Activated" },
		{ label: this.labels.general_Cancelled, value: "Cancelled" }
	];
	@track selectedOrderSteps = null;

	@track listOfSubscriptions = [];
	@track isModalOpen = false;
	@track isUpdate = false;
	@track numberOfSubscriptions = 0;
	@track subscriptionTypeOptions = [];
	@track subscriptionOptions = [];
	@track selectedSubscription = [];
	@track selectedSubscriptionType = null;
	@track isLoading = false;
	@track isContact = false;
	@track showComponent = false;
	@track showSubscriptionsPicklist = false;

	@track order = {
		BillToContactId: null,
		EffectiveDate: new Date(),
		EndDate: null,
		Pricebook2Id: null,
		Syntilio__ActivationReminder__c: null
	};
	@track selectOrderStep = false;
	@track orderInfoStep = true;
	@track selectProductsStep = false;
	@track editOrderProductsStep = false;

	@track pricebooksList = [];
	@track pricebooksOptions = [];

	@track ordersList = [];
	@track ordersOptions = [];
	@track selectedOrder = null;

	@track productsList = [];
	@track productsColumns = [
		{ label: this.labels.general_Name, fieldName: "Name" },
		{ label: this.labels.general_Family, fieldName: "Family" },
		{ label: this.labels.general_Code, fieldName: "ProductCode" },
		{ label: this.labels.general_Price, fieldName: "UnitPrice", type: "currency" }
	];
	@track selectedProductIds = [];

	@track orderProducts = [];
	@track orderProductsColumns = [
		{ label: this.labels.general_Name, fieldName: "Name" },
		{ label: this.labels.general_Price, fieldName: "UnitPrice", type: "currency" },
		{
			label: this.labels.general_Quantity,
			fieldName: "Quantity",
			type: "Number",
			editable: true
		},
		{
			label: this.labels.general_StartDate,
			fieldName: "ServiceDate",
			type: "Date",
			editable: true
		},
		{
			label: this.labels.general_EndDate,
			fieldName: "EndDate",
			type: "Date",
			editable: true
		}
	];

	@track oldOrderItems = {};

	@track step = "orderInfo";
	@track currentStep = 0;
	@track backButtonText = this.labels.general_Cancel;
	@track nextButtonText = this.labels.general_Next;

	@track nextButtonLoading = false;

	@track selectedStatus = null;
	@track selectedEndDate = null;

	@track loadingOrderChange = false;

	get statusChanged() {
		return (
			this.isUpdate &&
			((this.selectedStatus && this.selectedStatus !== this.order.Status) ||
				(this.selectedEndDate && this.selectedEndDate !== this.order.EndDate))
		);
	}

	get showEndDateInput() {
		return this.selectedStatus === "Ended" || this.order.Status === "Activated";
	}

	get isOrderNotDraft() {
		return this.order.Status !== "Draft" && this.isUpdate;
	}

	get isSelectedOrder() {
		return this.selectedOrder !== null;
	}

	get endDateMessage() {
		let message = this.showEndDateInput
			? this.labels.changeSubscription_OrderWillEndOnSpecifiedDate
			: this.order.EndDate
			? `${this.labels.changeSubscription_OrderWillEndOn} ${this.order.EndDate}`
			: "";
		return message;
	}

	@wire(CurrentPageReference)
	getStateParams(currentPageReference, error) {
		if (currentPageReference) {
			this.order.BillToContactId = currentPageReference.attributes?.recordId;
		}
		if (error) {
			this.logException(error, "getStateParams");
		}
	}

	handlePages() {
		this.selectOrderStep = this.step === "selectOrder";
		this.orderInfoStep = this.step === "orderInfo";
		this.selectProductsStep = this.step === "selectProducts";
		this.editOrderProductsStep = this.step === "editOrderProducts";
	}

	handleBack() {
		if (this.currentStep === this.steps.length - 1) {
			this.nextButtonText = this.labels.general_Next;
		}
		if (this.currentStep === 1) {
			this.backButtonText = this.labels.general_Cancel;
		} else if (this.currentStep === 0) {
			this.handleModalClose();
		} else {
			this.backButtonText = this.labels.general_Back;
		}
		if (this.currentStep > 0) {
			this.currentStep--;
		}
		this.step = this.steps[this.currentStep].value;
		this.handlePages();
	}

	async handleNext() {
		switch (this.step) {
			case "selectOrder": {
				if (!this.validateSelectOrder()) {
					return;
				}
				this.order = this.ordersList.filter(
					(order) => order.Id === this.selectedOrder
				)[0];
				if (this.order.OrderItems && this.order.OrderItems.totalSize > 0) {
					this.order.OrderItems.records.forEach((one) => {
						this.selectedProductIds.push(one.Product2Id);
						this.oldOrderItems[one.Product2Id] = one;
					});
				}
				this.selectedStatus = null;
				break;
			}
			case "orderInfo": {
				if (!this.validateOrderInfo()) {
					return;
				}
				await ChangeSubscriptionUtility.getProductsWrapper(
					this,
					this.order.Pricebook2Id
				);
				break;
			}
			case "selectProducts": {
				if (!this.validateSelectProducts()) {
					return;
				}
				let selectedProductsFromList = this.productsList.filter(
					(product) => this.selectedProductIds.indexOf(product.Id) !== -1
				);
				this.orderProducts = selectedProductsFromList.map((one) => {
					return {
						...(this.oldOrderItems[one.Id] && {
							Id: this.oldOrderItems[one.Id].Id
						}),
						Product2Id: one.Id,
						Name: one.Name,
						UnitPrice: one.UnitPrice,
						PricebookEntryId: one.PricebookEntryId,
						Quantity: this.oldOrderItems[one.Id]
							? this.oldOrderItems[one.Id].Quantity
							: 1,
						ServiceDate: this.oldOrderItems[one.Id]
							? this.oldOrderItems[one.Id].ServiceDate
							: this.order.EffectiveDate,
						EndDate: this.oldOrderItems[one.Id]
							? this.oldOrderItems[one.Id].EndDate
							: this.order.EndDate
					};
				});
				break;
			}
			case "editOrderProducts": {
				this.handleSubmit();
				break;
			}
			default:
				return;
		}
		if (this.currentStep === this.steps.length - 2) {
			this.nextButtonText = this.labels.general_Submit;
		} else if (this.currentStep !== this.steps.length - 1) {
			this.nextButtonText = this.labels.general_Next;
			this.backButtonText = this.labels.general_Back;
		}
		if (this.currentStep < this.steps.length - 1) {
			this.currentStep++;
		}
		this.step = this.steps[this.currentStep].value;
		this.handlePages();
	}

	validateSelectOrder() {
		if (this.selectedOrder) {
			return true;
		}
		this.notifyUser(
			this.labels.general_SubmissionError,
			this.labels.changeSubscription_SelectOrderToEdit,
			this.toastTypes.Error
		);
		return false;
	}

	validateOrderInfo() {
		if (this.order.EffectiveDate && this.order.Pricebook2Id) {
			return true;
		}
		this.notifyUser(
			this.labels.general_SubmissionError,
			this.labels.general_FillRequiredFields,
			this.toastTypes.Error
		);
		return false;
	}

	validateSelectProducts() {
		if (this.selectedProductIds.length !== 0) {
			return true;
		}
		this.notifyUser(
			this.labels.general_SubmissionError,
			this.labels.changeSubscription_SelectOneProduct,
			this.toastTypes.Error
		);
		return false;
	}

	handleChange(event) {
		if (!event.target.id) {
			return;
		}
		let componentId = event.target.id.split("-")[0];
		switch (componentId) {
			case "selectedEndDate":
				this.selectedEndDate = event.target.value;
				break;
			case "orderPricebook":
				this.order.Pricebook2Id = event.target.value;
				break;
			case "orderStartDate":
				this.order.EffectiveDate = event.target.value;
				break;
			case "orderEndDate":
				this.order.EndDate = event.target.value;
				break;
			case "orderActivationReminder":
				this.order.Syntilio__ActivationReminder__c = event.target.value;
				break;
			default:
		}
	}

	handleOrderChange(event) {
		this.loadingOrderChange = true;
		this.selectedOrder = event.target.value;
		let newOrder = this.ordersList.filter((one) => one.Id === this.selectedOrder)[0];
		this.selectedOrderSteps = this.draftOrderSteps;

		setTimeout(() => {
			this.order = newOrder;
			if (this.order.Status === "Activated") {
				this.selectedEndDate = this.order.EndDate;
			} else {
				this.selectedEndDate = null;
			}
			this.loadingOrderChange = false;
		}, 100);

		this.selectedStatus = null;
		this.selectedEndDate = null;
	}

	handleStatusChange(event) {
		this.selectedStatus = event.target.value;
		this.selectedEndDate = null;
	}

	handleSelectedEndDateChange(event) {
		this.selectedEndDate = event.target.value;
	}

	handleProductSelection(event) {
		let selectedProduct = this.productsList.filter(
			(one) => one.Id === event.detail.config.value
		)[0];
		switch (event.detail.config.action) {
			case "rowSelect":
				this.selectedProductIds.push(selectedProduct.Id);
				break;
			case "rowDeselect":
				this.selectedProductIds = this.selectedProductIds.filter(
					(one) => one !== selectedProduct.Id
				);
				break;
			case "deselectAllRows":
				this.selectedProductIds = [];
				break;
			case "selectAllRows":
				this.selectedProductIds = this.productsList.map((one) => one.Id);
				break;
			default:
		}
	}

	handleOrderProductsChange(event) {
		let draftValues = event.detail.draftValues;
		let draftValuesMap = draftValues.reduce((obj, item) => {
			obj[item.Product2Id] = item;
			return obj;
		}, {});

		let orderProductsMap = this.orderProducts.reduce((obj, item) => {
			obj[item.Product2Id] = item;
			return obj;
		}, {});

		for (const draftValueId of Object.keys(draftValuesMap)) {
			if (orderProductsMap[draftValueId]) {
				orderProductsMap[draftValueId] = {
					...orderProductsMap[draftValueId],
					...draftValuesMap[draftValueId]
				};
			}
		}

		this.orderProducts = Object.values(orderProductsMap);
		this.template.querySelector("lightning-datatable").draftValues = [];
	}

	handleSubmit() {
		this.nextButtonLoading = true;
		if (!this.isUpdate) {
			ChangeSubscriptionUtility.handleCreateOrder(this, this.order, this.orderProducts);
		} else {
			let orderToUpdate = {
				Id: this.order.Id,
				Pricebook2Id: this.order.Pricebook2Id,
				EffectiveDate: this.order.EffectiveDate,
				EndDate: this.order.EndDate,
				BillToContactId: this.order.BillToContactId,
				Syntilio__ActivationReminder__c: this.order.Syntilio__ActivationReminder__c
			};
			ChangeSubscriptionUtility.handleUpdateOrder(
				this,
				orderToUpdate,
				this.orderProducts
			);
		}
	}

	handleSubmitStatus() {
		this.nextButtonLoading = true;
		try {
			if (this.isOrderNotDraft) {
				let orderToUpdate = {
					Id: this.order.Id,
					EndDate: this.selectedEndDate,
					BillToContactId: this.order.BillToContactId
				};
				ChangeSubscriptionUtility.handleUpdateOrder(this, orderToUpdate, null);
			} else {
				ChangeSubscriptionUtility.handleUpdateOrderStatus(
					this,
					this.order.Id,
					this.selectedStatus,
					this.selectedEndDate
				);
			}
		} catch (error) {
			this.logException(error, "handleSubmitStatus");
			this.nextButtonLoading = false;
		}
	}

	connectedCallback() {
		super.connectedCallback();
		ChangeSubscriptionUtility.checkCurrentRecordType(this, this.recordId);
	}

	handleUpdateModalOpen() {
		this.steps = [
			{ label: this.labels.changeSubscription_SelectOrder, value: "selectOrder" },
			{ label: this.labels.changeSubscription_OrderInfo, value: "orderInfo" },
			{ label: this.labels.changeSubscription_SelectProducts, value: "selectProducts" },
			{
				label: this.labels.changeSubscription_EditOrderProducts,
				value: "editOrderProducts"
			}
		];
		this.step = "selectOrder";
		this.handlePages();
		ChangeSubscriptionUtility.getPriceBooksWrapper(this);
		ChangeSubscriptionUtility.getOrdersWrapper(this, this.order.BillToContactId);
		this.isModalOpen = true;
		this.isUpdate = true;
	}

	handleModalOpen() {
		this.steps = [
			{ label: this.labels.changeSubscription_OrderInfo, value: "orderInfo" },
			{ label: this.labels.changeSubscription_SelectProducts, value: "selectProducts" },
			{
				label: this.labels.changeSubscription_EditOrderProducts,
				value: "editOrderProducts"
			}
		];
		this.step = "orderInfo";
		this.handlePages();
		ChangeSubscriptionUtility.getPriceBooksWrapper(this);
		this.isModalOpen = true;
		this.isUpdate = false;
	}

	handleModalClose() {
		this.order = {
			BillToContactId: this.order.BillToContactId,
			EffectiveDate: new Date(),
			EndDate: null,
			Pricebook2Id: null
		};
		this.selectedProductIds = [];
		this.selectedOrder = null;
		this.oldOrderItems = {};
		this.orderProducts = [];
		this.step = "orderInfo";
		this.handlePages();
		this.currentStep = 0;
		this.backButtonText = this.labels.general_Cancel;
		this.nextButtonText = this.labels.general_Next;
		this.nextButtonLoading = false;
		this.selectedStatus = null;
		this.selectedEndDate = null;
		this.loadingOrderChange = false;
		this.isModalOpen = false;
		this.isUpdate = false;
	}

	handleSubscriptionChange(event) {
		this.selectedSubscription = event.target.value;
	}

	handleSubscriptionTypeChange(event) {
		this.selectedSubscriptionType = event.target.value;
		ChangeSubscriptionUtility.getSubscriptionsWrapper(
			this,
			this.selectedSubscriptionType
		);
	}
}
