/* eslint-disable no-unused-vars */
import { track, api, wire } from "lwc";
import updateAppointmentCareTeamId from "@salesforce/apex/CareTeamHandler.updateCaseCareTeamId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCareTeams from "@salesforce/apex/CareTeamHandler.getCareTeams";
import logExceptionAsString from "@salesforce/apex/HandleException.logExceptionAsString";
import UtilityLWC from "c/utils";

export default class AvailableCareTeams extends UtilityLWC {
  @api recordId;
  @track newCareTeamId;
  @track careTeamList = [];
  @track showCareTeamList = false;
  @track options;
  @track tableColumns = ["Care Team", "Care Organization", "Phone"];

  @wire(getCareTeams, { caseId: "$recordId" })
  getCareTeams({ error, data }) {
    if (data) {
      try {
        data = JSON.parse(data);
        // 
        if (!data.isSuccess) {
          this.openNotification("Care Team Warning", data.message, "warning");
          return;
        }
        let resultData = data.data;
        let allCareTeamsData = resultData.allCareTeams;
        let deepCopiedData = allCareTeamsData.map((item) =>
          Object.assign({}, item, { selected: false })
        );

        deepCopiedData.map((careTeam, index) => {
          deepCopiedData[index].isParent =
            String(resultData.parentCareOrgId) === String(careTeam.Account.Id);
          deepCopiedData[index].AccountName = careTeam.Account.Name;
          deepCopiedData[index].AccountUrl = "/" + careTeam.Account.Id;
          deepCopiedData[index].ContactUrl = "/" + careTeam.Id;
          deepCopiedData[index].isAvailable = true;
          deepCopiedData[index].style = "slds-hint-parent available";

          return deepCopiedData;
        });

        let careOrgTeams = resultData.careOrgTeams;
        let deepCopiedCareOrgTeams = careOrgTeams.map((item) =>
          Object.assign({}, item, { selected: false })
        );

        deepCopiedCareOrgTeams.map((item) => {
          item.isAvailable = this.isAvailable(deepCopiedData, item.Name);

          if (item.isAvailable) {
            deepCopiedCareOrgTeams = deepCopiedCareOrgTeams.filter((team) => {
              return !(team.Name === item.Name);
            });
          } else {
            item.isParent =
              String(resultData.parentCareOrgId) === String(item.Account.Id);
            item.style = item.isAvailable
              ? "slds-hint-parent available"
              : "slds-hint-parent slds-current-color disabled";
          }

          return item;
        });

        const allCareTeams = deepCopiedData.concat(deepCopiedCareOrgTeams);
        allCareTeams.sort(this.compare);
        this.careTeamList = allCareTeams;

        this.showCareTeamList = this.careTeamList.length > 0;
      } catch (LogiclError) {
        //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
        logExceptionAsString({
          exceptionType: LogiclError.Name,
          exceptionMessage: LogiclError.message,
          stackTrace: LogiclError.stack,
          lineNumber: 71,
          methodName: "getCareTeams",
          className: "AvailableCareTeams",
          nameSpace: "Syntilio",
          source: this.exceptionTypes.LWC
        });
        
      }
    } else if (error) {
      //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
      logExceptionAsString({
        exceptionType: error.Name,
        exceptionMessage: error.message,
        stackTrace: error.stack,
        lineNumber: 85,
        methodName: "getCareTeams",
        className: "AvailableCareTeams",
        nameSpace: "Syntilio",
        source: this.exceptionTypes.LWC
      });
      
      this.openNotification(
        "Care Team Unexpected Error",
        "We were unable to handle available care teams",
        "error"
      );
    }
  }

  isAvailable(deepCopiedData, name) {
    let flag =
      [...deepCopiedData].filter((item) => {
        return item.Name === name;
      }).length > 0;

    return flag;
  }

  getSelectedName(event) {
    this.newCareTeamId = event.target.value;
  }

  compare(a, b) {
    if (a.isParent) {
      return -1;
    }
    if (!a.isParent) {
      return 1;
    }
    return 0;
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

  handleSubmit() {
    updateAppointmentCareTeamId({
      caseId: this.recordId,
      newCareTeamId: this.newCareTeamId
    })
      .then(() => {
        this.openNotification("Success", "Case updated", "success");
      })
      .catch((error) => {
        //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
        logExceptionAsString({
          exceptionType: error.Name,
          exceptionMessage: error.message,
          stackTrace: error.stack,
          lineNumber: 147,
          methodName: "handleSubmit",
          className: "AvailableCareTeams",
          nameSpace: "Syntilio",
          source: this.exceptionTypes.LWC
        });
        
        this.openNotification("Care Team Error", error.body.message, "error");
      });
  }

  connectedCallback() {
    super.connectedCallback();
  }
}
