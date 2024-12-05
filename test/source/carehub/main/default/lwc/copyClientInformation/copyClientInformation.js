import { LightningElement, api, wire } from 'lwc';
import getContactData from '@salesforce/apex/GetCaseContact.getContactData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import general_Copy from '@salesforce/label/c.general_Copy';

export default class CopyContactInformation extends LightningElement {
    @api recordId; 
    buttonLabel = general_Copy;
    contact;
    wiredContact;

    @wire(getContactData, { caseId: '$recordId' })
    wiredGetContactData(result) {
        this.wiredContact = result;
        if (result.data) {
            this.contact = result.data;
        } else if (result.error) {
            this.contact = null;
            this.showToast('Error', 'Failed to retrieve contact information.', 'error');
            console.error('Error fetching contact data:', result.error);
        }
    }

    async refreshContactData() {
        if(this.wiredContact){
            try {
                await refreshApex(this.wiredContact);
            } catch (error) {
                console.error('Error refreshing contact data:', error);
            }
        }
    }

    async copyToClipboard() {
        try {
            await this.refreshContactData();

            if (this.contact) {
                const { Name, Birthdate, Syntilio__UserId__c, MailingAddress } = this.contact;

                const contactInfo = `${Name || 'N/A'}\n${this.formatDate(Birthdate) || 'N/A'}\n${Syntilio__UserId__c || 'N/A'}\n${this.formatMailingAddress(MailingAddress) || 'N/A'}`;

                await navigator.clipboard.writeText(contactInfo.trim());
                this.showToast('Success', 'Contact information copied to clipboard!', 'success');
            } else {
                this.showToast('Error', 'No contact data available to copy.', 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Failed to copy contact information.', 'error');
            console.error('Error copying contact information:', error);
        }
    }

    formatDate(dateString) {
        if (!dateString) return null;
        const date = new Date(dateString);
        const day = String(date.getDate()).padStart(2, '0');
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const year = date.getFullYear();
        return `${day}-${month}-${year}`;
    }

    formatMailingAddress(address) {
        if (!address) return null;
        return `${address.street || ''}, ${address.city || ''}, ${address.state || ''}, ${address.postalCode || ''}, ${address.country || ''}`.trim();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}
