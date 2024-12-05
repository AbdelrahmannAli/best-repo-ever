// Check SurveyJS documentation here: https://surveyjs.io/survey-creator/documentation/overview
import React, { Component } from "react";
import ReactDOM from "react-dom/client";
import "./formBuilder.css";
import "../customQuestions/QuillEditor";
import { SurveyCreatorComponent, SurveyCreator } from "survey-creator-react";
import { ComponentCollection, SvgRegistry } from "survey-core";
import { NotificationType } from "@/lib/utils/notificationsHandler";
import { action } from "@/lib/assets/icons/action.js";

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
	iconName: "icon-action",
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

ComponentCollection.Instance.remove("rich-text-editor");
ComponentCollection.Instance.add({
	name: "rich-text-editor",
	title: "Rich Text Editor",
	iconName: "icon-action",
	questionJSON: {
		type: "quill-editor",
		defaultValue: "",
	},
	inheritBaseProps: true,
});

// Used to register a new icon to be available for use inside the Survey creator library
SvgRegistry.registerIconFromSvg("icon-action", action);

interface FormBuilderProps {
	element: Element;
	json: any;
	reusableQuestions: any;
	showNotification: (type: string, message: string) => void;
	onSave: (json: any) => void;
}

interface FormBuilderState {
	creatorJSON: any;
}

var creator: SurveyCreator;

class FormBuilderComponent extends Component<FormBuilderProps, FormBuilderState> {
	showNotification: (message: string, type: string) => void;
	json: any;
	onSave: (json: any) => void;
	reusableQuestions: any;

	constructor(props: FormBuilderProps) {
		super(props);
		this.showNotification = props.showNotification;
		this.onSave = props.onSave;
		this.json = props.json;
		this.reusableQuestions = props.reusableQuestions;
		this.state = {
			creatorJSON: {
				showQuestionNumbers: "off",
				showProgressBar: "belowheader",
				progressBarType: "questions",
				pages: [
					{
						elements: []
					}
				],
				...props.json
			}
		};

		/*
			Initialize the creator component and then set some metadata:
			1. Set the JSON to the JSON we received from the props, which is the defined metadata for this protocol.
			2. Add the reusable questions to the toolbox to be available for the user
			3. Attach this.handleQuestionAdded() to the listener onQuestionAdded
			4. Attach this.handleSaveSurvey() to the saveSurveyFunc property
		*/
		creator = new SurveyCreator({
			showLogicTab: true,
			isAutoSave: false
		});
		creator.JSON = this.state.creatorJSON;
		creator.toolboxLocation = "sidebar";
		creator.toolbox.addItems(this.reusableQuestions);
		creator.survey.onQuestionAdded.add(this.handleQuestionAdded);
		creator.saveSurveyFunc = this.handleSaveSurvey;

		/*
			This is the part where we use the HTML element we received 
			in the props to render the FormBuilder inside
		*/
		if (props.element) {
			const root = ReactDOM.createRoot(props.element);
			root.render(this.renderComponent());
		}
	}

	renderComponent = () => {
		/*
			The div wrapper is used to set CSS Class that is used to overwrite some of the
			CSS defined by the library to make it look the way we want
		*/
		return (
			<div className="surveyCreatorStyle">
				<SurveyCreatorComponent creator={creator} />
			</div>
		);
	};

	handleQuestionAdded = (_, options) => {
		// Make sure questions are not repeated within the survey
		let duplicateCount = 0;

		creator.survey.pages.forEach((page) => {
			page.questions.forEach((q) => {
				if (q.title === options.question.title) {
					duplicateCount++;
				}
			});
		});

		if (duplicateCount > 1) {
			this.showNotification(
				NotificationType.ERROR,
				"This question is already present in the survey"
			);
			options.question.delete();
		} else {
			options.question.name = options.question.title;
		}
	};

	handleSaveSurvey = async () => {
		// Make sure the data is valid then call the callback function passed from Salesforce
		if (!(creator.JSON.pages?.length > 0)) {
			this.showNotification(
				NotificationType.ERROR,
				"You must have at least 1 page"
			);
			return;
		}
		this.onSave(creator.JSON);
	};
}

export default FormBuilderComponent;
