trigger MedicalPolicyTrigger on Syntilio__MedicalPolicy__c (after insert, after update) {
    Syntilio.MedicalSummaryHandler.handleMedicalPolicyTrigger(Trigger.operationType, Trigger.OldMap, Trigger.NewMap);
}