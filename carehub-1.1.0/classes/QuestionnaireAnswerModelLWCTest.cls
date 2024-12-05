@isTest
public with sharing class QuestionnaireAnswerModelLWCTest {
    
    private static void createQuestionnaireAndQuestion() {
        Syntilio__Questionnaire__c standardHospitalQuestionnaire = Syntilio.CareHubTestDataFactory.createQuestionnaire(null);
        
        Syntilio__Question__c anxietyQuestion = Syntilio.CareHubTestDataFactory.createQuestion(
            new Map<String, Object>{
                'Syntilio__Question__c' => 'Degree of patient anxiety on a scale from 0 to 10?'                
            }
        );
        insert new List<SObject>{standardHospitalQuestionnaire, anxietyQuestion};
    }
    
    @isTest
    public static void questionnaireAnswerModelLWC_Test(){
        createQuestionnaireAndQuestion();
        Syntilio__Question__c questionRecord = [SELECT Id FROM Syntilio__Question__c];
        QuestionnaireAnswerModelLWC questionnaireAnswerModelRecord = new QuestionnaireAnswerModelLWC();
        questionnaireAnswerModelRecord.answerValue = '1';
        questionnaireAnswerModelRecord.selectedQuestionId = questionRecord.Id;
    }
}