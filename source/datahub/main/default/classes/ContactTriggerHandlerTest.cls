@isTest
public with sharing class ContactTriggerHandlerTest {

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
    
    private static void createDataHubSyncInfoThatShouldUpdate() {  
        List<Map<String, Object>> dataHubSyncInfoList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Name' => 'Email',
                'Syntilio__ObjectName__c' => 'Contact',
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            },
            new Map<String, Object>{
                'Name' => 'LastName',
                'Syntilio__ObjectName__c' => 'Contact',
                'Syntilio__SyncMode__c' => 'AlwaysOverride',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'Pull'
            },
            new Map<String, Object>{
                'Name' => 'Phone',
                'Syntilio__ObjectName__c' => 'Contact',
                'Syntilio__SyncMode__c' => 'CreateTaskOnConflict',
                'Syntilio__ExternalSystems__c' => 'Ons',
                'Syntilio__Type__c' => 'PullAndPush'
            },
            new Map<String, Object>{
                'Name' => 'Birthdate',
                'Syntilio__ObjectName__c' => 'Contact',
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
    @testSetup
    public static void setup() {
        createDataHubSynchronisationTestData();
        createDataHubSyncInfoThatShouldUpdate();
    }
    
    @isTest
    public static void isAddressChangedTest() {
        Boolean addressChanged1;
        Boolean addressChanged2;
        try{
            Contact contact1 = Syntilio.DataHubTestDataFactory.createContact(new Map<String, Object>{
                'MailingStreet'  => 'some street'
                });
            Contact contact2 = Syntilio.DataHubTestDataFactory.createContact(new Map<String, Object>{
                'MailingStreet' => 'some other street'
                });
            Contact contact3 = Syntilio.DataHubTestDataFactory.createContact(new Map<String, Object>{
                'MailingStreet'  => 'some street'
                });
        
            Test.startTest();
            addressChanged1 = Syntilio.ContactTriggerHandler.isAddressChanged(contact1, contact2);
            addressChanged2 = Syntilio.ContactTriggerHandler.isAddressChanged(contact1, contact3);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(addressChanged1, true);
        System.assertEquals(addressChanged2, false);
    }
    
	@isTest
    public static void handleAfterInsertTest() {
        List<Syntilio.DataHubModel> datahubModels;
            
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertNotEquals(accounts.size(), 0);
        Contact testContact = Syntilio.DataHubTestDataFactory.createContact(new Map<String, Object>{
            'AccountId' => accounts[0].Id
            });
        insert testContact;
        Map<Id, Contact> newMap = new Map<Id, Contact>();
        newMap.put(testContact.Id, testContact);

        Test.startTest();
        datahubModels = Syntilio.ContactTriggerHandler.handleInsertUpdate(null, newMap, false);
        Test.stopTest();

        System.assertNotEquals(null, datahubModels);
        System.assertNotEquals(0, datahubModels.size());
        System.assertNotEquals(null, datahubModels[0].destinations);
        System.assertNotEquals(0, datahubModels[0].destinations.size());
        System.assertNotEquals(null, datahubModels[0].objectsBody);
        System.assertNotEquals(0, datahubModels[0].objectsBody.size());
        System.assertNotEquals(null, ((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Id'));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')).get('Email'));
    }
    
    @isTest
    public static void handleAfterUpdateTest() {
        List<Syntilio.DataHubModel> datahubModels;
        try{
            
            List<Contact> contacts = [SELECT Id, Email, AccountId, FirstName, LastName, Phone, Birthdate,
                                      MailingStreet, MailingPostalCode, MailingCity, MailingCountry, MailingState
                                      FROM Contact];
            System.assertNotEquals(contacts.size(), 0);
            Contact oldContact = contacts[0].clone(true, true, true);
            Contact newContact = contacts[0];
            newContact.Email = 'newemail@email.com';
            update newContact;

            Map<Id, Contact> oldMap = new Map<Id, Contact>();
            oldMap.put(oldContact.Id, oldContact);
            Map<Id, Contact> newMap = new Map<Id, Contact>();
            newMap.put(oldContact.Id, newContact);

            Test.startTest();
            datahubModels = Syntilio.ContactTriggerHandler.handleInsertUpdate(oldMap, newMap, true);
            Test.stopTest();
            
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertNotEquals(null, datahubModels);
        System.assertNotEquals(0, datahubModels.size());
        System.assertNotEquals(null, datahubModels[0].destinations);
        System.assertNotEquals(0, datahubModels[0].destinations.size());
        System.assertNotEquals(null, datahubModels[0].objectsBody);
        System.assertNotEquals(0, datahubModels[0].objectsBody.size());
        System.assertNotEquals(null, ((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Id'));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')));
        System.assertEquals('newemail@email.com', ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')).get('Email'));
    }
    
    @isTest
    public static void handleTriggerTest(){
        try{
            Syntilio.ContactTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_UPDATE, null, null); 
			Syntilio.ContactTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, null, null); 
			Syntilio.ContactTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_DELETE, null, null); 
			Syntilio.ContactTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_UPDATE, null, null); 
			Syntilio.ContactTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_INSERT, null, null); 
			Syntilio.ContactTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_DELETE, null, null); 
        	System.assertEquals(true, true);
        }catch(Exception e){
        	System.assertEquals(true, false);
        }
    }
}