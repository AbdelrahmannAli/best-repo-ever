import { LightningElement, track } from 'lwc';
import fetchAllClients from '@salesforce/apex/FetchAllClientsHandler.fetchAllClientsGenerator';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FetchAllClients extends LightningElement {
    @track fromClient;
    @track toClient;
    @track chunkSize;

    handleFromClient(event) {
        this.fromClient = event.target.value;
    }

    handleToClient(event) {
        this.toClient = event.target.value;
    }

    handleChunkSize(event) {
        this.chunkSize = event.target.value;
    }

    handleButtonClick() {
        fetchAllClients({ fromClient: this.fromClient, toClient: this.toClient, chunkSize: this.chunkSize})
            .then(() => {
                this.openNotification("Success", "Clients fetching is processing.", "success");
            })
            .catch((error) => {
                this.openNotification("Error", `Error occurred ${error}`, "error");
            });
    }

    openNotification(title, message, type) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: type
            })
        );
    }
}
