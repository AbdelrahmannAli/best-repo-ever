import { LightningElement, track, api } from "lwc";
import LightningModal from 'lightning/modal';
import { subscribe } from 'lightning/empApi';
import USER_ID from '@salesforce/user/Id';
import setCaseOwner from "@salesforce/apex/ClientCasesController.setCaseOwner";
import setCaseStatus from "@salesforce/apex/ClientCasesController.setCaseStatus";
import publishRefreshEvent from "@salesforce/apex/ModalHelper.publishRefreshEvent";
import caseProgressIndicator_NotCaseOwner from "@salesforce/label/c.caseProgressIndicator_NotCaseOwner";
import caseProgressIndicator_AssignCase from "@salesforce/label/c.caseProgressIndicator_AssignCase";
import caseProgressIndicator_ConfirmClose from "@salesforce/label/c.caseProgressIndicator_ConfirmClose";
import modal_NoEvent from "@salesforce/label/c.modal_NoEvent";
import modal_SelectEvent from "@salesforce/label/c.modal_SelectEvent";
import general_Cancel from "@salesforce/label/c.general_Cancel";
import general_SaveAndClose from "@salesforce/label/c.general_SaveAndClose";
import general_Yes from "@salesforce/label/c.general_Yes";
import general_No from "@salesforce/label/c.general_No";
import modal_EventName from "@salesforce/label/c.modal_EventName";
import getAllEvents from "@salesforce/apex/ClientCasesController.getAllEvents";
import setCaseEvent from "@salesforce/apex/ClientCasesController.setCaseEvent";
import { RefreshEvent } from 'lightning/refresh';
import getCaseEventCode from "@salesforce/apex/ClientCasesController.getCaseEventCode";


export default class ModalPopupLWC extends LightningElement {
	@track showModal = false;
	@track assignToMe = false;
	@api popupText;
	@api checkboxText;
	@api titleText = caseProgressIndicator_ConfirmClose;
	@track eventData;
	@track checkBoxShown = false;
	@track showEventList = false;
	@track allEvents;
	@track selectedEvent;
	@track isNonOwner=false;
	@track isNoEvent=false;
	@track isEventNull=true;
	@track value;
	subscription = {};
	channelName = '/event/Syntilio__Notification__e';

	labels={
		caseProgressIndicator_AssignCase,
		modal_SelectEvent,
		general_Cancel,
		general_SaveAndClose,
		modal_EventName
	}
	get assignOptions() {
        return [
            { label: general_Yes, value: 'true' },
            { label: general_No, value: 'false' },
        ];
    }

	get notificationContent() {
        let messages = [];
        if (this.checkBoxShown) {
            messages.push(caseProgressIndicator_NotCaseOwner);
        }
        if (this.showEventList) {
            messages.push(modal_NoEvent);
        }
        return messages;
    }

    get showNotification() {
        return this.checkBoxShown || this.showEventList;
    }

	async connectedCallback() {
        try {
			await this.getAllEvents()
            this.subscription = await subscribe(this.channelName, -1, (event) => {
				this.getCaseEvent(event.data.payload.Syntilio__CaseId__c);
                this.handlePlatformEvent(event);
            });
        } catch (error) {
            this.showToast('Error', 'Failed to subscribe to platform events.', 'error');
        }
    }

	handlePlatformEvent(event) {
		console.time('Total open Modal time');
		const payload = event.data.payload;
		this.value = this.assignOptions.find(option => option.value === 'false').value;
		this.assignToMe = this.value;
		if(payload.Syntilio__TargetUserId__c === USER_ID && payload.Syntilio__Message__c === 'The case was closed by a non-owner.'){
			this.isNonOwner = true;
		}
		if(payload.Syntilio__Message__c === 'The case has no event.'){
			this.isNoEvent = true;
		}
		setTimeout(()=>{
			if (this.isNonOwner && this.isNoEvent) {
				this.prepareNoEventNonOwnerPopup(payload);
				this.isNonOwner = false;
				this.isNoEvent = false;
			} else if (this.isNonOwner) {
				this.prepareNonOwnerPopup(payload);
				this.isNonOwner = false;
			} else if (this.isNoEvent){
				this.prepareMissingEventPopup(payload);
				this.isNoEvent = false;
			}
		}, 50)
		console.timeEnd('Total open Modal time');
    }

