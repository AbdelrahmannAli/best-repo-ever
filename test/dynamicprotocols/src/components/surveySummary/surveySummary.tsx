import React, { Component } from "react";
import PromptEdit from "@/lib/assets/icons/prompt_edit.js";
import EditPen from "@/lib/assets/icons/edit_pen.js";
import "./surveySummary.css";
import "../formFiller/formFiller.css";
import { Model } from "survey-core";

interface SurveySummaryProps {
	survey: Model;
	getLabel: (key: string) => string;
}

// This is the custom page we replace the SurveyJS preview page with
class SurveySummary extends Component<SurveySummaryProps> {
	pages: any;
	getLabel: (key: string) => string;

	constructor(props) {
		super(props);
		this.pages = this.calculatePages(props.survey);
		this.getLabel = props.getLabel;
	}

	calculatePages = (survey) => {
		// Formulate a JSON containing the info to be displayed inside the page
		let memoPages = {};
		for (let questionName of Object.keys(survey.data)) {
			let question = survey.getQuestionByName(questionName, true);
			let panel = survey.getQuestionByName(questionName, true).parent;
			let page = survey.getPanelByName(panel.name);
			if (!memoPages.hasOwnProperty(page.name)) {
				memoPages[page.name] = {
					title: page.title,
					name: page.name,
					elements: []
				};
			}
			memoPages[page.name].elements.push({
				name: question.name,
				title: question.title,
				value: question.getDisplayValue(survey.data[questionName])
			});
		}
		return memoPages;
	};

	render() {
		const { pages } = this;

		return (
			<div id="survey-review" className="summaryDiv">
				<h3
					className="sd-title summaryTitle"
					aria-label={this.getLabel("Review")}
				>
					<div className="titleDiv">
						<PromptEdit />
						<span className="titleSpan">{this.getLabel("Review")}</span>
					</div>
					<div className="sv-action">
						<div className="sv-action__content">
							<input
								className="copy-btn sd-btn sd-navigation__preview-btn copyButton"
								type="button"
								title={this.getLabel("Copy")}
								value={this.getLabel("Copy")}
							></input>
						</div>
					</div>
				</h3>
				{Object.values(pages).map((page: any) => (
					<div key={page.name} className="pageItemStyle">
						{page.title && (
							<table>
								<tbody>
									<tr>
										<td className="tableTitleColumn">
											{page.title && (
												<h4
													className="sd-title h4Margins"
													aria-label={page.title}
												>
													<span className="sv-string-viewer sv-string-viewer--multiline">
														{page.title}
													</span>
												</h4>
											)}
										</td>
									</tr>
								</tbody>
							</table>
						)}
						<table>
							<tbody>
								{page.elements.map((question) => (
									<>
										<tr key={question.name}>
											<td className="tableTitleColumn">
												<h5 className="sd-title sd-element__title sd-question__title sd-question__title--answer">
													<div className="sv-title-actions">
														<span className="sv-title-actions__title">
															<span className="sv-string-viewer sv-string-viewer--multiline">
																{question.title ||
																	question.name}
															</span>
														</span>
													</div>
												</h5>
											</td>
										</tr>
										<tr>
											<td>
												<h5
													className="sd-title sd-element__title sd-question__title sd-question__title--answer"
													style={{
														fontWeight: 500,
														display: "flex",
														flexDirection: "row",
														alignItems: "center"
													}}
												>
													<span className="sv-string-viewer sv-string-viewer--multiline">
														{typeof question.value ===
														"string"
															? question.value
															: JSON.stringify(
																	question.value
															  )}
													</span>
													<span
														id={page.name}
														className="action edit-pen"
														style={{
															display: "flex",
															flexDirection: "row",
															alignItems: "center"
														}}
													>
														<EditPen />
													</span>
												</h5>
											</td>
										</tr>
									</>
								))}
							</tbody>
						</table>
					</div>
				))}
			</div>
		);
	}
}

export default SurveySummary;
