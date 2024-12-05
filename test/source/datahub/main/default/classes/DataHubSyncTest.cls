@isTest
public with sharing class DataHubSyncTest {
    
    
    private static void createDataHubSyncInfoRecordsWithinFrequencyTimeFrame (String objectName) { 

        List<Map<String, Object>> dataHubSyncInfoList =  new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'FirstName',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 24,
                'Syntilio__IsUniqueIdentifier__c' => true,
                'Syntilio__LastSyncDate__c' => null,
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            },
            new Map<String, Object>{
                'Name' => 'Email',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 23,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => null,
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'Push'
            },
            new Map<String, Object>{
                'Name' => 'LastName',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 22,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => null,
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'Pull'
            },
            new Map<String, Object>{
                'Name' => 'Phone',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 21,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => null,
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'CreateTaskOnConflict',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            },
            new Map<String, Object>{
                'Name' => 'Birthdate ',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 24,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => null,
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            }
        };
        List<Syntilio__DataHubSyncInfo__c> recordsToInsert = new List<Syntilio__DataHubSyncInfo__c>();

        for (Map<String, Object> data : dataHubSyncInfoList) {
            Syntilio__DataHubSyncInfo__c syncInfo = Syntilio.DataHubTestDataFactory.createDataHubSyncInfo(data);
            recordsToInsert.add(syncInfo);
        }
        insert recordsToInsert;
    }
    
    private static void createDataHubSyncInfoRecordsNotWithinFrequencyTimeFrame (String objectName) {  
        List<Map<String, Object>> dataHubSyncInfoList =  new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'FirstName',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 24,
                'Syntilio__IsUniqueIdentifier__c' => true,
                'Syntilio__LastSyncDate__c' => DateTime.now().addHours(-5),
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'Push'
            },
            new Map<String, Object>{
                'Name' => 'Email',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 24,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => DateTime.now().addHours(-5),
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            },
            new Map<String, Object>{
                'Name' => 'Birthdate ',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 24,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => DateTime.now().addHours(-5),
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            }
        };
        List<Syntilio__DataHubSyncInfo__c> recordsToInsert = new List<Syntilio__DataHubSyncInfo__c>();

        for (Map<String, Object> data : dataHubSyncInfoList) {
            Syntilio__DataHubSyncInfo__c syncInfo = Syntilio.DataHubTestDataFactory.createDataHubSyncInfo(data);
            recordsToInsert.add(syncInfo);
        }
        insert recordsToInsert;
    }  
    private static void createTestRecords(Integer numberOfRecords){
        List<Contact> contactRecordsList = new List<Contact>();
        Map<String, Object> additionalFields = new  Map<String, Object>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            Contact contactToInsert = Syntilio.DataHubTestDataFactory.createContact(null);
            contactRecordsList.add(contactToInsert);
        }
        insert contactRecordsList;
    }

    
    private static HTTPResponse dataHubSyncSuccessfulResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ { "Syntilio__Id__c": "6", "IdentificationNo__c": "3232323110551", "FirstName": "Test", "lastName": "Test", "LastModifiedDate": "2023-02-01T16:51:38.000+01:00", "Phone": "+31722627282", "Birthdate": "1999-02-01" }, { "Syntilio__Id__c": "3232323110552", "IdentificationNo__c": "3232323110552", "FirstName": "Test", "lastName": "ChangeingLastName", "LastModifiedDate": "2023-02-01T16:55:22.000+01:00", "Phone": "+323827328", "Birthdate": "1999-02-01"} ]');
        response.setStatusCode(200);
        return response;
    }
    
    private static HTTPResponse dataHubSyncUnSuccessfulResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ { "Success": false, "Message": "Reason Phrase: Bad Request, Error: Response status code does not indicate success: 400 (Bad Request).", "ResponseData": null, "Data": null, "ProviderName": "Salesforce:GrowtivityDev", "StatusCode": 400, "ExcludedMappings": {} } ]');
        response.setStatusCode(400);
        return response;
    }

    private static HTTPResponse dataHubSyncSuccessfulEmptyResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[]');
        response.setStatusCode(200);
        return response;
    }

    @isTest
    public static void synchronizationHandler_SuccessfulSynchronization_WithInFrequencyTimeFrame_ShouldReturn_DmlActionsResults_SynchronizationHandlerUpdated_Test() {
        HttpResponse response;
        Object databaseDmlActionsResults;
        
        try{
            createTestRecords(3);
            
            // Syntilio.DataHubTestDataFactory.createContactRecordsWithoutAccountRelation(3);
            //Syntilio.DataHubTestDataFactory.createTestRecords('Contact', null, 3);
            
            String objectName = 'Contact';
            createDataHubSyncInfoRecordsWithinFrequencyTimeFrame(objectName);
            response = dataHubSyncSuccessfulResponse();

            Test.startTest();
            databaseDmlActionsResults = Syntilio.DataHubSync.synchronizationHandler(objectName, response);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertNotEquals(null, databaseDmlActionsResults);
    }
    
    
    
    @isTest
    public static void synchronizationHandler_UnSuccessfulSynchronization_ShouldReturn_Null_SynchronizationHandlerUpdated_Test() {
        HttpResponse response;
        Map<String,Object> callableInterfaceResponse;
        
        try{
            
            
            String objectName = 'Contact';
            response = dataHubSyncUnSuccessfulResponse();

            Test.startTest();
            callableInterfaceResponse = Syntilio.DataHubSync.synchronizationHandler(objectName, response);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(null, callableInterfaceResponse.get('Response status code is 400'));
    }
    
    
    @isTest
    public static void synchronizationHandler_SuccessfulSynchronization_ShouldReturn_Null_SynchronizationHandlerUpdated_Test() {
        HttpResponse response;
        Map<String,Object> callableInterfaceResponse;
        
        try{
            
            
            String objectName = 'Contact';
            
            response = dataHubSyncSuccessfulEmptyResponse();

            Test.startTest();
            callableInterfaceResponse = Syntilio.DataHubSync.synchronizationHandler(objectName, response);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(null, callableInterfaceResponse.get('Deserialised response records is empty'));
    }
    
    @isTest
    public static void synchronizationHandler_SuccessfulSynchronization_NotWithInFrequencyTimeFrame_ShouldReturn_SynchronizationHandlerUpdated_Null_Test() {
        HttpResponse response;
        Map<String,Object> callableInterfaceResponse;
        
        try{
            
            
            createTestRecords(3);
            // Syntilio.DataHubTestDataFactory.createContactRecordsWithoutAccountRelation(3);
            // Syntilio.DataHubTestDataFactory.createTestRecords('Contact', null, 3);
            
            String objectName = 'Contact';
            createDataHubSyncInfoRecordsNotWithinFrequencyTimeFrame(objectName);
            response = dataHubSyncSuccessfulResponse();

            Test.startTest();
            callableInterfaceResponse = Syntilio.DataHubSync.synchronizationHandler(objectName, response);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(null, callableInterfaceResponse.get('No records available in the current synchronisation window'));
    }
    
    @isTest
    public static void synchronizationHandler_Should_LogException_SynchronizationHandlerUpdated_Test() {
        HttpResponse response;
        Object databaseDmlActionsResults;
        
        try{
            
            
            String objectName = 'UnknownObject';
            
            response = dataHubSyncSuccessfulResponse();

            Test.startTest();
            databaseDmlActionsResults = Syntilio.DataHubSync.synchronizationHandler(objectName, response);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }
    
    @isTest
    public static void call_synchronizationHandler_CallableInterface_Should_return_success_Test() {
        Map<String,Object> callableInterfaceResponse;
        
        try{

            Map<String,Object> arguments = new Map<String,Object>();
            arguments.put('objectName', 'mock');
            arguments.put('response', new HttpResponse());
            
            String dataHubSyncClass = 'Syntilio.DataHubSync';
            Callable dataHubSyncClassCallableInstance = (Callable) Type.forName(dataHubSyncClass).newInstance();

            Test.startTest();
            callableInterfaceResponse = (Map<String,Object>) dataHubSyncClassCallableInstance.call('synchronizationHandler', arguments);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals('mockResponse', callableInterfaceResponse.get('mockResponse'));
    }
    
    @isTest
    public static void call_synchronizationHandler_CallableInterface_Should_return_null_Test() {
        Map<String,Object> callableInterfaceResponse;
        
        try{

            Map<String,Object> arguments = new Map<String,Object>();
            arguments.put('objectName', 'Contact');
            arguments.put('response', new HttpResponse());

            String dataHubSyncClass = 'Syntilio.DataHubSync';           
            Callable dataHubSyncClassCallableInstance = (Callable) Type.forName(dataHubSyncClass).newInstance();

            Test.startTest();
            callableInterfaceResponse = (Map<String,Object>) dataHubSyncClassCallableInstance.call('synchronizationHandler', arguments);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(null , callableInterfaceResponse.get('Response status code is 0'));
    }
    
    
    @isTest
    public static void call_UnImplemented_Method_CallableInterface_Should_LogException_Test() {
        Object callableInterfaceResponse;
        
        try{
            
            String dataHubSyncClass = 'Syntilio.DataHubSync';
            Callable dataHubSyncClassCallableInstance = (Callable) Type.forName(dataHubSyncClass).newInstance();

            Test.startTest();
            callableInterfaceResponse = dataHubSyncClassCallableInstance.call('unImplementedMethod', null);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }
}