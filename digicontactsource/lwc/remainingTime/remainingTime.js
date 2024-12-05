import getRemainingTime from "@salesforce/apex/OrderRemainingTimeHandler.getRemainingTime";
import { LightningElement, api, track } from "lwc";
import { subscribe } from "lightning/empApi";
import logExceptionAsString from "@salesforce/apex/Syntilio.HandleException.logExceptionAsString";


export default class RemainingTime extends LightningElement {
    @api recordId;
    @api percentage = 0;
    @api remainingTime = 0;
    @api totalTime = 0;
    channelName = "/event/Syntilio__Notification__e";
    
    getRemainingTime() {
        getRemainingTime({ caseId: this.recordId })
            .then((result) => {
                const parsedResult = JSON.parse(result);
                if(!parsedResult.data) {
                    
                    return;
                }
                
                
                if(!parsedResult?.data?.productMinutes){
                    
                    
                    return;

                }
                this.totalTime = parsedResult?.data?.productMinutes;
                this.remainingTime = parsedResult?.data?.remainingMinutes?.toFixed(2)?? this.totalTime;
                
                
                this.percentage = ((this.remainingTime / this.totalTime) * 100).toFixed(2);
                
                
                
            })
            .catch((error) => {
                logExceptionAsString({ 
                    exceptionType: error.Name,
                    exceptionMessage: error.message, 
                    stackTrace: error.stack,
                    lineNumber: 122,
                    methodName: 'getRemainingTime',
                    className: 'OrderRemainingTimeHandler',
                    nameSpace: 'Syntilio',
                    source: this.exceptionTypes.LWC
                  });
            });
    }

    receiveProgress() {
        
        this.getRemainingTime();
    }

    handleSubscribe() {
        subscribe(this.channelName, -1, () => this.receiveProgress())
          .then((response) => {
            
          })
          .catch((error) => {
            logExceptionAsString({
              exceptionType: error.Name,
              exceptionMessage: error.message,
              stackTrace: error.stack,
              lineNumber: 268,
              methodName: "handleSubscribe",
              className: "FetchClients",
              nameSpace: "Syntilio",
              source: this.exceptionTypes.LWC
            })
          });
      }

    connectedCallback() {
        this.getRemainingTime();
        this.handleSubscribe();
    }
}