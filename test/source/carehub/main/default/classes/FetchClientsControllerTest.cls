@isTest
public with sharing class FetchClientsControllerTest {
    
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
    
    private static Map<String, Object> fetchClientModelMock(){
		Account accountRecord = getAccount();
        List<Contact> contacts = [SELECT LastName FROM Contact];
        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c];
        List<Syntilio__ExternalId__c> externalIds = [SELECT Name, Syntilio__ContactId__c, Syntilio__Id__c, Syntilio__ExternalSystemId__c FROM Syntilio__ExternalId__c];
        List<Schema.Location> locations = [SELECT Name, Syntilio__AccountId__c, Syntilio__ExternalSystemId__c, Syntilio__LocationId__c FROM Location];
        
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
        
        Schema.Location newLocationMock = Syntilio.CareHubTestDataFactory.createLocation(
			new Map<String, Object>{
				'Syntilio__AccountId__c' => accountRecord.Id,
				'Syntilio__ExternalSystemId__c' => externalSystems[0].Id,
				'Syntilio__LocationId__c' => 'mocklocation',
                'Name' => 'mock location'
			}
		);
       	
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        locationsToInsert.add(newLocationMock);
        
        FetchClientModel secondClientModel = new FetchClientModel();
        secondClientModel.contact = newContact;
        secondClientModel.externalIds = secondExternalIds;
        secondClientModel.locations = locationsToInsert;
        fetchClientModels.add(secondClientModel);

        Map<String, Object> fetchClientModelMock = new Map<String, List<Syntilio.FetchClientModel>>();
        fetchClientModelMock.put('Twb_Ons', fetchClientModels);
        return fetchClientModelMock;
    }
    
    @testSetup
    public static void setupTestData() {
		createFetchClientsData();
    }


    @isTest
    static void handleFetchClientsTest_Success(){
        Account accountRecord = getAccount();
        Map<String, Object> fetchClientModelMock = fetchClientModelMock();
        List<Object> fetchClientModelMockList = (List<Object>) fetchClientModelMock.get('Twb_Ons');
        String serializedFetchClientModelMock = JSON.serialize(fetchClientModelMockList);
        
        Test.startTest();
        Syntilio.FetchClientsController.handleFetchClients(serializedFetchClientModelMock, accountRecord.Id, 'Ons');
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Id, Syntilio__LastFetchedDate__c FROM Account];
        System.assertEquals(Date.today(), updatedAccounts[0].Syntilio__LastFetchedDate__c);
    }

    @isTest
    static void handleFetchClientsTest_WithoutExistingLocation(){
        Account accountRecord = getAccount();
        Map<String, Object> fetchClientModelMock = fetchClientModelMock();
        List<Object> fetchClientModelMockList = (List<Object>) fetchClientModelMock.get('Twb_Ons');
        String serializedFetchClientModelMock = JSON.serialize(fetchClientModelMockList);
        
        Test.startTest();
        Syntilio.FetchClientsController.handleFetchClients(serializedFetchClientModelMock, '123', 'Onx');
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Id, Syntilio__LastFetchedDate__c FROM Account];
        System.assertNotEquals(Date.today(), updatedAccounts[0].Syntilio__LastFetchedDate__c);
    }

    @isTest
    static void getClientsTest_Success(){
        Account accountRecord = getAccount();
        List<Schema.Location> locations = [SELECT Id, Syntilio__LocationId__c FROM Location];
		Map<String, Object> fetchClientModelMock = fetchClientModelMock();
        Test.setMock(HttpCalloutMock.class, new MockDataHubCalloutFetchClients('GET', 'Ons', '?locationId=' + locations[0].Syntilio__LocationId__c, fetchClientModelMock));
        
		Test.startTest();
        Syntilio.FetchClientsController.inTest = true;
        Syntilio.FetchClientsController.getClients(accountRecord.Id, 'Ons');
        Syntilio.FetchClientsController.inTest = false;        
        Test.stopTest();
        
        List<Syntilio__Notification__e> eventList = Syntilio.FetchClientsController.eventList;
        System.assert(eventList.size() > 0);
        Map<String, Object> messageData = (Map<String, Object>) JSON.deserializeUntyped(eventList[0].Syntilio__Message__c);
        System.assertEquals(true, messageData.get('isSuccess'));
    }

    @isTest
    static void getchClientsTest_Fail404(){
        Account accountRecord = getAccount();
        List<Schema.Location> locations = [SELECT Id, Syntilio__LocationId__c FROM Location];
		Map<String, Object> fetchClientModelMock = Syntilio.FetchClientsControllerTest.fetchClientModelMock();
        Test.setMock(HttpCalloutMock.class, new MockDataHubCalloutFetchClients('GET', 'Ons', '?locationId=' + locations[0].Syntilio__LocationId__c + '&status=404', fetchClientModelMock));

		Test.startTest();
        Syntilio.FetchClientsController.inTest = true;
        Syntilio.FetchClientsController.getClients(accountRecord.Id, 'Ons');
        Syntilio.FetchClientsController.inTest = false;
        Test.stopTest();
        
        List<Syntilio__Notification__e> eventList = Syntilio.FetchClientsController.eventList;
        // System.assert(eventList.size() > 0);
        Map<String, Object> messageData = (Map<String, Object>) JSON.deserializeUntyped(eventList[0].Syntilio__Message__c);
        // System.assertEquals(false, messageData.get('isSuccess'));
    }
  
    @isTest
    static void getClientsTest_FailFailedGetLocation(){
        Account accountRecord = getAccount();
        List<Schema.Location> locations = [SELECT Id, Syntilio__LocationId__c FROM Location];
		Map<String, Object> fetchClientModelMock = Syntilio.FetchClientsControllerTest.fetchClientModelMock();
        Test.setMock(HttpCalloutMock.class, new MockDataHubCalloutFetchClients('GET', 'Ons', '?locationId=' + locations[0].Syntilio__LocationId__c + '&status=404', fetchClientModelMock));

		Test.startTest();
        Syntilio.FetchClientsController.inTest = true;
        Syntilio.FetchClientsController.getClients(accountRecord.Id, 'Ons');
        Syntilio.FetchClientsController.inTest = false;
        Test.stopTest();
        
        List<Syntilio__Notification__e> eventList = Syntilio.FetchClientsController.eventList;
        // System.assert(eventList.size() > 0);
        Map<String, Object> messageData = (Map<String, Object>) JSON.deserializeUntyped(eventList[0].Syntilio__Message__c);
        // System.assertEquals(false, messageData.get('isSuccess'));
    }
   
    @isTest 
    static void getSessionIdTest() {
        String sessionId = FetchClientsController.getSessionId();
        System.assertNotEquals(null, sessionId);
    }

    @isTest
    static void getClientsTest_ExternalSystemNotExists() {
        Account accountRecord = getAccount();
        List<Schema.Location> locations = [SELECT Id, Syntilio__LocationId__c FROM Location];
        Map<String, Object> fetchClientModelMock = Syntilio.FetchClientsControllerTest.fetchClientModelMock();
        Test.setMock(HttpCalloutMock.class, new MockDataHubCalloutFetchClients('GET', 'Ons', '?locationId=' + locations[0].Syntilio__LocationId__c, fetchClientModelMock));
        
        Test.startTest();
        Syntilio.FetchClientsController.inTest = true;
        Syntilio.FetchClientsController.getClients(accountRecord.Id, 'Onx');
        Syntilio.FetchClientsController.inTest = false;
        Test.stopTest();
        
        List<Syntilio__Notification__e> eventList = Syntilio.FetchClientsController.eventList;
        System.assertEquals(true, eventList.size() > 0);
        Map<String, Object> messageData = (Map<String, Object>) JSON.deserializeUntyped(eventList[0].Syntilio__Message__c);
        System.assertEquals(false, messageData.get('isSuccess'));
    }
}