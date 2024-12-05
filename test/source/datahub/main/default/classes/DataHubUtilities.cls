/*************************************************************************   
@description A class with the sole purpose of containing reusable functions.*/
@namespaceAccessible
public with sharing virtual class DataHubUtilities {
    @TestVisible private static List<Syntilio__Notification__e> eventList = new List<Syntilio__Notification__e>();
    
    /*************************************************************************   
@description A method used to parse an array of strings to an array of decimal by iteration over each item in a array, then calling safeparse on each item*/
    @NamespaceAccessible
    public static List<Decimal> castStringArrayToDecimalArray(List<String> stringList){
        if(stringList == null || stringList.isEmpty())
            return null;
        List<Decimal> decimalList = new List<Decimal>();
        for(String listItem : stringList) {
            Decimal parsedItem = safeParseDecimal(listItem);
            if (parsedItem != null) {
                decimalList.add(parsedItem);
            }
        } 
        return decimalList;
    }
    
    /*************************************************************************   
@description This method is used to safe parse a string to a decimal*/
    @NamespaceAccessible
    public static Decimal safeParseDecimal(String input) {
        Decimal result = null;
        if(String.isBlank(input))
            return null;
        try {
            result = Decimal.valueOf(input);
        } catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return result;
    }
    
    @NamespaceAccessible
    public static Task createTask(String objectName, Id recordId, String subject, String description, String priority) {
        String sObjectName = recordId == null? objectName : getSobjectFromId(recordId);
        Task taskRecord = new Task(
            WhoId = sObjectName.toLowerCase() == 'contact' || sObjectName.toLowerCase() == 'lead' ? recordId : null,
            WhatId = sObjectName.toLowerCase() != 'contact' && sObjectName.toLowerCase() != 'lead' ? recordId : null,
            Subject = subject,
            Description = description,
            Priority = priority
        );
        return taskRecord;
    }
    
    
    /*************************************************************************   
@description This method is used to create an SObject from type received as string parameter*/
    @NamespaceAccessible
    public static SObject createNewSobjectOfType(String sObjectTypeName) {
        
        /* Call global describe to get the map of string to token. */
        Map<String, Schema.SObjectType> sObjectGlobalDescribe = Schema.getGlobalDescribe(); 
        
        /* Get the token for the sobject based on the type. */
        Schema.SObjectType sObjectType = sObjectGlobalDescribe.get(sObjectTypeName);
        
        /* Instantiate the sobject from the token. */
        Sobject sObjectRecord = sObjectType.newSobject();
        
        return sObjectRecord;
    }
    
    /*************************************************************************   
@description This method is used to get Field Describe Metadata*/
    @NamespaceAccessible
    public static Map<String, Schema.DescribeFieldResult> getFieldDescribeMetaData(Schema.DescribeSObjectResult describeSObjectResult, Set<String> fields) {
        
        // the map to be returned with the final data
        Map<String,Schema.DescribeFieldResult> fieldDescribeMetaData = 
            new Map<String, Schema.DescribeFieldResult>();
        // map of all fields in the object
        Map<String, Schema.SObjectField> objectFields = describeSObjectResult.fields.getMap();
        
        // iterate over the requested fields and get the describe info for each one. 
        // add it to a map with field name as key
        for(String field : fields){
            // skip fields that are not part of the object
            if (objectFields.containsKey(field)) {
                Schema.DescribeFieldResult describeFieldResult = objectFields.get(field).getDescribe();
                // add the results to the map to be returned
                fieldDescribeMetaData.put(field, describeFieldResult); 
            }
        }
        return fieldDescribeMetaData;
    }
    
    /*************************************************************************   
@description This method is used to get Field Name dynamically from Field Describe Metadata*/
    @NamespaceAccessible
    public static Schema.SObjectField getSobjectFieldName(Map<String, Schema.DescribeFieldResult> fieldDescribeMetaData, String fieldName ) {
        Schema.DescribeFieldResult fieldDescribeFieldResult = fieldDescribeMetaData.get(fieldName);
        if(fieldDescribeFieldResult == null) {
            return null;
        }
        Schema.SObjectField sObjectField = fieldDescribeFieldResult.getSObjectField();
        
        return sObjectField;
    }
    
    /*************************************************************************   
@description This method is used to get object global describe dynamically and check CRUD or FLS access if it is createable.*/
    @NamespaceAccessible
    public static Boolean isObjectCreateable(String objectName, Set<String> fields){        
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Boolean isCreateable = objResult.isCreateable() ? true : false ;
        
        // Get the field dynamically
        //DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
        
        return isCreateable;
    }
    
    /*************************************************************************   
@description This method is used to get object global describe dynamically and check CRUD or FLS access if it is updateable.*/
    @NamespaceAccessible
    public static Boolean isObjectUpdateable(String objectName, Set<String> fields){        
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        Boolean isUpdateable = objResult.isUpdateable() ? true : false ;
        
        // Get the field dynamically
        //DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
        
        return isUpdateable;
    }
        /*************************************************************************   
@description This method is used to get object global describe dynamically and check CRUD or FLS access if it is deletable.*/
@NamespaceAccessible
public static Boolean isObjectDeletable(String objectName, Set<String> fields){        
    // Get the describe for the object
    DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
    
    Boolean isDeletable = objResult.isDeletable() ? true : false ;
    
    // Get the field dynamically
    //DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
    
    return isDeletable;
}
    /*************************************************************************
@description This method is used to get object global describe dynamically and check CRUD or FLS access if it is accessible.*/
    @NamespaceAccessible
    public static Boolean isObjectAccessible(String objectName, Set<String> fields){        
        // Get the describe for the object
        Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        Boolean isAccessible = objResult.isAccessible() ? true : false ;
        
        // Get the field dynamically
        //DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
        
        return isAccessible;
    }
    
    /*************************************************************************
@description This method is used to get default record type for an sObject.*/
    @NamespaceAccessible
    public static Schema.RecordTypeInfo getDefaultRecordTypeForSObject(String objectName){
        Schema.DescribeSObjectResult objDescribeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for(Schema.RecordTypeInfo objDescribeResultRecord : objDescribeResult.getRecordTypeInfos()) {
            if(objDescribeResultRecord.isDefaultRecordTypeMapping()) {
                defaultRecordType = objDescribeResultRecord;
                return defaultRecordType;
            }        
            
        }
        return defaultRecordType;
    }
    
    /*************************************************************************
@description This method is used to get org default language configured in custom metadata.*/
    @NamespaceAccessible
    public static String getOrgDefaultLanguage(){
        Syntilio__DataHubAppConfiguration__mdt  dataHubAppConfiguration = Syntilio__DataHubAppConfiguration__mdt.getInstance('DataHubAppConfiguration');
        return dataHubAppConfiguration.Syntilio__Language__c;
    }
    
    /*************************************************************************
@description This method is used to get error code description field api name.*/
    @NamespaceAccessible
    public static String composeErrorCodeDescriptionApiName(String orgLanguageApiName){
        String fieldApiName = 'Syntilio__Description_' + orgLanguageApiName + '__c';
        return fieldApiName;
    }
    
    /*************************************************************************
@description This method is used to get the sObject type name from Object Id.*/
    @NamespaceAccessible
    public static String getSobjectFromId(Id sObjectId) {
        Schema.SObjectType sobjectType = sObjectId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        return sobjectName;
    }
    
    @AuraEnabled
    public static List<string> getExceptionTypes(){
        List <Syntilio.HandleException.ExceptionSource> exceptionTypes = Syntilio.HandleException.ExceptionSource.values();
        List <String> exceptionTypesString = new List<String>();
        for(Syntilio.HandleException.ExceptionSource exceptionType : exceptionTypes){
            exceptionTypesString.add(exceptionType.name());
        }
        return exceptionTypesString;
    }
    
    @NamespaceAccessible
    public static boolean isSomeFieldsChanged(List<String> fields, SObject oldObject, SObject newObject){
        for(String field : fields){
            if(getFieldValueFromSObject(field, oldObject) != getFieldValueFromSObject(field, newObject)){
                return true;
            }
        }
        return false;
    }
    
    @NamespaceAccessible
    public static void castFieldAndInsertToSObject(SObject sObjectReference, String fieldName, Object fieldValue){
        DescribeSObjectResult sObjectDescribe = sObjectReference.getSObjectType().getDescribe();
        DisplayType fieldType = sObjectDescribe.fields.getMap().get(fieldName.toLowerCase()).getDescribe().getType();
        switch on fieldType {
            when BOOLEAN {
                sObjectReference.put(fieldName, (Boolean) fieldValue);
            }
            when DATE {
                sObjectReference.put(fieldName, Date.valueOf((String) fieldValue));
            }
            when DATETIME {
                sObjectReference.put(fieldName, Datetime.valueOf((String) fieldValue));
            }
            when DOUBLE {
                sObjectReference.put(fieldName, Double.valueOf(fieldValue));
            }
            when INTEGER {
                sObjectReference.put(fieldName, Integer.valueOf(fieldValue));
            }
            when LONG {
                sObjectReference.put(fieldName, Long.valueOf((String) fieldValue));
            }
            when STRING {
                sObjectReference.put(fieldName, String.valueOf(fieldValue));
            }
            when else{
                sObjectReference.put(fieldName, fieldValue);
            }
        }
    }

    @NamespaceAccessible
    public static SObject mapToSObject(String objectName, Map<String, Object> mapObject) {
        SObject sObjectToBuild = (SObject) Type.forName(objectName).newInstance();
        for(String field : mapObject.keySet()){
            Object fieldValue = mapObject.get(field);
            try{
                if(fieldValue == null){
                    continue;
                }
                castFieldAndInsertToSObject(sObjectToBuild, field, fieldValue);
                
            }catch(Exception e){
                
            }
        }
        return sObjectToBuild;
    }
    
    @NamespaceAccessible
    public static Object getFieldValueFromSObject(String fieldName, Object currentObject) {
        if(currentObject == null || String.isBlank(fieldName)){
            return currentObject;
        }
        List<String> fields = fieldName.split('\\.');
        if(fields.size() == 1){
            return ((SObject)currentObject).get(fieldName);
        }
        String currentField = fields.remove(0);
        return getFieldValueFromSObject(String.join(fields, '.'), ((SObject)currentObject).getSObject(currentField));
    }

    @NamespaceAccessible
    public static Map<String, Object> listToMap(String keyFieldName, String valueFieldName, List<SObject> sObjectList) {
        Map<String, Object> resultMap = new Map<String, Object>();
        List<String> fields = keyFieldName.split('\\.');
        for(SObject oneSObject : sObjectList){
            Object keyFieldValue = getFieldValueFromSObject(keyFieldName, oneSObject);
            Object valueFieldValue = getFieldValueFromSObject(valueFieldName, oneSObject);
            if(resultMap.get(String.valueOf(keyFieldValue)) == null){
                resultMap.put(String.valueOf(keyFieldValue), valueFieldValue);
            } else {
                List<Object> valueList;
                try{
                    valueList = (List<Object>) resultMap.get(String.valueOf(keyFieldValue));
                } catch(Exception e) {
                    valueList = new List<Object>{resultMap.get(String.valueOf(keyFieldValue))};
                }
                valueList.add(valueFieldValue);
                resultMap.put(String.valueOf(keyFieldValue), valueList);
            }
        }
        return resultMap;
    }
    
    @NamespaceAccessible
    public static Map<String, List<Syntilio__ExternalId__c>> getSObjectExternalIdsMap(String objectTypeName, Id recordId, Set<String> externalSystems) {
        String query = 'SELECT Id, Name, Syntilio__Id__c, Syntilio__ExternalSystemId__r.Syntilio__ApiName__c FROM Syntilio__ExternalId__c WHERE';
        String externalIdRecordName = 'clientId';
        if(externalSystems != null){
            query += ' Syntilio__ExternalSystemId__r.Syntilio__ApiName__c IN :externalSystems AND';
        }
        if(objectTypeName == 'Contact'){
            query += ' Syntilio__ContactId__c = :recordId AND Name LIKE :externalIdRecordName AND Syntilio__RelatedSalesforceInternalId__c = null';
        }else{
            query += ' Syntilio__RelatedSalesforceInternalId__c = :recordId';
        }
        query += ' WITH SECURITY_ENFORCED';
        List<Syntilio__ExternalId__c> sObjectExternalIds = Database.query(query);
        if(sObjectExternalIds.size() == 0){
            return null;
        }
        Map<String, List<Syntilio__ExternalId__c>> sObjectExternalSystemId = new Map<String, List<Syntilio__ExternalId__c>>();
        for(Syntilio__ExternalId__c externalId : sObjectExternalIds){
            List<Syntilio__ExternalId__c> ids = sObjectExternalSystemId.get(externalId.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c);
            if(ids == null){
                ids = new List<Syntilio__ExternalId__c>();
            }
            ids.add(externalId);
            sObjectExternalSystemId.put(externalId.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c, ids);
        }
        return sObjectExternalSystemId;
    }
    
    @NamespaceAccessible
    public static void setupExternalSystemsAndPushMap(
        List<Syntilio__DataHubSyncInfo__c> fieldsToPush, Set<String> fieldNamesList, 
        Map<String, List<String>> externalSystemFieldNames, Map<String, Syntilio__DataHubSyncInfo__c> fieldsToPushMap,
        Set<String> externalSystems) {
            for (Syntilio__DataHubSyncInfo__c fieldToPush : fieldsToPush){
                List<String> externalSystemsSplit = fieldToPush.Syntilio__ExternalSystems__c.split(',');
                if(fieldNamesList != null){
                    fieldNamesList.add(fieldToPush.Name);
                }
                if(externalSystems != null){
                    externalSystems.addAll(externalSystemsSplit);
                }
                if(fieldsToPushMap != null){
                    fieldsToPushMap.put(fieldToPush.Name, fieldToPush);
                }
                if(externalSystemFieldNames == null){
                    continue;
                }
                for(String externalSystem : externalSystemsSplit){
                    List<String> fields = externalSystemFieldNames.get(externalSystem);
                    if(fields == null){
                        fields = new List<String>();
                    }
                    fields.add(fieldToPush.Name);
                    externalSystemFieldNames.put(externalSystem, fields);
                }
            }
        }
    
    @NamespaceAccessible
    public static List<Syntilio.DataHubModel.Destination> getDestinationListAllAccounts(Set<String> externalSystems) {
        List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        List<Syntilio__AccountExternalSystemAssociation__c> accountExternalSystemAssociationRecords = [SELECT Syntilio__AccountId__r.Syntilio__ApiName__c, Syntilio__ExternalSystemId__r.Syntilio__ApiName__c FROM Syntilio__AccountExternalSystemAssociation__c WITH SECURITY_ENFORCED LIMIT 1000];
        if(accountExternalSystemAssociationRecords.size() == 0){
            for(String externalSystem : externalSystems){
                Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
                destinationRecord.technology = externalSystem;
                destinationRecordList.add(destinationRecord);
            } 
        }else{
            for(Syntilio__AccountExternalSystemAssociation__c externalAssociation : accountExternalSystemAssociationRecords){
                if(externalSystems == null || externalSystems.contains(externalAssociation.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c)){
                    Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
                    destinationRecord.destinationName = externalAssociation.Syntilio__AccountId__r.Syntilio__ApiName__c;
                    destinationRecord.technology = externalAssociation.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c;
                    destinationRecordList.add(destinationRecord);
                }
            }
        }
        return destinationRecordList;
    }
    
    @NamespaceAccessible
    public static List<Syntilio.DataHubModel.Destination> getDestinationList(Id accountId, Set<String> externalSystems) {
        List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        if(accountId == null){
            for(String externalSystem : externalSystems){
                Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
                destinationRecord.technology = externalSystem;
                destinationRecordList.add(destinationRecord);
            }
            return destinationRecordList;
        }
        List<Syntilio__AccountExternalSystemAssociation__c> accountExternalSystemAssociationRecord = [SELECT Syntilio__AccountId__r.Syntilio__ApiName__c, Syntilio__ExternalSystemId__r.Syntilio__ApiName__c FROM Syntilio__AccountExternalSystemAssociation__c WHERE Syntilio__AccountId__c = :accountId WITH SECURITY_ENFORCED];
        
        for(Syntilio__AccountExternalSystemAssociation__c externalAssociation : accountExternalSystemAssociationRecord){
            if(externalSystems == null || externalSystems.contains(externalAssociation.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c)){
                Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
                destinationRecord.destinationName = externalAssociation.Syntilio__AccountId__r.Syntilio__ApiName__c;
                destinationRecord.technology = externalAssociation.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c;
                destinationRecordList.add(destinationRecord);
            }
        }
        return destinationRecordList;
    }
    
    @NamespaceAccessible
    public static boolean messageExists(SObject objectWithError, String errorMessage) {
        List<Database.Error> errors = objectWithError.getErrors();
        for(Database.Error error : errors){
            if(error.getMessage() == errorMessage){
                return true;
            }
        }
        return false;
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
    public static Syntilio__Notification__e notifyLWC(String message) {
        Syntilio__Notification__e notification = new Syntilio__Notification__e();
        notification.Syntilio__Message__c = message;
        Syntilio.DataHubUtilities.eventList.add(notification);
        EventBus.publish(notification);
        
        return notification;
    }
    
    @NamespaceAccessible
    public static string getCaseContactId(Id caseId){
        Case[] caseLists = [
            SELECT ContactId
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
    public static Map<String, Set<String>> getViableExternalSystemsPerAccountId(List<Id> accountIds, String objectApiName) {
        Map<String, Set<String>> accountIdViableExternalSystems = new Map<String, Set<String>>();
        for(Id accountId : accountIds) {
            accountIdViableExternalSystems.put(accountId, new Set<String>());
        }
        Set<String> allExternalSystems = new Set<String>();
        
        String queryCondition = '%'+objectApiName+'%';
        List<Syntilio__DataHubSyncInfo__c> syncInfoList = [
            SELECT Syntilio__ExternalSystems__c 
            FROM Syntilio__DataHubSyncInfo__c 
            WHERE Syntilio__ObjectName__c LIKE :queryCondition
            WITH SECURITY_ENFORCED
        ];
        if(syncInfoList.size() == 0) return accountIdViableExternalSystems;        
        
        for (Syntilio__DataHubSyncInfo__c syncInfo : syncInfoList) {
            allExternalSystems.addAll(String.valueOf(syncInfo.Syntilio__ExternalSystems__c).split(','));
        }
        
        List<Syntilio__AccountExternalSystemAssociation__c> accountAssocList = [
            SELECT Syntilio__AccountId__c, Syntilio__ExternalSystemId__r.Syntilio__ApiName__c
            FROM Syntilio__AccountExternalSystemAssociation__c
            WHERE Syntilio__AccountId__c IN :accountIds
            WITH SECURITY_ENFORCED
        ];

        Map<String, Object> accountAssocMap = listToMap('Syntilio__AccountId__c', null, accountAssocList);
        
        for(String accountId : accountAssocMap.keySet()){
            Set<String> viableExternalSystems = new Set<String>();
            List<Object> thisAccountAssocList;
            try{
                thisAccountAssocList = (List<Object>) accountAssocMap.get(accountId);
            } catch(Exception e) {
                thisAccountAssocList = new List<Object>{accountAssocMap.get(accountId)};
            }
            for (Object accountAssoc : thisAccountAssocList) {
                Syntilio__AccountExternalSystemAssociation__c accountAssocObject = (Syntilio__AccountExternalSystemAssociation__c) accountAssoc;
                String externalSystemName = String.valueOf(accountAssocObject.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c);
                Boolean isExternalSystemAvailable = allExternalSystems.contains(externalSystemName);
                if(isExternalSystemAvailable) {
                    viableExternalSystems.add(externalSystemName);
                }
            }
            accountIdViableExternalSystems.put((Id) accountId, viableExternalSystems);
        }
        
        return accountIdViableExternalSystems;
    }

    @NamespaceAccessible
    public static Map<String, Map<String, Set<String>>>  getViableExternalSystemsPerAccount(List<Id> accountIds, String objectApiName) {
        Map<String, Map<String, Set<String>>> accountIdViableExternalSystems = new Map<String, Map<String, Set<String>>>();
        Set<String> allExternalSystems = new Set<String>();
        
        String queryCondition = '%'+objectApiName+'%';
        List<Syntilio__DataHubSyncInfo__c> syncInfoList = [
            SELECT Syntilio__ExternalSystems__c 
            FROM Syntilio__DataHubSyncInfo__c 
            WHERE Syntilio__ObjectName__c LIKE :queryCondition
            WITH SECURITY_ENFORCED
        ];
        if(syncInfoList.size() == 0) return accountIdViableExternalSystems;        
        
        for (Syntilio__DataHubSyncInfo__c syncInfo : syncInfoList) {
            allExternalSystems.addAll(String.valueOf(syncInfo.Syntilio__ExternalSystems__c).split(','));
        }

        List<Account> allAccounts = 
            [SELECT Id, ParentId,
                (SELECT Id, Syntilio__AccountId__c,
                    Syntilio__ExternalSystemId__c,
                    Syntilio__ExternalSystemId__r.Syntilio__ApiName__c
                FROM Syntilio__AccountExternalSystemAssociation__r) 
	        FROM Account]
        ;

        Map<String, Object> allAccountsMap = listToMap('Id', null, allAccounts);
        Map<Id, List<Id>> queryIdsPerAccount = new  Map<Id, List<Id>>(); 

        for (Id id : accountIds) {
            List<Id> queryIds = new List<Id>();
            Id accountAssocId = getAccountAssoc(id, allAccountsMap);
            if (accountAssocId != null) 
                queryIds.add(accountAssocId);
            queryIdsPerAccount.put(id, queryIds);
        }
        for(Id incomingAccountId : queryIdsPerAccount.keySet()){
            List<Id> queryIds = queryIdsPerAccount.get(incomingAccountId);
            Map<String, Set<String>> accountIdViableExternalSystemsInnerMap = new Map<String, Set<String>>();
            for(Id accountId: queryIds){

                Set<String> viableExternalSystems = new Set<String>();
                List<Object> thisAccountAssocList;
                try{
                    thisAccountAssocList = (List<Object>) allAccountsMap.get(accountId);
                } catch(Exception e) {
                    thisAccountAssocList = new List<Object>{allAccountsMap.get(accountId)};
                }
                for (Object accountAssoc : thisAccountAssocList) {
                    Account assoc = (Account) accountAssoc;
                    if(assoc.Syntilio__AccountExternalSystemAssociation__r != null && !assoc.Syntilio__AccountExternalSystemAssociation__r.isEmpty()){
                        Syntilio__AccountExternalSystemAssociation__c accountAssocObject = (Syntilio__AccountExternalSystemAssociation__c) assoc.Syntilio__AccountExternalSystemAssociation__r;
                        String externalSystemName = String.valueOf(accountAssocObject.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c);
                        Boolean isExternalSystemAvailable = allExternalSystems.contains(externalSystemName);
                        if(isExternalSystemAvailable) {
                            viableExternalSystems.add(externalSystemName);
                        }
                    }
                }
                accountIdViableExternalSystemsInnerMap.put(accountId, viableExternalSystems);
            }
            accountIdViableExternalSystems.put(incomingAccountId, accountIdViableExternalSystemsInnerMap);
        }
        return accountIdViableExternalSystems;
    }

    @NamespaceAccessible
    public static List<String> getViableExternalSystems(Id accountId, String objectApiName) {
        Set<String> viableExternalSystems = new Set<String>();  
        Set<String> allExternalSystems = new Set<String>();
        
        String queryCondition = '%'+objectApiName+'%';
        List<Syntilio__DataHubSyncInfo__c> syncInfoList = [
            SELECT Syntilio__ExternalSystems__c 
            FROM Syntilio__DataHubSyncInfo__c 
            WHERE Syntilio__ObjectName__c LIKE :queryCondition
            WITH SECURITY_ENFORCED
        ];
        if(syncInfoList.size() == 0) return new List<String>(viableExternalSystems);        
        
        for (Syntilio__DataHubSyncInfo__c syncInfo : syncInfoList) {
            allExternalSystems.addAll(String.valueOf(syncInfo.Syntilio__ExternalSystems__c).split(','));
        }
        
        List<Syntilio__AccountExternalSystemAssociation__c> accountAssocList = [
            SELECT Syntilio__ExternalSystemId__r.Syntilio__ApiName__c
            FROM Syntilio__AccountExternalSystemAssociation__c
            WHERE Syntilio__AccountId__c = :accountId
            WITH SECURITY_ENFORCED
        ];
        
        for (Syntilio__AccountExternalSystemAssociation__c accountAssoc : accountAssocList) {
            String externalSystemName = String.valueOf(accountAssoc.Syntilio__ExternalSystemId__r.Syntilio__ApiName__c);
            Boolean isExternalSystemAvailable = allExternalSystems.contains(externalSystemName);
            if(isExternalSystemAvailable == true) {
                viableExternalSystems.add(externalSystemName);
            }
        }
        return new List<String>(viableExternalSystems);
    }

    @NamespaceAccessible
    public static Map<String, Object> getExternalIdPerContact(List<Id> contactIds) {
        Map<String, Object> contactExternalId = new Map<String, Object>();
        for(Id contactId : contactIds) {
            contactExternalId.put(contactId, null);
        }

        String externalIdRecordName = 'clientId';
        List<Syntilio__ExternalId__c> externalIds = [
            SELECT Syntilio__ContactId__c, Syntilio__ExternalSystemId__c, Syntilio__Id__c
            FROM Syntilio__ExternalId__c
            WHERE Syntilio__ContactId__c IN :contactIds AND Name LIKE :externalIdRecordName AND Syntilio__RelatedSalesforceInternalId__c = null 
            WITH SECURITY_ENFORCED
        ];

        if(externalIds.size() == 0) return contactExternalId;

        contactExternalId = listToMap('Syntilio__ContactId__c', 'Syntilio__Id__c', externalIds);
        
        return contactExternalId;
    }
    
    @NamespaceAccessible
    public static String getContactExternalSystemId(Id contactId) {
        String externalIdRecordName = 'clientId';
        List<Syntilio__ExternalId__c> externalIds = [
            SELECT Syntilio__ExternalSystemId__c, Syntilio__Id__c
            FROM Syntilio__ExternalId__c
            WHERE Syntilio__ContactId__c = :contactId AND Name LIKE :externalIdRecordName AND Syntilio__RelatedSalesforceInternalId__c = null 
            WITH SECURITY_ENFORCED
        ];
        
        if(externalIds.size() == 0) return null;
        
        return externalIds[0].Syntilio__Id__c;
    }

    @NamespaceAccessible
    public static List<Id> sObjectListToIdList(List<SObject> sObjectList){
        List<Id> idList = new List<Id>();
        for(SObject record : sObjectList){
            idList.add(record.Id);
        }
        return idList;
    }

    @NamespaceAccessible
    public static Id getAccountAssoc(Id accountId, Map<String, Object> allAccountsMap){
        Account acc = (Account)allAccountsMap.get(accountId);
        if (acc == null) return null;
    
        List<Syntilio__AccountExternalSystemAssociation__c> assocList = acc.Syntilio__AccountExternalSystemAssociation__r;
        if ((assocList == null || assocList.isEmpty()) && acc.ParentId == null) {
            return null;
        } else if (assocList != null && !assocList.isEmpty()) {
            return assocList[0].Syntilio__AccountId__c;
        } else {
            return getAccountAssoc(acc.ParentId, allAccountsMap);
        }
    }

}