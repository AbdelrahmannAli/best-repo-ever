trigger ContactPostalCodeTrigger on Contact (after insert, after update) {
    if(Trigger.isInsert) {
        Syntilio.PostalCodeInfoHandler.handleContactInsert(Trigger.newMap);
    } else if(Trigger.isUpdate) {
        Syntilio.PostalCodeInfoHandler.handleContactUpdate(Trigger.oldMap, Trigger.newMap);
    }
}