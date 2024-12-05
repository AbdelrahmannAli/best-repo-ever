@isTest
public with sharing class PatientObservationsServiceTest {
    
    @isTest
    public static void getPatientDetails_ShouldCreateObservationRequestModel_Test() {
        ObservationRequestModel observationRequestModelRecord = new ObservationRequestModel();
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            
            MedHubTestDataFactory.createCaseRecords(contactRecordsList[0]);
            Case caseRecord = [SELECT Id FROM Case];
            
            Syntilio__EventConfiguration__c eventConfigurationMdtRecord = MedHubTestDataFactory.mockCreateEventConfigurationCustomMetadata_With_ObservationsPeriod();
            IEventConfigurationMdt eventConfigurationMdt = new MockEventConfigurationMdt(eventConfigurationMdtRecord);
            PatientObservationsService.eventConfigurationMdt = eventConfigurationMdt;
            
            PatientObservationsService patientObservationsService = new PatientObservationsService();
            observationRequestModelRecord = patientObservationsService.getPatientDetails(caseRecord.Id);
            
        }catch(Exception e){
        }
        system.assertEquals('1', observationRequestModelRecord.userId);
        system.assertEquals('AppSupplier', observationRequestModelRecord.supplierName);
        system.assertEquals('bp', observationRequestModelRecord.observationCodeSet);
    }
    
    @isTest
    public static void getPatientDetails_MissingValues_ShouldReturnNull_Test() {
        ObservationRequestModel observationRequestModelRecord = new ObservationRequestModel();
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
                        
            MedHubTestDataFactory.createCaseRecordsWithoutLinkedProductSupplier(contactRecordsList[0]);
            Case caseRecord = [SELECT Id FROM Case];
            
            Syntilio__EventConfiguration__c eventConfigurationMdtRecord = MedHubTestDataFactory.mockCreateEventConfigurationCustomMetadata_Without_ObservationsPeriod();
            IEventConfigurationMdt eventConfigurationMdt = new MockEventConfigurationMdt(eventConfigurationMdtRecord);
            PatientObservationsService.eventConfigurationMdt = eventConfigurationMdt;
            
            PatientObservationsService patientObservationsService = new PatientObservationsService();
            observationRequestModelRecord = patientObservationsService.getPatientDetails(caseRecord.Id);
            
        }catch(Exception e){
        }
        
        system.assertEquals(null, observationRequestModelRecord.userId);
        system.assertEquals(null, observationRequestModelRecord.supplierName);
    }
    
}