import { api, track } from "lwc";
import getClientInfo from "@salesforce/apex/RegisterNewClientsController.getClientInfo";
import createContact from "@salesforce/apex/RegisterNewClientsController.createContact";
import Salutation_Field from "@salesforce/schema/Contact.Salutation";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import UtilityLWC from "c/utils";
import registrationForm_WhichClient from "@salesforce/label/c.registrationForm_WhichClient";
import registrationForm_InformationCorrectNext from "@salesforce/label/c.registrationForm_InformationCorrectNext";
import registrationForm_SeeBeforeMovingForward from "@salesforce/label/c.registrationForm_SeeBeforeMovingForward";
import registrationForm_FetchedClient from "@salesforce/label/c.registrationForm_FetchedClient";
import registrationForm_FillInRequestedClientID from "@salesforce/label/c.registrationForm_FillInRequestedClientID";
import registrationForm_ClientCreatedSuccessfully from "@salesforce/label/c.registrationForm_ClientCreatedSuccessfully";
import registrationForm_SelectSalutation from "@salesforce/label/c.registrationForm_SelectSalutation";
import registrationForm_EnterValidEmail from "@salesforce/label/c.registrationForm_EnterValidEmail";
import registrationForm_EnterValidMobilePhone from "@salesforce/label/c.registrationForm_EnterValidMobilePhone";
import registrationForm_ClientIDNotValid from "@salesforce/label/c.registrationForm_ClientIDNotValid";
import general_Contact from "@salesforce/label/c.general_Contact";
import general_Registration from "@salesforce/label/c.general_Registration";
import general_FullName from "@salesforce/label/c.general_FullName";
import general_Email from "@salesforce/label/c.general_Email";
import general_MobilePhone from "@salesforce/label/c.general_MobilePhone";
import general_MailingCity from "@salesforce/label/c.general_MailingCity";
import general_MailingCountry from "@salesforce/label/c.general_MailingCountry";
import general_MailingPostalCode from "@salesforce/label/c.general_MailingPostalCode";
import general_MailingStreet from "@salesforce/label/c.general_MailingStreet";
import general_HomePhone from "@salesforce/label/c.general_HomePhone";
import general_Locations from "@salesforce/label/c.general_Locations";
import general_FirstName from "@salesforce/label/c.general_FirstName";
import general_LastName from "@salesforce/label/c.general_LastName";
import general_Gender from "@salesforce/label/c.general_Gender";
import general_MainLocationName from "@salesforce/label/c.general_MainLocationName";
import general_Submit from "@salesforce/label/c.general_Submit";
import general_Back from "@salesforce/label/c.general_Back";
import general_Next from "@salesforce/label/c.general_Next";
import general_ExternalSystem from "@salesforce/label/c.general_ExternalSystem";
import general_ClientID from "@salesforce/label/c.general_ClientID";
import general_Save from "@salesforce/label/c.general_Save";
import general_InvalidMobilePhoneNumber from "@salesforce/label/c.general_InvalidMobilePhoneNumber";
import general_InvalidEmailAddressFormat from "@salesforce/label/c.general_InvalidEmailAddressFormat";
import fetchClients_IntegrationTimeout from "@salesforce/label/c.fetchClients_IntegrationTimeout";
import { NavigationMixin } from "lightning/navigation";
import { RefreshEvent } from 'lightning/refresh';
export default class RegistrationForm extends NavigationMixin(UtilityLWC) {

	constructor() {
		super("registrationForm");
	}

	@api recordId;

	labels = {
		registrationForm_WhichClient,
		registrationForm_InformationCorrectNext,
		registrationForm_SeeBeforeMovingForward,
		registrationForm_FetchedClient,
		registrationForm_FillInRequestedClientID,
		registrationForm_ClientCreatedSuccessfully,
		registrationForm_SelectSalutation,
		registrationForm_EnterValidEmail,
		registrationForm_EnterValidMobilePhone,
		registrationForm_ClientIDNotValid,
		general_Contact,
		general_Registration,
		general_FullName,
		general_Email,
		general_MobilePhone,
		general_MailingCity,
		general_MailingCountry,
		general_MailingPostalCode,
		general_MailingStreet,
		general_HomePhone,
		general_Gender,
		general_Locations,
		general_FirstName,
		general_LastName,
		general_MainLocationName,
		general_Submit,
		general_Back,
		general_Next,
		general_ExternalSystem,
		general_ClientID,
		general_Save,
		general_InvalidMobilePhoneNumber,
		general_InvalidEmailAddressFormat,
		fetchClients_IntegrationTimeout
	};

	@track steps = [
		{ label: this.labels.general_ExternalSystem, value: "step-1" },
		{ label: this.labels.general_ClientID, value: "step-2" },
		{ label: this.labels.registrationForm_FetchedClient, value: "step-3" },
		{ label: this.labels.general_Save, value: "step-4" }
		// { label: "Done", value: "step-5" }
	];

