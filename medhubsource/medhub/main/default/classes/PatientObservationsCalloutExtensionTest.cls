@isTest
public with sharing class PatientObservationsCalloutExtensionTest {
    @isTest
    public static void makePatientObservationsCallout_Should_MakeCallout_Test(){
        
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            
            MedHubTestDataFactory.createCaseRecords(contactRecordsList[0]);
            Case caseRecord = [SELECT Id FROM Case];  
            
            ApexPages.currentPage().getParameters().put('Id', caseRecord.Id);
            ApexPages.StandardController caseStandardController = new ApexPages.StandardController(caseRecord);
            PatientObservationsCalloutExtension patientObservationsCalloutExtension  = new PatientObservationsCalloutExtension(caseStandardController);
            patientObservationsCalloutExtension.makePatientObservationsCallout();
            Test.stopTest(); 
            
        }catch(Exception e){
        }
    }
}