trigger ProtocolPageTrigger on Syntilio__ProtocolPage__c (before delete) {
	List<Id> protocolPageIds = Syntilio.DataHubUtilities.sObjectListToIdList(Trigger.old);
    List<SObject> sObjectsToDelete = new List<SObject>();
    sObjectsToDelete.addAll([
        SELECT Id FROM Syntilio__ProtocolPageQuestion__c WHERE Syntilio__ProtocolPageId__c IN :protocolPageIds
    ]);
    Syntilio.UpsertToDatabase.deleteAction(sObjectsToDelete, true);
}