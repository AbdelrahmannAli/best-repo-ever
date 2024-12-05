@isTest
public with sharing class QueryErrorCodeLanguageInSyntilioFlowTest {
    
    @isTest
    static void queryErrorCodeLanguageInSyntilioFlowTest_ShouldFindResults() {
        Syntilio__ErrorCodeConfiguration__mdt mockErrorCodeConfigurationCustomMetadataRecord = new Syntilio__ErrorCodeConfiguration__mdt(
            MasterLabel = 'Flow Error 0001',
            DeveloperName = 'FLE0001',
            Syntilio__Description_de_DE__c = '',
            Syntilio__Description_en_GB__c = 'We could not find this event configuration in your org, please contact your system administrator with the event code to check the custom metadata.',
            Syntilio__Description_fr_FR__c = '',
            Syntilio__Description_nl_NL__c = ''
        );
                
        Syntilio.IErrorCodeConfigurationCustomMetadata errorCodeConfigurationCustomMetadata = new Syntilio.MockErrorCodeConfigurationCustomMetadata(mockErrorCodeConfigurationCustomMetadataRecord);
        QueryErrorCodeLanguageInSyntilioFlow.errorCodeConfigurationCustomMetadata = errorCodeConfigurationCustomMetadata;
        
        List<Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables> queryErrorCodeLanguageInSyntilioFlowInputVariablesList = new List<Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables>();
        Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord = new Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables();
        queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord.selectedErrorCodeLanguageApiNameFormula = 'Syntilio__Description_en_GB__c';
        queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord.taskIssueReasonMappedToFlowErrorCodes = mockErrorCodeConfigurationCustomMetadataRecord.DeveloperName;
        queryErrorCodeLanguageInSyntilioFlowInputVariablesList.add(queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord);
        
        Test.startTest();
        List<QueryErrorCodeLanguageInSyntilioFlow.OutputVariables> queryErrorCodeLanguageInSyntilioFlowOutputVariablesList = Syntilio.QueryErrorCodeLanguageInSyntilioFlow.execute(queryErrorCodeLanguageInSyntilioFlowInputVariablesList);
        Test.stopTest();
        
        System.assertEquals('We could not find this event configuration in your org, please contact your system administrator with the event code to check the custom metadata.', queryErrorCodeLanguageInSyntilioFlowOutputVariablesList[0].taskReasonDescriptionWithSelectedLanguageVariable);
    }

    @isTest
    static void queryErrorCodeLanguageInSyntilioFlowTest_Exception() {
        List<Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables> queryErrorCodeLanguageInSyntilioFlowInputVariablesList = new List<Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables>();
        Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord = new Syntilio.QueryErrorCodeLanguageInSyntilioFlow.InputVariables();
        queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord.selectedErrorCodeLanguageApiNameFormula = null;
        queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord.taskIssueReasonMappedToFlowErrorCodes = 'Test';
        queryErrorCodeLanguageInSyntilioFlowInputVariablesList.add(queryErrorCodeLanguageInSyntilioFlowInputVariablesRecord);
        
        Test.startTest();
        List<Syntilio.QueryErrorCodeLanguageInSyntilioFlow.OutputVariables> queryErrorCodeLanguageInSyntilioFlowOutputVariablesList = Syntilio.QueryErrorCodeLanguageInSyntilioFlow.execute(queryErrorCodeLanguageInSyntilioFlowInputVariablesList);
        Test.stopTest();
        
        System.assertEquals(null, queryErrorCodeLanguageInSyntilioFlowOutputVariablesList[0].taskReasonDescriptionWithSelectedLanguageVariable);
    }

    @isTest
    static void queryErrorCodeLanguageInSyntilioFlow_Should_ReturnNull_Test() {
        
        Test.startTest();
        List<Syntilio.QueryErrorCodeLanguageInSyntilioFlow.OutputVariables> queryErrorCodeLanguageInSyntilioFlowOutputVariablesList = Syntilio.QueryErrorCodeLanguageInSyntilioFlow.execute(null);        
        Test.stopTest(); 
        
        System.assertEquals(null, queryErrorCodeLanguageInSyntilioFlowOutputVariablesList);    
    }

}