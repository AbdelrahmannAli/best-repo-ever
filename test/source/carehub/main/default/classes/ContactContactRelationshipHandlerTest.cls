@isTest
public with sharing class ContactContactRelationshipHandlerTest {
    
    private static List<Contact> getTestContacts() {
        return [SELECT Id, Name FROM Contact];
    }
    
    private static void createContactContactRelationshipTestData() {
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < 4; i++){
            contacts.add(
                Syntilio.CareHubTestDataFactory.createContact(
                    new Map<String, Object>{
                        'LastName' => 'Contact ' + i,
                            'Email' => 'test.contact' + i + '@example.com'
                            }
                )
            );
        }
        insert contacts;
        
        List<Syntilio__ContactContactRelationship__c> relationshipList = new List<Syntilio__ContactContactRelationship__c>{
            Syntilio.CareHubTestDataFactory.createContactContactRelationship(
                new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[0].Id, 'Syntilio__ContactId__c' => contacts[1].Id}
            ),
            Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            	new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[2].Id, 'Syntilio__ContactId__c' => contacts[1].Id}
            ),
			Syntilio.CareHubTestDataFactory.createContactContactRelationship(
				new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[2].Id, 'Syntilio__ContactId__c' => contacts[3].Id}
			)
		};
		insert relationshipList;
    }
    
    private static List<Syntilio__ContactContactRelationship__c> getTestContactContactRelationships() {
        return [
            SELECT
            Id,
            Name,
            Syntilio__RelatedContactId__c,
            Syntilio__ContactId__c,
            Syntilio__Type__c,
            Syntilio__Order__c,
            Syntilio__Relationship__c,
            Syntilio__RelationshipType__c
            FROM Syntilio__ContactContactRelationship__c
        ];
    }
    
    @testSetup
    static void setup() {
        createContactContactRelationshipTestData();
    }
    
    @isTest
    static void hasDuplicateRelationshipTest_True() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        
        Syntilio__ContactContactRelationship__c newRelationship = Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[0].Id, 'Syntilio__ContactId__c' => contacts[1].Id}
        );
        
        Test.startTest();
        Boolean hasDuplicate = Syntilio.ContactContactRelationshipHandler.hasDuplicateRelationship(newRelationship);
        System.assertEquals(true, hasDuplicate);
        
        Syntilio__ContactContactRelationship__c updatedRelationship = contactRelationships[0];
        updatedRelationship.Syntilio__RelatedContactId__c = contacts[2].Id;
        updatedRelationship.Syntilio__ContactId__c = contacts[3].Id;
        
        hasDuplicate = Syntilio.ContactContactRelationshipHandler.hasDuplicateRelationship(updatedRelationship);
        Test.stopTest();
        System.assertEquals(true, hasDuplicate);
    }
    
    @isTest
    static void hasDuplicateRelationshipTest_False() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        
        Syntilio__ContactContactRelationship__c newRelationship = Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[0].Id, 'Syntilio__ContactId__c' => contacts[1].Id, 'Syntilio__Type__c' => 'Other'}
        );
        
        Test.startTest();
        Boolean hasDuplicate = Syntilio.ContactContactRelationshipHandler.hasDuplicateRelationship(newRelationship);
        System.assertEquals(false, hasDuplicate);
        
        Syntilio__ContactContactRelationship__c updatedRelationship = contactRelationships[0];
        updatedRelationship.Syntilio__RelatedContactId__c = contacts[0].Id;
        updatedRelationship.Syntilio__ContactId__c = contacts[1].Id;
        hasDuplicate = Syntilio.ContactContactRelationshipHandler.hasDuplicateRelationship(updatedRelationship);
        Test.stopTest();
        System.assertEquals(false, hasDuplicate);
    }
    
    @isTest
    static void hasConflictingOrderTest_True() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        
        Syntilio__ContactContactRelationship__c newRelationship = Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[0].Id, 'Syntilio__ContactId__c' => contacts[1].Id, 'Syntilio__Order__c' => 1}
        );
        
        Test.startTest();
        Boolean hasConflict = Syntilio.ContactContactRelationshipHandler.hasConflictingOrder(
            newRelationship
        );
        System.assertEquals(true, hasConflict);
        
        Syntilio__ContactContactRelationship__c updatedRelationship = contactRelationships[0];
        updatedRelationship.Syntilio__Order__c = 2;
        hasConflict = Syntilio.ContactContactRelationshipHandler.hasConflictingOrder(
            updatedRelationship
        );
        Test.stopTest();
        
        System.assertEquals(true, hasConflict);
    }
    
    @isTest
    static void hasConflictingOrderTest_False() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        
        Syntilio__ContactContactRelationship__c newRelationship = Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            new Map<String, Object>{
                'Syntilio__RelatedContactId__c' => contacts[0].Id, 
                'Syntilio__ContactId__c' => contacts[1].Id, 
                'Syntilio__Type__c' => 'Other',
                'Syntilio__RelationshipType__c' => 'Formal'
            }
        );
        Test.startTest();
        Boolean hasConflict = Syntilio.ContactContactRelationshipHandler.hasConflictingOrder(
            newRelationship
        );
        System.assertEquals(false, hasConflict);
        
        Syntilio__ContactContactRelationship__c updatedRelationship = contactRelationships[0];
        updatedRelationship.Syntilio__RelatedContactId__c = contacts[0].Id;
        updatedRelationship.Syntilio__ContactId__c = contacts[1].Id;
        hasConflict = Syntilio.ContactContactRelationshipHandler.hasConflictingOrder(updatedRelationship);
        Test.stopTest();
        System.assertEquals(false, hasConflict);
    }
    
    @isTest
    static void getCaseEmergencyContactsTest_Success() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'ContactId' => contacts[1].Id
            }
        );
        insert newCase;
        
        Test.startTest();
        List<Syntilio__ContactContactRelationship__c> caseEmergencyContacts = Syntilio.ContactContactRelationshipHandler.getCaseEmergencyContacts(
            newCase.Id
        );
        Test.stopTest();
        System.assertEquals(2, caseEmergencyContacts.size());
        System.assertEquals(contactRelationships[0].Id, caseEmergencyContacts[0].Id);
    }
    
    @isTest
    static void getCaseEmergencyContactsTest_Failure() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'ContactId' => contacts[1].Id
            }
        );
        insert newCase;
        
        Test.startTest();
        List<Syntilio__ContactContactRelationship__c> caseEmergencyContacts = Syntilio.ContactContactRelationshipHandler.getCaseEmergencyContacts(
            contacts[1].Id
        );
        Test.stopTest();

        System.assertEquals(0, caseEmergencyContacts.size());
    }
    
    @isTest
    static void insertContactContactRelationshipTest_Duplicate() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        Syntilio__ContactContactRelationship__c newRelationship = Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[0].Id, 'Syntilio__ContactId__c' => contacts[1].Id}
        );
        Test.startTest();
        Database.SaveResult result = Database.insert(newRelationship, false);
        Test.stopTest();
        System.assertEquals(false, result.isSuccess());
        System.assert(result.getErrors().size() > 0);
        System.assertEquals('Contact relationship already exists', result.getErrors()[0].getMessage());
    }
    
    @isTest
    static void insertContactContactRelationshipTest_Conflicting() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        
        Syntilio__ContactContactRelationship__c newRelationship = Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            new Map<String, Object>{'Syntilio__RelatedContactId__c' => contacts[3].Id, 'Syntilio__ContactId__c' => contacts[1].Id, 'Syntilio__Order__c' => 1}
        );
        Test.startTest();
        Database.SaveResult result = Database.insert(newRelationship, false);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess());
    }
    
    @isTest
    static void updateContactContactRelationshipTest_Conflicting() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        Syntilio__ContactContactRelationship__c relationshipToUpdate = contactRelationships[0];
        relationshipToUpdate.Syntilio__Order__c = 2;
        
        Test.startTest();
        Database.SaveResult result = Database.update(relationshipToUpdate, false);
        Test.stopTest();
        
        System.assertEquals(true, result.isSuccess());
    }
    
    @isTest
    static void deleteContactContactRelationshipTest() {
        List<Contact> contacts = getTestContacts();
        List<Syntilio__ContactContactRelationship__c> contactRelationships = getTestContactContactRelationships();
        
        Test.startTest();
        Database.DeleteResult result = Database.delete(contactRelationships[0], false);
        Test.stopTest();

        System.assertEquals(true, result.isSuccess());
    }
}