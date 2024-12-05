@isTest
public with sharing class ReportHandlerTest {
    
    private static Contact getContact() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    private static Contact createContact() {
        Contact contactRecord = Syntilio.CareHubTestDataFactory.createContact(null);
        insert contactRecord;
        return contactRecord;
    }
    
    private static Syntilio__ExternalSystem__c createExternalSystem() {
        Syntilio__ExternalSystem__c externalSystem = Syntilio.DataHubTestDataFactory.createExternalSystem(null); 
        insert externalSystem;
        return externalSystem;
    }
    
    private static List<Case> createCases(Id contactId) {
        List<Case> caseRecords = new List<Case>();
        for(Integer i = 0; i < 3; i++){
            caseRecords.add(Syntilio.CareHubTestDataFactory.createCase(
                new Map<String, Object>{
                    'ContactId' => contactId
                }
            ));
        }
        insert caseRecords;
        return caseRecords;
    }
    
    private static List<Syntilio__MedicalReport__c> createCaseReports(Id contactId, List<Case> caseRecords) {
        List<Syntilio__MedicalReport__c> reportRecords = new List<Syntilio__MedicalReport__c>();
        for(Integer i = 0; i < 3; i++){
            reportRecords.add(Syntilio.CareHubTestDataFactory.createReport(
                new Map<String, Object>{
                    'Syntilio__CaseId__c' => caseRecords[i].Id,
                    'Syntilio__ContactId__c' => contactId
                }
            ));
        }
        insert reportRecords;
        return reportRecords;
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
                'Syntilio__Id__c' => '1234',
				'Syntilio__ContactId__c' => contactRecord.Id,
				'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
			}
        );
        insert new List<SObject>{externalIdRecord};
    }

    
    @isTest
    static void getContactReportTest_CaseHasReports() {
        Contact contactRecord = createContact();
        List<Case> caseRecords = createCases(contactRecord.Id);
        List<Syntilio__MedicalReport__c> reportRecords = createCaseReports(contactRecord.Id, caseRecords);
        
        Test.startTest();
        String reportListSerialized = Syntilio.ReportHandler.getContactReport(caseRecords[0].Id);
        Test.stopTest();
        
        ResponseMessage reportResponse = Syntilio.ResponseMessage.deserialize(reportListSerialized);
        List<Object> reportList = (List<Object>) reportResponse.data;
        System.assertNotEquals(null, reportList);
        System.assertEquals(true, reportResponse.isSuccess);
        System.assertEquals(3, reportList.size());
    }

    @isTest
    static void getReportsTest() {
        Syntilio__ExternalSystem__c externalSystem = createExternalSystem();
        Contact contactRecord = createContact();
        List<Case> caseRecords = createCases(contactRecord.Id);
        List<Syntilio__MedicalReport__c> reportRecords = createCaseReports(contactRecord.Id, caseRecords);
        
        insert Syntilio.DataHubTestDataFactory.createExternalId(
            new Map<String, Object>{
                'Syntilio__RelatedSalesforceInternalId__c' => reportRecords[0].Id,
                'Syntilio__ExternalSystemId__c' => externalSystem.Id
            }
        );
        
        Test.startTest();
        List<Map<String, Object>> reportList = Syntilio.ReportHandler.getReports(caseRecords[0].ContactId, caseRecords[0].Id);
        Test.stopTest();
        
        System.assertNotEquals(null, reportList);
        System.assertEquals(3, reportList.size());
    }

    @isTest
    static void syncReportsTest_Null() {
        Test.startTest();
        Syntilio.ReportHandler.syncReports(null);
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void syncReportsTest_NoViableExternalSystems() {
        createDataHubSynchronisationTestData();
		Contact contactRecord = getContact();
        
        Test.startTest();
        Syntilio.ReportHandler.syncReports(new List<Id>{contactRecord.Id});
        Test.stopTest();
        
        List<Syntilio__Notification__e> eventList = Syntilio.ReportHandler.eventList;
        System.assert(eventList.size() == 0);
    }

    @isTest
    static void syncReportsTest_Success() {
        createDataHubSynchronisationTestData();
        Contact contactRecord = getContact();
		insert Syntilio.DataHubTestDataFactory.createDataHubSyncInfo(
            new Map<String, Object>{
                'Name' => 'Syntilio__Comments__c',
                'Syntilio__ObjectName__c' => 'Syntilio__MedicalReport__c'
            }
        );
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'ContactId' => contactRecord.Id
            }
        );
        insert caseRecord;

        Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('GET', 'report', '?client_id=1234'));
        
        Test.startTest();
        Syntilio.ReportHandler.syncReports(new List<Id>{contactRecord.Id});
        Test.stopTest();
        
        System.assert(true);
    }
     
    @isTest
    static void getContactReportTest_RaiseException() {
        Syntilio.ReportHandler.raiseException = true;

        Test.startTest();
        String reportList = Syntilio.ReportHandler.getContactReport(null);
        Test.stopTest();
        
        Syntilio.ReportHandler.raiseException = false;
        
        ResponseMessage responseMessage = ResponseMessage.deserialize(reportList);
        System.assertEquals(false, responseMessage.isSuccess);
        System.assert(responseMessage.message.contains('An unexpected error occured'));
    }

    @isTest
    static void getContactsTest_NotFound() {
        Contact contactRecord = createContact();
        Id contactRecordId = contactRecord.Id;
        delete contactRecord;
        
        Test.startTest();
        List<Contact> returnedContacts = Syntilio.ReportHandler.getContacts(new List<Id>{contactRecordId});
        Test.stopTest();
        
        System.assertEquals(0, returnedContacts.size());
    }

    @isTest
    static void getContactsTest_Found() {
        Contact contactRecord = createContact();
        Id contactRecordId = contactRecord.Id;
        
        Test.startTest();
        List<Contact> returnedContacts = Syntilio.ReportHandler.getContacts(new List<Id>{contactRecordId});
        Test.stopTest();
        
        System.assertNotEquals(0, returnedContacts.size());
        System.assertEquals(contactRecordId, returnedContacts[0].Id);
    }

    @isTest
    public static void handleTrigger_Test() {
        Test.startTest();
        Syntilio.ReportHandler.handleTrigger(System.TriggerOperation.AFTER_INSERT, new Map<Id, Case>(), new Map<Id, Case>());
        Test.stopTest();
        
        System.assert(true);
    }
 
    @isTest
    public static void handleAfterInsert_Test() {
        Contact contactRecord = createContact();
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'ContactId' => contactRecord.Id
            }
        );
        insert caseRecord;
        
        Map<Id, Case> caseMap = new Map<Id, Case>{
            caseRecord.Id => caseRecord
        };
            
        Test.startTest();
        Syntilio.ReportHandler.handleAfterInsert(caseMap, caseMap);
        Test.stopTest();
        
        System.assert(true);
    }
}