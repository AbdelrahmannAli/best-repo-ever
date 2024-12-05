/*************************************************************************   
@description This class is responsible for the DataHub Synchronization*/
@NamespaceAccessible
public with sharing class DataHubSynchronisation implements callable {
    /*************************************************************************   
    @description This method perform the synchronisation logic and returns a Map<String, Object> that includes information about each database dml action with its relevant status*/
    @NamespaceAccessible    
    public static Map<String, Object> synchronizationHandler(String objectName, HttpResponse response, Boolean useDate){
        
        Map<String, Object> databaseDmlActionsResults = new Map<String, Object>(); //Map of database dml status
        Syntilio.DataHubSyncModel.isSyncing = true;
        try{
            String orgLanguage = Syntilio.DataHubUtilities.getOrgDefaultLanguage();
            String errorCodeApiName = Syntilio.DataHubUtilities.composeErrorCodeDescriptionApiName(orgLanguage);
            String errorCodeDesciptionsQuery = 'SELECT Id, Syntilio__StatusCode__c, ' + errorCodeApiName + ' FROM Syntilio__ErrorCodeConfiguration__mdt WHERE DeveloperName LIKE \'ADHS%\' WITH SECURITY_ENFORCED';
            
            Syntilio__DataHubAppConfiguration__mdt  dataHubAppConfiguration = Syntilio__DataHubAppConfiguration__mdt.getInstance('DataHubAppConfiguration');

            //Check CRUD or FLS access if it is accessible
            if(!Syntilio.DataHubUtilities.isObjectAccessible('Syntilio__ErrorCodeConfiguration__mdt', null)){
                //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
                Syntilio.HandleException.logExceptionAsString('DataHubSync invalid permissions', 'CRUD or FLS permission access failed while checking if object is accessible for performing a database query', 'Check object permissions', 24, 'synchronizationHandler', 'DataHubSync', 'Syntilio', 'Apex');
                return null;
            }

            if(!Syntilio.DataHubUtilities.isObjectAccessible(objectName, null)){
                Syntilio.HandleException.logExceptionAsString('DataHubSync invalid permissions for ' + objectName, 'CRUD or FLS permission access failed while checking if object is accessible for performing a database query', 'Check object permissions', 24, 'synchronizationHandler', 'DataHubSync', 'Syntilio', 'Apex');
                return null;
            }

            //Performing database query
            List<Syntilio__ErrorCodeConfiguration__mdt> errorCodeConfigurationList =  Database.query(errorCodeDesciptionsQuery);
            
            //List<Syntilio__ErrorCodeConfiguration__mdt> errorCodeConfigurationList2 = new List<Syntilio__ErrorCodeConfiguration__mdt >([SELECT FIELDS(CUSTOM) FROM Syntilio__ErrorCodeConfiguration__mdt WHERE DeveloperName LIKE '%ADHS%']);
            Map<String, Syntilio__ErrorCodeConfiguration__mdt> errorCodeConfigurationMap = new Map<String, Syntilio__ErrorCodeConfiguration__mdt>();
            for(Syntilio__ErrorCodeConfiguration__mdt errorCodeConfigurationRecord : errorCodeConfigurationList){
                errorCodeConfigurationMap.put(String.valueOf(errorCodeConfigurationRecord.Syntilio__StatusCode__c), errorCodeConfigurationRecord);
            }
			            
            if(Test.isRunningTest() && objectName.toLowerCase() == 'mock' ){
                Map<String,Object> dmlResponse = new Map<String,Object>();
                dmlResponse.put('mockResponse', 'mockResponse');
                return dmlResponse;
            }
            
            // if(response.getStatusCode() >= 400 || response.getStatusCode() == 0) {
            //     databaseDmlActionsResults.put('400', Syntilio.DataHubSynchronisation.createDataHubSyncModel((String)errorCodeConfigurationMap.get('400.0').get(errorCodeApiName), null));
            //     return databaseDmlActionsResults;
            // }
            
            // Create a map with the deserialized response with key Destination and value List
            Map<String, Object> responseDeserialized = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // List<Map<String, Object>>
            if(responseDeserialized.isEmpty()) {
               databaseDmlActionsResults.put('404', Syntilio.DataHubSynchronisation.createDataHubSyncModel((String)errorCodeConfigurationMap.get('404.0').get(errorCodeApiName), null));
               return databaseDmlActionsResults;
            }

            Map<String, Object> syncResult = synchronise(objectName, responseDeserialized, useDate);
            if(syncResult == null){
                databaseDmlActionsResults.put('204', Syntilio.DataHubSynchronisation.createDataHubSyncModel((String)errorCodeConfigurationMap.get('204.0').get(errorCodeApiName), null));
                return databaseDmlActionsResults;
            }
            List<SObject> objectsToBeUpdatedList = (List<SObject>) syncResult.get('objectsToBeUpdatedList');
            List<Object> saveResults = new List<Object>();
            List<Task> tasksToBeCreatedList = (List<Task>) syncResult.get('tasksToBeCreatedList');
            List<Syntilio__DataHubSyncInfo__c> fieldsToSync = (List<Syntilio__DataHubSyncInfo__c>) syncResult.get('fieldsToSync');
            //Check CRUD/FLS such as isAccessible() on the object and their fields before performing dml operation.
            //update records to database with field specification, field must be a standard or custom External Id indexed field
            Object synchronisedFields = fieldsToSync != null && !fieldsToSync.isEmpty() ? Syntilio.UpsertToDatabase.updateAction(fieldsToSync, false) : null;
            if(synchronisedFields != null) {
                databaseDmlActionsResults.put('200', Syntilio.DataHubSynchronisation.createDataHubSyncModel((String)errorCodeConfigurationMap.get('200.0').get(errorCodeApiName), synchronisedFields));
                databaseDmlActionsResults.put('ids', syncResult.get('insertedObjectsResults'));
                databaseDmlActionsResults.put('externalIds', syncResult.get('finalExternalIdsToInsert'));
                if(syncResult.get('insertedObjectsResults') != null) {
                    saveResults.addAll((List<Object>) syncResult.get('insertedObjectsResults'));
                }    
        }
            //Create Task records if any for records with data conflicts
            Object tasksRecords = tasksToBeCreatedList != null && !tasksToBeCreatedList.isEmpty() ? Syntilio.UpsertToDatabase.insertAction(tasksToBeCreatedList, false) : null;
            if (tasksRecords != null) databaseDmlActionsResults.put('202', Syntilio.DataHubSynchronisation.createDataHubSyncModel((String)errorCodeConfigurationMap.get('202.0').get(errorCodeApiName), tasksRecords));
            //update DataHubSyncInfo records with sync date
            Object synchronisedRecords = objectsToBeUpdatedList != null && !objectsToBeUpdatedList.isEmpty() ? Syntilio.UpsertToDatabase.updateAction(objectsToBeUpdatedList, false) : null;
            if (synchronisedRecords != null) { 
                databaseDmlActionsResults.put('203', Syntilio.DataHubSynchronisation.createDataHubSyncModel((String)errorCodeConfigurationMap.get('203.0').get(errorCodeApiName), synchronisedRecords));
                saveResults.addAll((List<Object>) synchronisedRecords);
            }
            databaseDmlActionsResults.put('saveResults', saveResults);
        } catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        Syntilio.DataHubSyncModel.isSyncing = false;
        return databaseDmlActionsResults;
    }

    @NamespaceAccessible
    public static Map<String, Object> synchronise(String objectName, Map<String, Object> responseDeserialized, Boolean useDate){
        List<SObject> objectsToBeUpdatedList = new List<SObject>();
        List<Task> tasksToBeCreatedList = new  List<Task>();
        Datetime now = useDate? Datetime.now() : null;
        // Convert the response to a Map with value Destination and value Map for the object id and value
        Map<String, Map<String, Map<String, Object>>> responseMap = new Map<String, Map<String, Map<String, Object>>>();
        for (String destination : responseDeserialized.keySet()) {
            List<Object> objectsList = (List<Object>) responseDeserialized.get(destination);
            Map<String, Map<String, Object>> objectsMap = new Map<String, Map<String, Object>>();
            for(Object oneObject : objectsList){
                Map<String, Object> oneObjectMap = (Map<String, Object>) oneObject;
                if(oneObjectMap.get('statusCode') != null && ((Decimal)oneObjectMap.get('statusCode')) >= 400){
                    continue;
                }
                List<Object> objectExternalIds = (List<Object>) oneObjectMap.get('ExternalIds');
                objectsMap.put(String.valueOf(((Map<String, Object>) objectExternalIds[0]).get('Syntilio__Id__c')), oneObjectMap);
            }
            responseMap.put(destination, objectsMap);
        }
    
        //List of fields within applicable synchronisation time frame
        List<Syntilio__DataHubSyncInfo__c> fieldsToSync = getDataHubSyncInfoFields(objectName, 'Pull', now);
                
        //No records from DataHubSyncInfo available in the current synchronisation window
        if(fieldsToSync.isEmpty() || fieldsToSync == null){
            return null;
        }
        
        Set<String> fieldNamesListSet = new Set<String>();
        // Map of external system that has map for field name and datahubsync info
        Map<String, Map<String, Syntilio__DataHubSyncInfo__c>> fieldsToSyncMap = new Map<String, Map<String, Syntilio__DataHubSyncInfo__c>>();
        
        for (Syntilio__DataHubSyncInfo__c fieldToSync : fieldsToSync){
            fieldNamesListSet.add(fieldToSync.Name);
            List<String> fieldExternalSystemsSplit = fieldToSync.Syntilio__ExternalSystems__c.split(',');
            for(String fieldExternalSystem : fieldExternalSystemsSplit){
                Map<String, Syntilio__DataHubSyncInfo__c> externalSystemFieldsMap = fieldsToSyncMap.get(fieldExternalSystem);
                if(externalSystemFieldsMap == null){
                    externalSystemFieldsMap = new Map<String, Syntilio__DataHubSyncInfo__c>();
                }
                externalSystemFieldsMap.put(fieldToSync.Name, fieldToSync);
                fieldsToSyncMap.put(fieldExternalSystem, externalSystemFieldsMap);
            }
            // update fieldToSync LastSyncDate
            fieldToSync.Syntilio__LastSyncDate__c = Datetime.now();
        }
        List<String> fieldNamesList = new List<String>(fieldNamesListSet);

        String databaseQuery = String.join(fieldNamesList, ', ');
        String condition = 'Id IN ';

        List<String> allExternalIds = new List<String>();

        if(objectName == 'Contact'){
            for (Syntilio__ExternalId__c externalItem : [SELECT Syntilio__ContactId__c FROM Syntilio__ExternalId__c WHERE Syntilio__RelatedSalesforceInternalId__c = null WITH SECURITY_ENFORCED]) {
                allExternalIds.add(externalItem.Syntilio__ContactId__c);
            }
        }else{
            for (Syntilio__ExternalId__c externalItem : [SELECT Syntilio__RelatedSalesforceInternalId__c FROM Syntilio__ExternalId__c WITH SECURITY_ENFORCED LIMIT 1000]) {
                allExternalIds.add(externalItem.Syntilio__RelatedSalesforceInternalId__c);
            }
        }
        condition += ':allExternalIds';
        databaseQuery = 'SELECT Id, ' + databaseQuery + ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE ' + condition ;  
        databaseQuery += ' WITH SECURITY_ENFORCED';        
        //Performing database query
        List<SObject> databaseQueriedRecords =  Database.query(databaseQuery);
        List<Id> recordsIds = new List<Id>();
        Map<Id, SObject> databaseQueriedRecordsMap = new Map<Id, SObject>();

        for(SObject record : databaseQueriedRecords){
            recordsIds.add(record.Id);
            databaseQueriedRecordsMap.put(record.Id, record);
        }
        String externalIdRecordName = 'clientId';
        String externalCareCircleIdRecordName = 'careCircleId';
        String externalIdsQuery = 'SELECT Id, Syntilio__ContactId__c, Syntilio__RelatedSalesforceInternalId__c, Syntilio__Id__c, Syntilio__Account__c, Syntilio__Account__r.Syntilio__ApiName__c, Syntilio__ExternalSystemId__c, Syntilio__ExternalSystemId__r.Syntilio__ApiName__c FROM Syntilio__ExternalId__c WHERE ';
        if(objectName == 'Contact'){
            externalIdsQuery += 'Syntilio__ContactId__c IN :recordsIds AND (Name LIKE : externalIdRecordName OR Name Like:externalCareCircleIdRecordName) AND Syntilio__RelatedSalesforceInternalId__c = null';
        }else{
            externalIdsQuery += 'Syntilio__RelatedSalesforceInternalId__c IN :recordsIds';
        }
        externalIdsQuery += ' WITH SECURITY_ENFORCED';
        List<Syntilio__ExternalId__c> externalIdsList = Database.query(externalIdsQuery);
        Map<String, Map<String, Map<String,Object>>> externalIdsMap = new Map<String, Map<String, Map<String,Object>>>();

        // Setup externalIdsMap to have ApiName as key and (the external id along with the object related to it in a map) as value
        for(Syntilio__ExternalId__c oneExternalId : externalIdsList){
            Map<String, Object> oneExternalIdMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(oneExternalId));
            Map<String, Map<String, Object>> idsMap = externalIdsMap.get(oneExternalId.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c);
            if(idsMap == null){
                idsMap = new Map<String, Map<String, Object>>();
            }
            oneExternalIdMap.put(objectName, databaseQueriedRecordsMap.get(objectName == 'Contact'? oneExternalId.Syntilio__ContactId__c : oneExternalId.Syntilio__RelatedSalesforceInternalId__c));
            idsMap.put(oneExternalId.Syntilio__Id__c, oneExternalIdMap);
            externalIdsMap.put(oneExternalId.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c, idsMap);
        }
        Map<String, SObject> fieldsToBeUpdatedMap = new Map<String, SObject>();  
        List<String> idsToBeUpdated = new List<String>();
        List<Map<String, Object>> objectsToInsert = new List<Map<String, Object>>();
        for(String destination : responseMap.keySet()){
            Map<String, Map<String, Object>> destinationResponseMap = responseMap.get(destination);
            List<String> destinationSplit = destination.split('_');
            String externalSystemName = destinationSplit[destinationSplit.size()-1];
            for(String externalId : destinationResponseMap.keySet()){
                Map<String, Object> externalObjectMap = destinationResponseMap.get(externalId);
                Map<String, Map<String, Object>> sfExternalIdsMap = externalIdsMap.get(externalSystemName);
                if(sfExternalIdsMap == null){
                    externalObjectMap.put('destination', destination);
                    objectsToInsert.add(externalObjectMap);
                    continue;
                }
                Map<String, Object> sfExternalId = sfExternalIdsMap.get(externalId);
                
                if(sfExternalId == null){
                    externalObjectMap.put('destination', destination);
                    objectsToInsert.add(externalObjectMap);
                    continue;
                }
                SObject sfObject = (SObject) sfExternalId.get(objectName);
                Boolean needsUpdate = false;
                for(String fieldName : externalObjectMap.keySet()){
                    Object fieldValue = externalObjectMap.get(fieldName);
                    if(!fieldNamesList.contains(fieldName)){
                        continue;
                    }
                    Map<String, Syntilio__DataHubSyncInfo__c> externalSystemFieldsToSync = fieldsToSyncMap.get(externalSystemName);
                    if(externalSystemFieldsToSync == null){
                        continue;
                    }
                    Syntilio__DataHubSyncInfo__c syncObject = externalSystemFieldsToSync.get(fieldName);
                    
                    Object sfValue = sfObject.get(fieldName);
                    if(!syncObject.Syntilio__ExternalSystems__c.contains(externalSystemName) || sfValue == fieldValue){
                        continue;
                    }
                    if(syncObject.Syntilio__SyncMode__c.contains('CreateTaskOnConflict')){
                        Task taskRecord = Syntilio.DataHubUtilities.createTask(
                            objectName, 
                            sfObject.Id, 
                            'DataHub Synchronisation: Conflict in the synchronised data from ' + externalSystemName, 
                            'Record needs manual intervention for data validation, field name: ' 
                            + fieldName + ', Synchronised ' + externalSystemName + ' value: ' 
                            + fieldValue + ', Salesforce value: ' 
                            + sfValue, 
                            'High');
                        tasksToBeCreatedList.add(taskRecord);
                        if(!syncObject.Syntilio__SyncMode__c.contains('Override')){
                            continue;
                        }
                    }
                    Syntilio.DataHubUtilities.castFieldAndInsertToSObject(sfObject, fieldName, fieldValue);
                    needsUpdate = true;
                }
                if(needsUpdate && !idsToBeUpdated.contains(sfObject.Id)){
                    objectsToBeUpdatedList.add(sfObject);
                    idsToBeUpdated.add(sfObject.Id);
                }
            }
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('fieldsToSync', fieldsToSync);
        result.put('tasksToBeCreatedList', tasksToBeCreatedList);
        result.put('objectsToBeUpdatedList', objectsToBeUpdatedList);
        if(objectsToInsert.size() == 0){
            return result;
        }
        List<Syntilio__DataHubSyncInfo__c> fieldsToInsert = [
            SELECT Id, Name
            FROM Syntilio__DataHubSyncInfo__c
            WHERE Syntilio__InsertNewRecords__c = true
            AND Syntilio__Enabled__c = true
            AND Syntilio__ObjectName__c = :objectName 
            WITH SECURITY_ENFORCED
        ];
        if(fieldsToInsert.size() == 0){
            return result;
        }
        List<SObject> newObjectsToInsert = new List<SObject>();
        List<List<Object>> externalIdsToInsert = new List<List<Object>>();
        List<Syntilio__ExternalSystem__c> externalSystemsFound = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c WITH SECURITY_ENFORCED LIMIT 1000];
        List<Account> accountsFound = [SELECT Id, Syntilio__ApiName__c FROM Account WITH SECURITY_ENFORCED LIMIT 1000];
        Map<String, Id> externalSystemsStringIdMap = new Map<String, Id>();
        for(Syntilio__ExternalSystem__c oneExternalSystem : externalSystemsFound){
            externalSystemsStringIdMap.put(oneExternalSystem.Syntilio__ApiName__c, oneExternalSystem.Id);
        }  
        Map<String, Id> accountsStringIdMap = new Map<String, Id>();
        for(Account oneAccount : accountsFound){
            accountsStringIdMap.put(oneAccount.Syntilio__ApiName__c, oneAccount.Id);
        }  

        // Pre-fetch data before the loop
        Map<String, Id> clientIdToContactIdMap = new Map<String, Id>();
        Map<String, Id> accountApiNameToAccountIdMap = new Map<String, Id>();

        // Get client IDs and external systems from objectsToInsert
        Set<String> clientIds = new Set<String>();
        Set<String> accountApiNames = new Set<String>();
        for (Map<String, Object> objectToInsert : objectsToInsert) {
            if (objectToInsert.get('clientId') != null) {
                clientIds.add(String.valueOf(objectToInsert.get('clientId')));
            }
            List<String> destinationSplit = ((String) objectToInsert.get('destination')).split('_');
            if (destinationSplit.size() > 1) {
                accountApiNames.add(destinationSplit[0]);
            }
        }

        // Perform queries to fetch related data
        if (!clientIds.isEmpty()) {
            List<Syntilio__ExternalId__c> contactExternalIds = [
                SELECT Syntilio__Id__c, Syntilio__ContactId__c 
                FROM Syntilio__ExternalId__c
                WHERE Syntilio__Id__c IN :clientIds
                                AND Syntilio__RelatedSalesforceInternalId__c = null
                WITH SECURITY_ENFORCED
            ];
            for (Syntilio__ExternalId__c contactExternalId : contactExternalIds) {
                clientIdToContactIdMap.put(contactExternalId.Syntilio__Id__c, contactExternalId.Syntilio__ContactId__c);
            }
        }

        if (!accountApiNames.isEmpty()) {
            List<Account> accountsFoundList = [
                SELECT Id, Syntilio__ApiName__c 
                FROM Account 
                WHERE Syntilio__ApiName__c IN :accountApiNames 
                WITH SECURITY_ENFORCED
            ];
            for (Account account : accountsFoundList) {
                accountApiNameToAccountIdMap.put(account.Syntilio__ApiName__c, account.Id);
            }
        }
        for(Map<String, Object> objectToInsert : objectsToInsert){
            externalIdsToInsert.add((List<Object>) objectToInsert.get('ExternalIds'));
            SObject newObjectToInsert = createSObjectsWithFields(
                (String) objectToInsert.get('destination'),
                objectName,
                fieldsToInsert,
                objectToInsert,
                clientIdToContactIdMap,
                accountApiNameToAccountIdMap
            );
            newObjectsToInsert.add(newObjectToInsert);
        }
        List<Database.SaveResult> insertedObjects = Syntilio.UpsertToDatabase.insertAction(newObjectsToInsert, false);
        List<SObject> finalExternalIdsToInsert = new List<SObject>();
        Map<String, Id> accountApiNameId = new Map<String, Id>();
        for(Integer i = 0; i < insertedObjects.size(); i++){
            if(!insertedObjects[i].isSuccess()){
                Task taskRecord = Syntilio.DataHubUtilities.createTask(
                    objectName, 
                    null, 
                    'DataHub Synchronisation: Failed to insert new ' + objectName, 
                    'Record needs manual intervention for data validation, record ' + insertedObjects[i], 
                    'High');
                tasksToBeCreatedList.add(taskRecord);
                continue;
            }
            for(Object oneExternalIdObject : externalIdsToInsert[i]){
                SObject oneExternalId = Syntilio.DataHubUtilities.mapToSObject('Syntilio__ExternalId__c', (Map<String, Object>) oneExternalIdObject);
                SObject sObjectToBuild = (SObject) Type.forName(ObjectName).newInstance();
                DescribeSObjectResult sObjectDescribe = sObjectToBuild.getSObjectType().getDescribe();
                Boolean hasContactIdField = sObjectDescribe.fields.getMap().keySet().contains('contactid');
                Boolean hasSyntilioContactIdField = sObjectDescribe.fields.getMap().keySet().contains('syntilio__contactid__c');
                Boolean hasWhoIdField = sObjectDescribe.fields.getMap().keySet().contains('whoid');

                if(objectName != 'Contact'){
                    if(hasWhoIdField){
                        oneExternalId.put('Syntilio__ContactId__c', newObjectsToInsert[i].get('WhoId'));
                    }else if(hasContactIdField){
                        oneExternalId.put('Syntilio__ContactId__c', newObjectsToInsert[i].get('ContactId'));
                    }else if(hasSyntilioContactIdField){
                        oneExternalId.put('Syntilio__ContactId__c', newObjectsToInsert[i].get('Syntilio__ContactId__c'));
                    }
                    oneExternalId.put('Syntilio__RelatedSalesforceInternalId__c', insertedObjects[i].getId());
                }else{
                    oneExternalId.put('Syntilio__ContactId__c', insertedObjects[i].getId());
                }
                String objectDestination = (String) objectsToInsert[i].get('destination'); 
                List<String> objectDestinationSplit = objectDestination.split('_');
                objectDestination = objectDestinationSplit[objectDestinationSplit.size() - 1];
                if(objectDestination != null){
                    oneExternalId.put('Syntilio__ExternalSystemId__c', externalSystemsStringIdMap.get(objectDestination));
                }
                if(objectDestinationSplit.size() > 1){
                    oneExternalId.put('Syntilio__Account__c', accountsStringIdMap.get(objectDestinationSplit[0]));
                }
                finalExternalIdsToInsert.add(oneExternalId);
            }
        }

        List<Database.SaveResult> insertedExternalIds = Syntilio.UpsertToDatabase.insertAction(finalExternalIdsToInsert, false);
        for(Integer i = 0; i < insertedExternalIds.size(); i++){
            if(insertedExternalIds[i].isSuccess()){
                continue;
            }
            Task taskRecord = Syntilio.DataHubUtilities.createTask(
                objectName, 
                null, 
                'DataHub Synchronisation: Failed to insert new External Id', 
                'Record needs manual intervention for data validation, record ' + insertedExternalIds[i], 
                'High');
            tasksToBeCreatedList.add(taskRecord);
        }

        result.put('fieldsToSync', fieldsToSync);
        result.put('tasksToBeCreatedList', tasksToBeCreatedList);
        result.put('objectsToBeUpdatedList', objectsToBeUpdatedList);
        result.put('insertedObjectsResults', insertedObjects);
        result.put('finalExternalIdsToInsert', finalExternalIdsToInsert);
        return result;
    }

    @NamespaceAccessible
    public static SObject createSObjectsWithFields(
        String destination,
        String objectName,
        List<Syntilio__DataHubSyncInfo__c> fieldsToInsert,
        Map<String, Object> objectMap,
        Map<String, Id> clientIdToContactIdMap,
        Map<String, Id> accountApiNameToAccountIdMap
    ) {
        SObject sObjectToBuild = (SObject) Type.forName(objectName).newInstance();
        DescribeSObjectResult sObjectDescribe = sObjectToBuild.getSObjectType().getDescribe();
        List<String> destinationSplit = destination.split('_');
        String externalSystem = destinationSplit[destinationSplit.size()-1];
        if(objectMap.get('clientId') != null){
            String clientId = String.valueOf(objectMap.get('clientId'));
            Id relatedContactId = clientIdToContactIdMap.get(clientId);
            
            if(relatedContactId != null){
                Boolean hasContactIdField = sObjectDescribe.fields.getMap().keySet().contains('contactid');
                Boolean hasSyntilioContactIdField = sObjectDescribe.fields.getMap().keySet().contains('syntilio__contactid__c');
                Boolean hasWhoIdField = sObjectDescribe.fields.getMap().keySet().contains('whoid');
                if(hasWhoIdField){
                    sObjectToBuild.put('WhoId', relatedContactId);
                }else if(hasContactIdField){
                    sObjectToBuild.put('ContactId', relatedContactId);
                }else if(hasSyntilioContactIdField){
                    sObjectToBuild.put('Syntilio__ContactId__c', relatedContactId);
                }
            } 
        }
        
        if(destinationSplit.size() > 1){
            String accountApiName = destinationSplit[0];
            Id relatedAccountId = accountApiNameToAccountIdMap.get(accountApiName);
            
            if(relatedAccountId != null){
                Boolean hasSyntilioAccountIdField = sObjectDescribe.fields.getMap().keySet().contains('syntilio__accountid__c');
                Boolean hasSyntilioAccountField = sObjectDescribe.fields.getMap().keySet().contains('syntilio__account__c');
                Boolean hasAccountIdField = sObjectDescribe.fields.getMap().keySet().contains('accountid');
                Boolean hasWhatIdField = sObjectDescribe.fields.getMap().keySet().contains('whatid');
                if(hasWhatIdField){
                    sObjectToBuild.put('WhatId', relatedAccountId);
                }else if(hasAccountIdField){
                    sObjectToBuild.put('AccountId', relatedAccountId);
                }else if(hasSyntilioAccountField){
                    sObjectToBuild.put('Syntilio__Account__c', relatedAccountId);
                }else if(hasSyntilioAccountIdField){
                    sObjectToBuild.put('Syntilio__AccountId__c', relatedAccountId);
                }
            }
        }
        Set<String> insertedFieldNames = new Set<String>();
        for(Syntilio__DataHubSyncInfo__c field : fieldsToInsert){
            if(insertedFieldNames.contains(field.Name) || field.Name.contains('\\.')){
                continue;
            }
            insertedFieldNames.add(field.Name);
            Object fieldValue = objectMap.get(field.Name);
            if(fieldValue == null){
                continue;
            }
            Syntilio.DataHubUtilities.castFieldAndInsertToSObject(sObjectToBuild, field.Name, fieldValue);
        }
        return sObjectToBuild;
    }

    @NamespaceAccessible
    public static List<Syntilio__DataHubSyncInfo__c> getDataHubSyncInfoFields(String objectName, String type, Datetime nextSyncDate){
        String likeType = '%' + type + '%';
        String query = 'SELECT Name, Syntilio__ObjectName__c, Syntilio__ExternalSystems__c, Syntilio__LastSyncDate__c, Syntilio__SyncMode__c FROM Syntilio__DataHubSyncInfo__c WHERE Syntilio__Enabled__c = true AND Syntilio__Type__c LIKE :likeType';
        if(nextSyncDate != null){
            query += ' AND Syntilio__NextSyncDate__c <= :nextSyncDate'; 
        }
        if(objectName != null){
            query += ' AND Syntilio__ObjectName__c = :objectName';
        }
        query += ' WITH SECURITY_ENFORCED ORDER BY Syntilio__LastSyncDate__c ASC';
        return Database.query(query);
    }
    
    @NamespaceAccessible
    public static Boolean validate(Syntilio__DataHubSyncInfo__c record){

        // Validate that the Name and ObjectName are valid
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(record.Syntilio__ObjectName__c);
        if(objectType == null){
            record.addError('Object with API Name ' + record.Syntilio__ObjectName__c + ' does not exist.');
            return false;
        }
        if(record.Name == 'Id'){
            record.addError('You cannot add field "Id" for synchronisation.');
            return false;
        }
        try{
            String query = 'SELECT ' + record.Name + ' FROM ' + record.Syntilio__ObjectName__c ;
            query += ' WITH SECURITY_ENFORCED';
            List<SObject> recordsList = Database.query(query);
        }catch(QueryException e){
            record.addError('Field with API Name ' + record.Name + ' is invalid for ' + record.Syntilio__ObjectName__c + '.');
            return false;
        }

        if(String.isBlank(record.Syntilio__ExternalSystems__c)){
            record.addError('At least 1 External System must be provided.');
            return false;
        }

        Pattern p = Pattern.compile('^[^,]+(?:,[^,]+)*$');
        Matcher pm = p.matcher(record.Syntilio__ExternalSystems__c);

        if(!pm.matches() || record.Syntilio__ExternalSystems__c.contains(' ')){
            record.addError('External Systems must be comma separated without any spaces like this format: "System1,System2,System3"');
            return false;
        }

        // Validate that the ExternalSystems are valid
        List<String> externalSystemsNames = record.Syntilio__ExternalSystems__c.split(',');
        Set<String> uniqueValuesSet = new Set<String>(externalSystemsNames);
        if(externalSystemsNames.size() != uniqueValuesSet.size()){
            record.addError('Please make sure you add the ExternalSystem ApiName only once in the text.');
            return false;
        }

        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c 
            FROM Syntilio__ExternalSystem__c 
            WHERE Syntilio__ApiName__c IN :externalSystemsNames WITH SECURITY_ENFORCED];
        if(externalSystems.size() != externalSystemsNames.size()){
            Set<String> apiNamesFound = new Set<String>();
            for (Syntilio__ExternalSystem__c externalSystem : externalSystems) {
                apiNamesFound.add(externalSystem.Syntilio__ApiName__c);
            }
    
            List<String> missingApiNames = new List<String>();
            for (String externalSystemName : externalSystemsNames) {
                if (!apiNamesFound.contains(externalSystemName)) {
                    missingApiNames.add(externalSystemName);
                }
            }
    
            record.addError('External Systems ' + String.join(missingApiNames, ',') + ' do not exist');
            return false;
        }

        // Validate that the record does not already exist
        Id recordId = record.Id;
        String recordName = record.Name;
        String objectName = record.Syntilio__ObjectName__c;
        String query = 'SELECT Id FROM Syntilio__DataHubSyncInfo__c WHERE Id != :recordId AND Name = :recordName AND Syntilio__ObjectName__c = :objectName';
        List<String> externalSystemsConditions = new List<String>();
        for(String oneExternalSystem : externalSystemsNames){
            String likeOneExternalSystem = '%' + oneExternalSystem + '%';
            externalSystemsConditions.add('Syntilio__ExternalSystems__c LIKE :likeOneExternalSystem');
        }
        query += ' AND (' + String.join(externalSystemsConditions, ' OR ') + ')';
        query += ' WITH SECURITY_ENFORCED';
        List<Syntilio__DataHubSyncInfo__c> duplicateRecordsFound = Database.query(query);
            
        if(duplicateRecordsFound.size() > 0){
            record.addError('DataHub Sync record already exists for this field.');
            return false;
        }
        
        if(!record.Syntilio__Type__c.contains('Pull') && !record.Syntilio__InsertNewRecords__c){
            return true;
        }
        if(record.Name.contains('.')){
            record.addError('Field ' + record.Name + ' cannot be marked for pulling nor inserting new records.');
            return false;
        }
        SObject sObjectToBuild = (SObject) Type.forName(record.Syntilio__ObjectName__c).newInstance();
        DescribeSObjectResult sObjectDescribe = sObjectToBuild.getSObjectType().getDescribe();
        Schema.DescribeFieldResult fieldDescribe = sObjectDescribe.fields.getMap().get(record.Name.toLowerCase()).getDescribe();

        if(record.Syntilio__InsertNewRecords__c == true && !fieldDescribe.isCreateable()){
            record.addError('Field ' + record.Name + ' cannot be marked for inserting new records. You should uncheck the "Insert New Records" checkbox.');
            return false;
        }

        if(record.Syntilio__Type__c.contains('Pull') && !fieldDescribe.isUpdateable()){
            record.addError('Field ' + record.Name + ' cannot be marked for pulling from External Systems. You should change the type to "Pull from External Systems" only.');
            return false;
        }

        return true;
    }
    
    /*************************************************************************   
    @description The call method provides functionality that other classes or packages can utilize and build upon.
    -> String action which reflects the behavior for the method to exhibit.
    -> Map<String,Object> arguments which reflects the arguments to be used by the specified action.*/
    @NamespaceAccessible    
    public Object call(String action, Map<String, Object> arguments) {
        switch on action.toLowerCase() {
            when 'synchronizationhandler' {
                return Test.isRunningTest()? new Map<String, Object>() : Syntilio.DataHubSynchronisation.synchronizationHandler((String)arguments.get('objectName'), (HttpResponse)arguments.get('response'), (Boolean)arguments.get('useDate'));
            }
            when 'validate' {
                return Test.isRunningTest()? true : Syntilio.DataHubSynchronisation.validate((Syntilio__DataHubSyncInfo__c)arguments.get('record'));
            }
            when else {
                Syntilio.HandleException.logExceptionAsString('DataHubSync Exception', 'action ' + action + ' not implemented', 'Method in not implemented in the callable interface', 230, 'call', 'DataHubSync', 'Syntilio', 'Apex');
                return null;
            }
            
        }
    }
    
    @namespaceAccessible
    public static Syntilio.DataHubSyncModel createDataHubSyncModel(String message, object data){
        Syntilio.DataHubSyncModel dataHubSyncModel = new Syntilio.DataHubSyncModel();
        dataHubSyncModel.message = message;
        dataHubSyncModel.data = data;

        return dataHubSyncModel;
    }
    
}