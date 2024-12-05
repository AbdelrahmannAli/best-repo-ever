import { api, LightningElement, track, wire } from "lwc";
import createWorkOrderRecord from "@salesforce/apex/CreateWorkOrderRecord.createWorkOrderRecord";
import LightningAlert from "lightning/alert";
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

  mailingStreet;
  mailingPostalCode;
  mailingState;
  mailingCity;
  mailingCountry;

  @track initialCaseId;
  @track relatedAccountId;
  @track relatedContactId;
  @track relatedAssetId;
  @track openCreateServiceAppointment = false;
  @track showBuffer = true;
  @track jsCurrentStep = "1";

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

      let workOrder = { sobjectType: "WorkOrder" };
      workOrder.CaseId = this.recordId;
      workOrder.Priority = "Critical";
      workOrder.AccountId = data.fields.AccountId.value;
      workOrder.AssetId = data.fields.AssetId.value;
      workOrder.ContactId = data.fields.ContactId.value;

      getContactData({ contactId: this.relatedContactId }).then((data) => {
        this.mailingCity = data.MailingCity;
        this.mailingCountry = data.MailingCountry;
        this.mailingPostalCode = data.MailingPostalCode;
        this.mailingState = data.MailingState;
        this.mailingStreet = data.MailingStreet;
        getTerritoryId({ city: data.MailingCity }).then((data) => {
          if (JSON.stringify(data).length > 0) {
            workOrder.ServiceTerritoryId = "0Hh1x000000JjrcCAC";
          }

          createWorkOrderRecord({ newRecord: workOrder })
            .then((result) => {
              this.workOrderId = result;

              // alert = LightningAlert.open({
              //   message: "Press Ok to continue to create a service appointment",
              //   theme: "success", // a red theme intended for error states
              //   label: "Your Work Order has been created succesfully !" // this is the header text
              // });

              this.openCreateServiceAppointment = true;
              this.jsCurrentStep = "2";
            })
            .catch((error) => {
              
                "error while creating work order -> " + JSON.stringify(error)
              );
            });
        });
      });
    }
    if (error) {
      
    }
  }

  closeServiceAppointmentModal() {
    this.openCreateServiceAppointment = false;
    this.dispatchEvent(
      new CustomEvent("succesService", {
        detail: { data: "cancel" }
      })
    );
  }

  notifyUser(message) {
    LightningAlert.open({
      message: { message },
      theme: "error", // a red theme intended for error states
      label: "Error!" // this is the header text
    });
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
    this.jsCurrentStep = "3";
    this.openCreateServiceAppointment = false;
    this.dispatchEvent(
      new CustomEvent("succesService", {
        detail: { data: "Service created" }
      })
    );
    
    // 

    // window.history.back();
  }
}
