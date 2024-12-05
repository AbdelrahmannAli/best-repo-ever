public with sharing class CaseTriggerHelper {
    
    public static void deleteCareObservationRecordsWhenCaseIsClosed(List<Case> newList) {
        list<CareObservation> careObservationToDeleteRecordsList = new list<CareObservation>();
        
        if (newList == null || newList.isEmpty())
            return;
        for(Case caseRecord :newList){
            if(caseRecord.Status.startsWithIgnoreCase('Closed') && caseRecord.AccountId != null ){
                try {
                    careObservationToDeleteRecordsList = [SELECT Id FROM CareObservation WHERE CodeId IN (SELECT Id FROM CodeSet WHERE Code =: caseRecord.Syntilio__CodeSet__c) AND ObservedSubjectId =: caseRecord.AccountId];
                } catch(Exception e){
                    Syntilio.HandleException.logException(e);
                }
            }
        }
        
        if(careObservationToDeleteRecordsList != null || !careObservationToDeleteRecordsList.isEmpty())
            delete careObservationToDeleteRecordsList;
    }
    
}