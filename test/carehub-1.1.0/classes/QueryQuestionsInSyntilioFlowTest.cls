@isTest
public with sharing class QueryQuestionsInSyntilioFlowTest {
    
    private static void createTriageQuestionsRelatedRecords() {
        Syntilio__Questionnaire__c standardHospitalQuestionnaire = Syntilio.CareHubTestDataFactory.createQuestionnaire(null);
        
        Syntilio__Question__c anxietyQuestion = Syntilio.CareHubTestDataFactory.createQuestion(
            new Map<String, Object>{
                'Syntilio__Question__c' => 'Degree of patient anxiety on a scale from 0 to 10?'                
            }
        );
        
        insert new List<SObject>{standardHospitalQuestionnaire, anxietyQuestion};
        
        
        Syntilio__QuestionnaireQuestion__c QQStandardHospitalAnxiety = Syntilio.CareHubTestDataFactory.createQuestionnaireQuestion(
            new Map<String, Object>{
                'Syntilio__Question__c' => anxietyQuestion.Id,
                'Syntilio__Questionnaire__c' => standardHospitalQuestionnaire.Id,
                'Syntilio__IsRequired__c' => true
            }
        );
        insert QQStandardHospitalAnxiety;
    }
    
    @isTest
    static void getAllQuestionsRelatedToQuestionnaireTest_ShouldFindResults() {
        
        createTriageQuestionsRelatedRecords();
        List<Syntilio__QuestionnaireQuestion__c> questionnaireQuestionRecordsList = [SELECT Id, Syntilio__Questionnaire__c, Syntilio__Question__c, Syntilio__IsRequired__c FROM Syntilio__QuestionnaireQuestion__c];
        
        List<Syntilio.QueryQuestionsInSyntilioFlow.InputVariables> queryQuestionsInSyntilioFlowInputVariablesList = new List<Syntilio.QueryQuestionsInSyntilioFlow.InputVariables>();
        Syntilio.QueryQuestionsInSyntilioFlow.InputVariables queryQuestionsInSyntilioFlowInputVariablesRecord = new Syntilio.QueryQuestionsInSyntilioFlow.InputVariables();
        queryQuestionsInSyntilioFlowInputVariablesRecord.questionnaireQuestionsRecordsCollection = questionnaireQuestionRecordsList;
        queryQuestionsInSyntilioFlowInputVariablesList.add(queryQuestionsInSyntilioFlowInputVariablesRecord);
        
        Test.startTest();
        List<QueryQuestionsInSyntilioFlow.OutputVariables> queryQuestionsInSyntilioFlowOutputVariablesList = Syntilio.QueryQuestionsInSyntilioFlow.execute(queryQuestionsInSyntilioFlowInputVariablesList);
        Test.stopTest();
        
        System.assertEquals('Degree of patient anxiety on a scale from 0 to 10?', queryQuestionsInSyntilioFlowOutputVariablesList[0].allRelatedQuestionsInQuestionnaireRecordsCollection[0].Syntilio__Question__c);    
        
    }
    
    @isTest
    public static void getAllQuestionsRelatedToQuestionnaireTest_ShouldNotFindResults() {
        
        List<Syntilio__QuestionnaireQuestion__c> questionnaireQuestionRecordsList = new List<Syntilio__QuestionnaireQuestion__c>();

        List<Syntilio.QueryQuestionsInSyntilioFlow.InputVariables> queryQuestionsInSyntilioFlowInputVariablesList = new List<Syntilio.QueryQuestionsInSyntilioFlow.InputVariables>();
        Syntilio.QueryQuestionsInSyntilioFlow.InputVariables queryQuestionsInSyntilioFlowInputVariablesRecord = new Syntilio.QueryQuestionsInSyntilioFlow.InputVariables();
        queryQuestionsInSyntilioFlowInputVariablesRecord.questionnaireQuestionsRecordsCollection = questionnaireQuestionRecordsList;
        queryQuestionsInSyntilioFlowInputVariablesList.add(queryQuestionsInSyntilioFlowInputVariablesRecord);
        
        Test.startTest();
        List<Syntilio.QueryQuestionsInSyntilioFlow.OutputVariables> queryQuestionsInSyntilioFlowOutputVariablesList = Syntilio.QueryQuestionsInSyntilioFlow.execute(queryQuestionsInSyntilioFlowInputVariablesList);
        Test.stopTest();
        
        System.assertEquals(questionnaireQuestionRecordsList.isEmpty(), queryQuestionsInSyntilioFlowOutputVariablesList[0].allRelatedQuestionsInQuestionnaireRecordsCollection.isEmpty());    
    }
    
    @isTest
    static void getAllQuestionsRelatedToQuestionnaireTest_ShouldReturnNull() {
        
        Test.startTest();            
        List<Syntilio.QueryQuestionsInSyntilioFlow.OutputVariables> queryQuestionsInSyntilioFlowOutputVariablesList = Syntilio.QueryQuestionsInSyntilioFlow.execute(null);
        Test.stopTest();
        
        System.assertEquals(null, queryQuestionsInSyntilioFlowOutputVariablesList);    
    }
    
    @isTest
    static void isRequiredTest_QuestionInQuestionnaire() {
        createTriageQuestionsRelatedRecords();
        
        List<Syntilio__QuestionnaireQuestion__c> questionnaireQuestionRecordsList = [SELECT Id, Syntilio__Questionnaire__c, Syntilio__Question__c, Syntilio__IsRequired__c FROM Syntilio__QuestionnaireQuestion__c];
        List<Syntilio__Question__c> questionRecordsList = [SELECT Id FROM Syntilio__Question__c];

        Test.startTest();            
        Boolean isRequired = Syntilio.QueryQuestionsInSyntilioFlow.isRequired(questionnaireQuestionRecordsList, questionRecordsList[0].Id);
        Test.stopTest();
        
        System.assertEquals(true, isRequired);
    }
    
    @isTest
    static void isRequiredTest_QuestionNotInQuestionnaire() {
        createTriageQuestionsRelatedRecords();
        
        List<Syntilio__QuestionnaireQuestion__c> questionnaireQuestionRecordsList = [SELECT Id, Syntilio__Questionnaire__c, Syntilio__Question__c, Syntilio__IsRequired__c FROM Syntilio__QuestionnaireQuestion__c];
		Syntilio__Question__c newQuestion = Syntilio.CareHubTestDataFactory.createQuestion(
            new Map<String, Object>{
                'Syntilio__Question__c' => 'Test Question?'                
            }
        );
        insert newQuestion;

        Test.startTest();            
        Boolean isRequired = Syntilio.QueryQuestionsInSyntilioFlow.isRequired(questionnaireQuestionRecordsList, newQuestion.Id);
        Test.stopTest();
        
        System.assertEquals(false, isRequired);
    }
}