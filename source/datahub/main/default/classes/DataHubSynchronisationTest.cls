@isTest
public with sharing class DataHubSynchronisationTest {
    
private static void createDataHubSynchronisationTestData(){
        Account twbAccount = Syntilio.DataHubTestDataFactory.createAccount( new Map<String, Object>{
            'Name' => 'Twb',
            'Syntilio__ApiName__c' => 'Twb'
        });
        insert twbAccount;

        Contact johanContact = Syntilio.DataHubTestDataFactory.createContact(new Map<String, Object>{
            'FirstName' => 'Johan',
            'LastName' => 'Hendrik',
            'Email' => 'Johan@nl.com',
            'AccountId' => twbAccount.Id
        });

        Syntilio__ExternalSystem__c onsSystem = Syntilio.DataHubTestDataFactory.createExternalSystem(new Map<String, Object>{
            'Name' => 'Ons',
            'Syntilio__ApiName__c' => 'Ons'
        });

        insert new List<SObject>{johanContact, onsSystem};

        Syntilio__AccountExternalSystemAssociation__c twbAccountAssociation = Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation(new Map<String, Object>{
            'Name' => 'Twb_Ons',
            'Syntilio__AccountId__c' => twbAccount.Id,
            'Syntilio__ExternalSystemId__c' => onsSystem.Id
        });

        Syntilio__ExternalId__c johanExternalId =  Syntilio.DataHubTestDataFactory.createExternalId( new Map<String, Object>{
            'Syntilio__Account__c' => twbAccount.Id,
            'Syntilio__ExternalSystemId__c' => onsSystem.Id,
            'Syntilio__ContactId__c' => johanContact.Id,
            'Syntilio__Id__c' => '1234',
            'Name' => 'clientId',
            'Syntilio__RelatedSalesforceInternalId__c' => null
        });

        insert new List<SObject>{twbAccountAssociation, johanExternalId};
    }
    
    
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

    private static void createDataHubSyncInfoThatShouldUpdate(String objectName) {  

        List<Map<String, Object>> dataHubSyncInfoList =  new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'Email',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 0,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => Datetime.now(),
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            },
            new Map<String, Object>{
                'Name' => 'LastName',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 0,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => Datetime.now(),
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'Pull'
            },
            new Map<String, Object>{
                'Name' => 'Phone',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 0,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => Datetime.now(),
                'Syntilio__ObjectName__c' => objectName,
                'Syntilio__SyncMode__c' => 'CreateTaskOnConflict',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            },
            new Map<String, Object>{
                'Name' => 'Birthdate',
                'Syntilio__Enabled__c' => true,
                'Syntilio__Frequency__c' => 0,
                'Syntilio__IsUniqueIdentifier__c' => false,
                'Syntilio__LastSyncDate__c' => Datetime.now(),
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
    
    
    private static HTTPResponse dataHubSyncV2SuccessfulResponse() {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Twb_Ons": [ { "Email": "Johan@newemail.com", "ExternalIds": [{"Name": "clientId", "Syntilio__Id__c": "1234"}, {"Name": "identificationNo", "Syntilio__Id__c": "123"}] } ]}');
        response.setStatusCode(200);
        return response;
    }

    @testSetup
    public static void setup() {
        createDataHubSynchronisationTestData();
    }
    
    @isTest
    public static void getDataHubSyncInfoFields_success(){
        List<Syntilio__DataHubSyncInfo__c> fieldsToPush;
        
        try{
            

            String objectName = 'Contact';
            createDataHubSyncInfoRecordsWithinFrequencyTimeFrame(objectName);

            Test.startTest();
            fieldsToPush = Syntilio.DataHubSynchronisation.getDataHubSyncInfoFields(objectName, 'Push', null);
            Test.stopTest(); 

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertNotEquals(null, fieldsToPush);
        System.assertNotEquals(0, fieldsToPush.size());
    }
    
    @isTest
    public static void synchronisationHandler_successWithFieldsToUpdateOverride() {
        HttpResponse response;
        Object databaseDmlActionsResults;
        
        try{
            
            String objectName = 'Contact';
            createDataHubSyncInfoThatShouldUpdate(objectName);
            response = dataHubSyncV2SuccessfulResponse();

            Test.startTest();
            databaseDmlActionsResults = Syntilio.DataHubSynchronisation.synchronizationHandler(objectName, response, true);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertNotEquals(null, databaseDmlActionsResults);
    }
    
    @isTest
    public static void synchronisationHandler_successWithFieldsToUpdateCreateTask() {
        HttpResponse response;
        Object databaseDmlActionsResults;
        
        try{
            
            
            String objectName = 'Contact';
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = objectName,
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
        	);
            insert dataHubSyncInfo;
            response = dataHubSyncV2SuccessfulResponse();

            Test.startTest();
            databaseDmlActionsResults = Syntilio.DataHubSynchronisation.synchronizationHandler(objectName, response, true);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Task> tasks = [SELECT Id FROM Task];
        System.assertNotEquals(null, databaseDmlActionsResults);
        System.assertNotEquals(0, tasks.size());
    }
    
    @isTest
    public static void synchronisationHandler_successRecordsToInsert() {
        HttpResponse response;
        Object databaseDmlActionsResults;
        
        try{
            
            
            String objectName = 'Contact';
            List<Syntilio__DataHubSyncInfo__c> datahubSyncInfoRecords = new List<Syntilio__DataHubSyncInfo__c>();
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = objectName,
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull',
                Syntilio__InsertNewRecords__c = true
        	);
            datahubSyncInfoRecords.add(dataHubSyncInfo);
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo2 = new Syntilio__DataHubSyncInfo__c(
                Name = 'LastName',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = objectName,
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull',
                Syntilio__InsertNewRecords__c = true
        	);
            datahubSyncInfoRecords.add(dataHubSyncInfo2);
            insert datahubSyncInfoRecords;
            
        	response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Twb_Ons": [ { "Email": "Johan@newemailtest.com", "LastName": "Test", "ExternalIds": [{"Name": "clientId", "Syntilio__Id__c": "123423"}, {"Name": "identificationNo", "Syntilio__Id__c": "12323"}] } ]}');
            response.setStatusCode(200);

            Test.startTest();
            databaseDmlActionsResults = Syntilio.DataHubSynchronisation.synchronizationHandler(objectName, response, true);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertNotEquals(null, databaseDmlActionsResults);
        System.assert(contacts.size() > 1);
    }
    
    @isTest
    public static void synchronisationHandler_failureRecordsToInsert() {
        HttpResponse response;
        Object databaseDmlActionsResults;
        
        try{
           
            
            String objectName = 'Contact';
            List<Syntilio__DataHubSyncInfo__c> datahubSyncInfoRecords = new List<Syntilio__DataHubSyncInfo__c>();
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = objectName,
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull',
                Syntilio__InsertNewRecords__c = true
        	);
            datahubSyncInfoRecords.add(dataHubSyncInfo);
            insert datahubSyncInfoRecords;
            
        	response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Twb_Ons": [ { "Email": "Johan@newemailtest.com", "LastName": "Test", "ExternalIds": [{"Name": "clientId", "Syntilio__Id__c": "123423"}, {"Name": "identificationNo", "Syntilio__Id__c": "12323"}] } ]}');
            response.setStatusCode(200);
            
            Test.startTest();
            databaseDmlActionsResults = Syntilio.DataHubSynchronisation.synchronizationHandler(objectName, response, true);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertNotEquals(null, databaseDmlActionsResults);
        System.assert(contacts.size() == 1);
    }
    
    @isTest
    public static void synchronisationHandler_successRecordsToInsertNotContact() {
        HttpResponse response;
        Object databaseDmlActionsResults;
        
        try{
           
            
            String objectName = 'Syntilio__AuditTrail__c';
            List<Syntilio__DataHubSyncInfo__c> datahubSyncInfoRecords = new List<Syntilio__DataHubSyncInfo__c>();
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Syntilio__Destination__c',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = objectName,
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull',
                Syntilio__InsertNewRecords__c = true
        	);
            datahubSyncInfoRecords.add(dataHubSyncInfo);
            insert datahubSyncInfoRecords;
            
        	response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Twb_Ons": [ { "Syntilio__Destination__c": "some destination", "clientId": "1234", "ExternalIds": [{"Name": "auditTrailId", "Syntilio__Id__c": "12315"}] } ]}');
            response.setStatusCode(200);

            Test.startTest();
            databaseDmlActionsResults = Syntilio.DataHubSynchronisation.synchronizationHandler(objectName, response, true);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__AuditTrail__c> auditTrails = [SELECT Id FROM Syntilio__AuditTrail__c];
        System.assertNotEquals(null, databaseDmlActionsResults);
        System.assertNotEquals(auditTrails.size(), 0);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_success(){
        Boolean isValid;
        
        try{
            
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
        	);
            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(true, isValid);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_hasDuplicate(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
        	);
            insert dataHubSyncInfo;
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo2 = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo2);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo2, 'DataHub Sync record already exists for this field.');
            Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_invalidObjectName(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'UnkownObject',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'Object with API Name UnkownObject does not exist.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_nameIsId(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Id',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'You cannot add field "Id" for synchronisation.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_invalidFieldName(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'UnkownField',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'Field with API Name UnkownField is invalid for Contact.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_externalSystemsRequired(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__Type__c = 'Pull'
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'At least 1 External System must be provided.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_externalSystemsBadFormat(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons, Fierit,',
                Syntilio__Type__c = 'Pull'
        	);
            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'External Systems must be comma separated without any spaces like this format: "System1,System2,System3"');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_externalSystemsDuplicate(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons,Ons',
                Syntilio__Type__c = 'Pull'
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'Please make sure you add the ExternalSystem ApiName only once in the text.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_externalSystemsDoNotExist(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons,Unkown1,Unkown2',
                Syntilio__Type__c = 'Pull'
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'External Systems Unkown1,Unkown2 do not exist');
            Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_fieldNotCreateableNorUpdateable(){
        Boolean isValid;
        Boolean hasError;
        try{
           
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'CreatedBy.Name',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Push',
                Syntilio__InsertNewRecords__c = true
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'Field CreatedBy.Name cannot be marked for pulling nor inserting new records.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_fieldNotCreateable(){
        Boolean isValid;
        Boolean hasError;
        try{
            
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'CreatedDate',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Push',
                Syntilio__InsertNewRecords__c = true
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'Field CreatedDate cannot be marked for inserting new records. You should uncheck the "Insert New Records" checkbox.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Validate_failure_fieldNotUpdateable(){
        Boolean isValid;
        Boolean hasError;
        try{
           
            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'CreatedDate',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull',
                Syntilio__InsertNewRecords__c = false
        	);

            Test.startTest();
            isValid = Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
            hasError = Syntilio.DataHubUtilities.messageExists(dataHubSyncInfo, 'Field CreatedDate cannot be marked for pulling from External Systems. You should change the type to "Pull from External Systems" only.');
        	Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(false, isValid);
        System.assertEquals(true, hasError);
    }
    
    @isTest
    public static void dataHubSyncV2Call_synchronisationHandler(){
        Map<String,Object> callableInterfaceResponse;
        try{
            Test.startTest();
            Map<String,Object> arguments = new Map<String,Object>();
            arguments.put('objectName', 'mock');
            arguments.put('response', new HttpResponse());
            arguments.put('useDate', true);
            
            String dataHubSyncClass = 'Syntilio.DataHubSynchronisation';
            Callable dataHubSyncClassCallableInstance = (Callable) Type.forName(dataHubSyncClass).newInstance();
            callableInterfaceResponse = (Map<String,Object>) dataHubSyncClassCallableInstance.call('synchronizationHandler', arguments);
            
            Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }

        System.assertNotEquals(null, callableInterfaceResponse);
    }
    
    @isTest
    public static void dataHubSyncV2Call_validate(){
        Boolean callableInterfaceResponse;
        try{
            Test.startTest();
            Map<String,Object> arguments = new Map<String,Object>();
            arguments.put('objectName', 'mock');
            arguments.put('response', new HttpResponse());
            
            String dataHubSyncClass = 'Syntilio.DataHubSynchronisation';
            Callable dataHubSyncClassCallableInstance = (Callable) Type.forName(dataHubSyncClass).newInstance();
            callableInterfaceResponse = (Boolean) dataHubSyncClassCallableInstance.call('validate', arguments);
            
            Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }

        System.assertNotEquals(null, callableInterfaceResponse);
    }
    
	@isTest
    public static void dataHubSyncV2Call_unknown(){
        Object callableInterfaceResponse;
        try{
            Test.startTest();
            Map<String,Object> arguments = new Map<String,Object>();
            arguments.put('objectName', 'mock');
            arguments.put('response', new HttpResponse());
            
            String dataHubSyncClass = 'Syntilio.DataHubSynchronisation';
            Callable dataHubSyncClassCallableInstance = (Callable) Type.forName(dataHubSyncClass).newInstance();
            callableInterfaceResponse = dataHubSyncClassCallableInstance.call('unknown', arguments);
            
            Test.stopTest(); 
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }

        System.assertEquals(callableInterfaceResponse, null);
    }
        
}