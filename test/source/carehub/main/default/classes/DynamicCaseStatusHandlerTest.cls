@isTest
public with sharing class DynamicCaseStatusHandlerTest {
    
    private static Case getCase() {
        return [SELECT Id, Status FROM Case LIMIT 1];
    }
    
    private static Syntilio__EventConfiguration__c getEventConfiguration() {
        return [SELECT Id FROM Syntilio__EventConfiguration__c LIMIT 1];
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
    
    private static void createProtocols() {
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
        
        Syntilio__EventConfiguration__c eventCode = getEventConfiguration();
        Syntilio__ProtocolActivator__c protocolActivator = Syntilio.CareHubTestDataFactory.createProtocolActivator(
            new Map<String, Object>{
                'Syntilio__Event__c' => eventCode.Id,
                'Syntilio__Protocol__c' => protocol.Id
            }
        );
        
        insert new List<SObject>{protocolActivator};
    }

    @testSetup
    public static void setupTestData() {
        
        Account newAccount = Syntilio.CareHubTestDataFactory.createAccount(null);
        insert newAccount;
        
        Contact newContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'AccountId' => newAccount.Id
			}
        );
        insert newContact;
        
        Syntilio__EventConfiguration__c eventCode = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert eventCode;
        
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'AccountId' => newAccount.Id,
				'ContactId' => newContact.Id,
                'Syntilio__Event__c' => eventCode.Id
            }
        );
        insert newCase;
    }

    @isTest
    public static void updateCaseTest_NotClosed() {
        Case caseRecord = getCase();

        Test.startTest();
        caseRecord.Status = 'Working';
        update caseRecord;
        Test.stopTest();
        
        List<Case> caseListAfter = [
            SELECT Id, Status
            FROM Case
            WHERE Status = 'Working'
        ];
        
        System.assertEquals(true, caseListAfter.size() > 0, 'Case status was not updated to Working');
    }

    @isTest
    public static void updateCaseTest_ClosedSuccess() {
        Case caseRecord = getCase();
		
        Test.startTest();
        caseRecord.Status = 'Closed';
        update caseRecord;
        Test.stopTest();
        
        List<Case> caseListAfter = [
            SELECT Id, Status
            FROM Case
            WHERE Status = 'Closed'
        ];
        System.assertEquals(caseListAfter.size() > 0, true, 'Case status was not updated to Closed');
    }

    @isTest
    public static void updateCaseTest_ClosedFailure() {
        createProtocols();
        Case caseRecord = getCase();

        Test.startTest();
        try{
            caseRecord.Status = 'Closed';
            update caseRecord;
        } catch(Exception e){
            System.assert(e.getMessage().contains('There are still unfinished protocols. Please completed them before closing the case.'));
        }
        Test.stopTest();
    }
}