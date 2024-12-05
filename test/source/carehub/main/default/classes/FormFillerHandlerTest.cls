@isTest
public with sharing class FormFillerHandlerTest {
    
    private static Syntilio__Protocol__c getProtocol() {
        return [SELECT Id FROM Syntilio__Protocol__c LIMIT 1];
    }
    
    private static Case getCase() {
        return [SELECT Id FROM Case LIMIT 1];
    }

    private static List<Syntilio__Question__c> createQuestions(Integer numberOfRecords){
        List<Syntilio__Question__c> questions = new List<Syntilio__Question__c>();
        for(Integer i = 1; i <= numberOfRecords; i++){
            questions.add(
                Syntilio.CareHubTestDataFactory.createQuestion(
                    new Map<String, Object>{
                        'Name' => 'question' + i,
                        'Syntilio__Title__c' => 'Question ' + i,
                        'Syntilio__QuestionType__c'  => 'text',
                        'Syntilio__JSON__c' => '{}'
                    }
        		)
			);
        }
        return questions;
    }
    private static List<Syntilio__ProtocolPage__c> createProtocolPages(Integer numberOfRecords, Id protocolId){
        List<Syntilio__ProtocolPage__c> protocolPages = new List<Syntilio__ProtocolPage__c>();
        for(Integer i = 1; i <= numberOfRecords; i++){
            protocolPages.add(
                Syntilio.CareHubTestDataFactory.createProtocolPage(
                    new Map<String, Object>{
                        'Syntilio__ProtocolId__c' => protocolId,
                        'Name' => 'page' + i,
                        'Syntilio__Title__c' => 'Page ' + i,
                        'Syntilio__Order__c' => i,
                        'Syntilio__JSON__c' => '{}'
                    }
        		)
			);
        }
        return protocolPages;
    }
    private static List<Syntilio__ProtocolPageQuestion__c> createProtocolPageQuestions(List<Syntilio__Question__c> questions, Id protocolPageId) {
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = new List<Syntilio__ProtocolPageQuestion__c>();
        for(Integer i = 1; i <= questions.size(); i++){
            protocolPageQuestions.add(
                Syntilio.CareHubTestDataFactory.createProtocolPageQuestion(
                    new Map<String, Object>{
                        'Syntilio__ProtocolPageId__c' => protocolPageId,
                        'Syntilio__QuestionId__c' => questions[i-1].Id,
                        'Name' => questions[i-1].Name,
                        'Syntilio__Order__c' => i,
                        'Syntilio__JSON__c' => '{}'
                    }
                )
            );
        }
        return protocolPageQuestions;
    }

    private static void createProtocolHandlerTestData() {
        Syntilio__Protocol__c protocol = Syntilio.CareHubTestDataFactory.createProtocol(null);
        
        List<Syntilio__Question__c> questions = createQuestions(3);
        List<SObject> protocolAndQuestions = new List<SObject>();
        protocolAndQuestions.add(protocol);
        protocolAndQuestions.addAll(questions);
        insert protocolAndQuestions;
        
        List<Syntilio__ProtocolPage__c> protocolPages = createProtocolPages(2, protocol.Id);
        insert protocolPages;
        
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = new List<Syntilio__ProtocolPageQuestion__c>();
        protocolPageQuestions.addAll(createProtocolPageQuestions(new List<Syntilio__Question__c>{questions[0]}, protocolPages[0].Id));
        protocolPageQuestions.addAll(createProtocolPageQuestions(new List<Syntilio__Question__c>{questions[1], questions[2]}, protocolPages[1].Id));
		insert protocolPageQuestions;
                
        Syntilio__EventConfiguration__c eventCode = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert eventCode;
        
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Syntilio__Event__c' => eventCode.Id
            }
        );
        
        Syntilio__ProtocolActivator__c protocolActivator = Syntilio.CareHubTestDataFactory.createProtocolActivator(
            new Map<String, Object>{
                'Syntilio__Event__c' => eventCode.Id,
                'Syntilio__Protocol__c' => protocol.Id
            }
        );
        
        insert new List<SObject>{newCase, protocolActivator};
    }
	@testSetup
    static void setupTestData() {
        createProtocolHandlerTestData();
    }
    
    @isTest
    static void getProtocolResultsMapTest(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Id, Syntilio__QuestionId__r.Name FROM Syntilio__ProtocolPageQuestion__c];
        Syntilio__ProtocolResult__c protocolResultToInsert = Syntilio.CareHubTestDataFactory.createProtocolResult(
            new Map<String, Object>{
                'Syntilio__ProtocolId__c' => protocolRecord.Id,
                'Syntilio__CaseId__c' => caseRecord.Id
            }
		);
        insert protocolResultToInsert;
        
        Syntilio__ProtocolPageQuestionResult__c protocolPageQuestionResultToInsert = Syntilio.CareHubTestDataFactory.createProtocolPageQuestionResult(
            new Map<String, Object>{
                'Syntilio__ProtocolResultId__c' => protocolResultToInsert.Id,
                'Syntilio__ProtocolPageQuestionId__c' => protocolPageQuestions[0].Id,
                'Syntilio__Answer__c' => 'Some answer'
            }
		);
        insert protocolPageQuestionResultToInsert;
        
        Test.startTest();
        Map<String, Object> protocolResultsMap = Syntilio.FormFillerHandler.getProtocolResultsMap(protocolRecord.Id, caseRecord.Id);
        Test.stopTest();
        
        System.assertEquals(1, protocolResultsMap.keySet().size());
        System.assertEquals(protocolPageQuestions[0].Syntilio__QuestionId__r.Name, new List<String>(protocolResultsMap.keySet())[0]);
    }
    
    @isTest
    static void getProtocolPageQuestionsMapTest(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Id, Syntilio__QuestionId__r.Name FROM Syntilio__ProtocolPageQuestion__c WHERE Syntilio__ProtocolPageId__r.Syntilio__ProtocolId__c = :protocolRecord.Id ORDER BY Syntilio__Order__c ASC];

        Test.startTest();
        Map<String, Object> protocolPageQuestionsMap = Syntilio.FormFillerHandler.getProtocolPageQuestionsMap(protocolRecord.Id);
        Test.stopTest();
        
        System.assertEquals(protocolPageQuestions.size(), protocolPageQuestionsMap.keySet().size());
        System.assertEquals(protocolPageQuestions[0].Syntilio__QuestionId__r.Name, new List<String>(protocolPageQuestionsMap.keySet())[0]);
    }
    
    @isTest
    static void generateProtocolPageQuestionResultsToInsertTest(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Id, Syntilio__QuestionId__r.Name FROM Syntilio__ProtocolPageQuestion__c];
        Syntilio__ProtocolResult__c protocolResultToInsert = Syntilio.CareHubTestDataFactory.createProtocolResult(
            new Map<String, Object>{
                'Syntilio__ProtocolId__c' => protocolRecord.Id,
                'Syntilio__CaseId__c' => caseRecord.Id
            }
		);
        insert protocolResultToInsert;
        
        Syntilio__ProtocolPageQuestionResult__c protocolPageQuestionResultToInsert = Syntilio.CareHubTestDataFactory.createProtocolPageQuestionResult(
            new Map<String, Object>{
                'Syntilio__ProtocolResultId__c' => protocolResultToInsert.Id,
                'Syntilio__ProtocolPageQuestionId__c' => protocolPageQuestions[0].Id,
                'Syntilio__Answer__c' => 'Some answer'
            }
		);
        insert protocolPageQuestionResultToInsert;

        Map<String, Object> resultBody = new Map<String, Object>{
            'question1' => 'answer 1',
            'question2' => 'answer 2'
        };
            
        Test.startTest();
        List<Syntilio__ProtocolPageQuestionResult__c> protocolPageQuestionResults = Syntilio.FormFillerHandler.generateProtocolPageQuestionResultsToInsert(protocolResultToInsert.Id, protocolRecord.Id, resultBody);
        Test.stopTest();

        System.assertEquals(2, protocolPageQuestionResults.size());
    }
    
    @isTest
    static void setupResultBodyAndRecordsTest(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Id, Syntilio__QuestionId__r.Name FROM Syntilio__ProtocolPageQuestion__c];
        Syntilio__ProtocolResult__c protocolResultToInsert = Syntilio.CareHubTestDataFactory.createProtocolResult(
            new Map<String, Object>{
                'Syntilio__ProtocolId__c' => protocolRecord.Id,
                'Syntilio__CaseId__c' => caseRecord.Id
            }
		);
        insert protocolResultToInsert;
        
        List<Syntilio__ProtocolPageQuestionResult__c> protocolPageQuestionResultsToInsert = new List<Syntilio__ProtocolPageQuestionResult__c>{
            Syntilio.CareHubTestDataFactory.createProtocolPageQuestionResult(
                new Map<String, Object>{
                    'Syntilio__ProtocolResultId__c' => protocolResultToInsert.Id,
                    'Syntilio__ProtocolPageQuestionId__c' => protocolPageQuestions[2].Id,
                    'Syntilio__Answer__c' => 'Some answer'
                }
            ),
            Syntilio.CareHubTestDataFactory.createProtocolPageQuestionResult(
                new Map<String, Object>{
                    'Syntilio__ProtocolResultId__c' => protocolResultToInsert.Id,
                    'Syntilio__ProtocolPageQuestionId__c' => protocolPageQuestions[1].Id,
                    'Syntilio__Answer__c' => 'answer 2'
                }
            )
        };
        insert protocolPageQuestionResultsToInsert;
        
        Map<String, Object> resultBody = new Map<String, Object>{
            'question1' => 'answer 1',
            'question2' => 'answer 2'
        };

        List<Syntilio__ProtocolPageQuestionResult__c> recordsToDelete = new List<Syntilio__ProtocolPageQuestionResult__c>();
        List<Syntilio__ProtocolPageQuestionResult__c> recordsToUpdate = new List<Syntilio__ProtocolPageQuestionResult__c>();
        
        Test.startTest();
		Syntilio.FormFillerHandler.setupResultBodyAndRecords(protocolResultToInsert.Id, resultBody, recordsToDelete,recordsToUpdate);
        Test.stopTest();

        System.assertEquals(1, recordsToDelete.size());
        System.assertEquals(0, recordsToUpdate.size());
    }
    
    @isTest
    static void handlePostFormTest_ResultExists(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Id, Syntilio__QuestionId__r.Name FROM Syntilio__ProtocolPageQuestion__c];

        Syntilio__ProtocolResult__c protocolResultToInsert = Syntilio.CareHubTestDataFactory.createProtocolResult(
            new Map<String, Object>{
                'Syntilio__ProtocolId__c' => protocolRecord.Id,
                'Syntilio__CaseId__c' => caseRecord.Id
            }
		);
        insert protocolResultToInsert;
        
        List<Syntilio__ProtocolPageQuestionResult__c> protocolPageQuestionResultsToInsert = new List<Syntilio__ProtocolPageQuestionResult__c>{
            Syntilio.CareHubTestDataFactory.createProtocolPageQuestionResult(
                new Map<String, Object>{
                    'Syntilio__ProtocolResultId__c' => protocolResultToInsert.Id,
                    'Syntilio__ProtocolPageQuestionId__c' => protocolPageQuestions[2].Id,
                    'Syntilio__Answer__c' => 'Some answer'
                }
            ),
            Syntilio.CareHubTestDataFactory.createProtocolPageQuestionResult(
                new Map<String, Object>{
                    'Syntilio__ProtocolResultId__c' => protocolResultToInsert.Id,
                    'Syntilio__ProtocolPageQuestionId__c' => protocolPageQuestions[1].Id,
                    'Syntilio__Answer__c' => 'answer 2'
                }
            )
        };
        insert protocolPageQuestionResultsToInsert;

        String resultBody = '{"question1": "answer 1", "question2": "answer 2"}';
            
        Test.startTest();
		String result = Syntilio.FormFillerHandler.handlePostForm(resultBody, protocolRecord.Id, caseRecord.Id);
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(result);

        System.assertEquals(true, response.isSuccess);
    }
    
    @isTest
    static void handlePostFormTest_ResultDoesNotExist(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();
        
        String resultBody = '{"question1": "answer 1", "question2": "answer 2"}';
        
        Test.startTest();
		String result = Syntilio.FormFillerHandler.handlePostForm(resultBody, protocolRecord.Id, caseRecord.Id);
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(result);

        System.assertEquals(true, response.isSuccess);
    }
    
	@isTest
    static void handlePostForm_BadRequestBody_Test(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();
        
        String resultBody = '"question1": "answer 1", "question2": "answer 2"}';
        
        Test.startTest();
		String result = Syntilio.FormFillerHandler.handlePostForm(resultBody, protocolRecord.Id, caseRecord.Id);
        Test.stopTest();

        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(result);
        
        System.assertEquals(false, response.isSuccess);
    }
}