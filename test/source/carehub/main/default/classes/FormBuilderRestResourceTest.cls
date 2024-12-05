@isTest
public with sharing class FormBuilderRestResourceTest {
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
    static void onGetFormTest_Success(){
        Syntilio__Protocol__c protocolRecord = getProtocol();

        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormBuilder/' + protocolRecord.Id;
        restRequest.httpMethod = 'GET';

        RestContext.request = restRequest;
        RestContext.response= restResponse;

        Test.startTest();
        Syntilio.FormBuilderRestResource.onGetForm();
        Test.stopTest(); 

        System.assertEquals(200, restResponse.statusCode);
    }

    @isTest
    static void onGetFormTest_Failure(){
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormBuilder/someid';
        restRequest.httpMethod = 'GET';

        RestContext.request = restRequest;
        RestContext.response = restResponse;

        Test.startTest();
        Syntilio.FormBuilderRestResource.onGetForm();
        Test.stopTest(); 

        System.assertEquals(400, restResponse.statusCode);
    }

    @isTest
    static void onPostForm_Success_Test(){
        Syntilio__Protocol__c protocolRecord = getProtocol();

        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormBuilder/' + protocolRecord.Id;
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf('{"pages": [{"name": "page1","elements": [{"name":"question1"}]}]}');

        RestContext.request = restRequest;
        RestContext.response = restResponse;

        Test.startTest();
        Syntilio.FormBuilderRestResource.onPostForm();
        Test.stopTest(); 

        System.assertEquals(200, restResponse.statusCode);
    }


    @isTest
    static void onPostForm_Failure_Test(){
        Syntilio__Protocol__c protocolRecord = getProtocol();
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/FormBuilder/' + protocolRecord.Id;
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf('"pages": [{"name": "page1","elements": [{"name":"question1"}]}]}');

        RestContext.request = restRequest;
        RestContext.response= restResponse;

        Test.startTest();
        Syntilio.FormBuilderRestResource.onPostForm();
        Test.stopTest(); 

        System.assertEquals(400, restResponse.statusCode);
    }
}