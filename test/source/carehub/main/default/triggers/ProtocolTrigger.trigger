trigger ProtocolTrigger on Syntilio__Protocol__c (before delete) {
    List<Id> protocolIds = Syntilio.DataHubUtilities.sObjectListToIdList(Trigger.old);
    List<SObject> sObjectsToDelete = new List<SObject>();
    sObjectsToDelete.addAll([
        SELECT Id FROM Syntilio__ProtocolPage__c WHERE Syntilio__ProtocolId__c IN :protocolIds
    ]);
    sObjectsToDelete.addAll([
        SELECT Id FROM Syntilio__ProtocolResult__c WHERE Syntilio__ProtocolId__c IN :protocolIds
    ]);
    Syntilio.UpsertToDatabase.deleteAction(sObjectsToDelete, true);
}