	@track step = "step-1";
	@track currentStep = 0;
	@track backButtonDisabled = true;
	@track nextButtonDisabled = false;
	@track clientId;
	@track firstPage = true;
	@track secondPage = false;
	@track thirdPage = false;
	@track fourthPage = false;
	// @track fifthPage = false;
	@track isLoading = false;
	@track fields = [Salutation_Field];
	@track client;
	@track externalSystem;
	@track externalSystems;
	@track modifiedClient;
	@track isAccountRecord = false;
	@track showExternalAccountError = false;
	@track isErrorShown = false;

	cleanupClientData() {
		delete this.modifiedClient?.contact?.attributes;
		this.modifiedClient?.locations.forEach((location) => {
			delete location?.attributes;
		});
		this.modifiedClient?.externalIds.forEach((externalId) => {
			delete externalId?.attributes;
		});
	}

	handlePages() {
		this.firstPage = this.currentStep === 0;
		this.secondPage = this.currentStep === 1;
		this.thirdPage = this.currentStep === 2;
		this.fourthPage = this.currentStep === 3;
		// this.fifthPage = this.currentStep === 4;
	}

	handleBack() {
		if (this.currentStep === this.steps.length - 1) {
			this.nextButtonDisabled = false;
		}
		if (this.currentStep === 1) {
			this.backButtonDisabled = true;
		} else {
			this.backButtonDisabled = false;
		}
		this.currentStep--;
		this.step = this.steps[this.currentStep].value;
		this.handlePages();
	}

	// handleNext() {
	//   if (this.currentStep === 0) {
	//     if (!this.externalSystem) {
	//       return;
	//     }
	//     this.backButtonDisabled = false;
	//     this.isLoading = true;
	//   }
	//   if (this.currentStep === 1) {
	//     if (!this.clientId) {
	//       var inputCmp = this.template.querySelector(".clientIdcmp");
	//       inputCmp.setCustomValidity("Please fill the requested client ID");
	//       inputCmp.reportValidity();
	//       return;
	//     }
	//     this.isLoading = true;
	//     this.handleGetClientResponse();
	//   }
	//   if (this.currentStep === this.steps.length - 2) {
	//     this.nextButtonDisabled = true;
	//   } else {
	//     this.nextButtonDisabled = false;
	//   }
	//   this.currentStep++;
	//   this.step = this.steps[this.currentStep].value;
	//   this.handlePages();
	//   if (this.currentStep === this.steps.length - 1) {
	//     setTimeout(() => {
	//       this.resetForm();
	//     })
	//   }
	// }

	handleNext() {
		switch (this.currentStep) {
			case 0:
				this.handleFirstStep();
				break;
			case 1:
				this.handleSecondStep();
				break;
			default:
				this.handleSubsequentSteps();
				break;
		}
		this.currentStep++;
		this.step = this.steps[this.currentStep].value;
		this.handlePages();
	}

	handleFirstStep() {
		if (!this.externalSystem) {
			return;
		}
		this.backButtonDisabled = false;
		this.isLoading = true;
	}

	handleSecondStep() {
		if (!this.clientId) {
			var inputCmp = this.template.querySelector(".clientIdcmp");
			inputCmp.setCustomValidity(this.labels.registrationForm_FillInRequestedClientID);
			inputCmp.reportValidity();
			return;
		}
		this.isLoading = true;
		this.handleGetClientResponse();
	}

	handleSubsequentSteps() {}

	handleClientIdChange(event) {
		this.clientId = event.detail.value;
	}

	selectExternalSystem = (event) => {
		this.externalSystem = event.detail;
		this.handleNext();
	};

	validateClientId() {
		if (this.clientId < 0) {
			this.notifyUser("Error", this.labels.registrationForm_ClientIDNotValid, "error");
			this.resetForm();
			return false;
		}
	}

	async handleGetClientResponse() {
		try {
			let timeout = true;
			const validClientId = this.validateClientId();
			if (validClientId === false) return;
			let result = await getClientInfo({
				clientId: String(this.clientId),
				accountId: this.recordId,
				externalSystem: this.externalSystem
			});
			this.isLoading = false;
			const parsedData = JSON.parse(result);
			timeout = false;
			this.handleResponseMessage(parsedData);

			setTimeout(async () => {
				this.isLoading = false;
				if (timeout && !this.isErrorShown) {
					this.notifyUser(
						"Error",
						this.labels.fetchClients_IntegrationTimeout,
						this.toastTypes.Error
					);
				}
			}, 50000);
		} catch (error) {
			this.logException(error, "handleGetClientResponse");
			this.isErrorShown = true;
			this.notifyUser(
				"Error",
				error.body ? error?.body?.message : error.message,
				this.toastTypes.Error
			);
			this.resetForm();
		}
	}

