import { api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import UtilityLWC from "c/utils";
import getExternalSystems from "@salesforce/apex/ClientCasesController.getExternalSystems";
import general_SelectExternalSystem from "@salesforce/label/c.general_SelectExternalSystem";
import general_NoOptionsAvailable from "@salesforce/label/c.general_NoOptionsAvailable";

export default class MultipleChatSystems extends NavigationMixin(UtilityLWC) {
    constructor() {
        super("MultipleChatSystems");
    }

    @api recordId;
    @track options = [];
    @track selectedOption;
    @track externalSystemName;
    @track redirect;

    labels = {
        general_SelectExternalSystem,
        general_NoOptionsAvailable
    };

    connectedCallback() {
        super.connectedCallback();
        this.getOptions();
    }

    handleClick(event) {
        this.selectedOption = event.detail.value;
        this.externalSystemName = this.selectedOption.split("~")[1];
        this.redirect = this.selectedOption.split("~")[0];
    }

    async getOptions() {
        try {
            let result = await getExternalSystems();
            this.options = result

                .filter((r) => r.Syntilio__ChatUrl__c)
                .map((r) => {
                    return {
                        label: r.Name,
                        value: `${r.Syntilio__ChatUrl__c}~${r.Name}`
                    };
                });
            if (this.options.length == 1) {
                this.externalSystemName = this.options[0].value.split("~")[1];
                this.redirect = this.options[0].value.split("~")[0];
                this.getUrl();
            }
        } catch (error) {
            this.logException(error, "getOptions");
        }
    }

    async getUrl() {
        try {
            if (this.selectedOption == null ) {
                return;
            }
            if(this.redirect){
                window.open(this.redirect, "_blank");
            }
            this.dispatchEvent(
                new CustomEvent("buttonPressed", {
                    detail: Date.now()
                })
            );
        } catch (error) {
            this.logException(error, "getUrl");
        }
    }
}