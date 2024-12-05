@isTest
public with sharing class FormBuilderHandlerTest {
    private static Syntilio__Protocol__c getProtocol() {
        return [SELECT Id FROM Syntilio__Protocol__c LIMIT 1];
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
    static void setupPagesToUpsertTest(){
		Syntilio__Protocol__c protocolRecord = getProtocol();
        List<Map<String, Object>> bodyPages = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => 'page1',
                'title' => 'Page 1 Title',
                'elements' => '[]'
            }
        };
            
        Test.startTest();
        List<Syntilio__ProtocolPage__c> protocolPages = Syntilio.FormBuilderHandler.setupPagesToUpsert(bodyPages, protocolRecord.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, protocolPages.size());
        System.assertEquals('Page 1 Title', protocolPages[0].Syntilio__Title__c);
    }

    @isTest
    static void setupQuestionsToUpsertTest(){
        List<Map<String, Object>> bodyPages = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => 'page1',
                'title' => 'Page 1 Title',
                'elements' => new List<Map<String, Object>>{
            		new Map<String, Object>{
                        'name' => 'question1', 
                        'title' => 'Question 1 Title', 
                        'type' => 'text',
                        'choices' => '[]'
                    }
                }
            },
            new Map<String, Object>{
                'name' => 'page1',
                'title' => 'Page 1 Title'
            }
        };
            
       	Test.startTest();
        List<Syntilio__Question__c> questions = Syntilio.FormBuilderHandler.setupQuestionsToUpsert(bodyPages);
        Test.stopTest();
        
        System.assertNotEquals(0, questions.size());
        System.assertEquals('Question 1 Title', questions[0].Syntilio__Title__c);
        System.assertEquals('text', questions[0].Syntilio__QuestionType__c);
    }

    @isTest
    static void setupProtocolPageQuestionsToUpsertTest(){
        List<Map<String, Object>> bodyPages = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => 'page1',
                'title' => 'Page 1 Title',
                'elements' => new List<Map<String, Object>>{
            		new Map<String, Object>{
                        'name' => 'question1', 
                        'title' => 'Question 1 Title', 
                        'type' => 'text'
                    }
                }
            },
            new Map<String, Object>{
                'name' => 'page2',
                'title' => 'Page 2 Title'
            }
        };
		List<Syntilio__ProtocolPage__c> protocolPages = [SELECT Id FROM Syntilio__ProtocolPage__c];
        
		Test.startTest();	
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = Syntilio.FormBuilderHandler.setupProtocolPageQuestionsToUpsert(bodyPages, protocolPages);
        Test.stopTest();
        
        System.assertEquals(1, protocolPageQuestions.size());
    }

    @isTest
    static void getProtocolPageQuestionsToDeleteTest(){
        List<Syntilio__ProtocolPage__c> protocolPages = [SELECT Id FROM Syntilio__ProtocolPage__c];
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Id FROM Syntilio__ProtocolPageQuestion__c WHERE Syntilio__ProtocolPageId__c = :protocolPages[1].Id];
        List<Id> protocolPageQuestionIds = Syntilio.DataHubUtilities.sObjectListToIdList(new List<Syntilio__ProtocolPageQuestion__c>{protocolPageQuestions[0]});
        
        Test.startTest();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestionsToDelete = Syntilio.FormBuilderHandler.getProtocolPageQuestionsToDelete(protocolPageQuestionIds, protocolPages[1].Id);
        Test.stopTest();
        
        System.assertEquals(1, protocolPageQuestionsToDelete.size());
    }

    @isTest
    static void getProtocolPagesToDeleteTest(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        List<Syntilio__ProtocolPage__c> protocolPages = [SELECT Id FROM Syntilio__ProtocolPage__c WHERE Syntilio__ProtocolId__c = :protocolRecord.Id];
        List<Id> protocolPageIds = Syntilio.DataHubUtilities.sObjectListToIdList(new List<Syntilio__ProtocolPage__c>{protocolPages[0]});
        
        Test.startTest();
        List<Syntilio__ProtocolPage__c> protocolPagesToDelete = Syntilio.FormBuilderHandler.getProtocolPagesToDelete(protocolPageIds, protocolRecord.Id);
        Test.stopTest();
        
        System.assertEquals(1, protocolPagesToDelete.size());
    }
 
    @isTest
    static void handleGetForm_Success_Test(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        
        Test.startTest();
        String protocolsFromGet = Syntilio.FormBuilderHandler.handleGetForm(protocolRecord.Id);
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(protocolsFromGet);
        
        System.assertEquals(true, response.isSuccess);
    }
    
    @isTest
    static void handleGetFormTest_Failure(){
        Test.startTest();
        String protocolsFromGet = Syntilio.FormBuilderHandler.handleGetForm('someid');
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(protocolsFromGet);
        
        System.assertEquals(false, response.isSuccess);
    }
    
    @isTest
    static void handlePostFormTest_NoSurvey(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        String bodyString = '{"key":"value"}';
        
        Test.startTest();
        String protocolsFromPost = Syntilio.FormBuilderHandler.handlePostForm(bodyString, protocolRecord.Id);
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(protocolsFromPost);
        
        System.assertEquals(false, response.isSuccess);        
        System.assertEquals('Forms must have at least 1 page.', response.message);
    }
    
    @isTest
    static void handlePostFormTest_NoPages(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        String bodyString = '{"pages": []}';
        
        Test.startTest();
        String protocolsFromPost = Syntilio.FormBuilderHandler.handlePostForm(bodyString, protocolRecord.Id);
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(protocolsFromPost);
        
        System.assertEquals(false, response.isSuccess);      
        System.assertEquals('Forms must have at least 1 page.', response.message);
    }
    
    @isTest
    static void handlePostFormTest_ProtocolNotFound(){
        String bodyString = '{"pages": [{"name": "page1"}]}';
        
        Test.startTest();
        String protocolsFromPost = Syntilio.FormBuilderHandler.handlePostForm(bodyString, 'someid');
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(protocolsFromPost);
        
        System.assertEquals(false, response.isSuccess);      
        System.assertEquals('Protocol not found someid', response.message);
    }
    
    @isTest
    static void handlePostFormTest_BadRequestBody(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        String bodyString = '"pages: [{name: page1,elements: [{name:question1}]}]"}';
        
        Test.startTest();
        String protocolsFromPost = Syntilio.FormBuilderHandler.handlePostForm(bodyString, protocolRecord.Id);
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(protocolsFromPost);
        
        System.assertEquals(false, response.isSuccess);
    }
    
    @isTest
    static void handlePostFormTest_Success(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        String bodyString = '{"pages": [{"name": "page1","elements": [{"name":"question1"}]}]}';
        
        Test.startTest();
        String protocolsFromPost = Syntilio.FormBuilderHandler.handlePostForm(bodyString, protocolRecord.Id);
        Test.stopTest();
        
        Syntilio.ResponseMessage response = Syntilio.ResponseMessage.deserialize(protocolsFromPost);
        
        System.assertEquals(true, response.isSuccess);
    }
}