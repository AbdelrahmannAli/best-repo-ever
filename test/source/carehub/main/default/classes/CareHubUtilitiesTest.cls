@isTest
public with sharing class CareHubUtilitiesTest {
    
    private static Account getAccount(){
		return [SELECT Id FROM Account LIMIT 1];
    }
    
    private static Contact getContact(){
		return [SELECT Id FROM Contact LIMIT 1];
    }
    
    private static Syntilio__ExternalSystem__c getExternalSystem(){
		return [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c LIMIT 1];
    }
    
    private static void createContactContactRelationshipData(){
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 4; i++){
            contacts.add(
                Syntilio.CareHubTestDataFactory.createContact(
                    new Map<String, Object>{
                        'LastName' => 'contact' + i,
                        'Email' => 'contact' + i + '@example.com'
                    }
                )
            );
        }
        insert contacts;
        List<Syntilio__ContactContactRelationship__c> relationshipList = new List<Syntilio__ContactContactRelationship__c>();
        
        Syntilio__ContactContactRelationship__c relationship01 = new Syntilio__ContactContactRelationship__c();
        relationship01.Syntilio__RelatedContactId__c = contacts[0].Id;
        relationship01.Syntilio__ContactId__c = contacts[1].Id;
        relationship01.Syntilio__Type__c = 'Emergency';
        relationship01.Syntilio__RelationshipType__c = 'Informal';
        relationshipList.add(relationship01);
        
        Syntilio__ContactContactRelationship__c relationship21 = new Syntilio__ContactContactRelationship__c();
        relationship21.Syntilio__RelatedContactId__c = contacts[2].Id;
        relationship21.Syntilio__ContactId__c = contacts[1].Id;
        relationship21.Syntilio__Type__c = 'Emergency';
        relationship21.Syntilio__RelationshipType__c = 'Informal';
        relationshipList.add(relationship21);
        
        Syntilio__ContactContactRelationship__c relationship23 = new Syntilio__ContactContactRelationship__c();
        relationship23.Syntilio__RelatedContactId__c = contacts[2].Id;
        relationship23.Syntilio__ContactId__c = contacts[3].Id;
        relationship23.Syntilio__Type__c = 'Emergency';
        relationship23.Syntilio__RelationshipType__c = 'Informal';
        relationshipList.add(relationship23);
        
        insert relationshipList;
    }
    
    @testSetup
    static void setup(){
        Account accountRecord = Syntilio.CareHubTestDataFactory.createAccount(null);
        Syntilio__ExternalSystem__c externalSystemRecord = Syntilio.DataHubTestDataFactory.createExternalSystem(null);
        insert new List<SObject>{accountRecord, externalSystemRecord};
        Contact contactRecord = Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{'AccountId' => accountRecord.Id});   
        Syntilio__AccountExternalSystemAssociation__c accountExternalSystemAssociationRecord = Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation(
            new Map<String, Object>{
                'Syntilio__AccountId__c' => accountRecord.Id,
                'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
            }
        );
        Schema.Location locationRecord = Syntilio.CareHubTestDataFactory.createLocation(
            new Map<String, Object>{
                'Syntilio__AccountId__c' => accountRecord.Id,
                'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
            }
        );
        insert new List<SObject>{contactRecord, accountExternalSystemAssociationRecord, locationRecord};
        createContactContactRelationshipData();
    }
    
    @isTest
    static void getSobjectFromIdTest_Contact() {
        Contact contactRecord = getContact();
        
        Test.startTest();
        String sObjectType = Syntilio.CareHubUtilities.getSobjectFromId(contactRecord.Id);
        Test.stopTest();
        
        System.assertEquals('contact', sObjectType.toLowerCase());
    }

    @isTest
    static void getSobjectFromIdTest_Account() {
        Account accountRecord = getAccount();
        
        Test.startTest();
        String sObjectType = Syntilio.CareHubUtilities.getSobjectFromId(accountRecord.Id);
        Test.stopTest();

        System.assertEquals('account', sObjectType.toLowerCase());
    }

    @isTest
    static void testGetExternalSystemIdTest_Found() {
        Syntilio__ExternalSystem__c externalSystemRecord = getExternalSystem();
        
        Test.startTest();
        ResponseMessage systemIdResponse = Syntilio.CareHubUtilities.getExternalSystemId('ES');
        Test.stopTest();
        
        String systemId = (String) systemIdResponse.data;
        System.assertEquals(externalSystemRecord.Id, systemId);
    }

    @isTest
    static void testGetExternalSystemIdTest_NotFound() {
        ResponseMessage exceptedResponse = new ResponseMessage(
            '',
            'External system not found; please verify the external system api name existence',
            ResponseMessage.MessageType.ERROR
        );
        
        Test.startTest();
        ResponseMessage result = Syntilio.CareHubUtilities.getExternalSystemId(
            'Nonexistent'
        );
        Test.stopTest();
        
        System.assertEquals(exceptedResponse.data, result.data);
        System.assertEquals(exceptedResponse.message, result.message);
        System.assertEquals(exceptedResponse.type, result.type);
    }

    @isTest
    static void getLocationIdTest_Found() {
        Syntilio__ExternalSystem__c externalSystemRecord = getExternalSystem();
        Account accountRecord = getAccount();
        List<Schema.Location> locationIds = [
            SELECT Syntilio__LocationId__c
            FROM Location
            WHERE Syntilio__AccountId__c = :accountRecord.Id
            AND Syntilio__ExternalSystemId__c = :externalSystemRecord.Id
        ];
        
        ResponseMessage exceptedResponse = new ResponseMessage(
            String.valueOf(locationIds[0].Syntilio__LocationId__c),
            'Success',
            ResponseMessage.MessageType.SUCCESS
        );
        
        Test.startTest();
        ResponseMessage locationIdResponse = Syntilio.CareHubUtilities.getLocationId(accountRecord.Id, 'ES');
        Test.stopTest();

        System.assertEquals(exceptedResponse.data, locationIdResponse.data);
        System.assertEquals(exceptedResponse.message, locationIdResponse.message);
        System.assertEquals(exceptedResponse.type, locationIdResponse.type);
    }

    @isTest
    static void getLocationIdLocationTest_NotFound() {        
        ResponseMessage response = new ResponseMessage(
            '',
            'Unable to locate the specified external system at the provided location for the associated account; please verify the accuracy of the location and account details.',
            ResponseMessage.MessageType.ERROR
        );
        
		Test.startTest();        
        ResponseMessage locationIdResponse = Syntilio.CareHubUtilities.getLocationId(
            'Wrong Id',
            'ES'
        );        
        Test.stopTest();
        
        System.assertEquals(response.data, locationIdResponse.data);
        System.assertEquals(response.message, locationIdResponse.message);
        System.assertEquals(response.type, locationIdResponse.type);
    }

    @isTest
    static void getLocationIdTest_LocationExternalSystemNotFound() {
        ResponseMessage response = new ResponseMessage(
            '',
            'External system not found; please verify the system existence and configuration',
            ResponseMessage.MessageType.ERROR
        );
        Test.startTest();
        ResponseMessage locationIdResponse = Syntilio.CareHubUtilities.getLocationId('Wrong Id', 'Wrong ES');
        Test.stopTest();
        
        System.assertEquals(response.data, locationIdResponse.data);
        System.assertEquals(response.message, locationIdResponse.message);
        System.assertEquals(response.type, locationIdResponse.type);
    }
    
    @isTest
    static void getAccountExternalSystemsTest_Found() {
        Account accountRecord = getAccount();
        
        Test.startTest();
        List<String> externalSystems = Syntilio.CareHubUtilities.getAccountExternalSystems(accountRecord.Id);
        Test.stopTest();
        
        System.assertEquals(1, externalSystems.size());
    }

    @isTest
    static void getAccountExternalSystemsTest_NotFound() {
        Test.startTest();
        List<String> externalSystems = Syntilio.CareHubUtilities.getAccountExternalSystems('Wrong Id');
        Test.stopTest();
        
        System.assertEquals(0, externalSystems.size());
    }

    @isTest
    static void testCreateTasksTest_NoTasksCreated() {
        List<Contact> contacts = new List<Contact>();
        List<Id> accountIds = new List<Id>();
        Account accountRecord = getAccount();
        
        for (Integer i = 0; i < 2; i++) {
            Contact newContact = Syntilio.CareHubTestDataFactory.createContact(
                new Map<String, Object>{
                    'LastName' => 'test' + i,
                    'Email' => 'test' + i + '@example.com'
                }
            );
            contacts.add(newContact);
            accountIds.add(accountRecord.Id);
        }
        
        List<Database.SaveResult> insertedContacts = Syntilio.UpsertToDatabase.insertAction(
            contacts,
            false
        );
        
        Test.startTest();
        Syntilio.CareHubUtilities.createTasks(
            insertedContacts,
            'Contact',
            accountIds,
            '',
            'High'
        );
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id, WhoId, WhatId FROM Task];
        System.assertEquals(0, tasks.size());
    }

    @isTest
    static void testCreateTasksTest_TasksCreated() {
        List<Contact> contacts = new List<Contact>();   
        List<Id> accountIds = new List<Id>();      
        Account accountRecord = getAccount();
       
        for (Integer i = 0; i < 4; i++) {
            Contact newContact = Syntilio.CareHubTestDataFactory.createContact(null);
            contacts.add(newContact);
            accountIds.add(accountRecord.Id);
        }
        
        List<Database.SaveResult> insertedContacts = Syntilio.UpsertToDatabase.insertAction(
            contacts,
            false
        );
        
        Test.startTest();
        Syntilio.CareHubUtilities.createTasks(
        	insertedContacts,
            'Contact',
            accountIds,
            'High',
            'High'
        );
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id, WhoId, WhatId FROM Task];
        System.assertEquals(4, tasks.size());
    }

    @isTest
    static void reorderRecordsTest_RecordIdNull() {
        List<Syntilio__ContactContactRelationship__c> relationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
        ];
        String condition =
            'Syntilio__ContactId__c = \'' +
            relationshipsList[0].Syntilio__ContactId__c +
            '\' AND Syntilio__Type__c = \'' +
            relationshipsList[0].Syntilio__Type__c +
            '\' ';
        Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
            'Syntilio__ContactContactRelationship__c',
            1,
            null,
            condition
        );
        List<Syntilio__ContactContactRelationship__c> updatedRelationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
            WHERE
            Syntilio__ContactId__c = :relationshipsList[0].Syntilio__ContactId__c
            AND Syntilio__Type__c = :relationshipsList[0].Syntilio__Type__c
        ];
        
        System.assertEquals(true, reordered);
        System.assertEquals(2, updatedRelationshipsList.size());
        System.assertEquals(2, updatedRelationshipsList[0].Syntilio__Order__c);
        System.assertEquals(3, updatedRelationshipsList[1].Syntilio__Order__c);
    }

    @isTest
    static void reorderRecordsTest_RecordIdNotNull() {
        List<Syntilio__ContactContactRelationship__c> relationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
        ];
        String condition =
            'Syntilio__ContactId__c = \'' +
            relationshipsList[0].Syntilio__ContactId__c +
            '\' AND Syntilio__Type__c = \'' +
            relationshipsList[0].Syntilio__Type__c +
            '\' ';
        Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
            'Syntilio__ContactContactRelationship__c',
            2,
            relationshipsList[0].Id,
            condition
        );
        List<Syntilio__ContactContactRelationship__c> updatedRelationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
            WHERE
            Syntilio__ContactId__c = :relationshipsList[0].Syntilio__ContactId__c
            AND Syntilio__Type__c = :relationshipsList[0].Syntilio__Type__c
        ];
        
        System.assertEquals(true, reordered);
        System.assertEquals(2, updatedRelationshipsList.size());
        System.assertEquals(1, updatedRelationshipsList[1].Syntilio__Order__c);
    }

    @isTest
    static void reorderRecordsTest_RecordIdNotNullOrderNull() {
        List<Syntilio__ContactContactRelationship__c> relationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
        ];
        String condition =
            'Syntilio__ContactId__c = \'' +
            relationshipsList[0].Syntilio__ContactId__c +
            '\' AND Syntilio__Type__c = \'' +
            relationshipsList[0].Syntilio__Type__c +
            '\' ';
        Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
            'Syntilio__ContactContactRelationship__c',
            null,
            relationshipsList[0].Id,
            condition
        );
        List<Syntilio__ContactContactRelationship__c> updatedRelationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
            WHERE
            Syntilio__ContactId__c = :relationshipsList[0].Syntilio__ContactId__c
            AND Syntilio__Type__c = :relationshipsList[0].Syntilio__Type__c
        ];
        
        System.assertEquals(true, reordered);
        System.assertEquals(2, updatedRelationshipsList.size());
        System.assertEquals(1, updatedRelationshipsList[1].Syntilio__Order__c);
    }

    @isTest
    static void reorderRecordsTest_BothNull() {
        List<Syntilio__ContactContactRelationship__c> relationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
        ];
        String condition =
            'Syntilio__ContactId__c = \'' +
            relationshipsList[0].Syntilio__ContactId__c +
            '\' AND Syntilio__Type__c = \'' +
            relationshipsList[0].Syntilio__Type__c +
            '\' ';
        Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
            'Syntilio__ContactContactRelationship__c',
            null,
            null,
            condition
        );
        
        System.assertEquals(false, reordered);
    }

    @isTest
    static void reorderRecordsTest_NoRecords() {
        List<Syntilio__ContactContactRelationship__c> relationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
        ];
        String condition =
            'Syntilio__ContactId__c = \'' +
            relationshipsList[0].Syntilio__ContactId__c +
            '\' AND Syntilio__Type__c = \'' +
            'SOMETYPE' +
            '\' ';
        Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
            'Syntilio__ContactContactRelationship__c',
            1,
            null,
            condition
        );
        
        System.assertEquals(true, reordered);
    }

    @isTest
    static void getNextOrderTest_OnInsert() {
        List<Syntilio__ContactContactRelationship__c> relationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
        ];
        String condition =
            'Syntilio__ContactId__c = \'' +
            relationshipsList[0].Syntilio__ContactId__c +
            '\' AND Syntilio__Type__c = \'' +
            relationshipsList[0].Syntilio__Type__c +
            '\' ';
        Decimal nextOrder = Syntilio.CareHubUtilities.getNextOrder(
            'Syntilio__ContactContactRelationship__c',
            false,
            condition
        );
        
        System.assertEquals(3, nextOrder);
    }

    @isTest
    static void getNextOrderTest_OnUpdate() {
        List<Syntilio__ContactContactRelationship__c> relationshipsList = [
            SELECT Id, Syntilio__Order__c, Syntilio__ContactId__c, Syntilio__Type__c
            FROM Syntilio__ContactContactRelationship__c
        ];
        String condition =
            'Syntilio__ContactId__c = \'' +
            relationshipsList[0].Syntilio__ContactId__c +
            '\' AND Syntilio__Type__c = \'' +
            relationshipsList[0].Syntilio__Type__c +
            '\' ';
        Decimal nextOrder = Syntilio.CareHubUtilities.getNextOrder(
            'Syntilio__ContactContactRelationship__c',
            true,
            condition
        );
        
        System.assertEquals(2, nextOrder);
    }

    @isTest
    static void createTasksTest_RaiseException() {
        Syntilio.CareHubUtilities.raiseException = true;
        Test.startTest();
        Syntilio.CareHubUtilities.createTasks(
            new List<Database.SaveResult>{},
            'Contact',
            new List<String>{},
            'Failure',
            'High'
        );
        Test.stopTest();
        
        List<Syntilio__Exception__c> exceptionLogs = [
            SELECT Id
            FROM Syntilio__Exception__c
        ];
        
        System.assert(exceptionLogs.size() > 0);
    }

    @isTest
    static void reorderRecordsTest_RaiseException() {
        Syntilio.CareHubUtilities.raiseException = true;
        
        Test.startTest();
        Boolean didReorder = Syntilio.CareHubUtilities.reorderRecords(
            'Syntilio__ProtocolRelation__c',
            1,
            null,
            null
        );
        Test.stopTest();
        System.assertEquals(false, didReorder);
    }

    @isTest
    static void getNextOrderTest_RaiseException() {
        Syntilio.CareHubUtilities.raiseException = true;
        Test.startTest();
        Decimal orderNum = Syntilio.CareHubUtilities.getNextOrder(
            'Contact',
            false,
            null
        ) ;
        Test.stopTest();
        System.assertEquals(1, orderNum);
    }

    @isTest
    static void updateCaseContactIdTest_RaiseException() {
        Syntilio.CareHubUtilities.raiseException = true;
        
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'LastName' => 'contact lastname',
                'Email' => 'contactlastname@example.com'
            }
        );

        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case',
            	'Description' => 'Test Description'
            }
        );
        
        insert new List<SObject>{testContact, testCase};
        
        Test.startTest();
        Syntilio.CareHubUtilities.updateCaseContactId(testCase.Id, testContact.Id);
        Test.stopTest();
        
        Case updatedCase = [SELECT ContactId FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(testContact.Id, updatedCase.ContactId);
    }

    @isTest
    static void getOrganisationNameTest() {
        Test.startTest();
        String organisationName = Syntilio.CareHubUtilities.getOrganisationName();
        Test.stopTest();
        System.assertNotEquals(null, organisationName);
    }

    @isTest
    static void getParentLocationTest() {
        Account accountRecord = getAccount();
        Syntilio__ExternalSystem__c externalSystemRecord = getExternalSystem();
        Test.startTest();
        Schema.Location parentLocation = Syntilio.CareHubUtilities.getParentLocation(
            accountRecord.Id, externalSystemRecord.Syntilio__ApiName__c
        );
        Test.stopTest();
        System.assertNotEquals(null, parentLocation);
    }
    
    @isTest
    static void notifyLwcTest() {
        Test.startTest();
        Syntilio.CareHubUtilities.notifyLwc('test message', 'test target', 'Success');
        Test.stopTest();
        
        System.assert(true);
    }
}