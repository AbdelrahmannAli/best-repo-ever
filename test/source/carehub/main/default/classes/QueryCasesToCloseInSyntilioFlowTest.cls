@isTest
public with sharing class QueryCasesToCloseInSyntilioFlowTest {
    
    private static Contact getContact() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    private static Case getCase() {
        return [SELECT Id, ContactId FROM Case LIMIT 1];
    }
    
    private static Syntilio__EventConfiguration__c getEventConfiguration() {
        return [SELECT Id, Syntilio__CloseEventCodes__c FROM Syntilio__EventConfiguration__c LIMIT 1];
    }
    
    private static Syntilio__ExternalId__c getExternalId() {
        return [SELECT Syntilio__Id__c FROM Syntilio__ExternalId__c LIMIT 1];
    }
    
    private static void createDataHubSynchronisationTestData(){
        Account accountRecord = Syntilio.CareHubTestDataFactory.createAccount(null);
        Syntilio__ExternalSystem__c externalSystemRecord = Syntilio.DataHubTestDataFactory.createExternalSystem(null);
        insert new List<SObject>{accountRecord, externalSystemRecord};

        Contact contactRecord = Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{'AccountId' => accountRecord.Id});
        Syntilio__AccountExternalSystemAssociation__c accountExternalSystemAssociationRecord = Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation(
            new Map<String, Object>{
                'Syntilio__AccountId__c' => accountRecord.Id,
                'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
            }
        );
        insert new List<SObject>{contactRecord, accountExternalSystemAssociationRecord};
            
        Syntilio__ExternalId__c externalIdRecord = Syntilio.DataHubTestDataFactory.createExternalId(
                new Map<String, Object>{
                    'Name' => 'clientId',
                    'Syntilio__Id__c' => '1',
                    'Syntilio__ContactId__c' => contactRecord.Id,
                    'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
                }
        );
        insert externalIdRecord;
    }
    
    @testSetup
    static void setup() {
        createDataHubSynchronisationTestData();
        
        Contact contactRecord = getContact();
        
        Syntilio__EventConfiguration__c eventConfiguration = Syntilio.CareHubTestDataFactory.createEventConfiguration(
            new Map<String, Object>{
                'Syntilio__CaseAction__c' => 'Close',
				'Syntilio__CloseEventCodes__c' => '1112',
				'Syntilio__Code__c' => 1112
            }
        );
        insert eventConfiguration;
        
        Case caseRecord = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'ContactId' => contactRecord.Id,
                'Syntilio__Event__c' => eventConfiguration.Id
            }
        );
        insert caseRecord;
    }
    
    @isTest
    static void queryCasesToCloseInSyntilioFlowTest_ShouldFindResults() {
        Syntilio__EventConfiguration__c mockCloseEventConfigurationCustomMetadata = getEventConfiguration();
        Case caseRecord = getCase();
        Contact contactRecord = getContact();
        Syntilio__ExternalId__c externalIdRecord = getExternalId();

        List<Syntilio.QueryCasesToCloseInSyntilioFlow.InputVariables> queryCasesToCloseInSyntilioFlowInputVariablesList = new List<Syntilio.QueryCasesToCloseInSyntilioFlow.InputVariables>();
        Syntilio.QueryCasesToCloseInSyntilioFlow.InputVariables queryCasesToCloseInSyntilioFlowInputVariablesRecord = new Syntilio.QueryCasesToCloseInSyntilioFlow.InputVariables();
        queryCasesToCloseInSyntilioFlowInputVariablesRecord.eventConfigurationRecord = mockCloseEventConfigurationCustomMetadata;
        queryCasesToCloseInSyntilioFlowInputVariablesRecord.userId = externalIdRecord.Syntilio__Id__c;
        queryCasesToCloseInSyntilioFlowInputVariablesRecord.assetId = null;
        queryCasesToCloseInSyntilioFlowInputVariablesList.add(queryCasesToCloseInSyntilioFlowInputVariablesRecord);

        Test.startTest();
        List<Syntilio.QueryCasesToCloseInSyntilioFlow.OutputVariables> queryCasesToCloseInSyntilioFlowOutputVariablesList = Syntilio.QueryCasesToCloseInSyntilioFlow.execute(queryCasesToCloseInSyntilioFlowInputVariablesList);
        Test.stopTest();
        
        System.assertEquals(caseRecord.Id, queryCasesToCloseInSyntilioFlowOutputVariablesList[0].caseRecordsCollection[0].Id);
    }
    
    @isTest
    static void queryCasesToCloseInSyntilioFlowTest_Excecption() {
        List<Syntilio.QueryCasesToCloseInSyntilioFlow.InputVariables> queryCasesToCloseInSyntilioFlowInputVariablesList = new List<Syntilio.QueryCasesToCloseInSyntilioFlow.InputVariables>();
		queryCasesToCloseInSyntilioFlowInputVariablesList.add(null);

        Test.startTest();
        List<Syntilio.QueryCasesToCloseInSyntilioFlow.OutputVariables> queryCasesToCloseInSyntilioFlowOutputVariablesList = Syntilio.QueryCasesToCloseInSyntilioFlow.execute(queryCasesToCloseInSyntilioFlowInputVariablesList);        
        Test.stopTest(); 

        System.assertEquals(true, queryCasesToCloseInSyntilioFlowOutputVariablesList[0].caseRecordsCollection.isEmpty());
    }
   

    @isTest
    static void queryCasesToCloseInSyntilioFlowTest_Null() {
        List<Syntilio.QueryCasesToCloseInSyntilioFlow.OutputVariables> queryCasesToCloseInSyntilioFlowOutputVariablesList;

        Test.startTest();
        queryCasesToCloseInSyntilioFlowOutputVariablesList = Syntilio.QueryCasesToCloseInSyntilioFlow.execute(null);        
        Test.stopTest(); 

        System.assertEquals(null, queryCasesToCloseInSyntilioFlowOutputVariablesList);    
    }
}