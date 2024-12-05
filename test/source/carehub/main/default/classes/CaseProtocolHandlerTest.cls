@isTest
public with sharing class CaseProtocolHandlerTest {
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
    public static void getProtocols_Test() {
        Case caseRecord = getCase();
        
        Test.startTest();
        List<Object> protocolsList =  Syntilio.CaseProtocolHandler.getProtocols(caseRecord.Id);
        Test.stopTest();
        
        System.assertEquals(1, protocolsList.size());
    }
    
    @isTest
    static void getProtocolById_Test(){
        List<Syntilio__Protocol__c> protocols = [SELECT Syntilio__JSON__c FROM Syntilio__Protocol__c];
        System.assertNotEquals(0, protocols.size());
        
        Test.startTest();
        Syntilio__Protocol__c protocolFound = Syntilio.CaseProtocolHandler.getProtocolById(protocols[0].Id);
        Test.stopTest();
        
        System.assertEquals(protocols[0].Syntilio__JSON__c, protocolFound.Syntilio__JSON__c);
    }
    
    @isTest
    static void getPagesList_Test(){        
        List<Syntilio__ProtocolPage__c> protocolPages = [SELECT Name, Syntilio__ProtocolId__c FROM Syntilio__ProtocolPage__c ORDER BY Syntilio__Order__c ASC];
        System.assertNotEquals(0, protocolPages.size());
        
        Test.startTest();
        List<Map<String, Object>> protocolPagesFound = Syntilio.CaseProtocolHandler.getProtocolPagesListByProtocol(protocolPages[0].Syntilio__ProtocolId__c);
        Test.stopTest();
        
        System.assertNotEquals(0, protocolPagesFound.size());
        System.assertEquals(protocolPages[0].Name, protocolPagesFound[0].get('name'));
    }
    
    @isTest
    static void getProtocolPageQuestionsList_Test(){
        List<Syntilio__ProtocolPage__c> protocolPages = [SELECT Name FROM Syntilio__ProtocolPage__c ORDER BY Syntilio__Order__c ASC];
        System.assertNotEquals(0, protocolPages.size());
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Name FROM Syntilio__ProtocolPageQuestion__c WHERE Syntilio__ProtocolPageId__c = :protocolPages[0].Id ORDER BY Syntilio__Order__c ASC];
        System.assertNotEquals(0, protocolPageQuestions.size());
        
        Test.startTest();
        List<Map<String, Object>> protocolPageQuestionsFound = Syntilio.CaseProtocolHandler.getProtocolPageQuestionsListByPage(protocolPages[0].Id);
        Test.stopTest();
        
        System.assertNotEquals(0, protocolPageQuestionsFound.size());
        System.assertEquals(protocolPageQuestions[0].Name, protocolPageQuestionsFound[0].get('name'));
    }
    
    @isTest
    static void getProtocolPageByName_Found_Test(){
        List<Syntilio__ProtocolPage__c> protocolPages = [SELECT Name, Syntilio__ProtocolId__c FROM Syntilio__ProtocolPage__c ORDER BY Syntilio__Order__c ASC];
        System.assertNotEquals(0, protocolPages.size());
        
        Test.startTest();
        Syntilio__ProtocolPage__c protocolPageFound = Syntilio.CaseProtocolHandler.getProtocolPageByName(protocolPages[0].Name, protocolPages[0].Syntilio__ProtocolId__c);
        Test.stopTest();
        
        System.assertNotEquals(null, protocolPageFound);
        System.assertEquals(protocolPages[0].Id, protocolPageFound.Id);
    }
    
    @isTest
    static void getProtocolPageByName_Created_Test(){
        List<Syntilio__Protocol__c> protocols = [SELECT Name FROM Syntilio__Protocol__c];
        System.assertNotEquals(0, protocols.size());
        
        Test.startTest();
        Syntilio__ProtocolPage__c protocolPageFound = Syntilio.CaseProtocolHandler.getProtocolPageByName('New Page', protocols[0].Id);
        Test.stopTest();
        
        System.assertNotEquals(null, protocolPageFound);
        System.assertEquals('New Page', protocolPageFound.Name);
    }
    
    @isTest
    static void getProtocolPageQuestionByName_Found_Test(){
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Name, Syntilio__ProtocolPageId__c FROM Syntilio__ProtocolPageQuestion__c ORDER BY Syntilio__Order__c ASC];
        System.assertNotEquals(0, protocolPageQuestions.size());
        
        Test.startTest();
        Syntilio__ProtocolPageQuestion__c protocolPageQuestionFound = Syntilio.CaseProtocolHandler.getProtocolPageQuestionByName(protocolPageQuestions[0].Name, protocolPageQuestions[0].Syntilio__ProtocolPageId__c);
        Test.stopTest();
        
        System.assertNotEquals(null, protocolPageQuestionFound);
        System.assertEquals(protocolPageQuestions[0].Id, protocolPageQuestionFound.Id);
    }
    
    @isTest
    static void getProtocolPageQuestionByName_Created_Test(){
        List<Syntilio__ProtocolPage__c> protocolPages = [SELECT Name FROM Syntilio__ProtocolPage__c ORDER BY Syntilio__Order__c ASC];
        System.assertNotEquals(0, protocolPages.size());
        
        Test.startTest();
        Syntilio__ProtocolPageQuestion__c protocolPageQuestionFound = Syntilio.CaseProtocolHandler.getProtocolPageQuestionByName('New Page Question', protocolPages[0].Id);
        Test.stopTest();
        
        System.assertNotEquals(null, protocolPageQuestionFound);
        System.assertEquals('New Page Question', protocolPageQuestionFound.Name);
    }
    
    @isTest
    static void getQuestionByName_Found_Test(){
        List<Syntilio__Question__c> questions = [SELECT Name FROM Syntilio__Question__c];
        System.assertNotEquals(0, questions.size());
        
        Test.startTest();
        Syntilio__Question__c questionFound = Syntilio.CaseProtocolHandler.getQuestionByName(questions[0].Name);
        Test.stopTest();
        
        System.assertNotEquals(null, questionFound);
        System.assertEquals(questions[0].Id, questionFound.Id);
    }
    
    @isTest
    static void getQuestionByName_Created_Test(){
        Test.startTest();
        Syntilio__Question__c questionFound = Syntilio.CaseProtocolHandler.getQuestionByName('New Question');
        Test.stopTest();
        
        System.assertNotEquals(null, questionFound);
        System.assertEquals('New Question', questionFound.Name);
    }
    
    
    @isTest
    static void getProtocolResults_Test(){
        List<Syntilio__Protocol__c> protocols = [SELECT Id FROM Syntilio__Protocol__c];
        List<Case> cases = [SELECT Id FROM Case];
        List<Syntilio__ProtocolResult__c> protocolResultsToInsert = new List<Syntilio__ProtocolResult__c>{
            new Syntilio__ProtocolResult__c(
                Syntilio__ProtocolId__c = protocols[0].Id,
                Syntilio__CaseId__c = cases[0].Id
            ),
            new Syntilio__ProtocolResult__c(
                Syntilio__ProtocolId__c = protocols[0].Id
            )
        };
        insert protocolResultsToInsert;
        
        Test.startTest();
        List<Syntilio__ProtocolResult__c> protocolResults = Syntilio.CaseProtocolHandler.getProtocolResults(protocols[0].Id, cases[0].Id);
        System.assertEquals(1, protocolResults.size());
        Test.stopTest();
    }
    
    @isTest
    static void getProtocolPageQuestionsByProtocol_Test(){
        List<Syntilio__Protocol__c> protocols = [SELECT Id FROM Syntilio__Protocol__c];
        
        Test.startTest();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = Syntilio.CaseProtocolHandler.getProtocolPageQuestionsByProtocol(protocols[0].Id);
        System.assertEquals(3, protocolPageQuestions.size());
        Test.stopTest();
    }


    @isTest
    static void deleteProtocol_Test(){
        List<Syntilio__Protocol__c> protocols = [SELECT Id FROM Syntilio__Protocol__c];
        List<Case> cases = [SELECT Id FROM Case];
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [SELECT Id, Syntilio__QuestionId__r.Name FROM Syntilio__ProtocolPageQuestion__c];

        Syntilio__ProtocolResult__c protocolResultToInsert = new Syntilio__ProtocolResult__c(
            Syntilio__ProtocolId__c = protocols[0].Id,
            Syntilio__CaseId__c = cases[0].Id
		);
        insert protocolResultToInsert;
        
        List<Syntilio__ProtocolPageQuestionResult__c> protocolPageQuestionResultsToInsert = new List<Syntilio__ProtocolPageQuestionResult__c>{
            new Syntilio__ProtocolPageQuestionResult__c(
                Syntilio__ProtocolResultId__c = protocolResultToInsert.Id,
                Syntilio__ProtocolPageQuestionId__c = protocolPageQuestions[2].Id,
                Syntilio__Answer__c = 'Some answer'
            ),
            new Syntilio__ProtocolPageQuestionResult__c(
                Syntilio__ProtocolResultId__c = protocolResultToInsert.Id,
                Syntilio__ProtocolPageQuestionId__c = protocolPageQuestions[1].Id,
                Syntilio__Answer__c = 'Some other answer'
            )
        };
        insert protocolPageQuestionResultsToInsert;

        
        Test.startTest();
        delete protocols[0];    
        Test.stopTest(); 

        List<Syntilio__Protocol__c> protocolsAfter = [SELECT Id FROM Syntilio__Protocol__c];
        List<Syntilio__ProtocolPage__c> protocolPagesAfter = [SELECT Id FROM Syntilio__ProtocolPage__c];
        List<Syntilio__ProtocolResult__c> protocolResultsAfter = [SELECT Id FROM Syntilio__ProtocolResult__c];
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestionsAfter = [SELECT Id FROM Syntilio__ProtocolPageQuestion__c];
        
        System.assertEquals(0, protocolsAfter.size());
        System.assertEquals(0, protocolPagesAfter.size());
        System.assertEquals(0, protocolResultsAfter.size());
        System.assertEquals(0, protocolPageQuestionsAfter.size());
    }


    @isTest
    public static void checkFlowApiNameTest() {
        String flowApiNameFound = 'runtime_appointmentbooking__Out_Modify';
        String flowApiNameNotFound = 'dummy';
        List<FlowDefinitionView> activeFlows = [
            SELECT ApiName
            FROM FlowDefinitionView
            WHERE IsActive = true
            WITH SECURITY_ENFORCED
        ];
            
        if(activeFlows.size()== 0){
            System.assertEquals(0, activeFlows.size());  
        }

        Test.startTest();
        boolean flowFound =  Syntilio.CaseProtocolHandler.checkFlowApiName(activeFlows[0].ApiName);
        boolean flowNotFound =  Syntilio.CaseProtocolHandler.checkFlowApiName(flowApiNameNotFound);
        Test.stopTest();

        System.assertEquals(true, flowFound);
        System.assertEquals(false, flowNotFound);

    }

}