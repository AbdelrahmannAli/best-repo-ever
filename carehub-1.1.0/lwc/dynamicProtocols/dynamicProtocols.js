/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable consistent-return */
import { api, track } from "lwc";
import getFlow from "@salesforce/apex/ProtocolHandler.getFlow";
import updateCaseProtocolActionResult from "@salesforce/apex/ProtocolHandler.updateCaseProtocolActionResult";
import logExceptionAsString from "@salesforce/apex/HandleException.logExceptionAsString";
import UtilityLWC from "c/utils";

const Status = {
  NOT_STARTED: "NOT_STARTED",
  IN_PROGRESS: "IN_PROGRESS",
  FINISHED: "FINISHED"
};

export default class DynamicProtocols extends UtilityLWC {
  @api recordId;
  @track flowApiName = "";
  @track protocolActionId = "";
  @track flowInputVariables = {};
  @track listOfCurrentProtocolFlows = [];
  @track allFlows = [];
  @track showFlow = false;
  @track showProtocolOptions = false;
  @track currentFlowIndex = 0;
  @track showFlowText = "";
  @track protocolOptions = [];
  @track defaultSyntilio__TypeApiName__c =
    "Syntilio__Show_Questionnaire_Questions_and_Create_Protocol_Results";

  get inputVariables() {
    let inputVariables = [];
    inputVariables.push({
      name: "recordId",
      type: "String",
      value: this.recordId
    });

    if (this.flowApiName === this.defaultSyntilio__TypeApiName__c) {
      inputVariables.push({
        name: "ProtocolActionId",
        type: "String",
        value: this.protocolActionId
      });
    }
    return inputVariables;
  }

  connectedCallback() {
    super.connectedCallback();
    this.getFlowFromApex();
  }

  handleProtocolEnd() {
    this.handleProtocolActionsOptions();
    if (this.protocolOptions.length === 0) return;
    this.showProtocolOptions = true;
    this.listOfCurrentProtocolFlows = [];
  }

  handleProtocolChange(event) {
    const selectedProtocol = event.target.dataset.name;
    this.listOfCurrentProtocolFlows = this.listOfFlows.filter(
      (flow) => flow.Syntilio__Protocol__c === selectedProtocol
    );

    if (this.listOfCurrentProtocolFlows.length === 0) {
      return this.handleProtocolEnd();
    }

    this.listOfFlows = this.listOfFlows.filter(
      (flow) => flow.Syntilio__Protocol__c !== selectedProtocol
    );

    // start order from beginning
    this.currentFlowIndex = 0;
    this.flowApiName = this.listOfCurrentProtocolFlows[0].Syntilio__ProtocolAction__r
      .Syntilio__TypeApiName__c
      ? this.listOfCurrentProtocolFlows[0].Syntilio__ProtocolAction__r
          .Syntilio__TypeApiName__c
      : this.defaultSyntilio__TypeApiName__c;

    this.protocolActionId =
      this.listOfCurrentProtocolFlows[0].Syntilio__ProtocolAction__c;
    setTimeout(() => {
      this.showFlow = true;
      this.showProtocolOptions = false;
    }, 100);
  }

  getProtocolActionId(actionId) {
    return [...this.listOfFlows].filter(
      (flow) => flow.Syntilio__ProtocolAction__c === actionId
    );
  }

  handleFlowStatusChange(event) {
    const flowStatus = event.detail.status;
    if (flowStatus.toLowerCase() === "started") {
      this.updateCase(Status.IN_PROGRESS, this.getProtocolActionId());
    } else if (flowStatus.toLowerCase() === "finished") {
      this.handleFlowEnd();
    }
  }

  updateCase(status, protocolActionId) {
    updateCaseProtocolActionResult({
      caseId: this.recordId,
      flowStatus: status,
      protocolActionId: protocolActionId
    }).catch((error) => {
      //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
      logExceptionAsString({
        exceptionType: error.Name,
        exceptionMessage: error.message,
        stackTrace: error.stack,
        lineNumber: 121,
        methodName: "updateCase",
        className: "DynamicProtocols",
        nameSpace: "Syntilio",
        source: this.exceptionTypes.LWC
      });
      
    });
  }

  handleFlowEnd() {
    this.updateCase(Status.FINISHED, this.protocolActionId);
    this.showFlow = false;
    this.currentFlowIndex++;

    if (this.currentFlowIndex > this.listOfCurrentProtocolFlows.length - 1) {
      return this.handleProtocolEnd();
    }

    this.protocolActionId =
      this.listOfCurrentProtocolFlows[
        this.currentFlowIndex
      ].Syntilio__ProtocolAction__c;
    this.flowApiName = this.listOfCurrentProtocolFlows[this.currentFlowIndex]
      .Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c
      ? this.listOfCurrentProtocolFlows[this.currentFlowIndex]
          .Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c
      : this.defaultSyntilio__TypeApiName__c;

    setTimeout(() => {
      this.showFlow = true;
    }, 500);
  }

  getFlowFromApex() {
    getFlow({
      caseId: this.recordId,
      initFlowEvents: true
    })
      .then((data) => {
        if (!data || data === "")
          return console.warn("No data was retrieved from apex class");
        const returnedFlows = JSON.parse(data);
        this.loadFlowRuntime(returnedFlows);
        return null;
      })
      .catch((error) => {
        //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
        logExceptionAsString({
          exceptionType: error.Name,
          exceptionMessage: error.message,
          stackTrace: error.stack,
          lineNumber: 187,
          methodName: "getFlowFromApex",
          className: "DynamicProtocols",
          nameSpace: "Syntilio",
          source: this.exceptionTypes.LWC
        });
        
      });
  }

  loadFlowRuntime(flowslist) {
    if (!flowslist)
      return console.warn(
        "There was an error getting data from apex, it returned ",
        flowslist
      );
    this.listOfFlows = flowslist;
    this.handleProtocolActionsOptions();
  }

  handleProtocolActionsOptions() {
    const uniqueArray = [...this.listOfFlows].filter(
      (obj, index, self) =>
        index ===
        self.findIndex(
          (flow) =>
            flow.Syntilio__Protocol__c === obj.Syntilio__Protocol__c &&
            flow.Syntilio__Protocol__r.Name === obj.Syntilio__Protocol__r.Name
        )
    );

    this.protocolOptions = uniqueArray.map((flow) => {
      const image = flow.Syntilio__Protocol__r.Syntilio__Image__c;
      const parser = new DOMParser();
      const doc = parser.parseFromString(image, 'text/html');
      const imgElement = doc.querySelector('img');
      let srcValue;
      if (imgElement) {
        srcValue = imgElement.getAttribute('src');
      } 
      return {
        label: flow.Syntilio__Protocol__r.Name,
        value: flow.Syntilio__Protocol__c,  
        Description: flow.Syntilio__Protocol__r.Syntilio__Description__c,
        Image: srcValue,
        Time: flow.Syntilio__Protocol__r.Syntilio__EstimatedTime__c
      };
    });
    this.showProtocolOptions = true;
  }
}
