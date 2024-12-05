import { LightningElement ,track} from 'lwc';
import getAutoRefreshInterval from "@salesforce/apex/ClientCasesController.getAutoRefreshInterval";

export default class AutoClickRefreshButton extends LightningElement {
    @track interval;
    connectedCallback() {
        this.getAutoRefreshTime();
    }

    async getAutoRefreshTime() {
		try {
			let data = await getAutoRefreshInterval();
			if (!data || data == "0") return;
            this.interval = data * 1000;
            this.clickRefreshButton();
		} catch (error) {
			this.logException(error, "getClientsFromApex");
		}
	}

clickRefreshButton() {
    this.intervalId = setInterval(() => {
        const refreshButtons = document.querySelectorAll('.slds-button.refreshButton.uiButton');

        if (refreshButtons.length > 0) {
            refreshButtons.forEach(button => {
                button.click(); 
            });
        } else {
            console.warn('No refresh buttons found.');
        }
    }, this.interval);
}

}
