@isTest
public with sharing class MedicalNotesHandlerTest {

    private static Id getContactId(){
		return [SELECT Id FROM Contact LIMIT 1].Id;
    }
    private static Id getAccountId(){
		return [SELECT Id FROM Account LIMIT 1].Id;
    }
    
    private static Id getExternalSystemId(){
		return [SELECT Id FROM Syntilio__ExternalSystem__c LIMIT 1].Id;
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
        insert externalIdRecord;
    }

    @testSetup
    static void setup() {
        createDataHubSynchronisationTestData();
    }

    private static List<Syntilio__DataHubSyncInfo__c> insertDataHubSyncInfo(){
		List<Syntilio__DataHubSyncInfo__c> datahubSyncInfo = new List<Syntilio__DataHubSyncInfo__c>{
            new Syntilio__DataHubSyncInfo__c(
                Name = 'Name',
                Syntilio__ObjectName__c = 'Syntilio__MedicalNote__c',
                Syntilio__ExternalSystems__c = 'ES',
                Syntilio__Enabled__c = true,
                Syntilio__InsertNewRecords__c = true,
                Syntilio__SyncMode__c = 'AlwaysOverride',
                Syntilio__Type__c = 'PullAndPush',
                Syntilio__Frequency__c = 0
            )
		};
        insert datahubSyncInfo;
        return datahubSyncInfo;
    }
    
    @isTest
    public static void handleTriggerTest() {
        Test.startTest();
        Syntilio.MedicalNotesHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, new Map<Id, Case>(), new Map<Id, Case>());
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    public static void handleAfterInsertTest() {
		Id contactId = getContactId();
        Case newCase = new Case(ContactId = contactId);
        insert newCase;        
        Map<Id, Case> caseMap = new Map<Id, Case>{
            newCase.Id => newCase
        };
            
        Test.startTest();
        Syntilio.MedicalNotesHandler.handleAfterInsert(caseMap, caseMap);
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest 
    static void syncMedicalNotesTest() {
        Id contactId = getContactId();
        insertDataHubSyncInfo();
        
        Test.startTest();
        Syntilio.MedicalNotesHandler.syncMedicalNotes(new List<Id>{contactId});
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest 
    static void manualSyncMedicalNotesTest() {
        Id contactId = getContactId();
        insertDataHubSyncInfo();
        
        Test.startTest();
        Syntilio.MedicalNotesHandler.manualSyncMedicalNotes(contactId);
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest 
    static void getContactMedicalNotesTest() {
        Id contactId = getContactId();
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'ContactId' => contactId}
        );
        insert caseRecord;
        
        Test.startTest();
        String result = Syntilio.MedicalNotesHandler.getContactMedicalNotes(contactId);
        Test.stopTest();
        
        ResponseMessage responseMessage = ResponseMessage.deserialize(result);
        System.assertEquals(true, responseMessage.isSuccess);
    }

}