import { api, track } from "lwc";
import getAccountExternalSystems from "@salesforce/apex/CareHubUtilities.getAccountExternalSystems";
import UtilityLWC from "c/utils";
import accountExternalSystems_ComboboxLabel from "@salesforce/label/c.accountExternalSystems_ComboboxLabel";
import accountExternalSystems_ComboboxPlaceholder from "@salesforce/label/c.accountExternalSystems_ComboboxPlaceholder";
import accountExternalSystems_ComboboxMissingMessage from "@salesforce/label/c.accountExternalSystems_ComboboxMissingMessage";
import LightningAlert from "lightning/alert";

export default class AccountExternalSystems extends UtilityLWC {
	constructor() {
		super("accountExternalSystems");
	}

	@api accountId;
	@api value;
	@track externalSystems;

	labels = {
		accountExternalSystems_ComboboxLabel,
		accountExternalSystems_ComboboxPlaceholder,
		accountExternalSystems_ComboboxMissingMessage
	};

	async openAlert(message, theme, label) {
		await LightningAlert.open({
			message: message,
			theme: theme,
			label: label
		});
	}

	getExternalSystems = async () => {
		try {
			let result = await getAccountExternalSystems({ accountId: this.accountId });
			this.externalSystems = result.map((externalSystem) => {
				return {
					label: externalSystem,
					value: externalSystem
				};
			});
		} catch (error) {
			this.logException(error, "getExternalSystems");
			this.notifyUser("Error", error?.body?.message, "error");
		}
	};

	sendDataToParent(externalSystem) {
		const dataEvent = new CustomEvent("externalsystem", {
			detail: externalSystem
		});
		this.dispatchEvent(dataEvent);
	}

	selectExternalSystem = (event) => {
		const externalSystem = event.target.value;
		this.sendDataToParent(externalSystem);
	};

	connectedCallback() {
		super.connectedCallback();
		this.getExternalSystems();
	}
}
