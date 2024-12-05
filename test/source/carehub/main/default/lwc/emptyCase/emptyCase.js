import { api, LightningElement } from 'lwc';
import createCase from '@salesforce/apex/ClientCasesController.createCase';
import { NavigationMixin } from 'lightning/navigation';


export default class EmptyCase extends NavigationMixin(LightningElement) {
    @api
    async createNewCase() {
        const caseId = await createCase();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }
}