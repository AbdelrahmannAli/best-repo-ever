@isTest
private class CaseCareCircleTriggerHandlerTest {
    private static Account getAccount() {
        return [SELECT Id, Syntilio__ApiName__c FROM Account LIMIT 1];
    }
    
    private static Syntilio__ExternalSystem__c getExternalSystem() {
        return [SELECT Id, Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c LIMIT 1];
    }
    private static void createDataHubSynchronisationTestData(){
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
        insert new List<SObject>{contactRecord, accountExternalSystemAssociationRecord};
            
        Syntilio__ExternalId__c externalIdRecord = Syntilio.DataHubTestDataFactory.createExternalId(
                new Map<String, Object>{
                    'Name' => 'clientId',
                    'Syntilio__Id__c' => '1',
                    'Syntilio__ContactId__c' => contactRecord.Id,
                    'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
                }
        );
        Syntilio__DataHubSyncInfo__c dataHubSyncInfoRecord = Syntilio.DataHubTestDataFactory.createDataHubSyncInfo(
            new Map<String, Object>{
                'Name' => 'LastName',
                'Syntilio__ObjectName__c' => 'Contact'
            }
        );
        insert new List<SObject>{externalIdRecord, dataHubSyncInfoRecord};
    }

    @testSetup
    static void setup() {
        createDataHubSynchronisationTestData();
    }
    
    @isTest
    static void handleAfterInsertTest() {
        List<Contact> initialContacts = [SELECT Id FROM Contact];
        System.assertNotEquals(initialContacts.size(), 0);
        Case testExternalId = new Case( );
        
        Map<Id, Case> newMap = new Map<Id, Case>{
            testExternalId.AccountId => testExternalId
        };
        Test.startTest();
        CaseCareCircleTriggerHandler.handleAfterInsert(new Map<Id, Case>(), newMap);
        Test.stopTest();
    }
    
    @isTest
    static void handleTriggerTest() {
        Test.startTest();
        CaseCareCircleTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, new Map<Id, Case>(), new Map<Id, Case>());
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    static void syncContactRelationsTest() {
        List<Contact> initialContacts = [SELECT Id FROM Contact];
        System.assertNotEquals(initialContacts.size(), 0);
        
        Test.startTest();
        Syntilio.CaseCareCircleTriggerHandler.syncContactRelations(new List<Id>{initialContacts[0].Id});
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    static void manualSyncContactRelationsTest() {
        List<Contact> initialContacts = [SELECT Id FROM Contact];
        System.assertNotEquals(initialContacts.size(), 0);
        
        Test.startTest();
        Syntilio.CaseCareCircleTriggerHandler.manualSyncContactRelations(initialContacts[0].Id);
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    static void getExternalIdsInsertedTest() {
        Account accountRecord = getAccount();
        Syntilio__ExternalSystem__c externalSystemRecord = getExternalSystem();
        Map<String, Object> careCircleMembersInsertion = new Map<String, Object>{
            'externalIds' => new List<Syntilio__ExternalId__c>{
                new Syntilio__ExternalId__c(
                    Name = 'clientId',
                    Syntilio__Id__c = '1234',
                    Syntilio__ExternalSystemId__c = externalSystemRecord.Id,
                    Syntilio__Account__c = accountRecord.Id
                ),
                new Syntilio__ExternalId__c(
                    Name = 'clientId',
                    Syntilio__Id__c = '12345',
                    Syntilio__ExternalSystemId__c = externalSystemRecord.Id,
                    Syntilio__Account__c = accountRecord.Id
                )
            }
        };

        List<Syntilio__ExternalSystem__c> allExternalSystems = [SELECT Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c ];
        Map<String, Object> allExternalSystemsMap = Syntilio.DataHubUtilities.listToMap('Id', 'Syntilio__ApiName__c', allExternalSystems);

        List<Account> allAccounts = [SELECT Syntilio__ApiName__c FROM Account];
        Map<String, Object> allAccountsMap = Syntilio.DataHubUtilities.listToMap('Id', 'Syntilio__ApiName__c', allAccounts);
            
        Test.startTest();
        Map<String, List<String>> externalIds = Syntilio.CaseCareCircleTriggerHandler.getExternalIdsInserted(careCircleMembersInsertion, allExternalSystemsMap, allAccountsMap);
        Test.stopTest();
        
        System.assertEquals('{"Test_ES":["1234","12345"]}', JSON.serialize(externalIds));
    }
    
    @isTest 
    static void getContactIdsInsertedTest() {
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(null);
        Database.SaveResult saveResult = Database.insert(caseRecord);
        
        Map<String, Object> synchronisationHandlerOutput = new Map<String, Object>{
            'ids' => new List<Database.SaveResult>{saveResult}
        };
        
        Test.startTest();
        List<String> ids = Syntilio.CaseCareCircleTriggerHandler.getContactIdsInserted(synchronisationHandlerOutput);
        Test.stopTest();
        
        System.assertEquals(1, ids.size());
        System.assertEquals(caseRecord.Id, ids[0]);
    }
}