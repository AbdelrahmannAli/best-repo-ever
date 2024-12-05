@NamespaceAccessible
public with sharing class CareHubUtilities {
    @TestVisible private static Boolean raiseException = false;
    public static Set<Id> recordsBeingUpdated = new Set<Id>();
    public enum Status {Success, Failure, Warning}

    @AuraEnabled(cacheable=true)
    public static String getSobjectFromId(Id sObjectId) {
        return Syntilio.DataHubUtilities.getSobjectFromId(sObjectId);
    }
    @NamespaceAccessible
    public static Syntilio.ResponseMessage getExternalSystemId(String externalSystem) {
        List<Syntilio__ExternalSystem__c> externalSystems = [
            SELECT Id
            FROM Syntilio__ExternalSystem__c
            WHERE Syntilio__ApiName__c = :externalSystem
            WITH SECURITY_ENFORCED
        ];
        
        if (externalSystems.size() == 0) {
            Syntilio.ResponseMessage response = new Syntilio.ResponseMessage(
                '',
                'External system not found; please verify the external system api name existence',
                Syntilio.ResponseMessage.MessageType.ERROR
            );
            return response;
        }
        return new Syntilio.ResponseMessage(
            String.valueOf(externalSystems[0].Id),
            'Success',
            Syntilio.ResponseMessage.MessageType.SUCCESS
        );
    }
    
    @NamespaceAccessible
    public static Syntilio.ResponseMessage getLocationId(String accountId, String externalSystem) {
        List<Syntilio__ExternalSystem__c> externalSystems = [
            SELECT Id, Syntilio__ApiName__c
            FROM Syntilio__ExternalSystem__c
            WHERE Syntilio__ApiName__c = :externalSystem
            WITH SECURITY_ENFORCED
        ];
        
        if (externalSystems.size() == 0) {
            Syntilio.ResponseMessage response = new Syntilio.ResponseMessage(
                '',
                'External system not found; please verify the system existence and configuration',
                Syntilio.ResponseMessage.MessageType.ERROR
            );
            return response;
        }
        
        String externalSystemId = externalSystems[0].Id;
        List<Schema.Location> locationIds = [
            SELECT Syntilio__LocationId__c
            FROM Location
            WHERE
            Syntilio__AccountId__c = :accountId
            AND Syntilio__ExternalSystemId__c = :externalSystemId
            WITH SECURITY_ENFORCED
        ];
        
        if (locationIds.size() == 0) {
            Syntilio.ResponseMessage response = new Syntilio.ResponseMessage(
                '',
                'Unable to locate the specified external system at the provided location for the associated account; please verify the accuracy of the location and account details.',
                Syntilio.ResponseMessage.MessageType.ERROR
            );
            return response;
        }
        
        return new Syntilio.ResponseMessage(
            String.valueOf(locationIds[0].Syntilio__LocationId__c),
            'Success',
            Syntilio.ResponseMessage.MessageType.SUCCESS
        );
    }
    
    @AuraEnabled
    public static List<String> getAccountExternalSystems(String accountId) {
        List<Syntilio__AccountExternalSystemAssociation__c> accountExternalSystems = [
            SELECT Syntilio__ExternalSystemId__r.Syntilio__ApiName__c
            FROM Syntilio__AccountExternalSystemAssociation__c
            WHERE Syntilio__AccountId__c = :accountId
            WITH SECURITY_ENFORCED
        ];
        List<String> externalSystems = new List<String>();
        for (
            Syntilio__AccountExternalSystemAssociation__c accountExternalSystem : accountExternalSystems
        ) {
            externalSystems.add(
                accountExternalSystem.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c
            );
        }
        return externalSystems;
    }
    @NamespaceAccessible
    public static void createTasks(
        List<Database.SaveResult> insertedRecords,
        String objectType,
        List<String> recordId,
        String subject,
        String priority
    ) {
        try {
            if(Test.isRunningTest() && Syntilio.CareHubUtilities.raiseException == true) {
                throw new DmlException();
            }
            List<Task> tasks = new List<Task>();
            for (Integer i = 0; i < insertedRecords.size(); i++) {
                Database.SaveResult insertedRecord = insertedRecords[i];
                if (insertedRecord.isSuccess()) {
                    continue;
                }
                Task newTask = Syntilio.DataHubUtilities.createTask(
                    objectType,
                    recordId[i],
                    subject,
                    insertedRecord.getErrors()[0].getMessage(),
                    priority
                );
                tasks.add(newTask);
            }
            if (tasks.size() == 0)
                return;
            List<Database.SaveResult> insertedTasks = Syntilio.UpsertToDatabase.insertAction(
                tasks,
                false
            );
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }
    
    @NamespaceAccessible
    public static Schema.Location getParentLocation(
        String accountId,
        String externalSystem
    ) {
        List<Schema.Location> parentLocation = [
            SELECT
            ParentLocationId,
            Syntilio__LocationId__c,
            Syntilio__ExternalSystemId__c,
            Syntilio__AccountId__c
            FROM Location
            WHERE
            Syntilio__AccountId__c = :accountId
            AND Syntilio__ExternalSystemId__r.Syntilio__ApiName__c = :externalSystem
            AND ParentLocationId = NULL
            WITH SECURITY_ENFORCED
        ];
        return parentLocation[0];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
    
    @NamespaceAccessible
    public static SObject getRecordById(String objectApiName, Id recordId) {
        String formatString = 'SELECT Id, Syntilio__Order__c FROM {0} WHERE Id = :recordId WITH SECURITY_ENFORCED';
        String[] variableList = new List<String>{ objectApiName };
            String query = String.format(formatString, variableList);
        List<SObject> recordsFound = Database.query(query);
        if (recordsFound.size() == 0) {
            return null;
        }
        return recordsFound[0];
    }
    
    // TEST THIS
    @NamespaceAccessible
    public static Boolean reorderRecords(
        String objectApiName,
        Decimal newOrder,
        Id recordId,
        String condition
    ) {
        try {
            if(Test.isRunningTest() && Syntilio.CareHubUtilities.raiseException == true) {
                throw new DmlException();
            }
            
            if (recordId == null && newOrder == null) {
                return false;
            }
            // First, get the record from the database and check if the newOrder is < the old order
            SObject record = getRecordById(objectApiName, recordId);
            String formatString =
                'SELECT Id, Syntilio__Order__c FROM {0} WHERE ' +
                condition +
                (condition != null && condition != '' ? ' AND ' : '');
            String query = '';
            List<String> variableList;
            Integer orderAddition = 1;
            if (recordId != null) {
                Decimal oldOrder = (Decimal) record.get('Syntilio__Order__c');
                if (newOrder == null) {
                    // in case of delete
                    formatString += 'Syntilio__Order__c > :oldOrder WITH SECURITY_ENFORCED ';
                    variableList = new List<String>{ objectApiName };
                        query = String.format(formatString, variableList);
                    orderAddition = -1;
                } else {
                    // in case of update
                    // if higher priority:
                    //    get records where Order >= newOrder & Order < oldOrder
                    // else:
                    //    get records where Order <= newOrder & Order > oldOrder
                    Boolean higherPriority = newOrder < oldOrder;
                    String oldOrderCondition = higherPriority ? '<' : '>';
                    String newOrderCondition = higherPriority ? '>=' : '<=';
                    formatString += 'Syntilio__Order__c {1} :oldOrder AND Syntilio__Order__c {2} :newOrder WITH SECURITY_ENFORCED';
                    variableList = new List<String>{
                        objectApiName,
                            oldOrderCondition,
                            newOrderCondition
                            };
                                query = String.format(formatString, variableList);
                    if (!higherPriority) {
                        orderAddition = -1;
                    }
                }
            } else {
                formatString += 'Syntilio__Order__c >= :newOrder';
                variableList = new List<String>{ objectApiName };
                    query = String.format(formatString, variableList);
            }
            List<SObject> recordsFound = Database.query(query);
            if (recordsFound.size() == 0) {
                return true;
            }
            
            for (SObject oneRecord : recordsFound) {
                Syntilio.CareHubUtilities.recordsBeingUpdated.add(oneRecord.Id);
                Decimal updatedOrder =
                    (Decimal) oneRecord.get('Syntilio__Order__c') + orderAddition;
                oneRecord.put('Syntilio__Order__c', updatedOrder);
            }
            List<Database.SaveResult> updatedRecords = Syntilio.UpsertToDatabase.updateAction(
                recordsFound,
                true
            );
            Syntilio.CareHubUtilities.recordsBeingUpdated.clear();
            return true;
        } catch (Exception e) {
            Syntilio.CareHubUtilities.recordsBeingUpdated.clear();
            Syntilio.HandleException.LogException(e);
            return false;
        }
    }
    
    @NamespaceAccessible
    public static Decimal getNextOrder(
        String objectApiName,
        Boolean isUpdate,
        String condition
    ) {
        try {
            if(Test.isRunningTest() && Syntilio.CareHubUtilities.raiseException == true) {
                throw new DmlException();
            }
            String formatString = 'SELECT Id, Syntilio__Order__c FROM {0} WHERE {1} WITH SECURITY_ENFORCED ORDER BY Syntilio__Order__c  DESC LIMIT 1';
            List<String> variableList = new List<String>{ objectApiName, condition };
                String query = String.format(formatString, variableList);
            List<SObject> recordsFound = Database.query(query);
            if (recordsFound.size() == 0) {
                return 1;
            }
            if (isUpdate) {
                return (Decimal) recordsFound[0].get('Syntilio__Order__c');
            }
            return (Decimal) recordsFound[0].get('Syntilio__Order__c') + 1;
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return 1;
        }
    }
    
    @AuraEnabled
    public static String getContactReport(Id caseId) {
        return Syntilio.ReportHandler.getContactReport(caseId);
    }

    @NamespaceAccessible
    public static void updateCaseContactId(Id caseId, String clientId) {
    Case[] caseToUpdate = [
        SELECT ContactId 
        FROM Case 
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
    ];
    if (caseToUpdate.size() == 0) {
        return;
    }
    for (Case c : caseToUpdate) {
        c.ContactId = clientId;
        c.AccountId = null;
    }
    Syntilio.UpsertToDatabase.updateAction(caseToUpdate,true);
}

    @NamespaceAccessible
    public static void updateCaseCaller(Id caseId, String callerId) {
    Case[] caseToUpdate = [
        SELECT ContactId 
        FROM Case 
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
    ];
    if (caseToUpdate.size() == 0) {
        return;
    }
    
    for (Case c : caseToUpdate) {
        c.Syntilio__Caller__c = callerId;
    }
    Syntilio.UpsertToDatabase.updateAction(caseToUpdate,true);
    }

    @NamespaceAccessible
    public static void updateCaseCallerGroup(Id caseId, String callerGroupId) {
    Case[] caseToUpdate = [
        SELECT ContactId 
        FROM Case 
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
    ];
    if (caseToUpdate.size() == 0) {
        return;
    }
    
    for (Case c : caseToUpdate) {
        c.Syntilio__CallerGroup__c = callerGroupId;
    }
    Syntilio.UpsertToDatabase.updateAction(caseToUpdate,true);
    }

    @NamespaceAccessible
    public static string getCaseContactId(Id caseId){
        Case[] caseLists = [
            SELECT ContactId , Syntilio__Caller__c, Syntilio__CallerGroup__c
            FROM Case 
            WHERE Id = :caseId
            WITH SECURITY_ENFORCED
        ];
        
        if(caseLists.size() == 0) {
            return null;
        }
        return JSON.serialize(caseLists[0]);
    }

    @NamespaceAccessible
    public static String getCaseSuggested(Id clientId) {
        List<Map<String, Object>> relationships = new List<Map<String, Object>>();
    
        List<Syntilio__ContactContactRelationship__c> careCircleMembers = [
            SELECT Syntilio__RelatedContactId__c, Syntilio__Relationship__c
            FROM Syntilio__ContactContactRelationship__c
            WHERE Syntilio__ContactId__c = :clientId
            WITH SECURITY_ENFORCED
        ];
    
        if (careCircleMembers.size() == 0) {
            return null;
        }
    
        for (Syntilio__ContactContactRelationship__c relationship : careCircleMembers) {
            Map<String, Object> relationshipData = new Map<String, Object>();
            relationshipData.put('relatedContactId', relationship.Syntilio__RelatedContactId__c);
            relationshipData.put('relationship', relationship.Syntilio__Relationship__c);
            relationships.add(relationshipData);
        }
    
        return JSON.serialize(relationships);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getOrganisationName(){
        List<Organization> organisations = [SELECT Name FROM Organization WITH SECURITY_ENFORCED LIMIT 1];
        if(organisations.size() > 0){
        	return organisations[0].Name;
        }
        return null;
    } 

    @AuraEnabled
    public static void notifyLwc(String message, String target, String status) {
        Id userId = getUserId();
        Syntilio__Notification__e notification = new Syntilio__Notification__e();
        notification.Syntilio__Message__c = message;
        notification.Syntilio__Target__c = target;
        notification.Syntilio__TargetUserId__c = userId;
        notification.Syntilio__Status__c = status;
        EventBus.publish(notification);
    }
    
    @AuraEnabled
    public static Id getUserId() {
        return UserInfo.getUserId();
    }
}