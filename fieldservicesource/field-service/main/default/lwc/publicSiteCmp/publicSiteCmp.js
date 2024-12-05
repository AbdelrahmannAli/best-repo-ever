import { LightningElement, wire, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import SERVICEAPPOINTMENT_FIELD from "@salesforce/schema/ServiceAppointment";
import SERVICECONTACTID_FIELD from "@salesforce/schema/ServiceAppointment.ContactId";
import SERVICEEARLIESTDATE_FIELD from "@salesforce/schema/ServiceAppointment.EarliestStartTime";
import SERVICEDUEDATE_FIELD from "@salesforce/schema/ServiceAppointment.DueDate";
import SERVICEPARENTACCOUNTID_FIELD from "@salesforce/schema/ServiceAppointment.ParentRecordId";
import getCaseInfo from "@salesforce/apex/GetSObjectDataLWC.getCaseInfo";
import createWorkOrderRecord from "@salesforce/apex/CreateWorkOrderRecord.createWorkOrderRecord";
import getServiceAppointment from "@salesforce/apex/GetSObjectDataLWC.getServiceAppointment";
import getTerritoryId from "@salesforce/apex/GetSObjectDataLWC.getTerritoryId";
import getContactData from "@salesforce/apex/GetSObjectDataLWC.getContactData";

export default class DigitalExperienceLogin extends LightningElement {
  costumerName;
  costumerEmail;

  parentAccountId;
  mailingStreet;
  mailingPostalCode;
  mailingState;
  mailingCity;
  mailingCountry;
  serviceId;
  serviceTerritoryChecker = false;

  // template handler
  showNoAppointmentsWarning = true;
  registerPage = true;
  showServiceAppointment = false;
  showCreateNewService = false;
  showDetailsModal = false;

  accountName;
  modifyAppointmentNumber;

  // URL INFO
  @track urlCostumerId;
  @track urlCaseId;
  @track workOrderId;
  @track serviceTerritoryId;
  @track serviceAppointmentList;
  @track serviceField = SERVICEAPPOINTMENT_FIELD;
  @track serviceFieldList = [
    SERVICEPARENTACCOUNTID_FIELD,
    SERVICECONTACTID_FIELD,
    SERVICEEARLIESTDATE_FIELD,
    SERVICEDUEDATE_FIELD
  ];

  //case related
  caseAssetId;
  caseAccountId;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlCostumerId = currentPageReference.state?.contactId;
      this.urlCaseId = currentPageReference.state?.caseId;
    }
    getServiceAppointment({ contactId: currentPageReference.state?.contactId })
      .then((data) => {
        this.serviceAppointmentList = data;
        this.error = null;
        if (this.serviceAppointmentList.length > 0) {
          this.showNoAppointmentsWarning = false;
        }
      })
      .catch((error) => {
        
          "error while getting service appointment info -> " +
            JSON.stringify(error)
        );
      });

    getContactData({ contactId: currentPageReference.state?.contactId })
      .then((data) => {
        this.parentAccountinfo = data;
        this.costumerEmail = data.Email;
        this.costumerName = data.LastName;
        this.parentAccountId = data.AccountId;
        this.mailingCity = data.MailingCity;
        this.mailingCountry = data.MailingCountry;
        this.mailingPostalCode = data.MailingPostalCode;
        this.mailingState = data.MailingState;
        this.mailingStreet = data.MailingStreet;
        this.error = null;

        getCaseInfo({ caseId: currentPageReference.state?.caseId })
          .then((data) => {
            this.caseAccountId = data.AccountId;
            this.caseAssetId = data.AssetId;
          })
          .catch((error) => {
            
              "error while getting case info -> " + JSON.stringify(error)
            );
          });

        let workOrder = { sobjectType: "WorkOrder" };
        workOrder.CaseId = this.urlCaseId;
        workOrder.Priority = "Critical";
        workOrder.AccountId = this.caseAccountId;
        workOrder.AssetId = this.caseAssetId;
        workOrder.ContactId = this.urlCostumerId;

        getTerritoryId({ city: data.MailingCity }).then((data) => {
          if (JSON.stringify(data).length > 0) {
            this.serviceTerritoryId = data.Id;
            
            workOrder.ServiceTerritoryId = this.serviceTerritoryId;
          } else {
            
          }
          createWorkOrderRecord({ newRecord: workOrder })
            .then((result) => {
              this.workOrderId = result;
            })
            .catch((error) => {
              
            });
        });
      })
      .catch((error) => {
        
          "error while getting contact parent account -> " +
            JSON.stringify(error)
        );
      });
  }

  @wire(getServiceAppointment, { contactId: "$urlCostumerId" })
  serviceAppointmentListccounts;

  @wire(getContactData, { contactId: "$urlCostumerId" })
  parentAccountId;

  @wire(getCaseInfo, { caseId: "$urlCaseId" })
  getInfo;

  @wire(createWorkOrderRecord, { newRecord: "$workOrder" })
  createWorkOrder;
  handlesubmit(event) {
    let name = event.target.name;
    if (name === "submitNewService") {
      this.showCreateNewService = true;
    } else if (name === "recordForm") {
      this.template
        .querySelector("lightning-record-edit-form")
        .submit(event.detail.fields);
    }
  }

  closeNewService() {
    this.showCreateNewService = false;
  }

  handleSubmitNewService(event) {
    event.preventDefault();
    const fields = event.detail.fields;
    this.accountName = fields.Name;
    try {
      this.template.querySelector("lightning-record-form").submit(fields);
    } catch (error) {
      
        "error while submitting new service appointment -> " +
          JSON.stringify(error)
      );
    }
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
    this.showCreateNewService = false;
  }

  handleModify(event) {
    this.showDetailsModal = true;
    this.getServiceAppointment(event.target.name);
    this.serviceId = event.target.name;
  }

  closewModifyModal() {
    this.showDetailsModal = false;
  }

  getServiceAppointment(sId) {
    this.serviceAppointmentList.map((serviceAppointment) => {
      if (serviceAppointment.Id == sId) {
        this.modifyAppointmentNumber = serviceAppointment.AppointmentNumber;
      }
    });
  }
}
