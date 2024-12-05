@isTest
public with sharing class PatientObservationsCalloutTest {
    @isTest
    public static void patientObservationsCallout_Test() {
        try{
        
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            
            MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            
            MedHubTestDataFactory.createCaseRecords(contactRecordsList[0]);
            Case caseRecord = [SELECT Id FROM Case];
            
            Syntilio__EventConfiguration__c eventConfigurationMdtRecord = MedHubTestDataFactory.mockCreateEventConfigurationCustomMetadata_With_ObservationsPeriod();
            IEventConfigurationMdt eventConfigurationMdt = new MockEventConfigurationMdt(eventConfigurationMdtRecord);
            PatientObservationsService.eventConfigurationMdt = eventConfigurationMdt;
            
            Test.setMock(HttpCalloutMock.class, new MockPatientObservationsCalloutResponse());
            
            PatientObservationsCallout.getPatientObservations(caseRecord.Id);

            Test.stopTest(); 
        }catch(Exception e){
        }
        
        List<CareObservation> careObservationRecordsList = new List<CareObservation>([SELECT Id FROM CareObservation]);
        system.assertEquals(1, careObservationRecordsList.Size());
    }
    
    @isTest
    public static void patientObservationsCallout_ShouldLogException_Test() {
        try{
        
            Test.startTest();
            
            PatientObservationsCallout.getPatientObservations('%@^#@*');

            Test.stopTest(); 
        }catch(Exception e){
        }
        
        List<CareObservation> careObservationRecordsList = new List<CareObservation>([SELECT Id FROM CareObservation]);
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertEquals(0, careObservationRecordsList.Size());
        system.assertEquals(2, exceptionList.size());
    }
}