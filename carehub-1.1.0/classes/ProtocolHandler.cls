@NamespaceAccessible
public with sharing class ProtocolHandler {
    public enum Status {NOT_STARTED, IN_PROGRESS, FINISHED}
    
    @AuraEnabled(cacheable=false)
    public static String getFlow(Id caseId, Boolean initFlowEvents) {
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionRelationList = Syntilio.ProtocolHandler.getCaseActions(caseId);   
        List<Syntilio__ProtocolActionRelation__c> deepCopyProtocolActionRelationList = new List<Syntilio__ProtocolActionRelation__c>();
        
        for(Syntilio__ProtocolActionRelation__c relation : protocolActionRelationList) {
            deepCopyProtocolActionRelationList.add(relation);
        }
        
        Syntilio.ProtocolHandler.insertCaseProtocolActionResult(caseId , deepCopyProtocolActionRelationList);
        return JSON.serialize(protocolActionRelationList) ;
    }

    @AuraEnabled(cacheable=false)
    public static String getClients() {
        Id clientContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, FirstName, LastName,Birthdate,MailingStreet,MailingPostalCode FROM Contact WHERE RecordTypeId =: clientContactRecordTypeId WITH SECURITY_ENFORCED];
        return JSON.serialize(contacts) ;
    }

    @AuraEnabled(cacheable=false)
    public static void updateCaseProtocolActionResult(Id caseId, Id protocolActionId, String flowStatus ) {
        List<Syntilio__ProtocolActionResult__c> caseProtocolActionResult = [
            SELECT Syntilio__FlowStatus__c 
            FROM Syntilio__ProtocolActionResult__c
            WHERE Syntilio__Case__c= :caseId AND
            Syntilio__ProtocolAction__c = :protocolActionId 
            AND Syntilio__FlowStatus__c != 'FINISHED'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if(caseProtocolActionResult.size() == 0) return;
        caseProtocolActionResult[0].Syntilio__FlowStatus__c = flowStatus;
        update caseProtocolActionResult[0];
    }
        
    @AuraEnabled(cacheable=false)
    public static void insertCaseProtocolActionResult(Id caseId, List<Syntilio__ProtocolActionRelation__c> actionRelationList) {
        
        List<String> unFinishedActions = Syntilio.ProtocolHandler.getFinishedOrUnfinishedCaseActions(caseId, False, True, True);
        List<Syntilio__ProtocolActionRelation__c> unFoundProtocolActions = removeAll(actionRelationList, unFinishedActions);
        List<Syntilio__ProtocolActionResult__c> caseProtocolActionResults = new List<Syntilio__ProtocolActionResult__c>();
        
        for(Syntilio__ProtocolActionRelation__c actionRelation : unFoundProtocolActions) {
            Syntilio__ProtocolActionResult__c actionResult = new Syntilio__ProtocolActionResult__c();
            actionResult.Syntilio__Case__c = caseId;
            actionResult.Syntilio__ProtocolAction__c = actionRelation.Syntilio__ProtocolAction__r.Id;
            actionResult.Syntilio__FlowStatus__c = Status.NOT_STARTED.name();
            caseProtocolActionResults.add(actionResult);
        }
        
        insert caseProtocolActionResults;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Syntilio__ProtocolActionRelation__c> getCaseActions(Id caseId) {
        Case requestedCase = [
            SELECT Id, ContactId, Syntilio__Event__c
            FROM Case
            WHERE Id = :caseId
            WITH SECURITY_ENFORCED
        ];

        List<Syntilio__GroupMember__c> groups = [SELECT Syntilio__GroupId__c FROM Syntilio__GroupMember__c WHERE (Syntilio__ContactId__c = :requestedCase.ContactId AND Syntilio__GroupId__r.Syntilio__ObjectType__c = 'Contact') OR (Syntilio__EventConfigurationId__c = :requestedCase.Syntilio__Event__c AND Syntilio__GroupId__r.Syntilio__ObjectType__c = 'Event Configuration') WITH SECURITY_ENFORCED];

        List<Id> groupIds = new List<Id>();
        
        for(Syntilio__GroupMember__c groupMember : groups) {
            groupIds.add(groupMember.Syntilio__GroupId__c);
        }
        

        List<Syntilio__Protocol__c> protocolsList = [ SELECT Id FROM Syntilio__Protocol__c WHERE Id IN (SELECT Syntilio__Protocol__c
                                                                                                        FROM Syntilio__ProtocolActivator__c
                                                                                                        WHERE ((Syntilio__ContactId__c = :requestedCase.ContactId AND Syntilio__ContactId__c != null)
                                                                                                               OR (Syntilio__Event__c  = :requestedCase.Syntilio__Event__c  AND Syntilio__Event__c != null) OR (Syntilio__Global__c = true) OR
                                                                                                                (Syntilio__GroupId__c IN :groupIds AND Syntilio__GroupId__c != null)
                                                                                                            )
                                                                                                        AND Syntilio__Active__c = true) WITH SECURITY_ENFORCED];
                                                                                                        
        
        List<Syntilio__ProtocolAction__c> unFinishedprotocolActions =   [SELECT Id
                                                                         FROM Syntilio__ProtocolAction__c
                                                                         WHERE Id IN (SELECT Syntilio__ProtocolAction__c  
                                                                                      FROM Syntilio__ProtocolActionResult__c
                                                                                      WHERE Syntilio__FlowStatus__c != 'FINISHED'
                                                                                      AND Syntilio__Case__c = :caseId ) WITH SECURITY_ENFORCED];
        
        List<Syntilio__ProtocolAction__c> createdProtocolActions =  [SELECT Id  
                                                                     FROM Syntilio__ProtocolAction__c
                                                                     WHERE Id IN (SELECT Syntilio__ProtocolAction__c  
                                                                                  FROM Syntilio__ProtocolActionResult__c
                                                                                  WHERE Syntilio__Case__c = :caseId ) WITH SECURITY_ENFORCED];
        List<Syntilio__ProtocolActionRelation__c> activatorProtocolActionRelationList = [      
            SELECT Syntilio__Protocol__c, Syntilio__Protocol__r.Name ,Syntilio__ProtocolAction__r.Id, Syntilio__ProtocolAction__r.Name,
            Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c, Syntilio__ProtocolAction__r.Syntilio__Questionnaire__c,Syntilio__Protocol__r.Syntilio__Image__c,Syntilio__Protocol__r.Syntilio__Description__c,Syntilio__Protocol__r.Syntilio__EstimatedTime__c
            FROM Syntilio__ProtocolActionRelation__c AS r
            WHERE Syntilio__Protocol__c IN :protocolsList
            AND (Syntilio__ProtocolAction__c IN :unFinishedprotocolActions OR Syntilio__ProtocolAction__c NOT IN :createdProtocolActions) 
            WITH SECURITY_ENFORCED
            ORDER BY Syntilio__Order__c ASC
        ];        
        
        Set<Id> protocolActionsSet = new Set<Id>();
        for(Integer i = 0; i < activatorProtocolActionRelationList.size(); i++) {
            if(protocolActionsSet.contains(activatorProtocolActionRelationList[i].Syntilio__ProtocolAction__r.Id)) {
                activatorProtocolActionRelationList.remove(i);
                i--;
            } else {
                protocolActionsSet.add(activatorProtocolActionRelationList[i].Syntilio__ProtocolAction__r.Id);
            }
        }        
        return activatorProtocolActionRelationList;
    }
    
    
    @AuraEnabled(cacheable=false)
    public static List<String> getFinishedOrUnfinishedCaseActions(Id caseId, Boolean finished, Boolean apiName, Boolean getOptionalToo) {
        String query = 'SELECT Name, Syntilio__TypeApiName__c, Syntilio__Optional__c ' +
            'FROM Syntilio__ProtocolAction__c ' +
            'WHERE Id IN (SELECT Syntilio__ProtocolAction__c ' +
            'FROM Syntilio__ProtocolActionResult__c ' +
            'WHERE Syntilio__Case__c = :caseId AND Syntilio__FlowStatus__c'; 
        
        query += finished == True ? '=' : '!=';
        query += '\'FINISHED\')';
        if(getOptionalToo == false) {
            query += 'AND Syntilio__Optional__c = false';
        }
        query += ' WITH SECURITY_ENFORCED';
        List<Syntilio__ProtocolAction__c> caseProtocolActionResults = Database.query(query);
        Set<String> caseActions = new Set<String>();
        for(Syntilio__ProtocolAction__c actionResult : caseProtocolActionResults) {
            String currentActionInfo = apiName ? actionResult.Syntilio__TypeApiName__c : actionResult.Name;
            caseActions.add(currentActionInfo);
        }
        
        List<String> convertedReturnedActionsList = new List<String>(caseActions);          
        return convertedReturnedActionsList;
    }
    @NamespaceAccessible
    public static List<Syntilio__ProtocolActionRelation__c> removeAll(List<Syntilio__ProtocolActionRelation__c> allList, List<String> removalList) {
        for(Integer i = 0 ; i < allList.size(); i++) {
            if(removalList.contains(allList[i].Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c )) {
                allList.remove(i);
                i--;
            }
        }  
        return allList;
    }
    @NamespaceAccessible
    public static Decimal getNextOrder(Id protocolId) {
        List<Syntilio__ProtocolActionRelation__c> relatedProtocolActionRelations = [
            SELECT Id, Syntilio__Order__c
            FROM Syntilio__ProtocolActionRelation__c
            WHERE Syntilio__Protocol__c = :protocolId
            WITH SECURITY_ENFORCED
            ORDER BY Syntilio__Order__c DESC
            LIMIT 1
        ];
        Decimal currentOrder = 0;
        if(relatedProtocolActionRelations.size() > 0) {
            currentOrder = relatedProtocolActionRelations[0].Syntilio__Order__c;
        }

        return currentOrder + 1;
    }
}