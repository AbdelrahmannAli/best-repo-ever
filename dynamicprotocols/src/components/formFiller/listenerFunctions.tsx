/* 
	This file is a helper file that includes all the functions needed to be attached to the listeners
	provided by SurveyJS
*/
import { NotificationType } from "@/lib/utils/notificationsHandler";
import { Model } from "survey-core";
import { renderToString } from "react-dom/server";
import SurveySummary from "../surveySummary/surveySummary";
import "./formFiller.css";
export const isActionsPage = (pageName) => {
	return pageName?.toLowerCase().includes("action");
};

/*
	Executes every time a new page is rendered.
	Documentation: 
	https://surveyjs.io/form-library/documentation/api-reference/survey-data-model#onAfterRenderPage
*/
export const surveyOnAfterRenderPageFn = (
	sender: Model,
	options: any,
	showNotification: (type: string, message: string) => void,
	getLabel: (key: string) => string
) => {
	options.htmlElement.scrollTo({ top: 0, behavior: "smooth" });

	/*
		The summary/preview page is the only page that does not have jsonObj inside it,
		and we need to overwrite the summary/preview page only
	*/
	if (options.page?.jsonObj) {
		return;
	}
	// Hide all components displayed by SurveyJS because we need to use our own display
	for (let child of options.htmlElement.children) {
		child.style.display = "none";
	}

	// Render the custom Summary page
	options.htmlElement.insertAdjacentHTML(
		"beforeend",
		renderToString(<SurveySummary survey={sender} getLabel={getLabel} />)
	);
	const handleClick = (e) => {
		e.preventDefault();
		/*
			This case is specific for SVG, because we need to handle the click of the edit pen,
			the source of the event emitted can be any part of the SVG. So we need to get the closest
			parent with className "action" which is the actual button or the icon itself
		*/
		let closest = e.target.closest(".action");
		let className = e.target.className || e.target.class;
		let id = e.target.id;
		if (closest) {
			className = closest.className || closest.class;
			id = closest.id;
		}
		// Handle differently based on the className of the event source
		if (className?.includes("edit-pen")) {
			handleEditClick(id);
		} else if (className?.includes("copy-btn")) {
			handleCopyClick();
		}
	};

	const handleEditClick = (id) => {
		// Manually go back to the page with the specific name
		sender.cancelPreview();
		while (sender.currentPage.name != id) {
			sender.prevPage();
		}
		sender.edit = true;
		options.htmlElement.removeEventListener("click", handleClick);
		(options.htmlElement as Element).parentElement
			.querySelector(".summaryDiv")
			.remove();
	};

	const handleCopyClick = () => {
		// Copy the page content to the clipboard
		let stringToCopy = "";
		let pages = {};
		for (let questionName of Object.keys(sender.data)) {
			let question = sender.getQuestionByName(questionName, true);
			let panel = question.parent;
			let page = sender.getPanelByName(panel.name);
			if (!pages.hasOwnProperty(page.name)) {
				pages[page.name] = {
					title: page.title,
					name: page.name,
					elements: []
				};
			}
			pages[page.name].elements.push({
				name: question.name,
				title: question.title,
				value: question.getDisplayValue(sender.data[questionName])
			});
		}

		for (let pageName of Object.keys(pages)) {
			if (pages[pageName]?.title) {
				stringToCopy += pages[pageName]?.title + "\n";
			}
			let questions = pages[pageName].elements;
			for (let question of questions) {
				stringToCopy += (question.title || question.name) + "   ";
				stringToCopy += question.value;
				stringToCopy += "\n";
			}
			stringToCopy += "\n";
		}

		navigator.clipboard.writeText(stringToCopy.trim()).then(() => {
			showNotification(NotificationType.INFO, getLabel("Copied to Clipboard"));
		});
	};
	// Since we are playing with the HTML, we need to attach event listeners manually as well
	options.htmlElement.addEventListener("click", handleClick);
};

/*
	Executes every time a new question is rendered.
	Documentation: 
	https://surveyjs.io/form-library/documentation/api-reference/survey-data-model#onAfterRenderQuestion
*/
export const surveyOnAfterRenderQuestionFn = (
	sender: Model,
	options: any,
	startFlow: (apiName: string) => void
) => {
	let page = options.question.parent;

	let questionName = options.question.name;
	let questionNameNoSpace = questionName.replace(/\s/g, "");

	// We only need to overwrite the questions in the action pages
	if (!isActionsPage(page.name)) {
		return;
	}
	const questionContent = options.htmlElement.querySelectorAll(
		".sd-question__content"
	);

	// Hide the content displayed by SurveyJS
	questionContent.forEach((content) => {
		content.style.display = "none";
	});
	const questionTitles = options.htmlElement.querySelectorAll(
		".sd-question__title .sv-string-viewer"
	);

	// Replace the SurveyJS rendered component with a checkbox followed by the action question title
	questionTitles.forEach((questionTitle: HTMLElement) => {
		if (!sender.getQuestionByName(options.question.name)) {
			return;
		}
		if (!sender.data[questionName]) {
			options.question.value = false;
		}

		questionTitle.parentElement.style.display = "flex";
		questionTitle.parentElement.style.alignItems = "center";
		questionTitle.insertAdjacentHTML(
			"beforebegin",
			renderToString(
				<span className="checkboxWrapper">
					<input
						id={questionName}
						type="checkbox"
						className={questionNameNoSpace}
						disabled={
							options.question?.jsonObj.type == "flow" &&
							options.question?.value
						}
						defaultChecked={options.question?.value}
					></input>
				</span>
			)
		);
	});

	const handleCheck = (e) => {
		// Manually set the question value to the checked value
		options.question.value = e.target.checked;
		// If the question is of type "flow", run the flow using the function sent from Salesforce
		if (options.question.jsonObj.type == "flow" && e.target.checked) {
			e.target.disabled = true;
			startFlow(options.question.jsonObj.name);
		}
	};
	options.htmlElement.addEventListener("change", handleCheck);
};