	handleCheckboxChange(event) {
		this.assignToMe = event.detail.value;	
	}

	handleEventChange(event){
		this.selectedEvent = event.detail.value;
		this.isEventNull = false;
	}

	removeEvent(){
		this.selectedEvent = null;
		this.isEventNull = true;
	}

	async closeModal() {
		this.showModal = false;
		try{
			this.updateCaseStatus(this.eventData.Syntilio__CaseId__c, this.eventData.Syntilio__Status__c);
			await publishRefreshEvent({ caseId: this.eventData.Syntilio__CaseId__c, message: 'Canceled' });
			this.selectedEvent = null;
		}catch(error){
			this.logException(error, "updateCaseStatus");
		}
	}

	async submitDetails() {
		this.showModal = false;
		if (this.assignToMe==='true') {
			await this.assignCaseToUser(this.eventData.Syntilio__CaseId__c, USER_ID);
		}
		if(this.selectedEvent){
			this.setCaseEvent(this.eventData.Syntilio__CaseId__c, this.selectedEvent);
		}
		await publishRefreshEvent({ caseId: this.eventData.Syntilio__CaseId__c, message: 'Confirmed' });
		this.selectedEvent = null;
	}

	async assignCaseToUser(caseId, ownerId) {
		try {
			await setCaseOwner({ caseId: caseId, ownerId: ownerId });
		} catch (error) {
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "assignCaseToUser");
		}
	}

	async updateCaseStatus(caseId,newStatus) {
		try {
			await setCaseStatus({ caseId: caseId, status: newStatus });
			this.notifyUser(
				"Success",
				"Record updated successfully",
				this.toastTypes.Success
			);
		} catch (error) {
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "updateCaseStatus");
		}
	}

	async getAllEvents() {
		try {
			const events = await getAllEvents();
			this.allEvents = events.map(event => ({
				label: event.Name,
				value: event.Id
			}));
		} catch (error) {
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "getAllEvents");
		}
	}

	async setCaseEvent(caseId,eventId) {
		try{
			await setCaseEvent({ caseId: caseId, eventId: eventId });
		} catch (error) {
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "setCaseEvent");
		}
		finally{
			this.dispatchEvent(new RefreshEvent());
		}
	}

	async getCaseEvent(caseId) {
		try {
			const event = await getCaseEventCode({ caseId: caseId });
			if (event){
				this.isEventNull = false;
			} else{
				this.isEventNull = true;
			}
			
		} catch (error) {
			this.notifyUser(
				"Error",
				error.body ? error.body.message : error.message,
				this.toastTypes.Error
			);
			this.logException(error, "getCaseEvent");
		}
	}

	prepareNoEventNonOwnerPopup(payload) {
		this.checkBoxShown = true;
		this.showEventList = true;
		this.selectedEvent = null;
		this.popupText = "This case cannot be closed because it has no associated event, and you are not the case owner.";
		this.checkboxText = caseProgressIndicator_AssignCase;
		this.eventData = payload;
		this.showModal = true;
	}

	prepareNonOwnerPopup(payload) {
		this.checkBoxShown = true;
		this.showEventList = false;
		this.selectedEvent = null;
		this.popupText = caseProgressIndicator_NotCaseOwner;
		this.checkboxText = caseProgressIndicator_AssignCase;
		this.eventData = payload;
		this.showModal = true;
	}
	
	prepareMissingEventPopup(payload) {
		this.checkBoxShown = false;
		this.showEventList = true;
		this.popupText = "You do not have an event";
		this.eventData = payload;
		this.showModal = true;
	}
}
