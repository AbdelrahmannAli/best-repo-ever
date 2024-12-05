import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccounts from "@salesforce/apex/AccountListLWC.getAccounts";
import accountObject from "@salesforce/schema/Account";
import nameField from "@salesforce/schema/Account.Name";
import websiteField from "@salesforce/schema/Account.Website";
//import hospitalBedsField from "@salesforce/schema/Account.HospitalBeds__c";
import billingStreetField from "@salesforce/schema/Account.BillingStreet";
import billingCityField from "@salesforce/schema/Account.BillingCity";

export default class addAccount extends LightningElement {
  @api recordId;
  @track editAccount = false;
  @track addAccount = false;
  @track showAccounts = false;
  @track pageAccounts = false;
  @track addAccountSubmit = false;
  @track accountName;

  errorMessage;

  totalAccounts;
  visibleRecords;
  totalPages;
  curentPage = 1;
  recordsPerPage = 3;

  @wire(getAccounts)
  accountsList({ error, data }) {
    if (data) {
      this.totalAccounts = data;
      this.visibleRecords = data.slice(0, this.recordsPerPage);
      this.totalPages = Math.ceil(data.length / this.recordsPerPage);
    }
    if (error) {
      
    }
  }

  accountObject = accountObject;
  myFields = [
    nameField,
    websiteField,
    //hospitalBedsField,
    billingCityField,
    billingStreetField,
  ];

  previoushandler() {
    if (this.curentPage > 1) {
      this.curentPage--;
      this.nextEnd = this.curentPage * this.recordsPerPage;
      this.nextStart = this.nextEnd - this.recordsPerPage;
      this.visibleRecords = this.totalAccounts.slice(
        this.nextStart,
        this.nextEnd
      );
    }
  }

  nexthandler() {
    if (this.curentPage < this.totalPages) {
      this.curentPage++;
      this.nextEnd = this.curentPage * this.recordsPerPage;
      this.nextStart = this.nextEnd - this.recordsPerPage;
      this.visibleRecords = this.totalAccounts.slice(
        this.nextStart,
        this.nextEnd
      );
    }
  }

  notifyUser(message) {
    const errorEvent = new ShowToastEvent({
      title: "Unexpcted Error has Happened",
      message: message,
      variant: "error",
      mode: "pester",
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
      title: "Adding Accounts is a Blast!",
      message:
        "Account " + this.accountName + " has been created successfully ",
      variant: "success",
      mode: "pester",
    });
    this.dispatchEvent(successEvent);
    this.addAccount = false;
  }

  handleSubmit(event) {
    event.preventDefault();
    const fields = event.detail.fields;

    this.accountName = fields.Name;

    try {
      this.template.querySelector("lightning-record-form").submit(fields);
    } catch (error) {
      
    }
  }

  openEditModal() {
    this.editAccount = true;
  }

  closeEditModal() {
    this.editAccount = false;
  }

  openAddModal() {
    this.addAccount = true;
  }

  closeAddModal() {
    this.addAccount = false;
  }

  openShowAccountsModal() {
    this.showAccounts = true;
  }

  closeShowAccountsModal() {
    this.showAccounts = false;
  }

  openPageAccountsModal() {
    this.pageAccounts = true;
  }

  closePageAccountsModal() {
    this.pageAccounts = false;
  }
}
