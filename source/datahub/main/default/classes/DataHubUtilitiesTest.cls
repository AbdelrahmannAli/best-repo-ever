/*************************************************************************   
@description This test class for DataHubUtilities class*/
@isTest
public with sharing class DataHubUtilitiesTest {
    public static String contactLastName = 'subscriptionTest';
    public static String contactEmail = 'subscriptionTest@test.com';
    public static String accountName = 'subscriptionHandlerTest';
    public static String subscriptionName = 'subscriptionHandlerTestBasis';

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

    
    @testSetup
    public static void setupTestData() {
        try {
            Contact newContact = new Contact();
            newContact.LastName = Syntilio.DataHubUtilitiesTest.contactLastName;
            newContact.Email = Syntilio.DataHubUtilitiesTest.contactEmail;
            
            insert newContact;
            
            Account newAccount = new Account();
            newAccount.Name = Syntilio.DataHubUtilitiesTest.accountName;
            
            insert newAccount;
            
            Date contractStartDate = Date.today().addMonths(-3).toStartOfMonth();
            
            Contract newContract = new Contract();
            newContract.Status = 'Draft';
            newContract.StartDate = contractStartDate;
            newContract.ContractTerm = 12;
            newContract.AccountId = newAccount.Id;
            
            insert newContract;
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }
    
    @isTest
    static void createNewSobjectOfTypeTest() { 
        Map<String, Schema.SObjectType> sObjectGlobalDescribe = Schema.getGlobalDescribe(); 
        Schema.SObjectType sObjectType = sObjectGlobalDescribe.get('Contact');
        
        SObject insertedContact = Syntilio.DataHubUtilities.createNewSobjectOfType('Contact');
        System.assertEquals(sObjectType, insertedContact.getSobjectType());
    }
    
    @isTest
    static void getFieldDescribeMetaDataTest() { 
        Schema.DescribeSObjectResult[] contactSchemaDescribe = Schema.describeSObjects(new String[]{'Contact'});
        Set<String> fields = new Set<String>();
        fields.add('Name');
        System.assertEquals(true, contactSchemaDescribe.size() >= 1 ? true : false);
        Map<String, Schema.DescribeFieldResult> returnedDescribe = Syntilio.DataHubUtilities.getFieldDescribeMetaData(contactSchemaDescribe[0], fields);
        
        
        System.assertEquals(true, returnedDescribe.size() == 1 ? true : false);
        System.assertEquals('Name' , returnedDescribe.get('Name').name);
    }
    
    @isTest
    static void getSobjectFieldNameFieldFoundTest() { 
        Schema.DescribeSObjectResult[] contactSchemaDescribe = Schema.describeSObjects(new String[]{'Contact'});
        Set<String> fields = new Set<String>();
        fields.add('Name');
        
        Map<String, Schema.DescribeFieldResult> returnedDescribe = Syntilio.DataHubUtilities.getFieldDescribeMetaData(contactSchemaDescribe[0], fields);
        System.assertNotEquals(null, returnedDescribe, 'Syntilio.DataHubUtilities.getFieldDescribeMetaData returns null');
        Schema.SObjectField sObjectField = Syntilio.DataHubUtilities.getSobjectFieldName(returnedDescribe, 'Name');
        System.assertNotEquals(null, sObjectField, 'Syntilio.DataHubUtilities.getSobjectFieldName returns null');
        Schema.DescribeFieldResult contactNameField = Contact.Name.getDescribe();
        
        Schema.sObjectField nameSObjectField = contactNameField.getSObjectField();
        
        System.assertEquals(nameSObjectField , sObjectField);
    }
    
    @isTest
    static void getSobjectFieldNameFieldNotFoundTest() { 
        Schema.DescribeSObjectResult[] contactSchemaDescribe = Schema.describeSObjects(new String[]{'Contact'});
        Set<String> fields = new Set<String>();
        fields.add('Name');
        
        Map<String, Schema.DescribeFieldResult> returnedDescribe = Syntilio.DataHubUtilities.getFieldDescribeMetaData(contactSchemaDescribe[0], fields);
        System.assertNotEquals(null, returnedDescribe, 'Syntilio.DataHubUtilities.getFieldDescribeMetaData returns null');
        Schema.SObjectField sObjectField = Syntilio.DataHubUtilities.getSobjectFieldName(returnedDescribe, 'ContactFakeField');
        System.assertEquals(null, sObjectField);
        
    }
    
    /*************************************************************************   
@description This test method inputs valid string array and should cast successfully */
    @isTest
    public static void stringArrayToDecimalArray_Should_CastSuccessfully_Test() {
        List<String> stringList = new List<String>{'1111','2222','3333'};
            List<Decimal> castedToDecimalList = new List<Decimal>();
        try{
            
            Test.startTest();
            castedToDecimalList = Syntilio.DataHubUtilities.castStringArrayToDecimalArray(stringList);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(1111, castedToDecimalList[0]);
        system.assertEquals(2222, castedToDecimalList[1]);
        system.assertEquals(3333, castedToDecimalList[2]);
    }
    
    /*************************************************************************   
@description This test method empty string array and should not cast successfully */
    @isTest
    public static void stringArrayToDecimalArray_Should_Not_CastSuccessfully_Test() {
        List<String> stringList = new List<String>();
        List<Decimal> castedToDecimalList = new List<Decimal>();
        Boolean checkIfStringListIsEmpty_ShouldBeTrue;
        Boolean checkIfCastedToDecimalListIsEmpty_ShouldBeTrue;
        
        try{

            Test.startTest();
            castedToDecimalList = Syntilio.DataHubUtilities.castStringArrayToDecimalArray(stringList);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        checkIfStringListIsEmpty_ShouldBeTrue = stringList.isEmpty()? true : false;
        checkIfCastedToDecimalListIsEmpty_ShouldBeTrue = castedToDecimalList == null? true : false;
        system.assertEquals(null, castedToDecimalList);
        system.assertEquals(checkIfStringListIsEmpty_ShouldBeTrue, checkIfCastedToDecimalListIsEmpty_ShouldBeTrue);
    }
    
    /*************************************************************************   
@description This test method tests safeParseDecimal with valid string and should cast successfully */
    @isTest
    public static void safeParseDecimal_Should_parseSuccessfully_Test() {
        String toBeParsedString ='1111';
        Decimal parsedString;
        try{

            Test.startTest();
            parsedString = Syntilio.DataHubUtilities.safeParseDecimal(toBeParsedString);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(1111, parsedString);
    }
    
    /*************************************************************************   
@description This test method tests safeParseDecimal with empty string and should not cast successfully */
    @isTest
    public static void safeParseDecimal_Should_Not_parseSuccessfully_Test() {
        String toBeParsedString;
        Decimal parsedString;
        try{

            Test.startTest();
            parsedString = Syntilio.DataHubUtilities.safeParseDecimal(toBeParsedString);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(null, parsedString);
    }
    
    /*************************************************************************   
@description This test method tests safeParseDecimal with invalid string and should not cast successfully */
    @isTest
    public static void safeParseDecimal_NonNumeric_Values_Should_Not_parseSuccessfully_Test() {
        String toBeParsedString = '%';
        Decimal parsedString;
        try{

            Test.startTest();
            parsedString = Syntilio.DataHubUtilities.safeParseDecimal(toBeParsedString);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertEquals(null, parsedString);
        system.assertEquals(true, exceptionList.size() >= 1 ? true : false);
        
    }
    
    /*************************************************************************   
@description This test method tests CRUD or FLS access to object to create a record in the database*/
    @isTest
    public static void createTask_Test() {
        Task taskRecord;
        try{

            Test.startTest();
            taskRecord = Syntilio.DataHubUtilities.createTask('Contact', null, 'Test Subject', 'Test description', 'High');
            insert taskRecord;
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Task> taskList = [SELECT Id FROM TASK];
        system.assertNotEquals(0, taskList.size());
    }
    
    /*************************************************************************   
@description This test method tests CRUD or FLS access to object to create a record in the database*/
    @isTest
    public static void isObjectisCreateable_Should_Be_Createable_Test() {
        Boolean isCreateable;
        try{

            Test.startTest();
            isCreateable = Syntilio.DataHubUtilities.isObjectCreateable('Contact', null);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(true, isCreateable);
    }
    
    /*************************************************************************   
@description This test method tests CRUD or FLS access to object to update a record in the database*/
    @isTest
    public static void isObjectUpdateable_Should_Be_Updateable_Test() {
        Boolean isUpdateable;
        try{

            Test.startTest();
            isUpdateable = Syntilio.DataHubUtilities.isObjectUpdateable('Contact', null);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(true, isUpdateable);
    }
    
    /*************************************************************************   
@description This test method tests CRUD or FLS access to object to access a record in the database*/
    @isTest
    public static void isObjectAccessible_Should_Be_Accessible_Test() {
        Boolean isAccessible;
        try{

            Test.startTest();
            isAccessible = Syntilio.DataHubUtilities.isObjectAccessible('Contact', null);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(true, isAccessible);
    }
    
    /*************************************************************************   
@description This test method tests getting default record type for any sobject*/
    @isTest
    public static void getDefaultRecordTypeForSObject_Test() {
        Schema.RecordTypeInfo defaultRecordTypeInfo;
        try{

            Test.startTest();
            defaultRecordTypeInfo = Syntilio.DataHubUtilities.getDefaultRecordTypeForSObject('Contact');
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(true, defaultRecordTypeInfo.isDefaultRecordTypeMapping());
    }
    
    /*************************************************************************   
@description This test method tests getting org default language*/
    @isTest
    public static void getOrgDefaultLanguage_Test() {
        String orgDefaultLanguage;
        try{

            Test.startTest();
            orgDefaultLanguage = Syntilio.DataHubUtilities.getOrgDefaultLanguage();
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertNotEquals(null, orgDefaultLanguage);
    }
    
    /*************************************************************************   
@description This test method tests getting Error Code Description ApiName*/
    @isTest
    public static void composeErrorCodeDescriptionApiName_Test() {
        String orgDefaultLanguage;
        String fieldApiName;
        try{

            Test.startTest();
            orgDefaultLanguage = Syntilio.DataHubUtilities.getOrgDefaultLanguage();
            fieldApiName = Syntilio.DataHubUtilities.composeErrorCodeDescriptionApiName(orgDefaultLanguage);
            Test.stopTest();
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertNotEquals(null, fieldApiName);
    }  
    
    @isTest
    static void getSobjectFromIdTest(){
        List<Account> accountList = [
            SELECT Id, Name
            FROM Account
            WHERE Name = :DataHubUtilitiesTest.accountName
        ];
        
        List<Contact> contactList = [
            SELECT Id, LastName, Email
            FROM Contact
            WHERE LastName = :DataHubUtilitiesTest.contactLastName AND Email = :DataHubUtilitiesTest.contactEmail
        ];
        
        
        List<Contract> contractList = [
            SELECT Id
            FROM Contract
        ];
        
        if(contractList.size() == 0 || contactList.size() == 0 || accountList.size()  == 0) {
            System.assertEquals(contractList.size() > 0, true, 'No contracts were found');
            System.assertEquals(contactList.size() > 0, true, 'No contacts were found');
            System.assertEquals(accountList.size() > 0, true, 'No accounts were found in createOrderTest');
            return;
        }
        
        
        System.assertEquals('Contract', Syntilio.DataHubUtilities.getSobjectFromId(contractList[0].Id));
        System.assertEquals('Contact', Syntilio.DataHubUtilities.getSobjectFromId(contactList[0].Id));
        System.assertEquals('Account', Syntilio.DataHubUtilities.getSobjectFromId(accountList[0].Id));
    }
    
    @isTest
    static void testGetExceptionTypes() {
        List<Syntilio.HandleException.ExceptionSource> exceptionTypes = Syntilio.HandleException.ExceptionSource.values();
        List<string> exceptionTypesStr = new List<string>();
        for(Syntilio.HandleException.ExceptionSource exceptionType : exceptionTypes) {
            exceptionTypesStr.add(exceptionType.name());
        }
        List<String> expectedTypesResult = Syntilio.DataHubUtilities.getExceptionTypes();
        for(String expectedType : expectedTypesResult) {
            System.assertEquals(true, exceptionTypesStr.contains(expectedType));
        }
    }
    
    @IsTest
    static void getCaseContactIdTest(){
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        
        Case testCase1 = new Case(Subject = 'Test Case 1', ContactId = testContact.Id);
        insert testCase1;
        
        Test.startTest();
        String contactInfo = Syntilio.DataHubUtilities.getCaseContactId(testCase1.Id);
        Map<String,Object> deserializedContactInfo = ( Map<String,Object> ) JSON.deserializeUntyped(contactInfo);
        Test.stopTest();
        
        System.assertEquals(deserializedContactInfo.containsKey('ContactId'), True);
        System.assertEquals(deserializedContactInfo.get('ContactId'), testContact.Id);
    }
    
    @IsTest
    static void isSomeFieldsChangedTest(){
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe');
        
        Contact contact2 = new Contact(FirstName = 'Youssef', LastName = 'Doe');
        
        List<String> fields = new List<String>{'FirstName'};
            
            Test.startTest();
        Boolean fieldsChanged = Syntilio.DataHubUtilities.isSomeFieldsChanged(fields, contact1, contact2);
        Boolean fieldsDidNotChanged = Syntilio.DataHubUtilities.isSomeFieldsChanged(fields, contact1, contact1);
        Test.stopTest();
        
        System.assertEquals(true, fieldsChanged);
        System.assertEquals(false, fieldsDidNotChanged);
    }
    
    @isTest
    static void mapToSObjectTest(){
        Map<String, Object> objectMap = new Map<String, Object>{'FirstName' => 'John', 'LastName' => 'Doe'};
            
            Test.startTest();
        try{
            Contact contact = (Contact) Syntilio.DataHubUtilities.mapToSObject('Contact', objectMap);
            System.assertEquals('John', contact.FirstName);
        }catch(Exception e){
            System.assert(false);
        }     
        Test.stopTest();
    }
    
    @isTest
    static void getFieldValueFromSObjectTest(){
        Account account = new Account(
            Name='test account'
        );
        insert account;
        Contact contact = new Contact(
            LastName='Doe',
            AccountId=account.Id
        );
        insert contact;
        
        Test.startTest();
        try{
            Contact contactFound = [SELECT LastName, Account.Name FROM Contact WHERE LastName = 'Doe' LIMIT 1];
            String lastName = (String) Syntilio.DataHubUtilities.getFieldValueFromSObject('LastName', contactFound);
            String accountName = (String) Syntilio.DataHubUtilities.getFieldValueFromSObject('Account.Name', contactFound);
            Contact returnedContact = (Contact) Syntilio.DataHubUtilities.getFieldValueFromSObject(null, contactFound);
            System.assertEquals('Doe', lastName);
            System.assertEquals('test account', accountName);
        }catch(Exception e){
            System.assert(false);
        }       
        Test.stopTest();
    }
    
    @isTest
    static void listToMapTest(){
        Account account = new Account(
            Name='test account'
        );
        insert account;
        Contact contact = new Contact(
            LastName='Doe',
            AccountId=account.Id
        );
        insert contact;
        
        Test.startTest();
        try{
            List<Contact> contactsFound = [SELECT LastName, Account.Name FROM Contact WHERE LastName = 'Doe' LIMIT 1];
            Map<String, Object> contactsMap = Syntilio.DataHubUtilities.listToMap('LastName', 'Account.Name', contactsFound);
            System.assert(contactsMap.size() > 0);
            System.assertEquals('test account', contactsMap.get('Doe'));
        }catch(Exception e){
            System.assert(false);
        }    
        Test.stopTest();   
    }
    
    @isTest
    static void getSObjectExternalIdsMapTest(){
        createDataHubSynchronisationTestData();
        List<Syntilio__ExternalId__c> externalIds = [SELECT Id, Syntilio__ContactId__c FROM Syntilio__ExternalId__c];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id = :externalIds[0].Syntilio__ContactId__c];
        Set<String> externalSystems = new Set<String>{'Ons'};
            Test.startTest();
        Map<String, List<Syntilio__ExternalId__c>> externalIdsMap = Syntilio.DataHubUtilities.getSObjectExternalIdsMap('Contact', contacts[0].Id, externalSystems);
        System.assert(externalIdsMap.size() > 0);
        System.assertNotEquals(null, externalIdsMap.get('Ons'));
        System.assertNotEquals(0, externalIdsMap.get('Ons').size());
        Test.stopTest();
    }
    
    @isTest 
    static void setupExternalSystemsAndPushMapTest(){
        List<Syntilio__DataHubSyncInfo__c> fieldsToPush = new List<Syntilio__DataHubSyncInfo__c>{
            new Syntilio__DataHubSyncInfo__c(
                Name = 'FirstName',
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__ExternalSystems__c = 'Ons'
            ),
                new Syntilio__DataHubSyncInfo__c(
                    Name = 'FirstName',
                    Syntilio__ObjectName__c = 'Contact',
                    Syntilio__ExternalSystems__c = 'Fierit'
                )
                }; 
                    Set<String> fieldNamesList = new Set<String>();
        Map<String, List<String>> externalSystemFieldNames = new Map<String, List<String>>();
        Map<String, Syntilio__DataHubSyncInfo__c> fieldsToPushMap = new Map<String, Syntilio__DataHubSyncInfo__c>();
        Set<String> externalSystems = new Set<String>();

        Test.startTest();
        Syntilio.DataHubUtilities.setupExternalSystemsAndPushMap(fieldsToPush, fieldNamesList, externalSystemFieldNames, fieldsToPushMap, externalSystems);
        Test.stopTest();

        System.assertEquals(1, fieldNamesList.size());
        System.assertEquals(2, externalSystemFieldNames.size());
        System.assertEquals('FirstName', externalSystemFieldNames.get('Ons')[0]);
        System.assertEquals(1, fieldsToPushMap.size());
        System.assertEquals('Contact', fieldsToPushMap.get('FirstName').Syntilio__ObjectName__c);
        System.assertEquals(2, externalSystems.size());
    }
    
    @isTest 
    static void getDestinationListAllAccountsAccountAssociationsFoundTest(){
        createDataHubSynchronisationTestData();
        Set<String> externalSystems = new Set<String>{'Ons'};

        Test.startTest();
        List<Syntilio.DataHubModel.Destination> destinations = Syntilio.DataHubUtilities.getDestinationListAllAccounts(externalSystems);
        Test.stopTest();

        System.assertEquals(1, destinations.size());
        System.assertEquals('Ons', destinations[0].technology);
    }
    
    @isTest 
    static void getDestinationListAllAccountsNoAccountAssociationsFoundTest(){
        Set<String> externalSystems = new Set<String>{'Ons'};

        Test.startTest();
        List<Syntilio.DataHubModel.Destination> destinations = Syntilio.DataHubUtilities.getDestinationListAllAccounts(externalSystems);
        Test.stopTest();

        System.assertEquals(1, destinations.size());
        System.assertEquals('Ons', destinations[0].technology);
    }
    
    @isTest 
    static void getDestinationListWithAccountIdTest(){
        createDataHubSynchronisationTestData();
        List<Account> accounts = [SELECT Id FROM Account WHERE Syntilio__ApiName__c = 'Twb'];
        Set<String> externalSystems = new Set<String>{'Ons'};

        Test.startTest();
        List<Syntilio.DataHubModel.Destination> destinations = Syntilio.DataHubUtilities.getDestinationList(accounts[0].Id, externalSystems);
        Test.stopTest();

        System.assertEquals(1, destinations.size());
        System.assertEquals('Ons', destinations[0].technology);
    }
    
    @isTest 
    static void getDestinationListWithoutAccountIdTest(){
        createDataHubSynchronisationTestData();
        Set<String> externalSystems = new Set<String>{'Ons'};

        Test.startTest();
        List<Syntilio.DataHubModel.Destination> destinations = Syntilio.DataHubUtilities.getDestinationList(null, externalSystems);
        Test.stopTest();

        System.assertEquals(1, destinations.size());
        System.assertEquals('Ons', destinations[0].technology);
    }
    
    @isTest 
    static void messageExistsTest(){
        Contact contact = new Contact(FirstName = 'Test');
        contact.addError('test error');

        Test.startTest();
        Boolean messageExists = Syntilio.DataHubUtilities.messageExists(contact, 'test error');
        Boolean messageDoesNotExists = Syntilio.DataHubUtilities.messageExists(contact, 'no error');
        Test.stopTest();

        System.assertEquals(true, messageExists);
        System.assertEquals(false, messageDoesNotExists);
    }
    
    @isTest 
    static void createTaskTest(){
        Account account = new Account(Name = 'Test Account');
        insert account;
        Contact contactFound = [SELECT Id FROM Contact LIMIT 1];
        Contact contact1 = new Contact(LastName = 'Test', AccountId = account.Id);
        Contact contact2 = new Contact(LastName = 'Test', AccountId = contactFound.Id);
        contact2.addError('some error');
        List<Contact> contacts = new List<Contact>{contact1, contact2};
            List<Database.SaveResult> insertedRecords = Syntilio.UpsertToDatabase.insertAction(contacts, false);
        String objectType = 'Contact';
        List<String> recordId = new List<String>{String.valueOf(account.Id), String.valueOf(contactFound.Id)};
            String subject = 'subject';
        String priority = 'high';

        Test.startTest();
        Syntilio.DataHubUtilities.createTasks(insertedRecords, objectType, recordId, subject, priority);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertNotEquals(0, tasks.size());
    }
    
    @isTest 
    static void getExternalSystemIdTest(){
        createDataHubSynchronisationTestData();

        Test.startTest();
        Syntilio.ResponseMessage resultSuccess = Syntilio.DataHubUtilities.getExternalSystemId('Ons');
        Syntilio.ResponseMessage resultFailure = Syntilio.DataHubUtilities.getExternalSystemId('Fierit');
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertNotEquals(resultSuccess.type, Syntilio.ResponseMessage.MessageType.ERROR);
        System.assertEquals(resultFailure.type, Syntilio.ResponseMessage.MessageType.ERROR);
    }
    
    @isTest 
    static void getViableExternalSystemsListTest(){
        createDataHubSynchronisationTestData();
        Syntilio__DataHubSyncInfo__c firstName = new Syntilio__DataHubSyncInfo__c(
            Name = 'FirstName',
            Syntilio__ObjectName__c = 'Contact',
            Syntilio__ExternalSystems__c = 'Ons,Fierit',
            Syntilio__Frequency__c = 10
        );
        insert firstName;
        List<Account> accounts = [SELECT Id FROM Account WHERE Syntilio__ApiName__c = 'Twb'];

        Test.startTest();
        List<String> externalSystemsList = Syntilio.DataHubUtilities.getViableExternalSystems(accounts[0].Id, 'Contact');
        Test.stopTest();

        System.assertNotEquals(0, externalSystemsList.size());
    }
    
    @isTest 
    static void getContactExternalSystemIdTest(){
        createDataHubSynchronisationTestData();
        Contact contact = [SELECT Id FROM Contact WHERE Account.Syntilio__ApiName__c = 'Twb' LIMIT 1];
        List<Account> accounts = [SELECT Id FROM Account WHERE Syntilio__ApiName__c = 'Twb'];

        Test.startTest();
        String externalId = Syntilio.DataHubUtilities.getContactExternalSystemId(contact.Id);
        Test.stopTest();

        System.assertNotEquals(null, externalId);
    }
    
    @isTest 
    static void sObjectListToIdListTest(){
        Test.startTest();
        List<Contact> contacts = [SELECT Id, Name FROM Contact];
		List<Id> contactIds = Syntilio.DataHubUtilities.sObjectListToIdList(contacts);
        
        for(Integer i = 0; i < contacts.size(); i++){
            System.assertEquals(contactIds[i], contacts[i].Id);
        }
        Test.stopTest();
    }
}