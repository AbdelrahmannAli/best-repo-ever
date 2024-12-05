import { api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import {
	FlowNavigationFinishEvent,
	FlowNavigationNextEvent
} from "lightning/flowSupport";
import UtilityLWC from "c/utils";

export default class RedirectToRecordDetails extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("redirectToRecordDetails");
	}

	@api recordId;
	@api availableActions = [];

	async getRecordType() {
		try {
			const objectType = await getSobjectFromId({ sObjectId: this.recordId });
			return String(objectType);
		} catch (error) {
			this.logException(error, "getRecordType");
		}
		return null;
	}

	async navigateToRecord() {
		try {
			const objectApiName = await this.getRecordType();
			if (!objectApiName) {
				return;
			}
			this[NavigationMixin.Navigate]({
				type: "standard__recordPage",
				attributes: {
					recordId: this.recordId,
					objectApiName: objectApiName,
					actionName: "view"
				}
			});
			let navigateEvent;
			if (this.availableActions.includes("NEXT")) {
				navigateEvent = new FlowNavigationNextEvent();
			} else {
				navigateEvent = new FlowNavigationFinishEvent();
			}
			this.dispatchEvent(navigateEvent);
		} catch (error) {
			this.logException(error, "navigateToRecord");
		}
	}
	connectedCallback() {
		super.connectedCallback();
		this.navigateToRecord();
	}
}
