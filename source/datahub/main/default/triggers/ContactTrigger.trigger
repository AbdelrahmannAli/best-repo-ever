trigger ContactTrigger on Contact (after insert, before insert, after update, after delete, before update, before delete, after undelete) {
    if(!Test.isRunningTest()){
		Syntilio.ContactTriggerHandler.handleTrigger(Trigger.operationType, Trigger.OldMap, Trigger.NewMap);
	}
}