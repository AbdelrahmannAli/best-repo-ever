@NamespaceAccessible
public with sharing class SendCaseReportHandler {

    @AuraEnabled(cacheable=false)
    public static void sendCaseReport(Syntilio__MedicalReport__c report){
        try {
            Id caseId = report.Syntilio__CaseId__c;
            List<Case> cases = [SELECT Id, ContactId From Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
            if(cases.size() == 0) return;
            report.Syntilio__ContactId__c = cases[0].ContactId;
            report.Syntilio__ExternalUpdatedAt__c = Datetime.now();
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(report);
            Syntilio.UpsertToDatabase.insertAction(sObjectList,false);
            Syntilio.CareHubUtilities.notifyLwc('', 'ReportHandler', 'NewReportCreated');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}