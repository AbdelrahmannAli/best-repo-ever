trigger CaseTrigger on Case (after insert,after update,before update ) {

    Id contactId = null;
    Id oldContactId = null;
    Id eventId = null;
    Id oldEventId = null;
    List<Syntilio__EventConfiguration__c> eventConfigurationsList = [
        SELECT Id, Syntilio__Sync__c 
        FROM Syntilio__EventConfiguration__c
        LIMIT 1000
    ];
    Map<String, Object> eventConfigurationsMap = Syntilio.DataHubUtilities.listToMap('Id', 'Syntilio__Sync__c', eventConfigurationsList);
    Map<Id, Case> oldMap = new Map<Id, Case>();
    Map<Id, Case> newMap = new Map<Id, Case>();
    if (Trigger.isAfter && Trigger.isUpdate && Syntilio.TriggerUpdated.isTriggerExecuted) return;
    if(Trigger.OldMap != null){
        oldMap = Trigger.OldMap.deepClone();
    }
    if(Trigger.NewMap != null){
        newMap = Trigger.NewMap.deepClone();
    }
    for(Case triggeringCase : Trigger.new) {
        Case oldCase = oldMap.get(triggeringCase.Id);
        if(eventConfigurationsMap.get(triggeringCase.Syntilio__Event__c) != true && Trigger.isInsert){
            oldMap.remove(triggeringCase.Id);
            newMap.remove(triggeringCase.Id);
        }
        contactId = triggeringCase.ContactId;
        eventId = triggeringCase.Syntilio__Event__c;
        if (Trigger.isUpdate){
            oldContactId = oldCase.ContactId;
            oldEventId = oldCase.Syntilio__Event__c;
        }
    }

    if(!Test.isRunningTest() && contactId != null && eventId!=null && Trigger.isAfter && (Trigger.isInsert || (Trigger.isUpdate && (oldContactId != contactId || oldEventId != eventId)))){
        Syntilio.CaseCareCircleTriggerHandler.handleTrigger(Trigger.operationType, oldMap, newMap);
        Syntilio.MedicalSummaryHandler.handleTrigger(Trigger.operationType, oldMap, newMap);
        Syntilio.ReportHandler.handleTrigger(Trigger.operationType, oldMap, newMap);
        Syntilio.MedicalNotesHandler.handleTrigger(Trigger.operationType, oldMap, newMap);
        Syntilio.AppointmentHandler.handleTrigger(Trigger.operationType, oldMap, newMap);
        Syntilio.ContactNotesHandler.handleTrigger(Trigger.operationType, oldMap, newMap);
        Syntilio.TriggerUpdated.isTriggerExecuted = true;
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        Syntilio.CaseStatusTriggerHandler.handleTrigger(oldMap, newMap);
    }
}