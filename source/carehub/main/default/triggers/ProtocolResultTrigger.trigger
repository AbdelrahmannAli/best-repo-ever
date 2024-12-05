trigger ProtocolResultTrigger on Syntilio__ProtocolResult__c (before delete) {
	List<Id> protocolResultIds = Syntilio.DataHubUtilities.sObjectListToIdList(Trigger.old);
    List<SObject> sObjectsToDelete = new List<SObject>();
    sObjectsToDelete.addAll([
        SELECT Id FROM Syntilio__ProtocolPageQuestionResult__c WHERE Syntilio__ProtocolResultId__c IN :protocolResultIds
    ]);
    Syntilio.UpsertToDatabase.deleteAction(sObjectsToDelete, true);
}