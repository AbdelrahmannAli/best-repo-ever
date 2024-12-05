// Check SurveyJS documentation here: https://surveyjs.io/form-library/documentation/overview
import React, { Component } from "react";
import ReactDOM from "react-dom/client";
import "./formFiller.css";
import { SyntilioTheme } from "@/lib/utils/themes.js";
import { Survey } from "survey-react-ui";
import { Model, ComponentCollection } from "survey-core";
import { NotificationType } from "@/lib/utils/notificationsHandler";
import {
	surveyOnAfterRenderPageFn,
	surveyOnAfterRenderQuestionFn
} from "./listenerFunctions";

/*
	Here we use ComponentCollection to add our custom types. We first use .remove() because
	when the 2 components are built at the same time in a Salesforce org, ComponentCollection
	detects that the types already exist from the other component, so we make sure to remove
	them here and then add again.
	Check documentation here:
	https://surveyjs.io/form-library/documentation/customize-question-types/create-specialized-question-types
*/
ComponentCollection.Instance.remove("action");
ComponentCollection.Instance.add({
	name: "action",
	title: "Action",
	questionJSON: {
		type: "boolean",
		defaultValue: false
	},
	inheritBaseProps: true
});
ComponentCollection.Instance.remove("flow");
ComponentCollection.Instance.add({
	name: "flow",
	title: "Flow (Make sure the question name is a valid flow API Name)",
	iconName: "icon-action",
	questionJSON: {
		type: "boolean",
		defaultValue: false
	},
	inheritBaseProps: true
});

interface FormFillerProps {
	element: Element;
	json: any;
	labels: string;
	view: string;
	reusableQuestions: any;
	showNotification: (type: string, message: string) => void;
	onSubmit: (json: any) => Promise<boolean>;
	goToActions?: (data: any) => void;
	endSurvey: () => void;
	startFlow: (apiName: string) => void;
}

interface FormFillerState {
	surveyRefresh: any;
	survey: Model;
}

class FormFillerComponent extends Component<FormFillerProps, FormFillerState> {
	element: Element;
	json: string;
	view: string;
	showNotification: (message: string, type: string) => void;
	onSubmit: (json: any) => Promise<boolean>;
	goToActions?: (data: any) => void;
	endSurvey: () => void;
	startFlow: (apiName: string) => void;
	labels: any;

	constructor(props: FormFillerProps) {
		super(props);
		this.element = props.element;
		this.showNotification = props.showNotification;
		this.onSubmit = props.onSubmit;
		this.json = props.json;
		this.view = props.view;
		this.goToActions = props.goToActions;
		this.endSurvey = props.endSurvey;
		this.startFlow = props.startFlow;
		this.labels = props.labels ? JSON.parse(props.labels) : {};
		let survey = this.setupSurvey();
		this.state = {
			surveyRefresh: undefined,
			survey: survey
		};
		this.mountComponent();
	}

	getLabel = (key: string) => {
		return (this.labels && this.labels[key]) || key;
	};

	mountComponent() {
		/*
			This is the part where we use the HTML element we received 
			in the props to render the FormFiller inside
		*/
		if (this.element) {
			const root = ReactDOM.createRoot(this.element);
			root.render(this.renderComponent());
		}
	}

	setupSurvey = () => {
		const jsonParsed = JSON.parse(this.json);
		const surveyJSON = jsonParsed.survey;
		const resultsJSON = jsonParsed.results;

		/* 
			Filter the pages to be displayed based on the view requested from Salesforce, 
			if view is "actions" show only the action page, otherwise show all pages 
			except for the actions page
		*/
		surveyJSON.pages = surveyJSON.pages.filter((page) => {
			let isActions = this.isActionsPage(page.name);
			return (this.view == "actions" || this.view === "acties") ? isActions : !isActions;
		});
		if (resultsJSON) {
			/* 
				If there are results for this survey (meaning that the answers were submitted before),
				make the pages read-only if the view is not "actions", if it's "actions" then we
				need it to be editable because the Centralist can do the actions at any time
			*/
			if (this.view != "actions" && this.view !== "acties") {
				surveyJSON.pages?.forEach((page) => {
					page.readOnly = false;
				});
			}
			// Make sure the answers are parsed correctly to be correctly displayed by SurveyJS
			for (var questionName in resultsJSON) {
				try {
					resultsJSON[questionName] = JSON.parse(resultsJSON[questionName]);
				} catch (e) {
					resultsJSON[questionName] = resultsJSON[questionName];
				}
			}
		}

		// Initialize the Survey object
		let surveyModel = new Model(surveyJSON);
		/*
			Since we are manually changing the pages to be displayed, we need to make sure
			that the answers we set for SurveyJS do not include questions that we are not displaying
			so we filter the results to only include the results that are related to questions
			that are visible
		*/
		let questions = this.getAllQuestions(surveyJSON.pages);
		surveyModel.data =
			(this.view == "actions" || this.view === "acties") || !resultsJSON
				? resultsJSON
				: this.filterResults(questions, resultsJSON);

		// Change the complete text based on the view
		surveyModel.completeText =
			(this.view == "review" || this.view === "bekijken")
				? this.getLabel("Done")
				: (this.view == "actions" || this.view === "acties")
				? this.getLabel("Finish")
				: this.getLabel("Next");

		if (this.view == "review" || this.view === "bekijken") {
			surveyModel.showPreview();
		}
		this.setupSurveyModel(surveyModel);
		// End survey if there is nothing to display
		if (!surveyModel.currentPage) {
			this.endSurvey();
		}
		return surveyModel;
	};

