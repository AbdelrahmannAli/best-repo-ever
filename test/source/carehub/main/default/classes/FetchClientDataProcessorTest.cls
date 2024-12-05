@isTest
public with sharing class FetchClientDataProcessorTest {
    
    private static Account getAccount() {
        return [SELECT Id FROM Account LIMIT 1];
    }
    
    private static void createFetchClientsData() {
        Account account = Syntilio.CareHubTestDataFactory.createAccount(
            new Map<String, Object>{
            	'Name' => 'Twb',
                'Syntilio__ApiName__c' => 'Twb'
            }
        );
        
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(null);
        
        Syntilio__ExternalSystem__c externalSystemOns = Syntilio.DataHubTestDataFactory.createExternalSystem(
            new Map<String, Object>{
            	'Name' => 'Ons',
                'Syntilio__ApiName__c' => 'Ons'
            }
        );
        
        Syntilio__ExternalSystem__c externalSystemFierit = Syntilio.DataHubTestDataFactory.createExternalSystem(
            new Map<String, Object>{
            	'Name' => 'Fierit',
                'Syntilio__ApiName__c' => 'Fierit'
            }
        );
        
        insert new List<SObject>{account, contact, externalSystemOns, externalSystemFierit};
        
        List<Schema.Location> locations = new List<Schema.Location>{
            Syntilio.CareHubTestDataFactory.createLocation(
                new Map<String, Object>{
                    'Syntilio__AccountId__c' => account.Id,
                    'Syntilio__ExternalSystemId__c' => externalSystemOns.Id,
                    'Syntilio__LocationId__c' => '123'
                }
            ),
            Syntilio.CareHubTestDataFactory.createLocation(
                new Map<String, Object>{
                    'Syntilio__AccountId__c' => account.Id,
                    'Syntilio__ExternalSystemId__c' => externalSystemFierit.Id,
                    'Syntilio__LocationId__c' => '456'
                }
            )
		};
       
        List<Syntilio__AccountExternalSystemAssociation__c> accountExternalSystemAssociations = 
            new List<Syntilio__AccountExternalSystemAssociation__c>{
                Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation(
            		new Map<String, Object>{
                		'Syntilio__AccountId__c' => account.Id,
                    	'Syntilio__ExternalSystemId__c' => externalSystemOns.Id
                    }
                ),
                Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation(
            		new Map<String, Object>{
                		'Syntilio__AccountId__c' => account.Id,
                    	'Syntilio__ExternalSystemId__c' => externalSystemFierit.Id
                    }
                )
		};
        
        List<Syntilio__ExternalId__c> externalIds = new List<Syntilio__ExternalId__c>{
            Syntilio.DataHubTestDataFactory.createExternalId(
            	new Map<String, Object>{
                	'Syntilio__ContactId__c' => contact.Id,
                    'Name' => 'onsClientId',
                    'Syntilio__Id__c' => '123',
                    'Syntilio__ExternalSystemId__c' => externalSystemOns.Id
                }
            ),
            Syntilio.DataHubTestDataFactory.createExternalId(
            	new Map<String, Object>{
                	'Syntilio__ContactId__c' => contact.Id,
                    'Name' => 'fieritClientId',
                    'Syntilio__Id__c' => '567',
                    'Syntilio__ExternalSystemId__c' => externalSystemFierit.Id
                }
            )
		};
        List<SObject> toInsert = new List<SObject>();
        toInsert.addAll(locations);
        toInsert.addAll(accountExternalSystemAssociations);
        toInsert.addAll(externalIds);
        insert toInsert;
    }
    
    private static List<FetchClientModel> generateFetchClientModels() {
        List<Contact> contacts = [SELECT Id, LastName FROM Contact];
        List<Syntilio__ExternalSystem__c> externalSystems = [
            SELECT Id, Syntilio__ApiName__c
            FROM Syntilio__ExternalSystem__c
        ];
        List<Syntilio__ExternalId__c> externalIds = [
            SELECT Id, Name, Syntilio__ContactId__c, Syntilio__Id__c, Syntilio__ExternalSystemId__c
            FROM Syntilio__ExternalId__c
        ];
        List<Schema.Location> locations = [
            SELECT Id, Name, Syntilio__AccountId__c, Syntilio__ExternalSystemId__c, Syntilio__LocationId__c
            FROM Location
        ];
        List<FetchClientModel> fetchClientModels = new List<FetchClientModel>();
        List<Syntilio__ExternalId__c> firstExternalIds = new List<Syntilio__ExternalId__c>();
        List<Schema.Location> firstLocations = new List<Schema.Location>();
        
        firstExternalIds.add(externalIds[0]);
        firstLocations.add(locations[0]);
        FetchClientModel firstClientModel = new FetchClientModel();
        firstClientModel.contact = contacts[0];
        firstClientModel.externalIds = firstExternalIds;
        firstClientModel.locations = firstLocations;
        fetchClientModels.add(firstClientModel);
        
        List<Syntilio__ExternalId__c> secondExternalIds = new List<Syntilio__ExternalId__c>();
        List<Schema.Location> secondLocations = new List<Schema.Location>();
        secondExternalIds.add(externalIds[1]);
        secondLocations.add(locations[1]);
        FetchClientModel secondClientModel = new FetchClientModel();
        secondClientModel.contact = contacts[0];
        secondClientModel.externalIds = secondExternalIds;
        secondClientModel.locations = secondLocations;
        fetchClientModels.add(secondClientModel);
        
        return fetchClientModels;
    }
    
    @testSetup
    static void setup(){
        createFetchClientsData();
    }

    @isTest
    static void filterExistingClientsTest(){
        Account accountRecord = getAccount();
        
        List<FetchClientModel> fetchClientModels = generateFetchClientModels();
        
		Test.startTest();       	
        Map<String, List<FetchClientModel>> result = Syntilio.FetchClientDataProcessor.filterClients(fetchClientModels, 'Ons', accountRecord.Id);
		Test.stopTest();
        
        List<FetchClientModel> nonExistingClients = (List<FetchClientModel>) result.get('notExisting');
        List<FetchClientModel> existingClients = (List<FetchClientModel>) result.get('existing');
        System.assertEquals(2, result.size());
        System.assertEquals(2, nonExistingClients.size());
        System.assertEquals(0, existingClients.size());
    }

    @isTest
    static void getClientsFromDBTest(){


        Account accountRecord = getAccount();

        List<FetchClientModel> fetchClientModels = generateFetchClientModels();
        
        Test.startTest();
        Syntilio.FetchClientLocationDataProcessor.connectContactsToLocations(fetchClientModels, 'Ons', accountRecord.Id);
        
        List<Syntilio__ContactToLocation__c> contactToLocations = [SELECT Id FROM Syntilio__ContactToLocation__c];
        // System.assertEquals(contactToLocations.size(), 2);
        
        String output = Syntilio.FetchClientDataProcessor.getClientsFromDB(accountRecord.Id, 'Ons');
        Test.stopTest();
        
        ResponseMessage responseMessage = Syntilio.ResponseMessage.deserialize(output);
        List<Object> outputList = (List<Object>) JSON.deserializeUntyped((String) responseMessage.data);
        // System.assertEquals(1, outputList.size());

    }

    @isTest
    static void getClientsFromDBTest_WithoutParams(){


        Account accountRecord = getAccount();

        List<FetchClientModel> fetchClientModels = generateFetchClientModels();
        
        Test.startTest();
        Syntilio.FetchClientLocationDataProcessor.connectContactsToLocations(fetchClientModels, 'Ons', accountRecord.Id);
        
        List<Syntilio__ContactToLocation__c> contactToLocations = [SELECT Id FROM Syntilio__ContactToLocation__c ];
        // System.assertEquals(contactToLocations.size(), 2);
        
        String output = Syntilio.FetchClientDataProcessor.getClientsFromDB(null, null);
        Test.stopTest();
        
        ResponseMessage responseMessage = Syntilio.ResponseMessage.deserialize(output);
        ResponseMessage exceptedResponse = new ResponseMessage('', 'Account Id or External System is null', Syntilio.ResponseMessage.MessageType.ERROR);

        // System.assertEquals(exceptedResponse.type, responseMessage.type);
        // System.assertEquals(exceptedResponse.message, responseMessage.message);
    }

    @isTest
    static void insertContactsTest_Success(){

        Account accountRecord = getAccount();
        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c];
        List<Syntilio__ExternalId__c> externalIds = [SELECT Id, Name, Syntilio__ContactId__c, Syntilio__Id__c, Syntilio__ExternalSystemId__c FROM Syntilio__ExternalId__c WHERE Name = 'onsClientId'];
        List<Schema.Location> locations = [SELECT Id, Name, Syntilio__AccountId__c, Syntilio__ExternalSystemId__c, Syntilio__LocationId__c FROM Location];
        
       	List<FetchClientModel> toBeInserted = new List<FetchClientModel>();
        
        List<Syntilio__ExternalId__c> secondExternalIds = new List<Syntilio__ExternalId__c>();
        List<Schema.Location> secondLocations = new List<Schema.Location>();
        secondExternalIds.add(externalIds[0]);
        secondLocations.add(locations[1]);
        Contact newContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'LastName' => 'Middin',
                'AccountId' => accountRecord.Id
            }
        );
        
        FetchClientModel secondClientModel = new FetchClientModel();
        secondClientModel.contact = newContact;
        secondClientModel.externalIds = secondExternalIds;
        secondClientModel.locations = secondLocations;
        toBeInserted.add(secondClientModel);
        
		Test.startTest();
        ResponseMessage responseMessage = Syntilio.FetchClientDataProcessor.insertContacts(toBeInserted, 'Ons', accountRecord.Id);
        Test.stopTest();
        
        Map<String,Object> result = (Map<String, Object>) responseMessage.data;
        System.assertEquals(((List<Id>)result.get('ids')).size(), 1);
    }

    @isTest
    static void testInsertContactsFailure(){
        Account accountRecord = getAccount();
       	
        List<FetchClientModel> fetchClientModels = generateFetchClientModels();
        List<FetchClientModel> toBeInserted = new List<FetchClientModel>();
        toBeInserted.add(fetchClientModels[0]);

		Test.startTest();
		ResponseMessage responseMessage = Syntilio.FetchClientDataProcessor.insertContacts(toBeInserted, 'Ons', accountRecord.Id);
        Test.stopTest();
        
        System.assertEquals(false, responseMessage.isSuccess);
    }

    @isTest
    static void insertExternalIdsTest_Success(){
        Account accountRecord = getAccount();
        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c];
        List<Syntilio__ExternalId__c> externalIds = [SELECT Id, Name, Syntilio__ContactId__c, Syntilio__Id__c, Syntilio__ExternalSystemId__c FROM Syntilio__ExternalId__c];

        List<Schema.Location> locations = [SELECT Id, Name, Syntilio__AccountId__c, Syntilio__ExternalSystemId__c, Syntilio__LocationId__c FROM Location];
        
        List<Schema.Location> secondLocations = new List<Schema.Location>();
        secondLocations.add(locations[1]);
        Contact newContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'LastName' => 'Middin',
                'AccountId' => accountRecord.Id
            }
        );
        insert newContact;
        
        Syntilio__ExternalId__c externalIdMock = Syntilio.DataHubTestDataFactory.createExternalId(
            new Map<String, Object>{
                'Syntilio__Id__c' => '789',
                'Syntilio__ContactId__c' => newContact.Id,
                'Syntilio__ExternalSystemId__c' => externalSystems[0].Id
            }
        );
        
        List<Syntilio__ExternalId__c> secondExternalIds = new List<Syntilio__ExternalId__c>();
        secondExternalIds.add(externalIdMock);
        
        FetchClientModel secondClientModel = new FetchClientModel();
        secondClientModel.contact = newContact;
        secondClientModel.externalIds = secondExternalIds;
        secondClientModel.locations = secondLocations;
        
       	List<FetchClientModel> toBeInserted = new List<FetchClientModel>();
        toBeInserted.add(secondClientModel);
		
		List<Contact> insertedContact = new List<Contact>();
		insertedContact.add(newContact);

        List<Id> insertedIds = new List<Id>();
        for (Contact contact : insertedContact) {
            insertedIds.add(contact.Id);
        }
        
		Test.startTest();
        Syntilio.FetchClientDataProcessor.insertExternalIds(toBeInserted, insertedIds, 'Ons');
        List<Syntilio__ExternalId__c> newExternalIds = [SELECT Id, Name, Syntilio__ContactId__c, Syntilio__Id__c, Syntilio__ExternalSystemId__c FROM Syntilio__ExternalId__c];
        Test.stopTest();
        
        System.assertEquals(3, newExternalIds.size());
    }
    
	@isTest
    static void insertExternalIdsTest_Failure(){
        Account accountRecord = getAccount();
        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c];
        List<Syntilio__ExternalId__c> externalIds = [SELECT Id, Name, Syntilio__ContactId__c, Syntilio__Id__c, Syntilio__ExternalSystemId__c FROM Syntilio__ExternalId__c];
        List<Schema.Location> locations = [SELECT Id, Name, Syntilio__AccountId__c, Syntilio__ExternalSystemId__c, Syntilio__LocationId__c FROM Location];
        
        List<Schema.Location> secondLocations = new List<Schema.Location>();
        secondLocations.add(locations[1]);
        
        Contact newContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'LastName' => 'Middin',
                'AccountId' => accountRecord.Id
            }
        );
        insert newContact;
        
        Syntilio__ExternalId__c externalIdMock = Syntilio.DataHubTestDataFactory.createExternalId(
            new Map<String, Object>{
                'Syntilio__Id__c' => '789',
                'Syntilio__ContactId__c' => newContact.Id,
                'Syntilio__ExternalSystemId__c' => externalSystems[0].Id
            }
        );
        insert externalIdMock;
        
        List<Syntilio__ExternalId__c> secondExternalIds = new List<Syntilio__ExternalId__c>();
        secondExternalIds.add(externalIdMock);
        
        FetchClientModel secondClientModel = new FetchClientModel();
        secondClientModel.contact = newContact;
        secondClientModel.externalIds = secondExternalIds;
        secondClientModel.locations = secondLocations;
        
       	List<FetchClientModel> toBeInserted = new List<FetchClientModel>();
        toBeInserted.add(secondClientModel);
		
		List<Contact> insertedContact = new List<Contact>();
		insertedContact.add(newContact);

        List<Id> insertedIds = new List<Id>();
        for (Contact contact : insertedContact) {
            insertedIds.add(contact.Id);
        }
        
        Test.startTest();
        ResponseMessage responseMessage = Syntilio.FetchClientDataProcessor.insertExternalIds(toBeInserted, insertedIds, 'Ons');
        Test.stopTest();
        
		List<Task> tasksCreated = [SELECT Id FROM Task];        
        System.assertNotEquals(0, tasksCreated.size());
    }
}