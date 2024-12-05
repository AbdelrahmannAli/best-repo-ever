import { subscribe } from "lightning/empApi";
import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import UtilityLWC from "c/utils";

export default class contactPageEventListener extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("contactPageEventListener");
	}

	@api recordId;
	@track caseId;
	@track channelName = "/event/Syntilio__Notification__e";

	receiveProgress(response) {
		try {
			if (!response) return;
			const payload = response?.data?.payload;
			if (payload.Syntilio__Target__c === "Phone") {
				this[NavigationMixin.Navigate]({
					type: "standard__recordPage",
					attributes: {
						recordId: String(payload.Syntilio__CaseId__c),
						objectApiName: "Case",
						actionName: "view"
					}
				});
			}
		} catch (error) {
			this.logException(error, "receiveProgress");
		}
	}

	connectedCallback() {
		this.handleSubscribe();
	}

	async handleSubscribe() {
		try {
			await subscribe(this.channelName, -1, (response) =>
				this.receiveProgress(response)
			);
		} catch (error) {
			this.logException(error, "handleSubscribe");
		}
	}
}
