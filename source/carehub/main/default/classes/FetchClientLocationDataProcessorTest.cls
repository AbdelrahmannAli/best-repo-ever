@isTest
public with sharing class FetchClientLocationDataProcessorTest {
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
    static void filterExistingLocationsTest(){
        Account accountRecord = getAccount();
        
        List<FetchClientModel> fetchClientModels = generateFetchClientModels();
        
        Test.startTest();
        ResponseMessage response = Syntilio.FetchClientLocationDataProcessor.filterExistingLocations(fetchClientModels, 'Ons', accountRecord.Id);
        Test.stopTest();
                
        List<Schema.Location> result = (List<Schema.Location>)response.data;
        System.assertEquals(1, result.size());
    }

    @isTest
    static void insertLocationsTest_Success(){
        Account accountRecord = getAccount();
        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c];

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Id> contactIds = new List<Id>();

        for(Contact contact : contacts){
            contactIds.add(contact.Id);
        }

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
        
		Test.startTest();
        Syntilio.FetchClientLocationDataProcessor.insertLocations(locationsToInsert, contactIds);
        Test.stopTest();
        
        List<Schema.Location> newLocationIds = [SELECT Id FROM Location];
        System.assertEquals(3, newLocationIds.size());
    }

    @isTest
    static void insertLocationsTest_SuccessWithEmptyList(){
        
        List<Id> contactIds = new List<Id>();
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        
        Test.startTest();
        ResponseMessage actualResponse = Syntilio.FetchClientLocationDataProcessor.insertLocations(locationsToInsert, contactIds);
		Test.stopTest();

        Syntilio.ResponseMessage expectedResponse = new Syntilio.ResponseMessage(
            '',
            'No new locations to insert',
            Syntilio.ResponseMessage.MessageType.SUCCESS
        );

        System.assertEquals(expectedResponse.data, actualResponse.data);
        System.assertEquals(expectedResponse.message, actualResponse.message);
        System.assertEquals(expectedResponse.type, actualResponse.type);
    }

    @isTest
    static void insertLocationsTest_SuccessWithWarning(){
        Account accountRecord = getAccount();
        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c];

        List<Contact> contacts = [SELECT Id FROM Contact];
        
        Contact contactMock = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'LastName' => 'mock contact'
			}
        );
        insert contactMock;

        List<Id> contactIds = new List<Id>();

        for(Contact contact : contacts){
            contactIds.add(contact.Id);
        }

        contactIds.add(contactMock.Id);

        Schema.Location newLocationMock1 = Syntilio.CareHubTestDataFactory.createLocation(
			new Map<String, Object>{
				'Syntilio__AccountId__c' => accountRecord.Id,
				'Syntilio__ExternalSystemId__c' => externalSystems[0].Id,
				'Syntilio__LocationId__c' => 'mocklocation',
                'Name' => 'mock location'
			}
		);
        
        Schema.Location newLocationMock2 = Syntilio.CareHubTestDataFactory.createLocation(
			new Map<String, Object>{
				'Syntilio__AccountId__c' => accountRecord.Id,
				'Syntilio__ExternalSystemId__c' => externalSystems[0].Id,
				'Syntilio__LocationId__c' => 'mocklocation',
                'Name' => 'mock location2'
			}
		);
       	
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        locationsToInsert.add(newLocationMock1);
        locationsToInsert.add(newLocationMock2);
        
		Test.startTest();
        ResponseMessage actualResponse = Syntilio.FetchClientLocationDataProcessor.insertLocations(locationsToInsert, contactIds);
        Test.stopTest();
        
        Syntilio.ResponseMessage expectedResponse = new Syntilio.ResponseMessage(
            '',
            'Some locations failed to be inserted',
            Syntilio.ResponseMessage.MessageType.WARNING
        );

        System.assertEquals(expectedResponse.data, actualResponse.data);
        System.assertEquals(expectedResponse.message, actualResponse.message);
        System.assertEquals(expectedResponse.type, actualResponse.type);
    }

    @isTest
    static void insertLocationsTest_SuccessWithError(){
        Account accountRecord = getAccount();
        List<Syntilio__ExternalSystem__c> externalSystems = [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c];

        List<Contact> contacts = [SELECT Id FROM Contact];
        Contact contactMock = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'LastName' => 'mock contact'
			}
        );
        insert contactMock;

        List<Id> contactIds = new List<Id>();

        for(Contact contact : contacts){
            contactIds.add(contact.Id);
        }

        contactIds.add(contactMock.Id);

        Schema.Location newLocationMock1 = Syntilio.CareHubTestDataFactory.createLocation(
			new Map<String, Object>{
				'Syntilio__AccountId__c' => contactMock.Id,
				'Syntilio__ExternalSystemId__c' => externalSystems[0].Id,
				'Syntilio__LocationId__c' => 'mocklocation',
                'Name' => 'mock location2'
			}
		);
        
        Schema.Location newLocationMock2 = Syntilio.CareHubTestDataFactory.createLocation(
			new Map<String, Object>{
				'Syntilio__AccountId__c' => contactMock.Id,
				'Syntilio__ExternalSystemId__c' => externalSystems[0].Id,
				'Syntilio__LocationId__c' => 'mocklocation',
                'Name' => 'mock location2'
			}
		);
       	
        List<Schema.Location> locationsToInsert = new List<Schema.Location>();
        locationsToInsert.add(newLocationMock1);
        locationsToInsert.add(newLocationMock2);
        
		Test.startTest();
        ResponseMessage actualResponse = Syntilio.FetchClientLocationDataProcessor.insertLocations(locationsToInsert, contactIds);
        Test.stopTest();

        Syntilio.ResponseMessage expectedResponse = new Syntilio.ResponseMessage(
            '',
            'Failed to insert locations',
            Syntilio.ResponseMessage.MessageType.ERROR
        );

        System.assertEquals(expectedResponse.data, actualResponse.data);
        System.assertEquals(expectedResponse.message, actualResponse.message);
        System.assertEquals(expectedResponse.type, actualResponse.type);
    }

    @isTest
    static void connectContactsToLocationsTest_Success(){
		Account accountRecord = getAccount();
        List<FetchClientModel> fetchClientModels = generateFetchClientModels();
        
		Test.startTest();
        Syntilio.FetchClientLocationDataProcessor.connectContactsToLocations(fetchClientModels, 'Ons', accountRecord.Id);
        Test.stopTest();
        
        List<Syntilio__ContactToLocation__c > contactToLocations = [SELECT Id FROM Syntilio__ContactToLocation__c];
        // System.assertEquals(2, contactToLocations.size());
    }
}