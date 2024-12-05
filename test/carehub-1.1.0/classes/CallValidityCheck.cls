@RestResource(urlMapping='/CallValidityCheck/*')
global with sharing class CallValidityCheck {
    @HttpPatch
    global static void updateCallValidity() {
        RestRequest req = RestContext.request;
        String body = req.requestBody.toString();
        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        String phoneNumber = (String)bodyMap.get('phoneNumber');
        updateCallValidity(phoneNumber);
    }

    public static void updateCallValidity(String phoneNumber) {
        try {
            Syntilio__CareHubAppConfiguration__mdt careHubAppConfiguration = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
            
            Integer mistakenCallWindow = Integer.valueOf(careHubAppConfiguration.Syntilio__CallValidityMistakenWindow__c);
            Datetime now = System.now();
            Group targetQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Stall' WITH SECURITY_ENFORCED LIMIT 1];

            List<AgentWork> agentWorkList = [SELECT WorkItemId From AgentWork WHERE AssignedDateTime >= :now.addSeconds(-mistakenCallWindow) AND AssignedDateTime <= :now AND WorkItem.ContactPhone = :phoneNumber AND Status = 'Assigned' WITH SECURITY_ENFORCED];
            List<Id> casesIdList = new List<Id>();
            
            for(AgentWork agentWork : agentWorkList) {
                casesIdList.add(agentWork.WorkItemId);
            }
            
            List<Syntilio__CallLog__c> callLogList = new List<Syntilio__CallLog__c>();
            for(Id caseId : casesIdList) {
                callLogList.add(new Syntilio__CallLog__c(Syntilio__CaseId__c = caseId));
            }

            List<Database.SaveResult> insertedCallLogs = Syntilio.UpsertToDatabase.insertAction(callLogList, false);
            Syntilio.CareHubUtilities.createTasks(insertedCallLogs, 'Case', casesIdList, 'Failed to insert call log', 'Normal');

            List<Case> caseList = [SELECT Id, ContactId FROM Case WHERE Id IN :casesIdList WITH SECURITY_ENFORCED];
            List<Id> contactIds = new List<Id>();
            for(Case caseObj : caseList) {
                caseObj.Syntilio__Tag__c = 'Abandoned';
                caseObj.Status = 'Closed';
                caseObj.OwnerId = targetQueue.Id;
                contactIds.add(caseObj.ContactId);
            }

            List<Database.SaveResult> updatedCases = Syntilio.UpsertToDatabase.updateAction(caseList, false);
            Syntilio.CareHubUtilities.createTasks(updatedCases, 'Contact', contactIds, 'Failed to update case', 'Normal');
            delete agentWorkList;
        } catch (Exception e) {
            Syntilio.HandleException.logException(e);
        }
    }

}