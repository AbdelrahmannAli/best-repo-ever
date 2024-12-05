/*************************************************************************   
@description This class is responsible for the DataHub Synchronization*/

global  with sharing class DataHubSync implements callable {
    
    /*************************************************************************   
@description This method perform the synchronisation logic and returns a Map<String, Object> that includes information about each database dml action with its relevant status*/
    global  static Map<String, Object> synchronizationHandler(String objectName, HttpResponse response){
        
        Map<String, Object> databaseDmlActionsResults = new Map<String, Object>(); //Map of database dml status
                
        List<SObject> objectsToBeUpdatedList = new List<SObject>(); //List of sobjects that will be updated in salesforce
        List<Task> tasksToBeCreatedList = new List<Task>(); //List of tasks that will be created based on fields synchronisation comparision
        List<Syntilio__DataHubSyncInfo__c> dataHubSyncInfoRecordListToBeUpdated = new List<Syntilio__DataHubSyncInfo__c>();//List to update the Syntilio__LastSyncDate__c field after synchronisation
        try{
            
            String orgLanguage = Syntilio.DataHubUtilities.getOrgDefaultLanguage();
            String errodCodefieldApiNameBasedOnOrgLanguage = Syntilio.DataHubUtilities.composeErrorCodeDescriptionApiName(orgLanguage);
            String errorCodeDesciptionsDatabaseQuery = 'SELECT Id, Syntilio__StatusCode__c, ' + errodCodefieldApiNameBasedOnOrgLanguage + ' FROM Syntilio__ErrorCodeConfiguration__mdt WHERE DeveloperName LIKE \'ADHS%\' WITH SECURITY_ENFORCED';

            List<Syntilio__ErrorCodeConfiguration__mdt> dataHubErrorCodeConfigurationList;
            //Check CRUD or FLS access if it is accessible
            if(Syntilio.DataHubUtilities.isObjectAccessible('Syntilio__ErrorCodeConfiguration__mdt', null)){
                //Performing database query
                dataHubErrorCodeConfigurationList =  Database.query(errorCodeDesciptionsDatabaseQuery);
            }else{
                //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
                Syntilio.HandleException.logExceptionAsString('DataHubSync invalid permissions', 'CRUD or FLS permission access failed while checking if object is accessible for performing a database query', 'Check object permissions', 24, 'synchronizationHandler', 'DataHubSync', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
                return null;
            }

            //List<Syntilio__ErrorCodeConfiguration__mdt> dataHubErrorCodeConfigurationList2 = new List<Syntilio__ErrorCodeConfiguration__mdt >([SELECT FIELDS(CUSTOM) FROM Syntilio__ErrorCodeConfiguration__mdt WHERE DeveloperName LIKE '%ADHS%']);
            Map<String, Syntilio__ErrorCodeConfiguration__mdt> dataHubErrorCodeConfigurationMap = new Map<String, Syntilio__ErrorCodeConfiguration__mdt>();
            for(Syntilio__ErrorCodeConfiguration__mdt dataHubErrorCodeConfigurationRecord : dataHubErrorCodeConfigurationList)
            {
                dataHubErrorCodeConfigurationMap.put(String.valueOf(dataHubErrorCodeConfigurationRecord.Syntilio__StatusCode__c), dataHubErrorCodeConfigurationRecord);
            }
			            
            if(Test.isRunningTest() && objectName.toLowerCase() == 'mock' ){
                Map<String,Object> dmlResponse = new Map<String,Object>();
                dmlResponse.put('mockResponse', 'mockResponse');
                return dmlResponse;
            }
            
            if(response.getStatusCode() >= 400 || response.getStatusCode() == 0) {
                databaseDmlActionsResults.put('400', Syntilio.DataHubSync.createDataHubSyncModel((String)dataHubErrorCodeConfigurationMap.get('400.0').get(errodCodefieldApiNameBasedOnOrgLanguage), null));
                return databaseDmlActionsResults;
            }
            
            //Creation of dynamic list of sobject and then deserialising
            Type mapType = Type.forName('List<' + objectName + '>');
            List<SObject> responseDeserializeAsSObjectList = (List<SObject>) JSON.deserialize(response.getBody(), mapType);
            
            if(responseDeserializeAsSObjectList.isEmpty()) {
                databaseDmlActionsResults.put('404', Syntilio.DataHubSync.createDataHubSyncModel((String)dataHubErrorCodeConfigurationMap.get('404.0').get(errodCodefieldApiNameBasedOnOrgLanguage), null));
                return databaseDmlActionsResults;
            }
            
            Map<String, SObject> responseSObjectMap = new Map<String, SObject>();
            
            //Most recent sync date for that relevant object
            Syntilio__DataHubSyncInfo__c mostRecentLastSyncRecord = ([SELECT Syntilio__LastSyncDate__c FROM Syntilio__DataHubSyncInfo__c WHERE Syntilio__ObjectName__c =: objectName WITH SECURITY_ENFORCED ORDER BY Syntilio__LastSyncDate__c DESC LIMIT 1]);
            
            //UniqueIdentifier Field Name for that relevant object
            Syntilio__DataHubSyncInfo__c objectUniqueIdentifierRecord = ([SELECT Name FROM Syntilio__DataHubSyncInfo__c WHERE Syntilio__IsUniqueIdentifier__c = true AND Syntilio__Enabled__c = true AND Syntilio__ObjectName__c =: objectName WITH SECURITY_ENFORCED LIMIT 1]);
            
            //Larget frequency field timeframe to use in first synchronisation when last sync date is not available yet
            Syntilio__DataHubSyncInfo__c largestFrequencyTimeRecord = ([SELECT Syntilio__Frequency__c FROM Syntilio__DataHubSyncInfo__c WHERE Syntilio__Enabled__c = true AND Syntilio__ObjectName__c =: objectName WITH SECURITY_ENFORCED ORDER BY Syntilio__Frequency__c DESC LIMIT 1]);
            
            //Hours between and last sync date & now compared with the Frequency : Frequency <= DateTimeNow-LastSyncDate
            Decimal hoursBetweenDateTimeNowAndLastSyncDate = mostRecentLastSyncRecord.Syntilio__LastSyncDate__c != null ? Integer.valueOf((DateTime.now().getTime() - mostRecentLastSyncRecord.Syntilio__LastSyncDate__c.getTime())/(1000*60*60)) : Integer.valueOf((DateTime.now().getTime() - (DateTime.now().addHours(- Integer.valueOf(largestFrequencyTimeRecord.Syntilio__Frequency__c))).getTime())/(1000*60*60));
            
            //List of fields within applicable synchronisation time frame
            List<Syntilio__DataHubSyncInfo__c> synchronisedFieldsConfigurationList = new List<Syntilio__DataHubSyncInfo__c>([SELECT Id, Name, Syntilio__Enabled__c, Syntilio__Frequency__c, Syntilio__IsUniqueIdentifier__c, Syntilio__LastSyncDate__c, Syntilio__ObjectName__c, Syntilio__SyncMode__c FROM Syntilio__DataHubSyncInfo__c WHERE Syntilio__ObjectName__c =: objectName AND Syntilio__Frequency__c <=: hoursBetweenDateTimeNowAndLastSyncDate AND Syntilio__Enabled__c = true AND Syntilio__IsUniqueIdentifier__c = false WITH SECURITY_ENFORCED]);
            
            //No records from DataHubSyncInfo available in the current synchronisation window
            if(synchronisedFieldsConfigurationList.isEmpty() || synchronisedFieldsConfigurationList == null){
                databaseDmlActionsResults.put('204', Syntilio.DataHubSync.createDataHubSyncModel((String)dataHubErrorCodeConfigurationMap.get('204.0').get(errodCodefieldApiNameBasedOnOrgLanguage), null));
                return databaseDmlActionsResults;
            }
            
            List<String> uniqueIdentifiersList = new List<String>();
            
            //List of external unique identifiers
            for(SObject responseDeserializeAsSObjectRecord : responseDeserializeAsSObjectList) {
                String uniqueIdentifier = (String) responseDeserializeAsSObjectRecord.get(objectUniqueIdentifierRecord.Name);
                responseSObjectMap.put(uniqueIdentifier, responseDeserializeAsSObjectRecord);
                uniqueIdentifiersList.add(uniqueIdentifier);
            }
            
            List<String> fieldsNameList = new List<String>();
            
            //List of fields names to add to the database query
            for (Syntilio__DataHubSyncInfo__c synchronisedFieldConfiguration : synchronisedFieldsConfigurationList){
                fieldsNameList.add(synchronisedFieldConfiguration.Name);
            }
            
            //Adding unque identifier field name to the database query
            fieldsNameList.add(objectUniqueIdentifierRecord.Name);
            String databaseQuery = String.join(fieldsNameList, ', ');
            databaseQuery = 'SELECT RecordTypeId, ' + databaseQuery + ' FROM ' + String.escapeSingleQuotes(objectName) + ' WHERE ' + objectUniqueIdentifierRecord.Name + ' IN: uniqueIdentifiersList WITH SECURITY_ENFORCED';            
            
            //Create an instance of the sobject using object name passed to class
            SObject objectInstance = Syntilio.DataHubUtilities.createNewSobjectOfType(objectName);
            
            List<SObject> databaseQueriedRecords;
            //Get sobject type
            String sObjectType = String.valueOf(objectInstance.getSObjectType());
            //Check CRUD or FLS access if it is accessible
            if(Syntilio.DataHubUtilities.isObjectAccessible(sObjectType, null)){
                //Performing database query
                databaseQueriedRecords =  Database.query(databaseQuery);
            }else{
                Syntilio.HandleException.logExceptionAsString('DataHubSync invalid permissions', 'CRUD or FLS permission access failed while checking if object is accessible for performing a database query', 'Check object permissions', 110, 'synchronizationHandler', 'DataHubSync', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
                return null;
            }
            
            
            Map<String, SObject> fieldsToBeUpdatedMap = new Map<String, SObject>();  
            List<SObject> sObjectsToBeUpdated = new  List<SObject>();
            
            String uniqueIdentifierFieldName = null;
            String currentSynchronisedFieldValue = null;
            String currentDatabaseFieldValue = null;
            //Perform the field comparision between the database records and the synchronised records
            for(SObject databaseQueriedRecord : databaseQueriedRecords){
                //checking if supplier response contains this database record via uniqueIdentifier
                uniqueIdentifierFieldName = (String) databaseQueriedRecord.get(objectUniqueIdentifierRecord.Name);
                
                if(responseSObjectMap.containsKey(uniqueIdentifierFieldName)){
                    //Creation of sobject to include fields that will be later updated in the database
                    SObject sObjectRecord = Syntilio.DataHubUtilities.createNewSobjectOfType(objectName);
                    //looping on sync custom object to check related fields for this object
                    for(Syntilio__DataHubSyncInfo__c synchronisedFieldConfiguration : synchronisedFieldsConfigurationList){
                        if(!dataHubSyncInfoRecordListToBeUpdated.contains(synchronisedFieldConfiguration)){
                            synchronisedFieldConfiguration.Syntilio__LastSyncDate__c = datetime.now();
                            dataHubSyncInfoRecordListToBeUpdated.Add(synchronisedFieldConfiguration);
                        }
                        currentSynchronisedFieldValue = (String) String.valueOf(responseSObjectMap.get(uniqueIdentifierFieldName).get(synchronisedFieldConfiguration.Name));
                        currentDatabaseFieldValue = (String) String.valueOf(databaseQueriedRecord.get(synchronisedFieldConfiguration.Name));
                        
                        if(currentDatabaseFieldValue != currentSynchronisedFieldValue){
                            if((currentSynchronisedFieldValue) != null && !String.isBlank(String.valueOf(currentSynchronisedFieldValue))){
                                if(synchronisedFieldConfiguration.Syntilio__SyncMode__c == 'AlwaysOverride') {
                                    if(sObjectRecord.get(objectUniqueIdentifierRecord.Name) == null){
                                        sObjectRecord.put(objectUniqueIdentifierRecord.Name, responseSObjectMap.get(uniqueIdentifierFieldName).get(objectUniqueIdentifierRecord.Name));
                                    }
                                    
                                    try {
                                        DateTime checkIfDateTimeForCurrentSynchronisedFieldValue = DateTime.valueOf(currentSynchronisedFieldValue);
                                        sObjectRecord.put(synchronisedFieldConfiguration.Name, checkIfDateTimeForCurrentSynchronisedFieldValue);
                                        
                                    }catch (Exception e1){
                                        try {
                                            Date checkIfDateForCurrentSynchronisedFieldValue = Date.valueOf(currentSynchronisedFieldValue);
                                            sObjectRecord.put(synchronisedFieldConfiguration.Name, checkIfDateForCurrentSynchronisedFieldValue);
                                            
                                        }
                                        catch(Exception e2){
                                            try {
                                                Boolean checkIfDateTimeForCurrentSynchronisedFieldValue = Boolean.valueOf(currentSynchronisedFieldValue);
                                                sObjectRecord.put(synchronisedFieldConfiguration.Name, checkIfDateTimeForCurrentSynchronisedFieldValue);
                                                
                                            }
                                            catch(Exception e3){
                                                try {
                                                    sObjectRecord.put(synchronisedFieldConfiguration.Name, currentSynchronisedFieldValue);
                                                }catch (Exception e4){
                                                    Syntilio.HandleException.logException(e4);
                                                    
                                                }
                                            }
                                        }    
                                    }
                                    
                                }else{
                                    //TaskWhoIds (List of contact’s ID or a List of lead’s ID), WhoId (contact’s ID or a lead’s ID), WhatId (accounts, opportunities, campaigns, cases, or custom objects) ,AccountId (Account or Opportunity or Contract or Custom object that is a child of Account)
                                    Task taskRecord = Syntilio.DataHubUtilities.createTask(objectName, databaseQueriedRecord.Id, 'DataHub Synchronisation: Conflict in the synchronised data' ,'Record needs manual intervention for data validition, field name: ' + synchronisedFieldConfiguration.Name + ' , synchronised value: ' + currentSynchronisedFieldValue + ' , salesforce value: ' + currentDatabaseFieldValue, 'High');
                                    tasksToBeCreatedList.add(taskRecord);
                                }
                            }
                        }
                    }
                    if(sObjectRecord.get(objectUniqueIdentifierRecord.Name) != null)
                        sObjectsToBeUpdated.add(sObjectRecord);
                    
                    //remove record from synchronised list to later insert un-found records into salesforce
                    responseSObjectMap.remove(uniqueIdentifierFieldName);
                }
            }
            //Inserting unfound records in salesforce and opening linked task for them ((DataHubSyncModel)databaseDmlActionsResults.get('201')).data)
            Object unfoundRecords = !responseSObjectMap.isEmpty() ? Syntilio.UpsertToDatabase.insertAction(responseSObjectMap.values(), false) : null;
            if(unfoundRecords != null){
                databaseDmlActionsResults.put('201', Syntilio.DataHubSync.createDataHubSyncModel((String)dataHubErrorCodeConfigurationMap.get('201.0').get(errodCodefieldApiNameBasedOnOrgLanguage), unfoundRecords));
                for(Database.SaveResult saveResultRecord : (List<Database.SaveResult>) unfoundRecords){
                    if(saveResultRecord.isSuccess()){
                        Task taskRecord = Syntilio.DataHubUtilities.createTask(objectName, saveResultRecord.getId(), 'DataHub Synchronisation: Synchronised record is not found in the database' ,' A Record that is synchronised is not found in Salesforce, accordingly a new record is created in Salesforce and needs manual intervention for validition' , 'High');
                        tasksToBeCreatedList.add(taskRecord);
                    }
                }
            }
            //Get field details to later insert to database with field specification
            Set<String> fields = new Set<String>{objectUniqueIdentifierRecord.Name};
            Map<String, Schema.DescribeFieldResult> fieldDescribeMetaData = Syntilio.DataHubUtilities.getFieldDescribeMetaData(objectInstance.getSObjectType().getDescribe(), fields);
            Schema.SObjectField sObjectUniqueIdentifierField = Syntilio.DataHubUtilities.getSobjectFieldName(fieldDescribeMetaData, objectUniqueIdentifierRecord.Name);
            
            //Check CRUD/FLS such as isAccessible() on the object and their fields before performing dml operation.
            //update records to database with field specification, field must be a standard or custom External Id indexed field
            Object synchronisedRecords = !sObjectsToBeUpdated.isEmpty() ? Syntilio.UpsertToDatabase.upsertAction(sObjectsToBeUpdated, sObjectUniqueIdentifierField, false) : null;
            if(synchronisedRecords != null) databaseDmlActionsResults.put('200', Syntilio.DataHubSync.createDataHubSyncModel((String)dataHubErrorCodeConfigurationMap.get('200.0').get(errodCodefieldApiNameBasedOnOrgLanguage), synchronisedRecords));
            //Create Task records if any for records with data conflicts
            Object tasksRecords = !tasksToBeCreatedList.isEmpty() ? Syntilio.UpsertToDatabase.insertAction(tasksToBeCreatedList, false) : null;
            if (tasksRecords != null) databaseDmlActionsResults.put('202', Syntilio.DataHubSync.createDataHubSyncModel((String)dataHubErrorCodeConfigurationMap.get('202.0').get(errodCodefieldApiNameBasedOnOrgLanguage), tasksRecords));
            //update DataHubSyncInfo records with sync date
            Object DataHubSyncInfoRecords = !dataHubSyncInfoRecordListToBeUpdated.isEmpty() ? Syntilio.UpsertToDatabase.updateAction(dataHubSyncInfoRecordListToBeUpdated, false) : null;
            if (DataHubSyncInfoRecords != null) databaseDmlActionsResults.put('203', Syntilio.DataHubSync.createDataHubSyncModel((String)dataHubErrorCodeConfigurationMap.get('203.0').get(errodCodefieldApiNameBasedOnOrgLanguage), DataHubSyncInfoRecords));
            
        } catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return databaseDmlActionsResults;
    }
    
    
    /*************************************************************************   
@description The call method provides functionality that other classes or packages can utilize and build upon.
-> String action which reflects the behavior for the method to exhibit.
-> Map<String,Object> arguments which reflects the arguments to be used by the specified action.*/
    global  Object call(String action, Map<String, Object> arguments) {
        switch on action.toLowerCase() {
            when 'synchronizationhandler' {
                return Syntilio.DataHubSync.synchronizationHandler((String)arguments.get('objectName'), (HttpResponse)arguments.get('response'));
            }
            when else {
                Syntilio.HandleException.logExceptionAsString('DataHubSync Exception', 'action ' + action + ' not implemented', 'Method in not implemented in the callable interface', 230, 'call', 'DataHubSync', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
                return null;
            }
        }
    }
    
    public static Syntilio.DataHubSyncModel createDataHubSyncModel(String message, object data){
        Syntilio.DataHubSyncModel dataHubSyncModel = new Syntilio.DataHubSyncModel();
        dataHubSyncModel.message = message;
        dataHubSyncModel.data = data;

        return dataHubSyncModel;
    }
    
}