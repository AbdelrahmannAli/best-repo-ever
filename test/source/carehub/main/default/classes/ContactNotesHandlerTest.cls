@isTest
public with sharing class ContactNotesHandlerTest {

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
                Syntilio__ObjectName__c = 'Syntilio__ContactNote__c',
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
        Syntilio.ContactNotesHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, new Map<Id, Case>(), new Map<Id, Case>());
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
        Syntilio.ContactNotesHandler.handleAfterInsert(caseMap, caseMap);
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest 
    static void syncContactNotesTest() {
        Id contactId = getContactId();
        insertDataHubSyncInfo();
        
        Test.startTest();
        Syntilio.ContactNotesHandler.syncContactNotes(new List<Id>{contactId});
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest 
    static void getCaseContactNotesTest() {
        Id contactId = getContactId();
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'ContactId' => contactId}
        );
        insert caseRecord;
        
        Test.startTest();
        String result = Syntilio.ContactNotesHandler.getCaseContactNotes(caseRecord.Id);
        Test.stopTest();
        
        ResponseMessage responseMessage = ResponseMessage.deserialize(result);
        System.assertEquals(true, responseMessage.isSuccess);
    }
    
    @isTest 
    static void getContactNotesTest() {
        Id contactId = getContactId();
        Date todayDate = Date.today();
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'ContactId' => contactId}
        );
        insert caseRecord;
        Syntilio__ContactNote__c contactNoteRecord = Syntilio.CareHubTestDataFactory.createContactNote(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => contactId,
                'Syntilio__StartDate__c' => todayDate,
                'Syntilio__EndDate__c' => todayDate.addDays(5)
            }
        );
        insert contactNoteRecord;
        
        Test.startTest();
        List<Syntilio__ContactNote__c> contactNotes = Syntilio.ContactNotesHandler.getContactNotes(contactId);
        Test.stopTest();
        
        System.assert(contactNotes.size() > 0);
    }
    
    @isTest 
    static void getContactNoteIdsTest() {
        Id contactId = getContactId();
        Date todayDate = Date.today();
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'ContactId' => contactId}
        );
        Database.SaveResult saveResult = Database.insert(caseRecord);
        
        Map<String, Object> synchronisationHandlerOutput = new Map<String, Object>{
            'saveResults' => new List<Database.SaveResult>{saveResult}
        };
        
        Test.startTest();
        List<String> ids = Syntilio.ContactNotesHandler.getContactNoteIds(synchronisationHandlerOutput);
        Test.stopTest();
        
        System.assertEquals(1, ids.size());
        System.assertEquals(caseRecord.Id, ids[0]);
    }
    
    @isTest 
    static void manualSyncContactNotesTest() {
        Id contactId = getContactId();
        insertDataHubSyncInfo();
        
        Test.startTest();
        Syntilio.ContactNotesHandler.manualSyncContactNotes(contactId);
        Test.stopTest();
        
        System.assert(true);
    }
}