trigger CaseTrigger on Case (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    TriggerEnablerConfiguration__mdt caseTriggerEnablerConfiguration = TriggerEnablerConfiguration__mdt.getInstance('MedHubCaseTriggerEnabler');

    //if(Trigger.isBefore && Trigger.isInsert && caseTriggerEnablerConfiguration.BeforeInsert__c)
      //CaseTriggerHandler.isBeforeInsert(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.NewMap);
    //else if(Trigger.isBefore && Trigger.isUpdate && caseTriggerEnablerConfiguration.BeforeUpdate__c)
      //CaseTriggerHandler.isBeforeUpdate(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.NewMap);
    //else if(Trigger.isBefore && Trigger.isDelete && caseTriggerEnablerConfiguration.BeforeDelete__c)
      //CaseTriggerHandler.isBeforeDelete(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.NewMap);
    //else if(Trigger.isAfter && Trigger.isInsert && caseTriggerEnablerConfiguration.AfterInsert__c)
      //CaseTriggerHandler.isAfterInsert(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.NewMap);
    //else 
        if(Trigger.isAfter && Trigger.isUpdate && caseTriggerEnablerConfiguration.AfterUpdate__c)
      CaseTriggerHandler.isAfterUpdate(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.NewMap);
    //else if(Trigger.isAfter && Trigger.isDelete && caseTriggerEnablerConfiguration.AfterDelete__c)
      //CaseTriggerHandler.isAfterDelete(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.NewMap);
    //else if(Trigger.isAfter && Trigger.isUndelete && caseTriggerEnablerConfiguration.AfterUndelete__c)
      //CaseTriggerHandler.isAfterUndelete(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.NewMap);
}