@isTest
public with sharing class ContactGroupControllerTest {
    
    private static Case getProductCase() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        return [SELECT Id FROM Case WHERE ProductId = :product.Id LIMIT 1];
    }
    
    private static Case getCase() {
        return [SELECT Id FROM Case WHERE ProductId = null LIMIT 1];
    }
    
    private static void createContactGroupControllerData() {
        Account accountRecord = Syntilio.CareHubTestDataFactory.createAccount(null);
        insert accountRecord;
        
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 2; i++){
            contacts.add(
                Syntilio.CareHubTestDataFactory.createContact(
                    new Map<String, Object>{
                        'LastName' => 'contact ' + i,
                        'AccountId' => accountRecord.Id
                    }
                )
            );
        }
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'SharedDevice' LIMIT 1].Id;
        
        Contact sharedDeviceContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
            	'FirstName' => 'Shared Device',
                'LastName' => 'Contact',
                'RecordTypeId' => recordTypeId
            }
        );
        
        contacts.add(sharedDeviceContact);
        
        Syntilio__Group__c testGroup = Syntilio.CareHubTestDataFactory.createGroup(null);
        
        List<SObject> toInsert = new List<SObject>();
        toInsert.addAll(contacts);
        toInsert.add(testGroup);
        insert toInsert;
        
        List<Syntilio__GroupMember__c> groupMemberAssociationList = new List<Syntilio__GroupMember__c>();
        for (Contact contact : contacts) {
            Syntilio__GroupMember__c groupMemberAssociation = Syntilio.CareHubTestDataFactory.createGroupMember(
                new Map<String, Object>{
                    'Syntilio__ContactId__c' => contact.Id,
                	'Syntilio__GroupId__c' => testGroup.Id
                }
            );
            groupMemberAssociationList.add(groupMemberAssociation);
        }
        
        Product2 product = Syntilio.CareHubTestDataFactory.createProduct2(null);
        
        toInsert = new List<SObject>();
        toInsert.addAll(groupMemberAssociationList);
        toInsert.add(product);
        insert toInsert;
        
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
			new Map<String, Object>{
                'ContactId' => sharedDeviceContact.Id,
                'ProductId' => product.Id
        	}
        );
        insert testCase;
    }
    
    @testSetup
    static void setup() {
        createContactGroupControllerData();
    }
    
    @isTest
    static void getContactsGroupTest(){
        Case caseRecord = getProductCase();
        
        Test.startTest();
        String responseStr = ContactGroupController.getContactsGroup(caseRecord.Id);
        Test.stopTest();

        ResponseMessage responseMsg = Syntilio.ResponseMessage.deserialize(responseStr);
        List<Object> groupMembers = (List<Object>)responseMsg.data;
        
        System.assertEquals(Syntilio.ResponseMessage.MessageType.SUCCESS, responseMsg.type);
        System.assertEquals(2, groupMembers.size());
    }

    @isTest
    static void getContactsGroupTest_CaseIdNull(){
        Test.startTest();
        String responseStr = ContactGroupController.getContactsGroup(null);
        Test.stopTest();

        ResponseMessage responseMsg = Syntilio.ResponseMessage.deserialize(responseStr);
        ResponseMessage exceptionMsg = new ResponseMessage(
            null,
            'Case Id is required',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
        System.assertEquals(exceptionMsg.type, responseMsg.type);
        System.assertEquals(exceptionMsg.message, responseMsg.message);
    }

    @isTest
    static void getContactsGroupTest_WithoutSharedDeviceContact(){
        Contact testContact = [SELECT Id FROM Contact WHERE LastName LIKE '%contact%' LIMIT 1];
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
            	'ContactId' => testContact.Id
        	}
        );
        insert testCase;
        
        Test.startTest();
        String responseStr = ContactGroupController.getContactsGroup(testCase.Id);
        Test.stopTest();

        ResponseMessage responseMsg = Syntilio.ResponseMessage.deserialize(responseStr);
        ResponseMessage exceptionMsg = new ResponseMessage(
            null,
            'Contact record type is not Shared Device or Care Team',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
        System.assertEquals(exceptionMsg.type, responseMsg.type);
        System.assertEquals(exceptionMsg.message, responseMsg.message);
    }

    @isTest
    public static void getContactsGroupTest_WithoutContactGroup(){
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'RecordTypeId' => Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                    .get('SharedDevice')
                    .getRecordTypeId()
        	}
        );
        insert testContact;
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
            	'ContactId' => testContact.Id
        	}
        );
        insert testCase;
        
        Test.startTest();
        String responseStr = ContactGroupController.getContactsGroup(testCase.Id);
        Test.stopTest();

        ResponseMessage responseMsg = Syntilio.ResponseMessage.deserialize(responseStr);
        ResponseMessage exceptionMsg = new ResponseMessage(
            null,
            'No group found for this contact',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
        System.assertEquals(exceptionMsg.type, responseMsg.type);
        System.assertEquals(exceptionMsg.message, responseMsg.message);
    }
}