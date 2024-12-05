trigger ProtocolProtocolPageQuestionTrigger on Syntilio__ProtocolPageQuestion__c (before delete) {
	List<Id> protocolPageQuestionIds = Syntilio.DataHubUtilities.sObjectListToIdList(Trigger.old);
    List<SObject> sObjectsToDelete = new List<SObject>();
    sObjectsToDelete.addAll([
        SELECT Id FROM Syntilio__ProtocolPageQuestionResult__c WHERE Syntilio__ProtocolPageQuestionId__c IN :protocolPageQuestionIds
    ]);
    Syntilio.UpsertToDatabase.deleteAction(sObjectsToDelete, true);
}