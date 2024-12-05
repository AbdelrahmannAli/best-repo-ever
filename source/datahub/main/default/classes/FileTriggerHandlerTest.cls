@isTest
public with sharing class FileTriggerHandlerTest {
    
    private static void createFileTriggerTestData(){

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

        Case newCase = Syntilio.DataHubTestDataFactory.createCase(  new Map<String, Object>{
            'AccountId' => twbAccount.Id,
            'ContactId' => johanContact.Id,
            'Origin' => 'Web',
            'Status' => 'New'
        });
        insert newCase;
    }

    @testSetup
    public static void setup() {
        createFileTriggerTestData();
    }
    
    @isTest
    public static void handleAfterInsertTest() {
        List<Syntilio.DataHubModel> datahubModels;
        try{
            Test.startTest();
            List<Case> cases = [SELECT Id FROM Case];
            System.assertNotEquals(cases.size(), 0);
            
            ContentVersion mockContent = new ContentVersion(
                Title = 'Test Document',
                VersionData = Blob.valueOf('Test content data'),
                PathOnClient = 'MyFile.txt',
                FirstPublishLocationId = cases[0].Id
        	);
            insert mockContent;
            Map<Id, ContentVersion> newMap = new Map<Id, ContentVersion>();
            newMap.put(mockContent.Id, mockContent);

            datahubModels = Syntilio.FileTriggerHandler.handleAfterInsert(null, newMap);
            
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
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')).get('fileName'));
    }
    
    @isTest
    public static void handleTriggerTest(){
        try{
            Syntilio.FileTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_UPDATE, null, null); 
			Syntilio.FileTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, null, null); 
			Syntilio.FileTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_DELETE, null, null); 
			Syntilio.FileTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_UPDATE, null, null); 
			Syntilio.FileTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_INSERT, null, null); 
			Syntilio.FileTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_DELETE, null, null); 
        	System.assertEquals(true, true);
        }catch(Exception e){
        	System.assertEquals(true, false);
        }
    }
}