	renderComponent = () => {
		/*
			The div wrapper is used to set CSS Class that is used to overwrite some of the
			CSS defined by the library to make it look the way we want
		*/
		return (
			<div className="formStyle">
				<Survey model={this.state.survey} />
			</div>
		);
	};

	componentDidUpdate(prevProps: FormFillerProps, prevState: FormFillerState) {
		if (this.view !== prevProps.view) {
			let survey = this.setupSurvey();
			this.setState({ survey: survey });
		}
	}

	isActionsPage(pageName) {
		return pageName?.toLowerCase().includes("action");
	}

	submitFormFailureCallback = (e) => {
		this.showNotification(
			NotificationType.ERROR,
			this.getLabel("Failed to submit form")
		);
		this.setState({ surveyRefresh: new Date() });
	};

	surveyOnComplete = (sender: Model) => {
		if ((this.view == "review" || this.view === "bekijken") && !sender.edit) {
			this.endSurvey();
			return;
		}

		this.onSubmit(sender.data)
			.then((success) => {
				if (!success) {
					this.state.survey.clear(false, false);
					return;
				}
				const actionsSubmitted = sender
					.toJSON()
					.pages.filter((page) => this.isActionsPage(page.name));

				// End the survey if the submitted answers were for an action page
				if (actionsSubmitted && actionsSubmitted.length > 0) {
					this.endSurvey();
					return;
				}
				// Go to the actions page if answers were for the normal questions in the survey
				const jsonParsed = JSON.parse(this.json);
				const containsAction = jsonParsed.survey.pages.some(page => page.name.toLowerCase().includes('action'));
				if (!containsAction){
					this.endSurvey();
					return;
				}
				this.goToActions && this.goToActions(sender.data);
			})
			.catch((error) => {
				this.showNotification(NotificationType.ERROR, error.message);
				this.state.survey.clear(false, false);
			});
	};

	surveyOnProgressText = (_, options: any) => {
		// Manually overwrite the progress text to enable translation
		let text = this.getLabel("Answered {questions} questions");
		options.text = text.replace(
			"{questions}",
			`${options.answeredQuestionCount}/${options.questionCount}`
		);
	};

	setupSurveyModel(surveyModel: Model) {
		/* 
			This is where we set up the Survey metadata:
			1. Apply the Syntilio Theme with the purple colors and all that
			2. Attach our functions to the survey listeners
		*/
		surveyModel.showCompletedPage = false;
		surveyModel.applyTheme(SyntilioTheme);
		surveyModel.onComplete.add((sender) => this.surveyOnComplete(sender));
		surveyModel.onAfterRenderPage.add((sender, options) => {
			surveyOnAfterRenderPageFn(
				sender,
				options,
				this.showNotification,
				this.getLabel
			);
		});
		surveyModel.onAfterRenderQuestion.add((sender, options) =>
			surveyOnAfterRenderQuestionFn(sender, options, this.startFlow)
		);
		surveyModel.onProgressText.add((sender, options) =>
			this.surveyOnProgressText(sender, options)
		);

		const jsonParsed = JSON.parse(this.json);
		const surveyJSON = jsonParsed.survey;

		let totalRequiredQuestions = 0;

		surveyJSON.pages.forEach(page => {
		if (!page.name.toLowerCase().includes('action')) {
			const requiredQuestions = page.elements.filter(element => element.isRequired).length;
			totalRequiredQuestions += requiredQuestions; 
		}
		});


		// We only need to show the "Preview" page when we're not in the "actions" view
		surveyModel.showPreviewBeforeComplete =
			(this.view == "actions" || this.view === "acties" || totalRequiredQuestions <3) ? "none" : "showAnsweredQuestions";

		if (this.view == "actions" || this.view === "acties") {
			surveyModel.showProgressBar = "off";
		}
		// Overwrite the navigation texts with the translated texts
		surveyModel.previewText = this.getLabel("Next");
		surveyModel.pageNextText = this.getLabel("Next");
		surveyModel.pagePrevText = this.getLabel("Previous");
	}

	// Gets all the questions in the survey
	getAllQuestions(pages) {
		let questions = [];
		pages.forEach((page) => {
			questions = questions.concat(page.elements.map((element) => element.name));
		});
		return questions;
	}

	// Filters the results to only include the results for the questions inside the survey
	filterResults(questions, results) {
		let filteredResults = {};
		questions.forEach((question) => {
			filteredResults[question] = results[question];
		});
		return filteredResults;
	}
}

export default FormFillerComponent;
