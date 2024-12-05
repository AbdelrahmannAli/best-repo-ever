import { api, track } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import FormFillerResource from "@salesforce/resourceUrl/FormFiller";
import ReactResource from "@salesforce/resourceUrl/React";
import ReactDOMResource from "@salesforce/resourceUrl/ReactDOM";
import ReactDOMServerResource from "@salesforce/resourceUrl/ReactDOMServer";
import SurveyCoreResource from "@salesforce/resourceUrl/SurveyCore";
import SurveyCoreCSSResource from "@salesforce/resourceUrl/SurveyCoreCSS";
import SurveyReactUIResource from "@salesforce/resourceUrl/SurveyReactUI";
import handleGetForm from "@salesforce/apex/FormFillerHandler.handleGetForm";
import handlePostForm from "@salesforce/apex/FormFillerHandler.handlePostForm";
import general_Next from "@salesforce/label/c.general_Next";
import general_Previous from "@salesforce/label/c.general_Previous";
import general_Done from "@salesforce/label/c.general_Done";
import general_Finish from "@salesforce/label/c.general_Finish";
import general_Copy from "@salesforce/label/c.general_Copy";
import general_Review from "@salesforce/label/c.general_Review";
import general_CopiedToClipboard from "@salesforce/label/c.general_CopiedToClipboard";
import dynamicProtocols_FailedToSubmitForm from "@salesforce/label/c.dynamicProtocols_FailedToSubmitForm";
import dynamicProtocols_AnsweredQuestions from "@salesforce/label/c.dynamicProtocols_AnsweredQuestions";
import UtilityLWC from "c/utils";

export default class FormFiller extends UtilityLWC {
	constructor() {
		super("formFiller");
	}

	@api surveyView;
	@api protocolId;
	@api caseId;
	@api endSurvey;
	@api startFlow;
	@track endModalOpen = false;
	@track flowApiName;
	@track surveyJSON;
	@track reusableQuestions;
	@track loading = false;
	@track inputVariables;

	initialized = false;

	labels = {
		Next: general_Next,
		Previous: general_Previous,
		Done: general_Done,
		Finish: general_Finish,
		Copy: general_Copy,
		Review: general_Review,
		"Copied to Clipboard": general_CopiedToClipboard,
		"Failed to submit form": dynamicProtocols_FailedToSubmitForm,
		"Answered {ansQuestion} from {allQuestions} questions": dynamicProtocols_AnsweredQuestions
	};

	handleModalOpenFlow = () => {

		if (this.flowApiName == "Shared_Device_Contact_Group"){
			this.inputVariables = [
				{ 
					name: 'recordIdInput',
					type: 'String',
					value: this.caseId
				}
			]
		}
		this.endModalOpen = true;
	};

	handleModalClose() {
		this.endModalOpen = false;
	}
	handleFlowStatusChange(event) {
		const flowStatus = event.detail.status;
		if (flowStatus.toLowerCase() === "finished") {
			this.handleModalClose();
		}
	}

	renderedCallback() {
		if (this.initialized) {
			return;
		}
		this.initialized = true;
		this.getDataAndRender();
	}

	async getDataAndRender() {
		try {
			this.loading = true;
			let response = await handleGetForm({
				protocolId: this.protocolId,
				caseId: this.caseId
			});
			let responseParsed = JSON.parse(response);
			if (!responseParsed.isSuccess) {
				throw new Error(responseParsed.message);
			}
			this.surveyJSON = responseParsed.data;
			this.loadFormFiller();
		} catch (error) {
			this.logException(error, "getDataAndRender");
			this.notifyUser("", "Error loading Form Filler please refresh the page and try again", this.toastTypes.Error);
		} finally {
			this.loading = false;
		}
	}

	async loadFormFiller() {
		try {
			await Promise.all([
				loadScript(this, ReactResource),
				loadScript(this, ReactDOMResource),
				loadScript(this, ReactDOMServerResource)
			]);
			await Promise.all([
				loadScript(this, SurveyCoreResource),
				loadStyle(this, SurveyCoreCSSResource)
			]);
			await loadScript(this, SurveyReactUIResource);
			await loadScript(this, FormFillerResource);
			this.initializeFormFiller();
		} catch (error) {
			this.logException(error, "loadFormFiller");
			this.notifyUser("", "Error loading Form Filler please refresh the page and try again", this.toastTypes.Error);
		} finally {
			this.loading = false;
		}
	}

	async handleSubmit(data) {
		try {
			let response = await handlePostForm({
				body: JSON.stringify(data),
				protocolId: this.protocolId,
				caseId: this.caseId
			});
			let responseParsed = JSON.parse(response);
			if (!responseParsed.isSuccess) {
				throw new Error(responseParsed.message);
			}
			return true;
		} catch (error) {
			this.logException(error, "handleSubmit");
			this.notifyUser("", "Failed to load Form Filler", this.toastTypes.Error);
			return false;
		}
	}

	initializeFormFiller() {
		try {
			const ctx = this.template.querySelector(".form-filler");
			if (ctx) {
				const props = {
					element: ctx,
					showNotification: (type, message) => this.notifyUser("", message, type),
					onSubmit: async (data) => {
						let output = await this.handleSubmit(data);
						return output;
					},
					endSurvey: () => {
						this.endSurvey();
					},
					startFlow: (apiName) => {
						this.flowApiName = apiName;
						this.handleModalOpenFlow();
					},
					view: this.surveyView,
					json: this.surveyJSON,
					labels: JSON.stringify(this.labels)
				};

				// eslint-disable-next-line no-new
				new window.FormFiller({
					...props,
					goToActions: (data) => {
						ctx.removeChild(ctx.lastElementChild);
						// eslint-disable-next-line no-new
						new window.FormFiller({
							...props,
							view: "actions",
							json: JSON.stringify({
								...JSON.parse(this.surveyJSON),
								results: data
							})
						});
					}
				});
			}
		} catch (error) {
			this.logException(error, "initializeFormFiller");
			this.notifyUser("", "Error loading Form Filler please refresh the page and try again", this.toastTypes.Error);
		}
	}
}
