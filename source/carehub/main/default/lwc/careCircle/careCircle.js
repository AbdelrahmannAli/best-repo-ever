import { api, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import UtilityLWC from "c/utils";
import { loadStyle } from "lightning/platformResourceLoader";
import style from "@salesforce/resourceUrl/staticStyles";
import getCaseContactId from "@salesforce/apex/ClientCasesController.getCaseContactId";
import getCaseContactCareCircleMembers from "@salesforce/apex/ClientCasesController.getCaseContactCareCircleMembers";
import getExternalSystems from "@salesforce/apex/ClientCasesController.getExternalSystems";
import getSobjectFromId from "@salesforce/apex/CareHubUtilities.getSobjectFromId";
import manualSyncContactRelations from "@salesforce/apex/CaseCareCircleTriggerHandler.manualSyncContactRelations";
import { subscribe } from "lightning/empApi";
import getUserId from "@salesforce/apex/CareHubUtilities.getUserId";
import { getRecord } from "lightning/uiRecordApi";
import careCircle_NoCareCircleMembers from "@salesforce/label/c.careCircle_NoCareCircleMembers";
import careCircle_SyncCareCircle from "@salesforce/label/c.careCircle_SyncCareCircle";
import careCircle_CopyEmail from "@salesforce/label/c.careCircle_CopyEmail";
import general_Relationship from "@salesforce/label/c.general_Relationship";
import general_Name from "@salesforce/label/c.general_Name";
import general_Phone from "@salesforce/label/c.general_Phone";
import general_LastModifiedAt from "@salesforce/label/c.general_LastModifiedAt";
import general_Available from "@salesforce/label/c.general_Available";
import general_All from "@salesforce/label/c.general_All";
import general_Formal from "@salesforce/label/c.general_Formal";
import general_Informal from "@salesforce/label/c.general_Informal";
import { EnclosingTabId, getTabInfo, openSubtab } from 'lightning/platformWorkspaceApi';
export default class CareCircle extends NavigationMixin(UtilityLWC) {
  constructor() {
    super("careCircle");
  }
  @api recordId;
  @track contactId;
  @track recordType;
  @track showCareCircleMembers = false;
  @track isLoading = false;
  @track channelName = "/event/Syntilio__Notification__e";
  @track userId;
  @track manualSync = false;

  labels = {
    careCircle_NoCareCircleMembers,
    careCircle_SyncCareCircle,
    careCircle_CopyEmail,
    general_Relationship,
    general_Name,
    general_Phone,
    general_LastModifiedAt,
    general_Available,
    general_All,
    general_Formal,
    general_Informal
  };

  @track careCircleMembersColumns = [
    {
      label: this.labels.general_Relationship,
      fieldName: "Relationship",
      type: "text"
    },
    {
      label: this.labels.general_Name,
      fieldName: "Name",
      type: "button",
      typeAttributes: {
        label: { fieldName: "Name" },
        name: "contact-details"
      },
      cellAttributes: { class: "button-style-no-border" }
    },
    {
      label: this.labels.general_Phone,
      fieldName: "Phone",
      type: "customTypePhone"
    },
    {
      label: "Email",
      type: "button",
      typeAttributes: {
        label: { fieldName: "Email" },
        name: "copyEmail",
        variant: "base"
      }
    },
    {
      label: this.labels.general_Available,
      fieldName: "Available",
      type: "text"
    }
  ];
  @track filterButtons = [
    {
      label: this.labels.general_All,
      name: "All",
      class: "slds-button slds-button_brand"
    },
    {
      label: this.labels.general_Formal,
      name: "Formal",
      class: "slds-button slds-button_neutral"
    },
    {
      label: this.labels.general_Informal,
      name: "Informal",
      class: "slds-button slds-button_neutral"
    }
  ];
  @track allCareCircleMembers = [];
  @track careCircleMembers = [];
  @track caseContactId;

  @wire(getRecord, { recordId: "$recordId", fields: ["Case.ContactId"] })
  recordUpdated({ data }) {
    if (!this.recordId || !data) {
      return;
    }
    if (data.apiName !== "Case") {
      this.checkRecordType();
      return;
    }
    let contactId = data.fields.ContactId;
    if (this.contactId !== contactId) {
      this.checkRecordType();
    }
  }

  connectedCallback() {
    super.connectedCallback();
    this.handleSubscribe();
    loadStyle(this, style);
    this.setUpChatButton();
  }

  receiveProgress(response) {
    if (!response) {
      this.isLoading = false;
      return;
    }
    if (
      !(
        response.data.payload.Syntilio__Target__c === "CareCircle" &&
        response.data.payload.Syntilio__TargetUserId__c === this.userId
      )
    ) {
      return;
    }
    this.checkRecordType();
    if (response.data.payload.Syntilio__Status__c === "Success" && this.manualSync) {
      this.notifyUser(
        "",
        "Care circle members synced successfully!",
        this.toastTypes.Success
      );
      this.manualSync = false;
    }
    if (response.data.payload.Syntilio__Status__c === "Failure") {
      this.notifyUser(
        "",
        "Updating care circle members failed. You can try manually updating it. If issues persist, contact your administrator for assistance",
        this.toastTypes.Error
      );
    }
    if (response.data.payload.Syntilio__Status__c === "Warning" && this.manualSync) {
      this.notifyUser(
        "",
        "Care circle members already up to date!",
        this.toastTypes.Info
      );
    }
    this.isLoading = false;
  }

  async handleSubscribe() {
    try {
      await subscribe(this.channelName, -1, (response) =>
        this.receiveProgress(response)
      );
      const userId = await getUserId();
      this.userId = userId;
    } catch (error) {
      this.logException(error, "handleSubscribe");
    }
  }

  handleButtonClick() {
    this.manualSync = true;
    if (this.recordType.toLowerCase() === "contact") {
      this.syncCareCircleMembers();
    } else {
      // eslint-disable-next-line @lwc/lwc/no-api-reassignments
      this.recordId = this.contactId;
      this.syncCareCircleMembers();
    }
  }

  syncCareCircleMembers() {
    this.isLoading = true;
    if(!this.recordId){
				this.isLoading = false;
				return;
			}
    manualSyncContactRelations({
      clientId: this.recordId
    }).catch((error) => {
      this.notifyUser("", "Failed to sync care circle", this.toastTypes.Error);
      this.logException(error, "syncCareCircleMembers");
      this.isLoading = false;
    });
  }

  async checkRecordType() {
    try {
      let result = await getSobjectFromId({ sObjectId: this.recordId });
      this.recordType = result;
      if (this.recordType.toLowerCase() === "contact") {
        this.contactId = this.recordId;
        this.getCareCircleMembers();
      } else {
        this.getCareCircleData();
      }
    } catch (error) {
      this.logException(error, "checkRecordType");
    }
  }
  async getCareCircleData() {
    try {
      let contact = await getCaseContactId({
        caseId: this.recordId
      });
      const contactData = JSON.parse(contact);
      this.contactId = contactData.ContactId;
      this.getCareCircleMembers();
    } catch (error) {
      this.logException(error, "getCareCircleData");
    }
  }
  async getCareCircleMembers() {
    try {
      let result = await getCaseContactCareCircleMembers({
        clientId: this.contactId
      });
      this.showCareCircleMembers = result.length > 0;
      result.sort((a, b) => {
        if (a.Syntilio__RelationshipType__c === "Informal" && b.Syntilio__RelationshipType__c !== "Informal") {
          return -1; 
        }
        if (a.Syntilio__RelationshipType__c !== "Informal" && b.Syntilio__RelationshipType__c === "Informal") {
          return 1; 
        }
        if (!a.Syntilio__Relationship__c && b.Syntilio__Relationship__c) {
          return 1; 
        }
        if (a.Syntilio__Relationship__c && !b.Syntilio__Relationship__c) {
          return -1; 
        }
        return 0;
      });
      this.allCareCircleMembers = this.prepareCareCircleMembersData(result);
      this.careCircleMembers = this.allCareCircleMembers;
          } catch (error) {
      this.logException(error, "getCareCircleMembers");
    }
  }

  handleButtonSelection(event) {
    this.careCircleMembers =
      event.target.dataset.name === "All"
        ? this.allCareCircleMembers
        : this.allCareCircleMembers.filter(
            (careCircleMember) =>
              careCircleMember.RelationshipType === event.target.dataset.name
          );
    this.filterButtons = this.filterButtons.map((filterButton) => {
      if (filterButton.name === event.target.dataset.name) {
        filterButton.class = "slds-button slds-button_brand";
      } else {
        filterButton.class = "slds-button slds-button_neutral";
      }
      return filterButton;
    });
  }

  prepareCareCircleMembersData(result) {
    let index = 1;
    return result.map((careCircleMember) => {
      return {
        RelationshipType: careCircleMember.Syntilio__RelationshipType__c,
        Relationship: careCircleMember.Syntilio__Relationship__c,
        ContactId: careCircleMember.Syntilio__RelatedContactId__c,
        Name: careCircleMember.Syntilio__RelatedContactId__r.Salutation
          ? careCircleMember.Syntilio__RelatedContactId__r.Salutation +
            " " +
            careCircleMember.Syntilio__RelatedContactId__r.Name
          : careCircleMember.Syntilio__RelatedContactId__r.Name,
        Phone: careCircleMember.Syntilio__RelatedContactId__r.Phone,
        Email: careCircleMember.Syntilio__RelatedContactId__r.Email,
        // LastModifiedDate: (new Date(careCircleMember.Syntilio__RelatedContactId__r.LastModifiedDate)).toLocaleDateString(),
        Available: careCircleMember.Syntilio__Order__c,
        index: careCircleMember.Syntilio__RelationshipType__c === "Informal" ? index++ : ''
      };
    });
  }

  handleRowAction(event) {
    const email = event.target.dataset.email;
    if (email) {
			this.copyEmail(email);
		}
  }
  copyEmail(email) {
    navigator.clipboard
      .writeText(email)
      .then(() => {
        this.notifyUser("", this.labels.careCircle_CopyEmail, this.toastTypes.Info);
      })
      .catch((err) => {});
  }
  handleNameClick(event) {
    const contactId = event.currentTarget.dataset.id;
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: contactId,
            objectApiName: 'Contact',
            actionName: 'view'
        }
    });
}
@track chatAvailable = false
@track chatUrl = null
@track moreThanOneExternalSystem = null
	async setUpChatButton() {
		try{
		let externalSystems = await getExternalSystems();
		externalSystems= externalSystems.filter((r) => r.Syntilio__ChatUrl__c );
		if (externalSystems.length == 1) {
			this.chatUrl = externalSystems[0].Syntilio__ChatUrl__c ;
			this.chatAvailable = true
		}
		else if (externalSystems.length > 1){
			this.chatAvailable = true
			this.moreThanOneExternalSystem = true
		}
		else{
			this.logException("There are no external systems");
			this.chatAvailable = false
		}
		}
		catch(error){
			this.logException(error, "setUpChatButton");
		}
	}
	get isChatDisabled(){
		return ! this.chatAvailable;
	}
	@wire(EnclosingTabId) tabId;
	async handleChatClick() {
		try{
		if (this.chatUrl) {
			window.open(this.chatUrl, '_blank');
		}
		else if (this.moreThanOneExternalSystem){
			if (!this.tabId) {
				return;
			}
			const tabInfo = await getTabInfo(this.tabId);
			const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
			await openSubtab(primaryTabId, { url: '/apex/multipleChatSystems', focus: true });
		}
		else{
			this.logException("The chat URL is unavailable");
		}
		}
		catch(error){
			this.logException(error, "handleChatClick");
		}

	}
	
}
