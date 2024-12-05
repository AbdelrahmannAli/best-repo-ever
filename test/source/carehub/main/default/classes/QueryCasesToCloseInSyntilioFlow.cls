@namespaceAccessible
public with sharing class QueryCasesToCloseInSyntilioFlow {
    
    @invocableMethod(label='Convert All Open Cases on Event Code to Record Collection')
    public static List<OutputVariables> execute (List<InputVariables> inputVariables) {
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        List<Case> allOpenCasesOnEventCodeToClose = new List<Case>();
        if(inputVariables == null)
            return null;
        
        for(InputVariables inputVariable : inputVariables){
            try {                
                String externalIdRecordName = '%clientId';
                List<String> splitCloseEventCodesStringList = new List<String>(inputVariable.eventConfigurationRecord.Syntilio__CloseEventCodes__c.split(';'));
                List<Decimal> splitCloseEventCodesCastedToDecimalList = new List<Decimal>(Syntilio.DataHubUtilities.castStringArrayToDecimalArray(splitCloseEventCodesStringList));
                List<Syntilio__EventConfiguration__c> eventConfigurationList = new List<Syntilio__EventConfiguration__c>([SELECT Id, Syntilio__Code__c FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c IN: splitCloseEventCodesCastedToDecimalList WITH SECURITY_ENFORCED]);
                
                List<String> statusList = new List<String>{'Closed', 'AutoClosed', 'ClosedByDevice'}; //needs to be enum
                allOpenCasesOnEventCodeToClose = !String.isBlank(inputVariable.assetId) ? ([SELECT Id FROM Case WHERE Syntilio__Event__c IN: eventConfigurationList AND Syntilio__AssetId__c =: inputVariable.assetId AND Status NOT IN: statusList WITH SECURITY_ENFORCED]) : !String.isBlank(inputVariable.userId) ? ([SELECT Id FROM Case WHERE Syntilio__Event__c IN: eventConfigurationList AND ContactId =: ([SELECT Syntilio__ContactId__c FROM Syntilio__ExternalId__c WHERE Syntilio__Id__c =: inputVariable.userId AND Name LIKE :externalIdRecordName AND Syntilio__RelatedSalesforceInternalId__c = null LIMIT 1].Syntilio__ContactId__c) AND Status NOT IN: statusList WITH SECURITY_ENFORCED]) : ([SELECT Id FROM Case WHERE Syntilio__Event__c IN: eventConfigurationList AND ContactPhone =: inputVariable.phone AND Status NOT IN: statusList WITH SECURITY_ENFORCED]);
            } catch(Exception e){
            	Syntilio.HandleException.logException(e);
            }
            
            OutputVariables outputVariables = new OutputVariables();
            outputVariables.caseRecordsCollection = allOpenCasesOnEventCodeToClose;
            if (outputVariables.caseRecordsCollection.size() > 0)
        		outputVariables.firstCaseRecordForSyntilioEventRecord = outputVariables.caseRecordsCollection[0];
            outputVariablesList.add(outputVariables);

        }
        return outputVariablesList;
    }
    
    @NamespaceAccessible
    public class InputVariables {
        @invocableVariable
        public Syntilio__EventConfiguration__c eventConfigurationRecord ;
        @invocableVariable
        public String userId;
        @invocableVariable
        public String assetId;
        @invocableVariable
        public String phone;
    }
    
    @NamespaceAccessible
    public class OutputVariables {
        @invocableVariable
        public List<Case> caseRecordsCollection;
        @invocableVariable
        public Case firstCaseRecordForSyntilioEventRecord;
    }
}