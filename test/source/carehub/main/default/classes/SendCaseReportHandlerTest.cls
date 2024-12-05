@isTest
public with sharing class SendCaseReportHandlerTest {

    @isTest
    static void sendCaseReportTest() {
        Contact newContact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert newContact;
        
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'ContactId' => newContact.Id
			}
        );
        insert newCase;
        
        Syntilio__MedicalReport__c newReport = Syntilio.CareHubTestDataFactory.createReport(
            new Map<String, Object>{
                'Syntilio__Comments__c' => 'some new comment',
                'Name' => 'some new report',
                'Syntilio__CaseId__c' => newCase.Id
			}
        );
        
        Test.startTest();
        Syntilio.SendCaseReportHandler.sendCaseReport(newReport);
        Test.stopTest();
        
        List<Syntilio__MedicalReport__c> reportsAfter = [SELECT Id FROM Syntilio__MedicalReport__c];
        System.assert(reportsAfter.size() > 0);
    }
}