/* eslint-disable @lwc/lwc/no-api-reassignments */
import logExceptionAsString from "@salesforce/apex/HandleException.logExceptionAsString";
import { api, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import style from "@salesforce/resourceUrl/staticStyles";
import UtilityLWC from "c/utils";

export default class DynamicQuestionTypes extends UtilityLWC {
  @api label;
  @api name;
  @api type;
  @api options;
  @api radioName = null;
  @api required;

  @track className;
  @track isText = false;
  @track isRadio = false;
  @track isSlider = false;
  @track isPicklist = false;
  @track sliderMin = 0;
  @track sliderMax = 100;
  @track optionsList;
  @track sumOfAnswersValues = 0;

  handleChange(event) {
    const valueChangeEvent = new CustomEvent("answerselect", {
      detail: {
        answer: event.target.value,
        Id: this.name,
        sourceName: this.radioName === null ? event.target.name : this.type
      }
    });

    this.dispatchEvent(valueChangeEvent);
  }

  connectedCallback() {
    super.connectedCallback();
    try {
      switch (this.type?.toLowerCase()) {
        case "radiobutton":
          this.options = this.options.split(";").map((option) => {
            return {
              label: option.trim(),
              value: option.trim()
            };
          });
          this.radioName = this.name + " radio";
          this.isRadio = true;
          break;
        case "picklist":
          this.options = this.options?.split(";").map((option) => {
            return {
              label: option.trim(),
              value: option.trim()
            };
          });

          this.isPicklist = true;
          break;
        case "slider":
          if (this.options) {
            this.options = this.options?.split(";");
            this.sliderMax =
              this.options?.length === 1 ? this.options[0] : this.options[1];
            this.sliderMin = this.options?.length === 1 ? 0 : this.options[0];
          }
          this.isSlider = true;
          break;
        case "text":
          this.isText = true;
          break;
        default:
          this.isText = true;
          break;
      }

      loadStyle(this, style)
        .then(() => {
          this.className = this.required ? "requiredInput" : "";
        })
        .catch((e) => {
          
        });
    } catch (error) {
      //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
      logExceptionAsString({
        exceptionType: error.Name,
        exceptionMessage: error.message,
        stackTrace: error.stack,
        lineNumber: 68,
        methodName: "connectedCallback",
        className: "DynamicQuestionTypes",
        nameSpace: "Syntilio",
        source: this.exceptionTypes.LWC
      });
    }
  }
}
