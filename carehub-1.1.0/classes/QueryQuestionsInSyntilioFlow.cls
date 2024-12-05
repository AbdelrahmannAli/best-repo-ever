@namespaceAccessible
public with sharing class QueryQuestionsInSyntilioFlow {
    
    @invocableMethod(label='Query All Related Questions In A Questionnaire')
    public static List<OutputVariables> execute (List<InputVariables> inputVariables) {
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        
        if(inputVariables == null)
            return null;
        
        for(InputVariables inputVariable : inputVariables){
            
            List<Syntilio__Question__c> allRelatedQuestionsInQuestionnaire = new List<Syntilio__Question__c>();
            List<Id> allRelatedQuestionsInQuestionnaireIds = new List<Id>();
            
            if(inputVariable.questionnaireQuestionsRecordsCollection != null)
            {
                for( Syntilio__QuestionnaireQuestion__c questionnaireQuestionRecord : inputVariable.questionnaireQuestionsRecordsCollection ){
                    allRelatedQuestionsInQuestionnaireIds.add(questionnaireQuestionRecord.Syntilio__Question__c) ;
                }
                try {
                    allRelatedQuestionsInQuestionnaire = [SELECT Id,Name,  Syntilio__Question__c, Syntilio__Options__c , Syntilio__Type__c  FROM Syntilio__Question__c WHERE Id IN: allRelatedQuestionsInQuestionnaireIds WITH SECURITY_ENFORCED];
                } catch(Exception e){
                    Syntilio.HandleException.logException(e);
                }
            }
            
            OutputVariables outputVariables = new OutputVariables();
            outputVariables.allRelatedQuestionsInQuestionnaireRecordsCollection = allRelatedQuestionsInQuestionnaire;
            outputVariables.requiredQuestions = JSON.serialize(getIsQuestionRequired(inputVariable.questionnaireQuestionsRecordsCollection, allRelatedQuestionsInQuestionnaire));
            outputVariablesList.add(outputVariables);
            
        }
        return outputVariablesList;
    }
    @NamespaceAccessible
    public static Map<Id,Boolean> getIsQuestionRequired(List<Syntilio__QuestionnaireQuestion__c> questionnaireQList, List<Syntilio__Question__c> questionList) {
        Map<Id,Boolean> returnedQuestionMap = new Map<Id,Boolean>();
        for (Syntilio__Question__c question : questionList) {
            returnedQuestionMap.put(question.Id, isRequired(questionnaireQList, question.Id));
        }
        return returnedQuestionMap;
    }
    @NamespaceAccessible
    public static Boolean isRequired(List<Syntilio__QuestionnaireQuestion__c> questionnaireQList, Id questionId) {
        for (Syntilio__QuestionnaireQuestion__c questionnaireQuestion : questionnaireQList) {
            if(questionnaireQuestion.Syntilio__Question__c == questionId) {
                return questionnaireQuestion.Syntilio__IsRequired__c;
            }
        }
        return false;
    }
    @NamespaceAccessible
    public class InputVariables {
        @invocableVariable
        public List<Syntilio__QuestionnaireQuestion__c> questionnaireQuestionsRecordsCollection;
    }
    
    @NamespaceAccessible
    public class OutputVariables {
        @invocableVariable
        public List<Syntilio__Question__c> allRelatedQuestionsInQuestionnaireRecordsCollection;
        @invocableVariable
        public String requiredQuestions;
    }
    
}