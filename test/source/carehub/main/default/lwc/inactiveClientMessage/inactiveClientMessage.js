import { api, track } from "lwc";
import clientInactiveDate from "@salesforce/apex/SubscriptionHandler.clientInactiveDate";
import getCaseInfo from "@salesforce/apex/SubscriptionHandler.getCaseInfo";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import UtilityLWC from "c/utils";
import inactiveClientMessage_NoActiveSubscription from "@salesforce/label/c.inactiveClientMessage_NoActiveSubscription";
import inactiveClientMessage_ClientInactiveAsOf from "@salesforce/label/c.inactiveClientMessage_ClientInactiveAsOf";
import inactiveClientMessage_InactiveAsOf from "@salesforce/label/c.inactiveClientMessage_InactiveAsOf";
import general_Inactive from "@salesforce/label/c.general_Inactive";

export default class InactiveClientMessage extends UtilityLWC {
	constructor() {
		super("inactiveClientMessage");
	}

	@api recordId;
	@track message = null;
	@track showMessage = false;

	labels = {
		inactiveClientMessage_NoActiveSubscription,
		inactiveClientMessage_ClientInactiveAsOf,
		inactiveClientMessage_InactiveAsOf,
		general_Inactive
	};

	connectedCallback() {
		super.connectedCallback();
		this.setMessage();
	}

	async setMessage() {
		var type = await getSobjectFromId({ sObjectId: this.recordId });
		if (type === "Contact") {
			this.contactMessage();
			return;
		}
		if (type === "Case") {
			this.caseMessage();
			return;
		}
		this.reset_data();
	}

	async contactMessage() {
		try {
			let endDate = await clientInactiveDate({ clientId: this.recordId });
			if (endDate == null) {
				this.reset_data();
				return;
			}
			let dateEnd = new Date(endDate);
			dateEnd.setHours(0);
			let today = new Date();
			today.setHours(0);
			if (dateEnd <= today) {
				this.message = this.labels.general_Inactive;
			} else {
				this.message = this.labels.inactiveClientMessage_InactiveAsOf.includes("{date}")
					? this.labels.inactiveClientMessage_InactiveAsOf.replace(
							"{date}",
							`${endDate}`
					  )
					: `${this.labels.inactiveClientMessage_InactiveAsOf} ${endDate}`;
			}
			this.showMessage = true;
		} catch (error) {
			this.logException(error, "contactMessage");
			this.reset_data();
		}
	}

	async caseMessage() {
		try {
			const caseInfo = await getCaseInfo({ caseId: this.recordId });
			if (!caseInfo) {
				this.reset_data();
				return;
			}
			const endDate = await clientInactiveDate({ clientId: caseInfo.ContactId });
			if (endDate != null) {
				let dateEnd = new Date(endDate);
				dateEnd.setHours(0);
				let today = new Date();
				today.setHours(0);
				if (dateEnd <= today) {
					this.message = this.labels.inactiveClientMessage_NoActiveSubscription;
				} else {
					this.message = this.labels.inactiveClientMessage_ClientInactiveAsOf.includes(
						"{date}"
					)
						? this.labels.inactiveClientMessage_ClientInactiveAsOf.replace(
								"{date}",
								`${endDate}`
						  )
						: `${this.labels.inactiveClientMessage_ClientInactiveAsOf} ${endDate}`;
				}
				this.showMessage = true;
			}
		} catch (error) {
			this.logException(error, "caseMessage");
			this.reset_data();
		}
	}

	reset_data() {
		this.showMessage = false;
		this.message = null;
	}
}
