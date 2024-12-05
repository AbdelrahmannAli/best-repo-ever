import { LightningElement, api } from "lwc";
import LightningAlert from "lightning/alert";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import logExceptionAsString from "@salesforce/apex/HandleException.logExceptionAsString";

export default class UtilityLWC extends LightningElement {
	lwcName;

	constructor(lwcName) {
		super();
		this.lwcName = lwcName;
	}

	@api exceptionTypes = {
		Apex: "Apex",
		LWC: "LWC",
		Flow: "Flow"
	};

	@api toastTypes = {
		Success: "success",
		Error: "error",
		Info: "info"
	};

	//  excepted format:- /lightning/r/(Account, Contact, ...etc)/001JW000008KPiRYAW/view
	@api
	checkRecordPageType() {
		const pathName = window.location.pathname;
		const pathNameSplit = pathName.split("/");
		if (pathName.length < 4) {
			return null;
		}
		return pathNameSplit[3];
	}

	@api
	async openAlert(message, theme, label) {
		await LightningAlert.open({
			message: message,
			theme: theme,
			label: label
		});
	}

	@api
	notifyUser(title, message, variant) {
		const errorEvent = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: "pester"
		});
		this.dispatchEvent(errorEvent);
	}

	@api
	logException(error, methodName) {
		let exception = {
			exceptionType: error.body ? error.body.exceptionType : error.name,
			exceptionMessage: error.body ? error.body.message : error.message,
			stackTrace: error.body ? error.body.stackTrace : error.stack,
			lineNumber: 0,
			methodName: methodName,
			className: this.lwcName,
			nameSpace: "Syntilio",
			source: this.exceptionTypes.LWC
		};
		logExceptionAsString(exception);
	}

	connectedCallback() {
		// Object.freeze(this.exceptionTypes);
	}
}
