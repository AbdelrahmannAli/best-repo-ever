trigger FileTrigger on ContentVersion (after delete, after insert, after update) {
    if(!Test.isRunningTest()){
    	Syntilio.FileTriggerHandler.handleTrigger(Trigger.operationType, Trigger.OldMap, Trigger.NewMap);
    }
}