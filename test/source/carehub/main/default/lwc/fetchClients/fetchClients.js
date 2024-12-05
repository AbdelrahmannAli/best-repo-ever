import { api, track, wire } from "lwc";
import getClients from "@salesforce/apex/FetchClientsController.getClients";
import getClientsFromDB from "@salesforce/apex/FetchClientDataProcessor.getClientsFromDB";
import { subscribe } from "lightning/empApi";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import UtilityLWC from "c/utils";
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from "@salesforce/apex/FetchClientsController.getSessionId";
import logExceptionAsString from "@salesforce/apex/HandleException.logExceptionAsString";
import getUserId from "@salesforce/apex/CareHubUtilities.getUserId";
import fetchClients_FetchClients from "@salesforce/label/c.fetchClients_FetchClients";
import fetchClients_FetchClientsData from "@salesforce/label/c.fetchClients_FetchClientsData";
import fetchClients_FetchClientsProgress from "@salesforce/label/c.fetchClients_FetchClientsProgress";
import fetchClients_IntegrationTimeout from "@salesforce/label/c.fetchClients_IntegrationTimeout";
import general_FirstName from "@salesforce/label/c.general_FirstName";
import general_LastName from "@salesforce/label/c.general_LastName";
import general_MobilePhone from "@salesforce/label/c.general_MobilePhone";
import general_Email from "@salesforce/label/c.general_Email";
import general_Gender from "@salesforce/label/c.general_Gender";
import general_Birthdate from "@salesforce/label/c.general_Birthdate";
import general_Locations from "@salesforce/label/c.general_Locations";

export default class FetchClients extends UtilityLWC {
	constructor() {
		super("fetchClients");
	}

	@api recordId;
	@track dataFetched = false;
	@track isLoading = false;
	@track clientsData;
	@track channelName = "/event/Syntilio__Notification__e";
	@track externalSystem;
	@track isExternalSystemSelected = false;
	@track isAccountRecord = false;
	@track errorShowed = false;
	@track sessionId;
	@track libInitialized = false;
	@track userId;

	labels = {
		fetchClients_FetchClients,
		fetchClients_FetchClientsData,
		fetchClients_FetchClientsProgress,
		fetchClients_IntegrationTimeout,
		general_FirstName,
		general_LastName,
		general_MobilePhone,
		general_Email,
		general_Gender,
		general_Birthdate,
		general_Locations
	};

	@track columns = [
		{ label: this.labels.general_FirstName, fieldName: "firstName", type: "text" },
		{ label: this.labels.general_LastName, fieldName: "lastName", type: "text" },
		{ label: this.labels.general_MobilePhone, fieldName: "mobilePhone", type: "phone" },
		{ label: this.labels.general_Email, fieldName: "emailAddress", type: "email" },
		{ label: this.labels.general_Gender, fieldName: "gender", type: "text" },
		{ label: this.labels.general_Birthdate, fieldName: "birthdate", type: "date" },
		{
			label: this.labels.general_Locations,
			fieldName: "locations",
			type: "text",
			wrapText: true
		}
	];

	@wire(getSessionId)
	async wiredSessionId({ error, data }) {
		try {
			if (data) {
				this.sessionId = data;
				await loadScript(this, cometdlwc);
				this.initializecometd();
			} else if (error) {
				this.logException(error, "wiredSessionId");
				this.error = error;
				this.sessionId = undefined;
			}
		} catch (error) {
			this.logException(error, "wiredSessionId");
		}
	}

	selectExternalSystem = (event) => {
		this.externalSystem = event.detail;
		this.isExternalSystemSelected = true;
	};

	startFetchingClientsData = async () => {
		try {
			this.isLoading = true;

			setTimeout(() => {
				this.isLoading = false;
				if (!this.dataFetched && !this.errorShowed) {
					this.notifyUser(
						"Error",
						this.labels.fetchClients_IntegrationTimeout,
						this.toastTypes.Error
					);
				}
			}, 50000);

			await getClients({
				accountId: this.recordId,
				externalSystem: this.externalSystem
			});
		} catch (error) {
			this.logException(error, "startFetchingClientsData");
			this.dataFetched = false;
			this.isLoading = false;
			this.errorShowed = true;
		}
	};

	getClientsData = async () => {
		try {
			let result = await getClientsFromDB({
				accountId: this.recordId,
				externalSystem: this.externalSystem
			});
			const parsedResult = JSON.parse(result);
			const unParsedData = parsedResult.data;
			this.clientsData = JSON.parse(unParsedData);
			this.dataFetched = true;
		} catch (error) {
			this.logException(error, "getClientsData");
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.dataFetched = false;
		} finally {
			this.isLoading = false;
		}
	};

	receiveProgress = async (response) => {
		const msg = response?.data?.payload?.Syntilio__Message__c;
		const parsedMsg = JSON.parse(msg);
		this.isLoading = false;
		this.errorShowed = true;
		if (response.data.payload.Syntilio__TargetUserId__c !== this.userId) {
			return;
		}
		switch (parsedMsg.type) {
			case "SUCCESS":
				this.getClientsData();
				break;
			case "ERROR":
				this.notifyUser("Error", parsedMsg?.message, "error");
				break;
			case "INFO":
				this.notifyUser("Info", parsedMsg?.message, "info");
				this.getClientsData();
				break;
			case "WARNING":
				this.notifyUser("Warning", parsedMsg?.message, "warning");
				this.getClientsData();
				break;
			default:
				break;
		}
	};

	initializecometd() {
		try {
			var cometdlib;
			if (this.libInitialized) {
				return;
			}

			this.libInitialized = true;

			cometdlib = new window.org.cometd.CometD();

			cometdlib.configure({
				url:
					window.location.protocol + "//" + window.location.hostname + "/cometd/47.0/",
				requestHeaders: { Authorization: "OAuth " + this.sessionId },
				appendMessageTypeToURL: false,
				logLevel: "debug"
			});

			cometdlib.websocketEnabled = false;

			const receiveCometdResponse = (response) => {
				this.receiveProgress(response);
			};

			cometdlib.handshake(function (status) {
				if (status.successful) {
					cometdlib.subscribe(
						"/event/Syntilio__Notification__e",
						(response) => {
							receiveCometdResponse(response);
						},
						function (error) {}
					);
				} else {
					logExceptionAsString({
						exceptionType: "Custom Error",
						exceptionMessage: `Error in handshaking: + ${JSON.stringify(status)}`,
						stackTrace: "",
						lineNumber: 0,
						methodName: "cometdlib.handshake",
						className: this.lwcName,
						nameSpace: "Syntilio",
						source: this.exceptionTypes.LWC
					});
				}
			});
		} catch (error) {
			this.logException(error, "initializecometd");
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

	async checkCurrentRecordType() {
		try {
			let result = await getSobjectFromId({ sObjectId: this.recordId });
			this.isAccountRecord = result === "Account" ? true : false;
		} catch (error) {
			this.logException(error, "checkCurrentRecordType");
			this.errorShowed = true;
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.checkCurrentRecordType();
		const recordPageType = this.checkRecordPageType();
		if (recordPageType === "Account") {
			this.handleSubscribe();
		}
	}
}
