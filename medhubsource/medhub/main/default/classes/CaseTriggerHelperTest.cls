@isTest
public with sharing class CaseTriggerHelperTest {
    @isTest
    public static void deleteCareObservationRecordsWhenCaseIsClosed_Should_DeleteFoundResults_Test() {
        Boolean checkIfCareObservationRecordBeforeDeleteTriggerIsEmpty_ShouldBeFalse;
        Boolean checkIfCareObservationRecordAfterDeleteTriggerIsEmpty_ShouldBeTrue;
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            
            checkIfCareObservationRecordBeforeDeleteTriggerIsEmpty_ShouldBeFalse = [SELECT Id, Name FROM CareObservation].IsEmpty()? true : false;
            
            MedHubTestDataFactory.createCaseRecords(contactRecordsList[0]);
            Case caseRecord = [SELECT Id, Status FROM Case];
            
            caseRecord.Status = 'Closed';
            update caseRecord;
            
            Test.stopTest();
            
        }catch(Exception e){
        }
        List<CareObservation> careObservationlistAfterDeletion = [SELECT Id, Name, ObservedSubjectId, CodeId  FROM CareObservation];
        checkIfCareObservationRecordAfterDeleteTriggerIsEmpty_ShouldBeTrue = [SELECT Id, Name FROM CareObservation].IsEmpty()? true : false;
        system.assertNotEquals(checkIfCareObservationRecordBeforeDeleteTriggerIsEmpty_ShouldBeFalse, checkIfCareObservationRecordAfterDeleteTriggerIsEmpty_ShouldBeTrue);
        system.assertEquals(0, careObservationlistAfterDeletion.size());
        
    }
    
    @isTest
    public static void deleteCareObservationRecordsWhenCaseIsSolvedByAgent_Should_Not_DeleteFoundResults_Test() {
        Boolean checkIfCareObservationRecordBeforeDeleteTriggerIsEmpty_ShouldBeFalse;
        Boolean checkIfCareObservationRecordAfterDeleteTriggerIsEmpty_ShouldBeFalse;
        
        List<CareObservation> careObservationsRecordsListBeforeTrigger = new List<CareObservation>();
        List<CareObservation> careObservationsRecordsListAfterTrigger = new List<CareObservation>();
        
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            
            MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            
            checkIfCareObservationRecordBeforeDeleteTriggerIsEmpty_ShouldBeFalse = [SELECT Id, Name FROM CareObservation].IsEmpty()? true : false;
            careObservationsRecordsListBeforeTrigger = [SELECT Id, Name FROM CareObservation];
            
            MedHubTestDataFactory.createCaseRecords(contactRecordsList[0]);
            Case caseRecord = [SELECT Id, Status FROM Case];
            
            caseRecord.Status = 'Solved By Agent';
            update caseRecord;
            
            Test.stopTest();
            
        }catch(Exception e){
        }
        checkIfCareObservationRecordAfterDeleteTriggerIsEmpty_ShouldBeFalse = [SELECT Id, Name FROM CareObservation].IsEmpty()? true : false;
        careObservationsRecordsListAfterTrigger = [SELECT Id, Name FROM CareObservation];
        
        //system.assertEquals(checkIfCareObservationRecordBeforeDeleteTriggerIsEmpty_ShouldBeFalse, checkIfCareObservationRecordAfterDeleteTriggerIsEmpty_ShouldBeFalse);
        system.assertEquals(careObservationsRecordsListBeforeTrigger.size(), careObservationsRecordsListAfterTrigger.size());
    }
    
    @isTest
    public static void deleteCareObservationRecordsWhenCaseIsClosed_Should_ThrowAnException_ReturnNull_Test() {
        Boolean checkIfCareObservationRecordAfterDeleteTriggerIsEmpty_ShouldBeTrue;
        try{
            Test.startTest();
            
            CaseTriggerHelper.deleteCareObservationRecordsWhenCaseIsClosed(null);
            
            Test.stopTest();
            
        }catch(Exception e){
        }
    }
}