import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import UtilityLWC from "c/utils";
import errorUI_UnexpectedError from "@salesforce/label/c.errorUI_UnexpectedError";
export default class ErrorUI extends NavigationMixin(UtilityLWC) {
	@api errorMessage;
	@api errorId;
	@api recordId;
	@track href;

	labels = {
		errorUI_UnexpectedError
	};

	renderedCallback() {
		this.href = `/Syntilio__Exception__c/${this.errorId}`;
	}

	handleErrorClick() {
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: this.errorId,
				objectApiName: "Syntilio__Exception__c",
				actionName: "view"
			}
		});
	}
}
