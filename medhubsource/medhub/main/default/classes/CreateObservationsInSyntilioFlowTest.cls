@isTest
public with sharing class CreateObservationsInSyntilioFlowTest {
    @isTest
    public static void createObservationsInSyntilioFlowTest_Should_SuccessfullyCreateCareObservation_Test() {
        List<CreateObservationsInSyntilioFlow.OutputVariables> CreateObservationsInSyntilioFlowOutputVariablesList;
        CareObservation careObservationRecord = new CareObservation();
        Id observationRecordCreatedId;

        try{
            Test.startTest();
            
        	List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);

        	MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            MedHubTestDataFactory.createQuestionnaireAndQuestion();

            Syntilio__Questionnaire__c questionnaireRecord = [SELECT Id FROM Syntilio__Questionnaire__c];
            Syntilio__Question__c questionRecord = [SELECT Id FROM Syntilio__Question__c];

            careObservationRecord = [SELECT Id, Name, ObservedSubjectId, CodeId, NumericValue FROM CareObservation LIMIT 1];

            List<CreateObservationsInSyntilioFlow.InputVariables> CreateObservationsInSyntilioFlowInputVariablesList = new List<CreateObservationsInSyntilioFlow.InputVariables>();
            CreateObservationsInSyntilioFlow.InputVariables CreateObservationsInSyntilioFlowInputVariableRecord = new CreateObservationsInSyntilioFlow.InputVariables();
            CreateObservationsInSyntilioFlowInputVariableRecord.sObjectType = 'CareObservation';
            CreateObservationsInSyntilioFlowInputVariableRecord.name = careObservationRecord.Name;
            CreateObservationsInSyntilioFlowInputVariableRecord.observedSubjectId = careObservationRecord.ObservedSubjectId;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeId = careObservationRecord.CodeId;
            CreateObservationsInSyntilioFlowInputVariableRecord.numericValue = String.valueOf(careObservationRecord.NumericValue);
            CreateObservationsInSyntilioFlowInputVariableRecord.questionnaireId = questionnaireRecord.Id;
            CreateObservationsInSyntilioFlowInputVariableRecord.careObservationId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeSetBundleId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.questionId = null;

            CreateObservationsInSyntilioFlowInputVariablesList.add(CreateObservationsInSyntilioFlowInputVariableRecord);
            
            CreateObservationsInSyntilioFlowOutputVariablesList = CreateObservationsInSyntilioFlow.execute(CreateObservationsInSyntilioFlowInputVariablesList);
            
            Test.stopTest();

        }catch(Exception e){
        }
        system.assertNotEquals(null, CreateObservationsInSyntilioFlowOutputVariablesList[0].observationRecordCreatedId);
    }
    
    @isTest
    public static void createObservationsInSyntilioFlowTest_Should_SuccessfullyCreateCareObservationComponent_Test() {
        List<CreateObservationsInSyntilioFlow.OutputVariables> CreateObservationsInSyntilioFlowOutputVariablesList;
        CareObservation careObservationRecord = new CareObservation();
        Id observationRecordCreatedId;

        try{
            Test.startTest();
            
        	List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            
        	MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            
            MedHubTestDataFactory.createQuestionnaireAndQuestion();
            
            Syntilio__Questionnaire__c questionnaireRecord = [SELECT Id FROM Syntilio__Questionnaire__c];
            Syntilio__Question__c questionRecord = [SELECT Id FROM Syntilio__Question__c];
            CodeSetBundle codeSetBundleRecord = [SELECT Id FROM CodeSetBundle];
            
            careObservationRecord = [SELECT Id, Name, ObservedSubjectId, CodeId, NumericValue FROM CareObservation LIMIT 1];
            
            List<CreateObservationsInSyntilioFlow.InputVariables> CreateObservationsInSyntilioFlowInputVariablesList = new List<CreateObservationsInSyntilioFlow.InputVariables>();
            CreateObservationsInSyntilioFlow.InputVariables CreateObservationsInSyntilioFlowInputVariableRecord = new CreateObservationsInSyntilioFlow.InputVariables();
            CreateObservationsInSyntilioFlowInputVariableRecord.sObjectType = 'CareObservationComponent';
            CreateObservationsInSyntilioFlowInputVariableRecord.name = careObservationRecord.Name;
            CreateObservationsInSyntilioFlowInputVariableRecord.observedSubjectId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeId = careObservationRecord.CodeId;
            CreateObservationsInSyntilioFlowInputVariableRecord.numericValue = String.valueOf(careObservationRecord.NumericValue);
            CreateObservationsInSyntilioFlowInputVariableRecord.questionnaireId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.careObservationId = careObservationRecord.Id;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeSetBundleId = codeSetBundleRecord.Id;
            CreateObservationsInSyntilioFlowInputVariableRecord.questionId = questionRecord.Id;

            CreateObservationsInSyntilioFlowInputVariablesList.add(CreateObservationsInSyntilioFlowInputVariableRecord);
            
            CreateObservationsInSyntilioFlowOutputVariablesList = CreateObservationsInSyntilioFlow.execute(CreateObservationsInSyntilioFlowInputVariablesList);
            
            Test.stopTest();
            
        }catch(Exception e){
        }
        system.assertNotEquals(null, CreateObservationsInSyntilioFlowOutputVariablesList[0].observationRecordCreatedId);
    }
    
    @isTest
    public static void createObservationsInSyntilioFlowTest_Should_Not_CreateCareObservationComponent_Test() {
        List<CreateObservationsInSyntilioFlow.OutputVariables> CreateObservationsInSyntilioFlowOutputVariablesList;
        CareObservation careObservationRecord = new CareObservation();
        Id observationRecordCreatedId;

        try{
            Test.startTest();
            
        	List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);

        	MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            
            MedHubTestDataFactory.createQuestionnaireAndQuestion();
            
            Syntilio__Questionnaire__c questionnaireRecord = [SELECT Id FROM Syntilio__Questionnaire__c];
            Syntilio__Question__c questionRecord = [SELECT Id FROM Syntilio__Question__c];
            CodeSetBundle codeSetBundleRecord = [SELECT Id FROM CodeSetBundle];
            
            careObservationRecord = [SELECT Id, Name, ObservedSubjectId, CodeId, NumericValue FROM CareObservation LIMIT 1];
            
            List<CreateObservationsInSyntilioFlow.InputVariables> CreateObservationsInSyntilioFlowInputVariablesList = new List<CreateObservationsInSyntilioFlow.InputVariables>();
            CreateObservationsInSyntilioFlow.InputVariables CreateObservationsInSyntilioFlowInputVariableRecord = new CreateObservationsInSyntilioFlow.InputVariables();
            CreateObservationsInSyntilioFlowInputVariableRecord.sObjectType = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.name = careObservationRecord.Name;
            CreateObservationsInSyntilioFlowInputVariableRecord.observedSubjectId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeId = careObservationRecord.CodeId;
            CreateObservationsInSyntilioFlowInputVariableRecord.numericValue = String.valueOf(careObservationRecord.NumericValue);
            CreateObservationsInSyntilioFlowInputVariableRecord.questionnaireId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.careObservationId = careObservationRecord.Id;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeSetBundleId = codeSetBundleRecord.Id;
            CreateObservationsInSyntilioFlowInputVariableRecord.questionId = questionRecord.Id;

            CreateObservationsInSyntilioFlowInputVariablesList.add(CreateObservationsInSyntilioFlowInputVariableRecord);
            
            CreateObservationsInSyntilioFlowOutputVariablesList = CreateObservationsInSyntilioFlow.execute(CreateObservationsInSyntilioFlowInputVariablesList);
            
            Test.stopTest();
            
        }catch(Exception e){
        }
        system.assertEquals(null, CreateObservationsInSyntilioFlowOutputVariablesList);
    }

    @isTest
    public static void createObservationsInSyntilioFlowTest_Should_ReturnNull_Test() {
        List<CreateObservationsInSyntilioFlow.OutputVariables> CreateObservationsInSyntilioFlowOutputVariablesList;
        CareObservation careObservationRecord = new CareObservation();
        Id observationRecordCreatedId;

        try{
            Test.startTest();
            
        	List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);

        	MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            
            MedHubTestDataFactory.createQuestionnaireAndQuestion();
            
            Syntilio__Questionnaire__c questionnaireRecord = [SELECT Id FROM Syntilio__Questionnaire__c];
            Syntilio__Question__c questionRecord = [SELECT Id FROM Syntilio__Question__c];
            CodeSetBundle codeSetBundleRecord = [SELECT Id FROM CodeSetBundle];
            
            careObservationRecord = [SELECT Id, Name, ObservedSubjectId, CodeId, NumericValue FROM CareObservation LIMIT 1];
            
            List<CreateObservationsInSyntilioFlow.InputVariables> CreateObservationsInSyntilioFlowInputVariablesList = null;
            
            CreateObservationsInSyntilioFlowOutputVariablesList = CreateObservationsInSyntilioFlow.execute(CreateObservationsInSyntilioFlowInputVariablesList);
            
            Test.stopTest();
            
        }catch(Exception e){
        }
        system.assertEquals(null, CreateObservationsInSyntilioFlowOutputVariablesList);
    }
    
    @isTest
    public static void createObservationsInSyntilioFlowTest_Should_LogException_Test() {
        List<CreateObservationsInSyntilioFlow.OutputVariables> CreateObservationsInSyntilioFlowOutputVariablesList;
        CareObservation careObservationRecord = new CareObservation();
        Id observationRecordCreatedId;

        try{
            Test.startTest();
            
        	List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);

        	MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            MedHubTestDataFactory.createQuestionnaireAndQuestion();

            Syntilio__Questionnaire__c questionnaireRecord = [SELECT Id FROM Syntilio__Questionnaire__c];
            Syntilio__Question__c questionRecord = [SELECT Id FROM Syntilio__Question__c];

            careObservationRecord = [SELECT Id, Name, ObservedSubjectId, CodeId, NumericValue FROM CareObservation LIMIT 1];
            List<CreateObservationsInSyntilioFlow.InputVariables> CreateObservationsInSyntilioFlowInputVariablesList = new List<CreateObservationsInSyntilioFlow.InputVariables>();
            CreateObservationsInSyntilioFlow.InputVariables CreateObservationsInSyntilioFlowInputVariableRecord = new CreateObservationsInSyntilioFlow.InputVariables();
            CreateObservationsInSyntilioFlowInputVariableRecord.sObjectType = 'CareObservation';
            CreateObservationsInSyntilioFlowInputVariableRecord.name = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.observedSubjectId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.numericValue = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.questionnaireId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.careObservationId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.codeSetBundleId = null;
            CreateObservationsInSyntilioFlowInputVariableRecord.questionId = null;

            CreateObservationsInSyntilioFlowInputVariablesList.add(CreateObservationsInSyntilioFlowInputVariableRecord);
            
            CreateObservationsInSyntilioFlowOutputVariablesList = CreateObservationsInSyntilioFlow.execute(CreateObservationsInSyntilioFlowInputVariablesList);
            
            Test.stopTest();

        }catch(Exception e){
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertEquals(1, exceptionList.size());
    }
    
}