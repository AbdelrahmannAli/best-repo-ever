import { NavigationMixin } from "lightning/navigation";
import UtilityLWC from "c/utils";
import { track, api } from "lwc";
import getCaseTabClosureConfirmation from "@salesforce/apex/ClientCasesController.getCaseTabClosureConfirmation";
import getCaseStatus from "@salesforce/apex/ClientCasesController.getCaseStatus";
import caseTabClosureConfirmation_ConfirmationMessage from "@salesforce/label/c.caseTabClosureConfirmation_ConfirmationMessage";
export default class CaseTabClosureConfirmation extends NavigationMixin(UtilityLWC) {
	constructor() {
		super("caseTabClosureConfirmation");
	}
	@track closeCase = false;
	@track caseStatus;
	@api recordId;

	labels = {
		caseTabClosureConfirmation_ConfirmationMessage
	};

	connectedCallback() {
		this.getClientsFromApex();
		this.getCaseStatus();
		const closeButton = document.querySelectorAll(
			".slds-button.slds-button_icon.slds-button_icon-x-small.slds-button_icon-container"
		);
		if (closeButton) {
			closeButton.forEach((one) => {
				one.addEventListener("click", this.handleCloseButtonClick.bind(this));
			});
		}
	}

	async getClientsFromApex() {
		try {
			let data = await getCaseTabClosureConfirmation();
			if (!data) return;
			this.closeCase = data;
		} catch (error) {
			this.logException(error, "getClientsFromApex");
		}
	}

	async getCaseStatus() {
		try {
			let data = await getCaseStatus({ caseId: this.recordId });
			if (!data) return;
			this.caseStatus = data;
		} catch (error) {
			this.logException(error, "getCaseStatus");
		}
	}
	async handleCloseButtonClick(event) {
		if (!this.closeCase || this.caseStatus === "Closed") return;
		if (!confirm(this.labels.caseTabClosureConfirmation_ConfirmationMessage)) {
			window.location.replace(window.location.href);
		}
		// this.isDialogVisible = true;
		// const modal = document.getElementById('myModal');
		//
		// const element = document.querySelectorAll(".First > button");
		//
		// element.addEventListener("click");
		//   return new Promise(function (resolve, reject) {
		//     var listener = event => {
		//         element.removeEventListener("click", listener);
		//         resolve(event);
		//     };
		//     element.addEventListener("click", listener);
		// });
		//   var element = document.querySelector("button");
		// await waitListener(element,"click");
		// if(!this.closeCase)
		//     return;
		// if (!(confirm("Are you sure you want to navigate away from the case without closing it?"))) {
		//      window.location.replace(window.location.href);
		//   }
		// else {
		//   if(confirm("Do you want to set a reminder?")){
		//     prompt("Reminder after (days)")
		//   }
		// }
	}
}
