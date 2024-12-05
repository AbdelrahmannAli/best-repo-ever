import { api, track, wire } from "lwc";
import { subscribe } from "lightning/empApi";
import UtilityLWC from "c/utils";
import getContactSafetyBadges from "@salesforce/apex/MedicalSummaryHandler.getContactSafetyBadges";
import getUserId from "@salesforce/apex/CareHubUtilities.getUserId";
import { getRecord } from "lightning/uiRecordApi";
import safetyBadges_UpdatingSafetyBadgesFailed from "@salesforce/label/c.safetyBadges_UpdatingSafetyBadgesFailed";

export default class SafetyBadges extends UtilityLWC {
	constructor() {
		super("safetyBadges");
	}

	@api recordId;
	@track channelName = "/event/Syntilio__Notification__e";
	@track alerts = [];
	@track resuscitation;
	@track userId;
	@track contactId;

	labels = {
		safetyBadges_UpdatingSafetyBadgesFailed
	};

	connectedCallback() {
		const metaTag = document.createElement("meta");
		metaTag.setAttribute("http-equiv", "Content-Security-Policy");
		metaTag.setAttribute(
			"content",
			"img-src 'self' data: blob: https://development-development.ons-dossier.nl *.force.com *.sfdcstatic.com *.salesforce.com *.my-salesforce.com *.cloudinary.com;"
		);
		document.head.appendChild(metaTag);
	}

	@wire(getRecord, { recordId: "$recordId", fields: ["Case.ContactId"] })
	recordUpdated({ data }) {
		this.alerts = []
		this.resuscitation = false
		if (!this.recordId || !data) {
			return;
		}
		if (data.apiName !== "Case") {
			this.handleGetContactAlerts();
			this.handleSubscribe();
			return;
		}
		let contactId = data.fields.ContactId.value;
		if (this.contactId !== contactId) {
			this.contactId = contactId;
			this.handleGetContactAlerts();
			this.handleSubscribe();
		}
	}

	async handleGetContactAlerts() {
		try {
			let serializedResponseData = await getContactSafetyBadges({
				objectId: this.recordId
			});
			const responseData = JSON.parse(serializedResponseData);
			this.handleContactSafetyBadgesResponse(responseData);
		} catch (error) {
			this.logException(error, "handleGetContactAlerts");
		}
	}

	handleContactSafetyBadgesResponse(responseData) {
		if (!responseData || !responseData.data) {
			throw new Error(
				"Falsy response coming from getContactSafetyBadges, responseValue -> " +
					responseData +
					"responseData" +
					responseData.data
			);
		}
		const safetyBadges = responseData.data;
		this.resuscitation =
			safetyBadges.resuscitationDecision &&
			safetyBadges.resuscitationDecision !== "Unknown Resuscitation Decision"
				? safetyBadges.resuscitationDecision
				: null;
		this.resuscitationClass =
			"card " +
			(safetyBadges.resuscitationDecision === "Resuscitate" ? "success" : "error");
		this.alerts = Array.isArray(safetyBadges.alerts)
			? safetyBadges.alerts.map((alert) => {
					alert.description = alert.Syntilio__Description__c ?? alert.Name;
					return alert;
			  })
			: [];
	}

	receiveProgress(response) {
		if (!response) return;
		if (
			response.data.payload.Syntilio__Target__c === "SafetyBadges" &&
			response.data.payload.Syntilio__TargetUserId__c === this.userId
		) {
			if (response.data.payload.Syntilio__Status__c === "Failure") {
				this.notifyUser(
					"",
					this.labels.safetyBadges_UpdatingSafetyBadgesFailed,
					this.toastTypes.Error
				);
			}
			this.handleGetContactAlerts();
		}
	}

	async handleSubscribe() {
		try {
			await subscribe(this.channelName, -1, (response) =>
				this.receiveProgress(response)
			);
			let userId = await getUserId();
			this.userId = userId;
		} catch (error) {
			this.logException(error, "handleSubscribe");
		}
	}
}
