@isTest
public with sharing class ReportTriggerHandlerTest {
    
    private static Contact getContact() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
   
    private static Syntilio__MedicalReport__c getReport() {
        return [SELECT Id, Syntilio__ContactId__c, Name, Syntilio__Comments__c FROM Syntilio__MedicalReport__c LIMIT 1];
    }
    
    private static void createReportTriggerTestData(){
        Account twbAccount = Syntilio.CareHubTestDataFactory.createAccount( 
            new Map<String, Object>{
                'Name' => 'Twb',
                'Syntilio__ApiName__c' => 'Twb'
        	}
        );
        
        Syntilio__ExternalSystem__c onsSystem = Syntilio.DataHubTestDataFactory.createExternalSystem(
            new Map<String, Object>{
                'Name' => 'Ons',
                'Syntilio__ApiName__c' => 'Ons'
        	}
        );
        insert new List<SObject>{twbAccount, onsSystem};

        Contact contactRecord = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
            	'AccountId' => twbAccount.Id
        	}
        );
       
        Syntilio__AccountExternalSystemAssociation__c twbAccountAssociation = Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation( 
            new Map<String, Object>{
                'Syntilio__AccountId__c' => twbAccount.Id,
                'Syntilio__ExternalSystemId__c' => onsSystem.Id
        	}
        );
        insert new List<SObject>{contactRecord, twbAccountAssociation};

        Syntilio__ExternalId__c contactExternalId = Syntilio.DataHubTestDataFactory.createExternalId(
            new Map<String, Object>{
                'Name' => 'clientId',
                'Syntilio__Account__c' => twbAccount.Id,
                'Syntilio__ExternalSystemId__c' => onsSystem.Id,
                'Syntilio__ContactId__c' => contactRecord.Id,
                'Syntilio__Id__c' => '1234'
        	}
        );

        Syntilio__MedicalReport__c newReport = Syntilio.CareHubTestDataFactory.createReport(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => contactRecord.Id
       		}
        );
        insert new List<SObject>{contactExternalId, newReport};

        Syntilio__ExternalId__c reportExternalId = Syntilio.DataHubTestDataFactory.createExternalId(
            new Map<String, Object>{
                'Syntilio__Account__c' => twbAccount.Id,
                'Syntilio__ExternalSystemId__c' => onsSystem.Id,
                'Syntilio__ContactId__c' => contactRecord.Id,
                'Syntilio__Id__c' => '12345',
                'Name' => 'reportId',
                'Syntilio__RelatedSalesforceInternalId__c' => newReport.Id
        	}
        );
        Syntilio__DataHubSyncInfo__c dataHubSyncInfo = Syntilio.DataHubTestDataFactory.createDataHubSyncInfo(
            new Map<String, Object>{
                'Name' => 'Syntilio__Comments__c',
            	'Syntilio__ObjectName__c' => 'Syntilio__MedicalReport__c',
                'Syntilio__ExternalSystems__c' => 'Ons'
            }
        );
        insert new List<SObject>{reportExternalId, dataHubSyncInfo};
    }
    
    @testSetup
    static void setup() {
        createReportTriggerTestData();
    }

    @isTest
    static void handleAfterInsertTest() {

        Contact contactRecord = getContact();
        Syntilio__MedicalReport__c newReport = Syntilio.CareHubTestDataFactory.createReport(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => contactRecord.Id,
                'Syntilio__Comments__c' => 'some new comment',
                'Name' => 'some new report'
			}
        );
        insert newReport;
        Map<Id, Syntilio__MedicalReport__c> newMap = new Map<Id, Syntilio__MedicalReport__c>{
            newReport.Id => newReport
        };
        
        Test.startTest();
        List<Syntilio.DataHubModel> datahubModels = Syntilio.ReportTriggerHandler.handleInsertUpdate(null, newMap, false);
        Test.stopTest();
        
        System.assertNotEquals(null, datahubModels);
        System.assertNotEquals(0, datahubModels.size());
        System.assertNotEquals(null, datahubModels[0].destinations);
        System.assertNotEquals(0, datahubModels[0].destinations.size());
        System.assertNotEquals(null, datahubModels[0].objectsBody);
        System.assertNotEquals(0, datahubModels[0].objectsBody.size());
        System.assertNotEquals(null, ((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Id'));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')).get('Syntilio__Comments__c'));
    }

    @isTest
    static void handleAfterUpdateTest() {
            
        Syntilio__MedicalReport__c reportRecord = getReport();
        Syntilio__MedicalReport__c oldReport = reportRecord.clone(true, true, true);
        Syntilio__MedicalReport__c newReport = reportRecord;
        newReport.Syntilio__Comments__c = 'updated comments';
        update newReport;
        
        Map<Id, Syntilio__MedicalReport__c> oldMap = new Map<Id, Syntilio__MedicalReport__c>();
        oldMap.put(oldReport.Id, oldReport);
        Map<Id, Syntilio__MedicalReport__c> newMap = new Map<Id, Syntilio__MedicalReport__c>();
        newMap.put(oldReport.Id, newReport);
        
        Test.startTest();
        List<Syntilio.DataHubModel> datahubModels = Syntilio.ReportTriggerHandler.handleInsertUpdate(oldMap, newMap, true);
        Test.stopTest();
        
        System.assertNotEquals(null, datahubModels);
        System.assertNotEquals(0, datahubModels.size());
        System.assertNotEquals(null, datahubModels[0].destinations);
        System.assertNotEquals(0, datahubModels[0].destinations.size());
        System.assertNotEquals(null, datahubModels[0].objectsBody);
        System.assertNotEquals(0, datahubModels[0].objectsBody.size());
        System.assertNotEquals(null, ((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Id'));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')));
        System.assertEquals('updated comments', ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')).get('Syntilio__Comments__c'));
    }

    @isTest
    static void handleAfterDeleteTest() {

        Syntilio__MedicalReport__c reportRecord = getReport();
        
        Map<Id, Syntilio__MedicalReport__c> oldMap = new Map<Id, Syntilio__MedicalReport__c>();
        oldMap.put(reportRecord.Id, reportRecord);
        delete reportRecord;
        
        Test.startTest();
        List<Syntilio.DataHubModel> datahubModels = Syntilio.ReportTriggerHandler.handleAfterDelete(oldMap, null);
        Test.stopTest();
        
        List<Syntilio__ExternalId__c> externalIds = [SELECT Id FROM Syntilio__ExternalId__c WHERE Syntilio__RelatedSalesforceInternalId__c = :reportRecord.Id];
        
        System.assertNotEquals(null, datahubModels);
        System.assertNotEquals(0, datahubModels.size());
        System.assertNotEquals(null, datahubModels[0].destinations);
        System.assertNotEquals(0, datahubModels[0].destinations.size());
        System.assertNotEquals(null, datahubModels[0].objectsBody);
        System.assertNotEquals(0, datahubModels[0].objectsBody.size());
        System.assertNotEquals(null, ((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Id'));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')));
        System.assertNotEquals(null, ((Map<String, Object>)((Map<String, Object>) datahubModels[0].objectsBody[0]).get('Twb_Ons')).get('reportId'));
        System.assertNotEquals(null, externalIds);
        System.assertEquals(0, externalIds.size());
    }
  
    @isTest
    static void handleTriggerTest(){
        try{
            Syntilio.ReportTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_UPDATE, null, null); 
			Syntilio.ReportTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, null, null); 
			Syntilio.ReportTriggerHandler.handleTrigger(System.TriggerOperation.AFTER_DELETE, null, null); 
			Syntilio.ReportTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_UPDATE, null, null); 
			Syntilio.ReportTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_INSERT, null, null); 
			Syntilio.ReportTriggerHandler.handleTrigger(System.TriggerOperation.BEFORE_DELETE, null, null); 
        	System.assert(true);
        }catch(Exception e){
        	System.assert(false);
        }
    }
}