import getSubscriptions from "@salesforce/apex/SubscriptionHandler.getSubscriptions";
import getPricebooks from "@salesforce/apex/SubscriptionHandler.getPricebooks";
import getClientOrders from "@salesforce/apex/SubscriptionHandler.getClientOrders";
import getProducts from "@salesforce/apex/SubscriptionHandler.getProducts";
import createOrder from "@salesforce/apex/SubscriptionHandler.createOrder";
import getSubscriptionTypes from "@salesforce/apex/SubscriptionHandler.getSubscriptionTypes";
import updateOrder from "@salesforce/apex/SubscriptionHandler.updateOrder";
import updateOrderStatus from "@salesforce/apex/SubscriptionHandler.updateOrderStatus";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";

export default class ChangeSubscriptionUtility {
	static async checkCurrentRecordType(component, recordId) {
		try {
			let sObject = await getSobjectFromId({ sObjectId: recordId });
			const sObjectType = String(sObject).toLowerCase();
			component.isContact = sObjectType === "contact";
			component.showComponent = sObjectType === "contact" || sObjectType === "account";
		} catch (error) {
			component.logException(error, "checkCurrentRecordType");
		}
	}

	static async getOrdersWrapper(component, contactId) {
		try {
			component.nextButtonLoading = true;
			let orders = await getClientOrders({ contactId: contactId });
			const deserializedOrders = JSON.parse(orders);
			component.ordersList = deserializedOrders.data;
			component.ordersOptions = Array.isArray(component.ordersList)
				? component.ordersList.map((one) => {
						return {
							value: one.Id,
							label: one.OrderNumber
						};
				  })
				: [];
			component.nextButtonLoading = false;
		} catch (error) {
			component.logException(error, "getOrdersWrapper");
			component.nextButtonLoading = false;
		}
	}

	static async getPriceBooksWrapper(component) {
		try {
			component.nextButtonLoading = true;
			let pricebooks = await getPricebooks();
			const deserializedPricebooks = JSON.parse(pricebooks);
			component.pricebooksList = deserializedPricebooks.data;
			component.pricebooksOptions = Array.isArray(component.pricebooksList)
				? component.pricebooksList.map((one) => {
						return {
							value: one.Id,
							label: one.Name
						};
				  })
				: [];
			component.nextButtonLoading = false;
		} catch (error) {
			component.logException(error, "getPriceBooksWrapper");
			component.nextButtonLoading = false;
		}
	}

	static async getProductsWrapper(component, pricebookId) {
		try {
			component.nextButtonLoading = true;
			const products = await getProducts({
				pricebookId: pricebookId
			});
			const deserializedProducts = JSON.parse(products);
			component.productsList = deserializedProducts.data.map((one) => {
				return {
					Id: one.Id,
					Name: one.Name,
					Family: one.Family,
					ProductCode: one.ProductCode,
					...(one.PricebookEntries &&
						one.PricebookEntries.totalSize > 0 && {
							PricebookEntryId: one.PricebookEntries.records[0].Id,
							UnitPrice: one.PricebookEntries.records[0].UnitPrice
						})
				};
			});
			component.nextButtonLoading = false;
		} catch (error) {
			component.logException(error, "getProductsWrapper");
			component.nextButtonLoading = false;
		}
	}

	static async handleCreateOrder(component, order, orderProducts) {
		try {
			let value = await createOrder({
				order: order,
				orderItems: orderProducts
			});
			let parsedValue = JSON.parse(value);
			if (!parsedValue.isSuccess) {
				let errorSplit = parsedValue.message.split(",");
				component.notifyUser(
					component.labels.general_SubmissionError,
					errorSplit[errorSplit.length - 1].split(":")[0],
					component.toastTypes.Error
				);
			} else {
				component.handleModalClose();
				component.template
					.querySelector("c-subscriptions-history")
					.checkCurrentRecordType();
			}
			component.nextButtonLoading = false;
		} catch (error) {
			component.logException(error, "handleCreateOrder");
			component.notifyUser(
				component.labels.general_SubmissionError,
				error.body ? error.body.message : error.message,
				component.toastTypes.Error
			);
			component.nextButtonLoading = false;
		}
	}

	static async handleUpdateOrder(component, order, orderProducts) {
		try {
			let value = await updateOrder({
				order: order,
				orderItems: orderProducts
			});
			let parsedValue = JSON.parse(value);
			if (!parsedValue.isSuccess) {
				component.notifyUser(
					component.labels.general_SubmissionError,
					parsedValue.message,
					component.toastTypes.Error
				);
			} else {
				component.handleModalClose();
				component.template
					.querySelector("c-subscriptions-history")
					.checkCurrentRecordType();
			}
			component.nextButtonLoading = false;
		} catch (error) {
			component.logException(error, "handleUpdateOrder");
			component.notifyUser(
				component.labels.general_SubmissionError,
				error.body ? error.body.message : error.message,
				component.toastTypes.Error
			);
			component.nextButtonLoading = false;
		}
	}

	static async handleUpdateOrderStatus(component, orderId, status, endDate) {
		try {
			let value = await updateOrderStatus({
				orderId: orderId,
				status: status,
				endDate: endDate
			});
			let parsedValue = JSON.parse(value);
			if (!parsedValue.isSuccess) {
				let errorSplit = parsedValue.message.split(",");
				component.notifyUser(
					component.labels.general_SubmissionError,
					errorSplit[errorSplit.length - 1].split(":")[0],
					component.toastTypes.Error
				);
			} else {
				component.handleModalClose();
				component.template
					.querySelector("c-subscriptions-history")
					.checkCurrentRecordType();
			}
			component.nextButtonLoading = false;
		} catch (error) {
			component.logException(error, "handleUpdateOrderStatus");
			component.notifyUser(
				component.labels.general_SubmissionError,
				error.body ? error.body.message : error.message,
				component.toastTypes.Error
			);
			component.nextButtonLoading = false;
		}
	}

	static async getSubscriptionsWrapper(component, subscriptionType) {
		try {
			let subscriptions = await getSubscriptions({
				subscriptionType: subscriptionType
			});
			const deserializedSubscriptions = JSON.parse(subscriptions);
			component.listOfSubscriptions = deserializedSubscriptions.data;
			component.numberOfSubscriptions = Array.isArray(component.listOfSubscriptions)
				? component.listOfSubscriptions.length
				: 0;
			component.subscriptionOptions = Array.isArray(component.listOfSubscriptions)
				? component.listOfSubscriptions.map((subscription) => {
						return {
							value: subscription.Id,
							label: subscription.Name
						};
				  })
				: [];
			component.showSubscriptionsPicklist = true;
		} catch (error) {
			component.logException(error, "getSubscriptionsWrapper");
		}
	}

	static async getSubscriptionTypesWrapper(component) {
		try {
			let subscriptions = await getSubscriptionTypes();
			const deserializedSubscriptions = JSON.parse(subscriptions);
			component.listOfSubscriptionsTypes = deserializedSubscriptions.data;
			component.subscriptionTypeOptions = Array.isArray(
				component.listOfSubscriptionsTypes
			)
				? component.listOfSubscriptionsTypes.map((subscriptionType) => {
						return {
							value: subscriptionType,
							label: subscriptionType
						};
				  })
				: [];
		} catch (error) {
			component.logException(error, "getSubscriptionsWrapper");
		}
	}
}
