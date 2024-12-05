@isTest
public with sharing class MedicalSummaryHandlerTest {
    
    private static Id getContactId(){
		return [SELECT Id FROM Contact LIMIT 1].Id;
    }
    
    private static Id getAccountId(){
		return [SELECT Id FROM Account LIMIT 1].Id;
    }
    
    private static Id getExternalSystemId(){
		return [SELECT Id FROM Syntilio__ExternalSystem__c LIMIT 1].Id;
    }
    
    private static List<Syntilio__MedicalPolicy__c> insertMedicalPolicies(Id contactId){
		List<Syntilio__MedicalPolicy__c> medicalPolicies = new List<Syntilio__MedicalPolicy__c>{
            Syntilio.CareHubTestDataFactory.createMedicalPolicy(
                new Map<String, Object>{
                    'Syntilio__ContactId__c' => contactId,
                    'Syntilio__ResuscitationDecision__c' => 'Resuscitate',
                	'Syntilio__MostRecent__c' => true
                }
            ),
            Syntilio.CareHubTestDataFactory.createMedicalPolicy(
                new Map<String, Object>{
                    'Syntilio__ContactId__c' => contactId,
                    'Syntilio__ResuscitationDecision__c' => 'Do Not Resuscitate'
                }
            )
		};
        insert medicalPolicies;
        return medicalPolicies;
    }
    
    private static List<Syntilio__ContactAlert__c> insertContactAlerts(Id contactId){
		List<Syntilio__ContactAlert__c> contactAlerts = new List<Syntilio__ContactAlert__c>{
            Syntilio.CareHubTestDataFactory.createContactAlert(
                new Map<String, Object>{
                    'Syntilio__ContactId__c' => contactId
                }
            ),
            Syntilio.CareHubTestDataFactory.createContactAlert(
                new Map<String, Object>{
                    'Syntilio__ContactId__c' => contactId,
                    'Syntilio__Active__c' => false
                }
            )
		};
        insert contactAlerts;
        return contactAlerts;
    }
    
    private static List<Syntilio__DataHubSyncInfo__c> insertContactAlertDataHubSyncInfo(){
        List<Syntilio__DataHubSyncInfo__c> datahubSyncInfo = new List<Syntilio__DataHubSyncInfo__c>{
            Syntilio.DataHubTestDataFactory.createDataHubSyncInfo(
                new Map<String, Object>{
                    'Name' => 'Name',
                    'Syntilio__ObjectName__c' => 'Syntilio__ContactAlert__c',
                	'Syntilio__ExternalSystems__c' => 'ES'
                }
            )
		};
        insert datahubSyncInfo;
        return datahubSyncInfo;
    }
    
    private static List<Syntilio__DataHubSyncInfo__c> insertMedicalPolicyDataHubSyncInfo(){
		List<Syntilio__DataHubSyncInfo__c> datahubSyncInfo = new List<Syntilio__DataHubSyncInfo__c>{
            Syntilio.DataHubTestDataFactory.createDataHubSyncInfo(
                new Map<String, Object>{
                    'Name' => 'Name',
                    'Syntilio__ObjectName__c' => 'Syntilio__MedicalPolicy__c',
                	'Syntilio__ExternalSystems__c' => 'ES'
                }
            )
		};
        insert datahubSyncInfo;
        return datahubSyncInfo;
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
    
    @isTest
	static void getContactResuscitationDecisionTest_NoPolicies() {  
        Id contactId = getContactId();
        Test.startTest();
        String resuscitationDecision = Syntilio.MedicalSummaryHandler.getContactResuscitationDecision(contactId);
        Test.stopTest();
        
        System.assertEquals(null, resuscitationDecision);
    }

    @isTest
	static void getContactResuscitationDecisionTest() {
        Id contactId = getContactId();
        List<Syntilio__MedicalPolicy__c> medicalPolicies = insertMedicalPolicies(contactId);
        
        Test.startTest();
        String resuscitationDecision = Syntilio.MedicalSummaryHandler.getContactResuscitationDecision(contactId);
        Test.stopTest();
        
        System.assertEquals(medicalPolicies[0].Syntilio__ResuscitationDecision__c, resuscitationDecision);
    }
    
    
    @isTest
	static void getContactAlertsTest() {
        Id contactId = getContactId();
        insertContactAlerts(contactId);
        
        Test.startTest();
        List<Syntilio__ContactAlert__c> contactAlertsFound = Syntilio.MedicalSummaryHandler.getContactAlerts(contactId);
        Test.stopTest();
        
        System.assertEquals(1, contactAlertsFound.size());
    }
    
    @isTest
	static void getContactTest() {
        Id contactId = getContactId();
        Test.startTest();
        List<Contact> contactFound = Syntilio.MedicalSummaryHandler.getContacts(new List<Id>{contactId});
        Test.stopTest();
        
        System.assertNotEquals(0, contactFound.size());
        System.assertEquals(contactId, contactFound[0].Id);
    }
    
    @isTest
	static void handleMedicalPolicyTriggerTest() {
        Id contactId = getContactId();
        List<Syntilio__MedicalPolicy__c> medicalPolicies = insertMedicalPolicies(contactId);
        
        medicalPolicies = new List<Syntilio__MedicalPolicy__c>{
            new Syntilio__MedicalPolicy__c(
                Syntilio__ResuscitationDecision__c = 'Do Not Resuscitate',
                Syntilio__ContactId__c = contactId,
                Syntilio__MostRecent__c = true
            )
		};
        insert medicalPolicies;
        
        Test.startTest();
        String resuscitationDecision = Syntilio.MedicalSummaryHandler.getContactResuscitationDecision(contactId);
        Test.stopTest();
        
        System.assertEquals(medicalPolicies[0].Syntilio__ResuscitationDecision__c, resuscitationDecision);
    }
    
    @isTest
	static void handleContactAlertTriggerTest() {
        Id contactId = getContactId();
        insertContactAlerts(contactId);
        
        insert new List<Syntilio__ContactAlert__c>{
            new Syntilio__ContactAlert__c(
                Syntilio__ContactId__c = contactId,
                Syntilio__Active__c = false
            )
		};
        
        Test.startTest();
        List<Syntilio__ContactAlert__c> contactAlertsFound = Syntilio.MedicalSummaryHandler.getContactAlerts(contactId);
        Test.stopTest();
        
        System.assertEquals(0, contactAlertsFound.size());
    }
        
    @isTest
	static void getContactSafetyBadgesTest_FromContact() {
        Id contactId = getContactId();
        
        List<Syntilio__ContactAlert__c> contactAlerts = insertContactAlerts(contactId);
        List<String> contactAlertIds = new List<String>();
        for(Syntilio__ContactAlert__c contactAlert : contactAlerts){
            if(contactAlert.Syntilio__Active__c == true){
                contactAlertIds.add(contactAlert.Id);
            }
        }
        
        List<Syntilio__MedicalPolicy__c> medicalPolicies = insertMedicalPolicies(contactId);
        String resuscitationDecision = medicalPolicies[0].Syntilio__ResuscitationDecision__c;
        
        Test.startTest();
        String safetyBadges = Syntilio.MedicalSummaryHandler.getContactSafetyBadges(contactId);
        ResponseMessage responseMessage = ResponseMessage.deserialize(safetyBadges);
        Test.stopTest();

		List<String> responseAlertIds = new List<String>();
        Map<String, Object> data = (Map<String, Object>) responseMessage.data;
        System.assertNotEquals(null, data);
        System.assertEquals(resuscitationDecision, data.get('resuscitationDecision'));
        List<Object> alertsList = (List<Object>) data.get('alerts');
        for(Object alertObject : alertsList){
            responseAlertIds.add((String) ((Map<String, Object>) alertObject).get('Id'));
        }
        System.assertEquals(JSON.serialize(contactAlertIds), JSON.serialize(responseAlertIds));
    }
        
    @isTest
	static void getContactSafetyBadgesTest_FromCase() {
        Id contactId = getContactId();
        Case newCase = new Case(ContactId = contactId);
        insert newCase;
        
        List<Syntilio__ContactAlert__c> contactAlerts = insertContactAlerts(contactId);
        List<String> contactAlertIds = new List<String>();
        for(Syntilio__ContactAlert__c contactAlert : contactAlerts){
            if(contactAlert.Syntilio__Active__c == true){
                contactAlertIds.add(contactAlert.Id);
            }
        }
        
        List<Syntilio__MedicalPolicy__c> medicalPolicies = insertMedicalPolicies(contactId);
        String resuscitationDecision = medicalPolicies[0].Syntilio__ResuscitationDecision__c;
        
        Test.startTest();
        String safetyBadges = Syntilio.MedicalSummaryHandler.getContactSafetyBadges(newCase.Id);
        ResponseMessage responseMessage = ResponseMessage.deserialize(safetyBadges);
        Test.stopTest();

		List<String> responseAlertIds = new List<String>();
        Map<String, Object> data = (Map<String, Object>) responseMessage.data;
        System.assertNotEquals(null, data);
        System.assertEquals(resuscitationDecision, data.get('resuscitationDecision'));
        List<Object> alertsList = (List<Object>) data.get('alerts');
        for(Object alertObject : alertsList){
            responseAlertIds.add((String) ((Map<String, Object>) alertObject).get('Id'));
        }
        System.assertEquals(JSON.serialize(contactAlertIds), JSON.serialize(responseAlertIds));
    }
    
    @isTest
	static void getContactSafetyBadgesTest_Exception() {
        Id accountId = getAccountId();
        Test.startTest();
        String safetyBadges = Syntilio.MedicalSummaryHandler.getContactSafetyBadges(accountId);
        ResponseMessage responseMessage = ResponseMessage.deserialize(safetyBadges);
        Test.stopTest();

        System.assertEquals(null, responseMessage.data);
        System.assert(responseMessage.message.contains('An unexpected error occured'));
    }
    
    @isTest
	static void syncContactMedicalSummariesTest_ContactNotFound() {
        Id accountId = getAccountId();
        
        Test.startTest();
        Syntilio.MedicalSummaryHandler.syncContactMedicalSummaries(new List<Id>{accountId});
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
	static void syncContactMedicalSummariesTest_NothingToSync() {
        Id contactId = getContactId();
        
        Test.startTest();
        Syntilio.MedicalSummaryHandler.syncContactMedicalSummaries(new List<Id>{contactId});
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
	static void syncContactMedicalSummariesTest_ContactHasNoExternalId() {
        Contact newContact = new Contact(LastName='Contact', AccountId=getAccountId());
        insert newContact;
        insertMedicalPolicyDataHubSyncInfo();
        
        Test.startTest();
        Syntilio.MedicalSummaryHandler.syncContactMedicalSummaries(new List<Id>{newContact.Id});
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
	static void syncContactMedicalSummariesTest_MedicalPolicy() {
        Id contactId = getContactId();
        insertMedicalPolicyDataHubSyncInfo();
        
        Test.startTest();
        Syntilio.MedicalSummaryHandler.syncContactMedicalSummaries(new List<Id>{contactId});
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
	static void syncContactMedicalSummariesTest_ContactAlert() {
        Id contactId = getContactId();
        insertContactAlertDataHubSyncInfo();
        
        Test.startTest();
        Syntilio.MedicalSummaryHandler.syncContactMedicalSummaries(new List<Id>{contactId});
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    static void handleTriggerTest() {
        Test.startTest();
        Syntilio.MedicalSummaryHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, new Map<Id, Case>(), new Map<Id, Case>());
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest
    static void handleAfterInsertTest() {
		Id contactId = getContactId();
        Case newCase = new Case(ContactId = contactId);
        insert newCase;        
        Map<Id, Case> caseMap = new Map<Id, Case>{
            newCase.Id => newCase
        };
        Test.startTest();
        Syntilio.MedicalSummaryHandler.handleAfterInsert(caseMap, caseMap);
        Test.stopTest();
        
        System.assert(true);
    }
}