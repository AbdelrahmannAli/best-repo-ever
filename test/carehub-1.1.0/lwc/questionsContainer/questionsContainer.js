import { LightningElement, track, api } from "lwc";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent
} from "lightning/flowSupport";
import logExceptionAsString from "@salesforce/apex/HandleException.logExceptionAsString";
import UtilityLWC from "c/utils";

export default class questionsContainer extends UtilityLWC {
  @api inputSobjectRecordList;
  @api requiredQuestions;
  @api allowSubmit = false;
  @track questionareQuestions = [];
  @track answers = [];
  @api outputSobjectRecordList;
  @track sumOfAnswersValues = 0;
  @api outputSobjectRecord;
  @api outputTest;
  @track numericAnswersValues = {};
  @track errorMessage;

  connectedCallback() {
    super.connectedCallback();
    try {
      const requiredQuestionsMap = JSON.parse(this.requiredQuestions);
      // eslint-disable-next-line guard-for-in
      for (let key in this.inputSobjectRecordList) {
        this.questionareQuestions.push({
          value: this.inputSobjectRecordList[key].Syntilio__Question__c,
          key: this.inputSobjectRecordList[key].Id,
          type: this.inputSobjectRecordList[key].Syntilio__Type__c,
          options: this.inputSobjectRecordList[key].Syntilio__Options__c,
          required: requiredQuestionsMap[this.inputSobjectRecordList[key].Id]
        });
      }
    } catch (error) {
      //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
      logExceptionAsString({
        exceptionType: error.Name,
        exceptionMessage: error.message,
        stackTrace: error.stack,
        lineNumber: 25,
        methodName: 'connectedCallback',
        className: 'questionsContainer',
        nameSpace: 'Syntilio',
        source: this.exceptionTypes.LWC
      });
    }
  }

  handlAnswerSelect(event) {
    try {
      const sourceName = event.detail.sourceName;
      const value = event.detail.answer;
      const sourceId = event.detail.Id;

      if (sourceName === "slider" && !isNaN(value)) {
        this.numericAnswersValues[sourceId] = parseInt(value, 10);

        this.sumOfAnswersValues = Object.values(this.numericAnswersValues).reduce(
          (a, b) => a + b,
          0
        );
      }

      const questionIndex = this.isQuestionAlreadyAdded(sourceId);
      if (questionIndex < 0) {
        this.answers.push({
          answerValue: event.detail.answer,
          selectedQuestionId: event.detail.Id
        });
      } else {
        this.answers[questionIndex].answerValue = value;
      }

      const attributeChangeEventFirstOutput = new FlowAttributeChangeEvent(
        "outputSobjectRecordList",
        this.answers
      );
      this.dispatchEvent(attributeChangeEventFirstOutput);
      const attributeChangeEventSecondOutput = new FlowAttributeChangeEvent(
        "outputSobjectRecord",
        this.sumOfAnswersValues
      );
      this.dispatchEvent(attributeChangeEventSecondOutput);
    } catch (error) {
      //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
      logExceptionAsString({
        exceptionType: error.Name,
        exceptionMessage: error.message,
        stackTrace: error.stack,
        lineNumber: 75,
        methodName: 'handlAnswerSelect',
        className: 'questionsContainer',
        nameSpace: 'Syntilio',
        source: this.exceptionTypes.LWC
      });
    }
  }

  checkAllRequiredQuestionsAnswered() {
    const requiredQuestionsMap = JSON.parse(this.requiredQuestions);
    const unFilledRequired = [];

    Object.entries(requiredQuestionsMap).forEach(([key, value]) => {
      if (value === true && this.isQuestionAlreadyAdded(key) < 0) {
        unFilledRequired.push(key);
      }
    });

    if (unFilledRequired.length === 0) {
      this.allowSubmit = true;
    }
  }

  isQuestionAlreadyAdded(id) {
    var isAddedIndex = -1;
    isAddedIndex = this.answers.findIndex((answer) => answer.selectedQuestionId === id);
    return isAddedIndex;
  }

  handleSubmit() {
    this.checkAllRequiredQuestionsAnswered();

    if (!this.allowSubmit) {
      this.errorMessage = "Please fill all fields marked with (*)";
      return;
    }

    this.handleNext();
  }

  handleNext() {
    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);
  }
}
