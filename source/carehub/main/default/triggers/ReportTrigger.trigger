trigger ReportTrigger on Syntilio__MedicalReport__c (after delete, after insert, after update) {
    if(!Test.isRunningTest()){
    	Syntilio.ReportTriggerHandler.handleTrigger(Trigger.operationType, Trigger.OldMap, Trigger.NewMap);
    }
}