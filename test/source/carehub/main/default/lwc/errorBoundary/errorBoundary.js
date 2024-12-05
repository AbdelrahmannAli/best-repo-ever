import { api, track } from "lwc";
import logExceptionLWC from "@salesforce/apex/HandleException.logExceptionLWC";
import UtilityLWC from "c/utils";
export default class ErrorBoundary extends UtilityLWC {
	constructor() {
		super("errorBoundary");
	}

	@api className;
	@track hasError = false;
	@track errorMessage = "";
	@track errorId = "";

	async errorCallback(error) {
		try {
			this.hasError = true;
			const methodName = error.stack.split("\n")[1].trim().split(" ")[1];
			const stackLines = error.stack.split("\n");
			const lineNumber = stackLines[1].trim().split(":")[1];
			let logInfo = await logExceptionLWC({
				exceptionType: error.Name,
				exceptionMessage: error.message,
				stackTrace: error.stack,
				lineNumber: lineNumber,
				methodName: methodName,
				className: this.className,
				nameSpace: "Syntilio",
				source: this.exceptionTypes.LWC
			});
			if (!logInfo) return;
			const idArray = JSON.parse(logInfo);
			this.errorId =
				Array.isArray(idArray) && idArray.length > 0 ? idArray[0].id ?? "" : "";
			this.notifyUser(
				"An Unexpected Behavior",
				"An error has occurred in " + this.className,
				this.toastTypes.Error
			);
		} catch (error) {
			this.logException(error, "errorCallback");
		}
	}

	connectedCallback() {
		if (this.hasError) {
			this.hasError = false;
			this.errorMessage = "";
		}
	}
}
