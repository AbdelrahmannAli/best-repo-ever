trigger ContactAlertTrigger on Syntilio__ContactAlert__c (after insert, after update) {
	Syntilio.MedicalSummaryHandler.handleContactAlertTrigger(Trigger.operationType, Trigger.OldMap, Trigger.NewMap);
}