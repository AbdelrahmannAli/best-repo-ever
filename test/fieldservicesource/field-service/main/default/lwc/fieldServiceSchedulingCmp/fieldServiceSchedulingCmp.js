import { api, LightningElement, track, wire } from "lwc";
import createWorkOrderRecord from "@salesforce/apex/CreateWorkOrderRecord.createWorkOrderRecord";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import serviceAppointmentObject from "@salesforce/schema/ServiceAppointment";
import serviceAccountId from "@salesforce/schema/ServiceAppointment.AccountId";
import serviceContactId from "@salesforce/schema/ServiceAppointment.ContactId";
import serviceEarliestStartTime from "@salesforce/schema/ServiceAppointment.EarliestStartTime";
import serviceDueDate from "@salesforce/schema/ServiceAppointment.DueDate";
import getContactData from "@salesforce/apex/GetSObjectDataLWC.getContactData";
import getTerritoryId from "@salesforce/apex/GetSObjectDataLWC.getTerritoryId";

const workOrderFields = [
  "Case.Id",
  "Case.AccountId",
  "Case.ContactId",
  "Case.AssetId"
];

export default class fieldServiceSchedulingCmp extends LightningElement {
  @api recordId;

  @track initialCaseId;
  @track relatedAccountId;
  @track relatedContactId;
  @track relatedAssetId;
  @track openCreateServiceAppointment = false;

  serviceAppointmentObject = serviceAppointmentObject;
  serviceAppointmentFields = [
    serviceEarliestStartTime,
    serviceDueDate,
    serviceAccountId,
    serviceContactId
  ];

  @wire(getRecord, { recordId: "$recordId", fields: workOrderFields })
  caseData;

  @wire(getRecord, { recordId: "$recordId", fields: workOrderFields })
  caseDate({ data, error }) {
    if (data) {
      this.initialCaseId = JSON.stringify(data.fields.Id.value);
      this.relatedAccountId = data.fields.AccountId.value;
      this.relatedContactId = data.fields.ContactId.value;
      this.relatedAssetId = data.fields.AssetId.value;
    }
    if (error) {
      
    }
  }

  createWorkOrder() {
    let workOrder = { sobjectType: "WorkOrder" };
    workOrder.CaseId = this.recordId;
    workOrder.Priority = "Critical";
    workOrder.AccountId = this.relatedAccountId;
    workOrder.AssetId = this.relatedAssetId;
    workOrder.ContactId = this.relatedContactId;

    getContactData({ contactId: this.relatedContactId }).then((data) => {
      getTerritoryId({ city: data.MailingCity }).then((data) => {
        if (JSON.stringify(data).length > 0) {
          workOrder.ServiceTerritoryId = "0Hh1x000000JjrcCAC";
        }

        createWorkOrderRecord({ newRecord: workOrder })
          .then((result) => {
            this.workOrderId = result;

            const workOrderCreated = new ShowToastEvent({
              title: "A Work Order has been created !",
              message:
                "Work Order " +
                this.workOrderId +
                " has been created successfully ",
              variant: "success",
              mode: "pester"
            });
            this.dispatchEvent(workOrderCreated);

            this.openCreateServiceAppointment = true;
          })
          .catch((error) => {
            
              "error while creating work order -> " + JSON.stringify(error)
            );
          });
      });
    });
  }

  closeServiceAppointmentModal() {
    this.openCreateServiceAppointment = false;
  }

  notifyUser(message) {
    const errorEvent = new ShowToastEvent({
      title: "Unexpcted Error has Happened",
      message: message,
      variant: "error",
      mode: "pester"
    });
    this.dispatchEvent(errorEvent);
  }

  handleError(event) {
    if (Object.entries(event.detail.output.fieldErrors).length !== 0) {
      const getField = Object.keys(event.detail.output.fieldErrors)[0];
      this.errorMessage = event.detail.output.fieldErrors[getField][0].message;
    } else {
      this.errorMessage = event.detail.message + "\n" + event.detail.detail;
    }
    this.notifyUser(this.errorMessage);
  }

  handleSuccess() {
    const successEvent = new ShowToastEvent({
      title: "A Service Appointment has been created !",
      message: "Service Appointment has been created successfully ",
      variant: "success",
      mode: "pester"
    });
    this.dispatchEvent(successEvent);
    this.openCreateServiceAppointment = false;
  }
}
