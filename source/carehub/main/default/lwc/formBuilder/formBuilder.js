import { api, track } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import FormBuilderResource from "@salesforce/resourceUrl/FormBuilder";
import ReactResource from "@salesforce/resourceUrl/React";
import ReactDOMResource from "@salesforce/resourceUrl/ReactDOM";
import SurveyCoreResource from "@salesforce/resourceUrl/SurveyCore";
import SurveyCoreCSSResource from "@salesforce/resourceUrl/SurveyCoreCSS";
import SurveyReactUIResource from "@salesforce/resourceUrl/SurveyReactUI";
import SurveyCreatorCoreResource from "@salesforce/resourceUrl/SurveyCreatorCore";
import SurveyCreatorCoreCSSResource from "@salesforce/resourceUrl/SurveyCreatorCoreCSS";
import SurveyCreatorReactResource from "@salesforce/resourceUrl/SurveyCreatorReact";
import QuillResource from "@salesforce/resourceUrl/QuillJS";
import QuillCSSResource from "@salesforce/resourceUrl/QuillCSS";
import handleGetForm from "@salesforce/apex/FormBuilderHandler.handleGetForm";
import handlePostForm from "@salesforce/apex/FormBuilderHandler.handlePostForm";
import UtilityLWC from "c/utils";

export default class FormBuilder extends UtilityLWC {
	constructor() {
		super("formBuilder");
	}

	@api recordId;
	@track creatorJSON;
	@track reusableQuestions;
	@track loading = false;
	initialized = false;

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
			let response = await handleGetForm({ protocolId: this.recordId });
			let responseParsed = JSON.parse(response);
			if (!responseParsed.isSuccess) {
				throw new Error(responseParsed.message);
			}
			let parsedData = JSON.parse(responseParsed.data);
			this.creatorJSON = parsedData.creatorJSON;
			this.reusableQuestions = parsedData.reusableQuestions.map((question) => {
				const choices = question.Syntilio__Choices__c
					? JSON.parse(question.Syntilio__Choices__c.replace(/\\/g, ""))
					: [];
				return {
					id: question.Name,
					title: question.Syntilio__Title__c
						? question.Syntilio__Title__c
						: question.Name,
					name: question.Name,
					type: question.Syntilio__QuestionType__c,
					json: {
						id: question.Name,
						title: question.Syntilio__Title__c
							? question.Syntilio__Title__c
							: question.Name,
						name: question.Name,
						type: question.Syntilio__QuestionType__c,
						choices: choices
					}
				};
			});
			this.loadFormBuilder();
		} catch (error) {
			this.logException(error, "getDataAndRender");
			this.notifyUser("", "Error loading Form Builder", this.toastTypes.Error);
		} finally {
			this.loading = false;
		}
	}

	async loadFormBuilder() {
		try {
			await Promise.all([
				loadScript(this, ReactResource),
				loadScript(this, ReactDOMResource)
			]);
			await Promise.all([
				loadScript(this, SurveyCoreResource),
				loadStyle(this, SurveyCoreCSSResource)
			]);
			await loadScript(this, SurveyReactUIResource);
			await Promise.all([
				loadScript(this, SurveyCreatorCoreResource),
				loadStyle(this, SurveyCreatorCoreCSSResource)
			]);
			await loadScript(this, SurveyCreatorReactResource);
			await Promise.all([
				loadScript(this, QuillResource),
				loadStyle(this, QuillCSSResource)
			]);
			
			await loadScript(this, FormBuilderResource);
			this.initializeFormBuilder();
		} catch (error) {
			this.logException(error, "loadFormBuilder");
			this.notifyUser("", "Error loading Form Builder ", this.toastTypes.Error);
		} finally {
			this.loading = false;
		}
	}

	async handleSave(data) {
		try {
			this.notifyUser("", "Saving...", this.toastTypes.Info);
			let response = await handlePostForm({
				body: JSON.stringify(data),
				protocolId: this.recordId
			});
			let responseParsed = JSON.parse(response);
			if (!responseParsed.isSuccess) {
				throw new Error(responseParsed.message);
			}
			this.notifyUser("", "Saved Successfully", this.toastTypes.Success);
		} catch (error) {
			this.logException(error, "handleSave");
			this.notifyUser("", "Failed to save Form", this.toastTypes.Error);
		}
	}

	initializeFormBuilder() {
		try {
			const ctx = this.template.querySelector(".form-builder");
			if (ctx) {
				new window.FormBuilder({
					element: ctx,
					json: this.creatorJSON ?? {},
					reusableQuestions: this.reusableQuestions,
					showNotification: (type, message) => this.notifyUser("", message, type),
					onSave: (data) => this.handleSave(data)
				});
			}
		} catch (error) {
			this.logException(error, "initializeFormBuilder");
			this.notifyUser("", "Failed to load Form Builder", this.toastTypes.Error);
		}
	}
}
