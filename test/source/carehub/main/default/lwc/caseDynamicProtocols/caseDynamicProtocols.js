import { api, track, wire } from "lwc";
import getProtocols from "@salesforce/apex/CaseProtocolHandler.getProtocols";
import UtilityLWC from "c/utils";
import { subscribe } from "lightning/empApi";
import getUserId from "@salesforce/apex/CareHubUtilities.getUserId";
import { getRecord } from "lightning/uiRecordApi";
import general_Protocols from "@salesforce/label/c.general_Protocols";
import general_EstimatedTime from "@salesforce/label/c.general_EstimatedTime";
import general_Minutes from "@salesforce/label/c.general_Minutes";
import general_Finished from "@salesforce/label/c.general_Finished";
import general_Required from "@salesforce/label/c.general_Required";
import general_ActionsInProgress from "@salesforce/label/c.general_ActionsInProgress";
import general_Start from "@salesforce/label/c.general_Start";
import general_Review from "@salesforce/label/c.general_Review";
import general_Actions from "@salesforce/label/c.general_Actions";
import checkFlowApiName from "@salesforce/apex/CaseProtocolHandler.checkFlowApiName";
import handleGetActions from "@salesforce/apex/FormFillerHandler.handleGetActions";
export default class CaseDynamicProtocols extends UtilityLWC {
	constructor() {
		super("caseDynamicProtocols");
	}
	@api recordId;
	@track showProtocols = false;
	@track showSurvey = false;
	@track showFlow = false;
	@track surveyView = null;
	@track protocols = [];
	@track selectedProtocol = null;
	@track channelName = "/event/Syntilio__ProtocolEvent__e";
	@track userId;
	@track contactId;
	@track flowApiName;
	@track inputVariables;
	@track surveyEnded = false;

	labels = {
		general_Protocols,
		general_EstimatedTime,
		general_Minutes,
		general_Finished,
		general_Required,
		general_ActionsInProgress,
		general_Start,
		general_Review,
		general_Actions
	};

	@api
	endSurvey = () => {
		this.getProtocolsHandler();
	};

	@wire(getRecord, { recordId: "$recordId", fields: ["Case.ContactId"] })
	recordUpdated({ data }) {
		this.surveyEnded = false;
		if (!this.recordId || !data) {
			return;
		}
		if (data.apiName !== "Case") {
			this.getProtocolsHandler();
			return;
		}
		let contactId = data.fields.ContactId;
		if (this.contactId !== contactId) {
			this.getProtocolsHandler();
		}
	}

	connectedCallback() {
		super.connectedCallback();
		this.handleSubscribe();
	}

	async checkFlowApiNameHandler() {
		try {
			let data = await checkFlowApiName({
				flowApiName: this.flowApiName
			});
			if (!data) {
				this.showSurvey = true;
			} else {
				this.handleFlowOpener();
			}
		} catch (error) {
			this.logException(error, "checkFlowApiNameHandler");
		}
	}
	async getProtocolsHandler() {
		try {
			let data = await getProtocols({
				caseId: this.recordId
			});
			if (!data) return;
			const returnedProtocols = data;
			this.handleReturnedProtocols(returnedProtocols);
		} catch (error) {
			this.logException(error, "getProtocolsHandler");
		}
	}

	protocolStatusAndButtons(protocol, status) {
		switch (status) {
			case "finished":
				protocol = {
					...protocol,
					finished: true,
					required: false,
					actions: false
				};
				break;
			case "required":
				protocol = {
					...protocol,
					finished: false,
					required: true,
					actions: false
				};
				break;
			case "actions":
				protocol = {
					...protocol,
					finished: false,
					required: false,
					actions: true
				};
				break;
			default:
				break;
		}
		
		return { ...protocol, actionsBrand: protocol.actions ? "brand" : "neutral" };
	}

	async handleReturnedProtocols(returnedProtocols) {
		this.protocols = await Promise.all(returnedProtocols.map(async (protocol) => {
			const image = protocol.Syntilio__Image__c;
			const parser = new DOMParser();
			const doc = parser.parseFromString(image, "text/html");
			const imgElement = doc.querySelector("img");
			let srcValue;
			let showActionButton = await handleGetActions({
				protocolId: protocol.Id			
			});

			if (imgElement) {
				srcValue = imgElement.getAttribute("src");
			}
			
			let protocolToReturn = {
				label: protocol.Name,
				value: protocol.Id,
				Description: protocol.Syntilio__Description__c,
				Image: srcValue,
				Time: protocol.Syntilio__EstimatedTime__c,
				FlowApiName: protocol.Syntilio__Flow__c,
				showActionButton: showActionButton
			};
			return this.protocolStatusAndButtons(protocolToReturn, protocol.status);
		}));
		this.showSurvey = false;
		this.showProtocols = true;

		if (this.protocols.length === 1 && !this.surveyEnded && !this.protocols[0].finished) {
			const singleProtocol = this.protocols[0];
			const mockEvent = {
				target: {
					dataset: {
						id: singleProtocol.value
					},
					label: singleProtocol.label 
				}
			};
			this.surveyEnded = true;
			this.handleProtocolSelected(mockEvent);
		}
	}
	handleProtocolSelected(event) {
		this.selectedProtocol = event.target.dataset.id;
		this.surveyView = event.target.label.toLowerCase();
		this.showProtocols = false;

		const selectedProtocolObject = this.protocols.find(
			(protocol) => protocol.value === this.selectedProtocol
		);
		if (selectedProtocolObject) {
			this.flowApiName = selectedProtocolObject.FlowApiName;
		}

		if (this.flowApiName && this.surveyView == "start") {
			this.checkFlowApiNameHandler();
		} else {
			this.showSurvey = true;
		}
	}

	handleFlowOpener() {
		if (this.flowApiName == "Shared_Device_Contact_Group"){
		this.inputVariables = [
			{ 
				name: 'recordIdInput',
				type: 'String',
				value: this.recordId
			}
		]
	}
		this.showFlow = true;
	}
	handleFlowStatusChange(event) {
		const flowStatus = event.detail.status;
		if (flowStatus.toLowerCase() === "finished") {
			this.handleFlowEnd();
		}
	}

	handleFlowEnd() {
		this.showFlow = false;
		this.showSurvey = true;
		this.flowApiName = null;
	}

	handleEvent(event) {
		if (!event) return;
		if (
			this.selectedProtocol &&
			event.data.payload.Syntilio__Message__c ===
				`${this.selectedProtocol} ${this.recordId}` &&
			event.data.payload.Syntilio__TargetUserId__c === this.userId
		) {
			this.getProtocolsHandler();
		}
	}

	async handleSubscribe() {
		try {
			await subscribe(this.channelName, -1, (response) =>
				this.receiveProgress(response)
			);
			const userId = await getUserId();
			this.userId = userId;
		} catch (error) {
			this.logException(error, "handleSubscribe");
		}
	}
}