	handleResponseMessage(parsedData) {
		try {
			switch (parsedData?.type) {
				case "ERROR":
					this.isErrorShown = true;
					this.notifyUser("Error", parsedData?.message, "error");
					this.resetForm();
					break;
				case "SUCCESS":
					const clientData = JSON.parse(parsedData.data);
					this.client = clientData;
					this.client.contact.FullName =
						(clientData?.contact?.Salutation || "") +
						" " +
						(clientData?.contact?.FirstName || "") +
						" " +
						(clientData?.contact?.LastName || "");
					this.client.contact.MobilePhone =
						clientData?.contact.MobilePhone !== null &&
						clientData?.contact.MobilePhone !== "" &&
						clientData?.contact.MobilePhone;
					this.client.contact.Email =
						clientData?.contact.Email !== null &&
						clientData?.contact.Email !== "" &&
						clientData?.contact.Email;
					this.client.locations =
						clientData?.locations !== null &&
						clientData?.locations !== "" &&
						clientData?.locations;
					break;
				default:
					break;
			}
		} catch (error) {
			this.logException(error, "handleResponseMessage");
		}
	}

	validateContactField(field, errorMessage) {
		if (
			this.modifiedClient?.contact?.[field] &&
			!this.validateInputsValues(this.modifiedClient.contact[field], field)
		) {
			this.notifyUser("Error", errorMessage, this.toastTypes.Error);
			return false;
		}
		return true;
	}

	async createClient() {
		try {
			if (
				!this.validateContactField(
					"MobilePhone",
					this.labels.registrationForm_EnterValidMobilePhone
				)
			) {
				return;
			}

			if (
				!this.validateContactField(
					"Email",
					this.labels.registrationForm_EnterValidEmail
				)
			) {
				return;
			}

			if (
				!this.validateContactField(
					"Salutation",
					this.labels.registrationForm_SelectSalutation
				)
			) {
				return;
			}

			this.cleanupClientData();
			this.isLoading = true;
			const serializedClient = JSON.stringify(this.modifiedClient ?? this.client);

			let result = await createContact({
				client: serializedClient,
				externalSystem: this.externalSystem,
				accountId: this.recordId
			});
			this.isLoading = false;

			const parsedResult = JSON.parse(result);
			this.handleResponseMessage(parsedResult);
			this.notifyUser(
				"Success",
				this.labels.registrationForm_ClientCreatedSuccessfully,
				this.toastTypes.Success
			);
			this.dispatchEvent(new RefreshEvent());

		} catch (error) {
			this.logException(error, "createClient");
		} finally {
			this.resetForm();
		}
	}

	validateInputs(selector, msg) {
		const inputCmp = this.template.querySelector(selector);
		inputCmp.setCustomValidity(msg);
		inputCmp.reportValidity();
	}

	handleChange(event) {
		try {
			const name = event.target.name;
			if (this.modifiedClient === undefined || this.modifiedClient === null) {
				this.modifiedClient = JSON.parse(JSON.stringify(this.client));
			}

			if (name === "MobilePhone") {
				if (!this.validateInputsValues(event.target.value, "MobilePhone")) {
					this.validateInputs(
						".mobilePhoneCMP",
						this.labels.general_InvalidMobilePhoneNumber
					);
					return;
				} else {
					this.validateInputs(".mobilePhoneCMP", "");
				}
			}

			if (name === "Email") {
				if (!this.validateInputsValues(event.target.value, "Email")) {
					this.validateInputs(
						".emailCMP",
						this.labels.general_InvalidEmailAddressFormat
					);
					return;
				} else {
					this.validateInputs(".emailCMP", "");
				}
			}
			this.modifiedClient.contact[name] = event.target.value;
		} catch (error) {
			this.logException(error, "handleChange");
		}
	}

	validateInputsValues(input, type) {
		if (input === undefined || input === null || input === "") {
			return false;
		}
		if (type === "Email") {
			const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
			if (!emailRegex.test(String(input))) {
				return false;
			}
		} else if (type === "MobilePhone") {
			const phoneNumberRegex = /^\+(?:[0-9] ?){6,14}[0-9]$/;
			if (!phoneNumberRegex.test(String(input))) {
				return false;
			}
		}
		return true;
	}

	resetForm() {
		this.currentStep = 0;
		this.step = this.steps[this.currentStep].value;
		this.handlePages();
		this.clientId = "";
		this.backButtonDisabled = true;
		this.nextButtonDisabled = false;
		this.isLoading = false;
		this.client = undefined;
		this.modifiedClient = undefined;
		this.externalSystems = undefined;
		this.externalSystem = "";
		this.showExternalAccountError = false;
	}

	async checkCurrentRecordType() {
		try {
			let result = await getSobjectFromId({ sObjectId: this.recordId });
			this.isAccountRecord = result === "Account" ? true : false;
		} catch (error) {
			this.logException(error, "checkCurrentRecordType");
			this.isErrorShown = true;
			this.notifyUser(
				"Error",
				error.body ? error?.body?.message : error.message,
				this.toastTypes.Error
			);
		}
	}

	connectedCallback() {
		this.checkCurrentRecordType();
	}
}
