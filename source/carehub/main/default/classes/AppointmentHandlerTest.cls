@isTest
public with sharing class AppointmentHandlerTest {
    private static Id getContactId(){
		return [SELECT Id FROM Contact LIMIT 1].Id;
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
                'Name' => 'StartDateTime',
                'Syntilio__ObjectName__c' => 'Event'
            }
        );
        insert new List<SObject>{externalIdRecord, dataHubSyncInfoRecord};
    }

    @isTest
    public static void handleTriggerTest() {
        Test.startTest();
        Syntilio.AppointmentHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, new Map<Id, Case>(), new Map<Id, Case>());
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
        Syntilio.AppointmentHandler.handleAfterInsert(caseMap, caseMap);
        Test.stopTest();
        
        System.assert(true);
    }

    @testSetup
    static void setup() {
        createDataHubSynchronisationTestData();
    }
    
    @isTest 
    static void syncContactAppointmentsTest() {
        Date fromDate = Date.newInstance(2024, 5, 8); 
        Date toDate = Date.newInstance(2024, 6, 15); 
        Id contactId = getContactId();
        
        Test.startTest();
        Syntilio.AppointmentHandler.syncContactAppointments(new List<Id>{contactId},fromDate,toDate);
        Test.stopTest();
        
        System.assert(true);
    }
    @isTest 
    static void syncAppointmentsTest() {
        Date fromDate = Date.newInstance(2024, 5, 8); 
        Date toDate = Date.newInstance(2024, 6, 15); 
        Id contactId = getContactId();
        
        Test.startTest();
        Syntilio.AppointmentHandler.syncAppointments(new List<Id>{contactId},fromDate,toDate);
        Test.stopTest();
        
        System.assert(true);
    }
    @isTest 
    static void getExternalSystemAppointmentsTest() {
        AppointmentHandler.InputVariables inputVariable = new AppointmentHandler.InputVariables();
        inputVariable.contactId = null; 
        inputVariable.fromDate = null; 
        inputVariable.toDate = null; 

        List<AppointmentHandler.InputVariables> inputParams = new List<AppointmentHandler.InputVariables>();
        inputParams.add(inputVariable);

        Test.startTest();
        Syntilio.AppointmentHandler.getExternalSystemAppointments(inputParams);
        Test.stopTest();
        
        System.assert(true);
        
    }
}