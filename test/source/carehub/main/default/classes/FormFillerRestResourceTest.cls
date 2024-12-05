@isTest
public with sharing class FormFillerRestResourceTest {

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
    static void onGetFormTest_Success(){
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

        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormFiller?protocolId=' + protocolRecord.Id + '&caseId=' + caseRecord.Id;
        restRequest.httpMethod = 'GET';
        restRequest.params.put('protocolId', protocolRecord.Id);
        restRequest.params.put('caseId', caseRecord.Id);

        RestContext.request = restRequest;
        RestContext.response = restResponse;

        Test.startTest();
        Syntilio.FormFillerRestResource.onGetForm();
        Test.stopTest(); 

        System.assertEquals(200, restResponse.statusCode);
    }

    @isTest
    static void onGetForm_Failure_Test(){
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormFiller';
        restRequest.httpMethod = 'GET';

        RestContext.request = restRequest;
        RestContext.response= restResponse;

        Test.startTest();
        Syntilio.FormFillerRestResource.onGetForm();
        Test.stopTest(); 

        System.assertEquals(400, restResponse.statusCode);
    }

    @isTest
    static void onPostForm_Success_Test(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();

        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormFiller?protocolId=' + protocolRecord.Id + '&caseId=' + caseRecord.Id;
        restRequest.httpMethod = 'POST';
        restRequest.params.put('protocolId', protocolRecord.Id);
        restRequest.params.put('caseId', caseRecord.Id);
        restRequest.requestBody = Blob.valueOf('{"question1": "answer 1","question2": "answer 2"}');

        RestContext.request = restRequest;
        RestContext.response = restResponse;

        Test.startTest();
        Syntilio.FormFillerRestResource.onPostForm();
        Test.stopTest(); 

        System.assertEquals(200, restResponse.statusCode);
    }

    @isTest
    static void onPostForm_Failure_Test(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        Case caseRecord = getCase();

        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormFiller?protocolId=' + protocolRecord.Id + '&caseId=' + caseRecord.Id;
        restRequest.httpMethod = 'POST';
        restRequest.params.put('protocolId', protocolRecord.Id);
        restRequest.params.put('caseId', caseRecord.Id);
        restRequest.requestBody = Blob.valueOf('"question1": "answer 1","question2": "answer 2"}');

        RestContext.request = restRequest;
        RestContext.response = restResponse;

        Test.startTest();
        Syntilio.FormFillerRestResource.onPostForm();
        Test.stopTest(); 

        System.assertEquals(400, restResponse.statusCode);
    }
}