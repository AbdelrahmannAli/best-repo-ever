global class QuestionnaireAnswerModelLWC {
    @AuraEnabled global String answerValue{get; set;}
    @AuraEnabled global Id selectedQuestionId{get; set;}
}