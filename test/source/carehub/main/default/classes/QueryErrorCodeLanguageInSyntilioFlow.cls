@namespaceAccessible
public with sharing class QueryErrorCodeLanguageInSyntilioFlow {
    
    @NamespaceAccessible @testVisible public static IErrorCodeConfigurationCustomMetadata errorCodeConfigurationCustomMetadata = new ErrorCodeConfigurationCustomMetadata();
    
    @invocableMethod(label='Query Flow Error Code Description For Selected Org Language')
    public static List<OutputVariables> execute (List<InputVariables> inputVariables) {
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        Syntilio__ErrorCodeConfiguration__mdt mapErrorCodeObjects;
        if(inputVariables == null)
            return null;
        
        for(InputVariables inputVariable : inputVariables){
            if (inputVariable.taskIssueReasonMappedToFlowErrorCodes != null){
        		String taskReasonDescriptionWithSelectedLanguage;
                try{
                    mapErrorCodeObjects = errorCodeConfigurationCustomMetadata.getErrorCodeConfigurationCustomMetadata(inputVariable.taskIssueReasonMappedToFlowErrorCodes);
                    if (inputVariable.selectedErrorCodeLanguageApiNameFormula != null && mapErrorCodeObjects != null){
                        Map<String, Object> errorObjectMap = (Map<String, Object>) JSON.deserializeUntyped(Json.serialize(mapErrorCodeObjects));                        
                        taskReasonDescriptionWithSelectedLanguage = String.valueOf(errorObjectMap.get(inputVariable.selectedErrorCodeLanguageApiNameFormula));                        
                    }
                }
                catch(Exception e){
                    Syntilio.HandleException.logException(e);
                }
                OutputVariables outputVariables = new OutputVariables();
                outputVariables.taskReasonDescriptionWithSelectedLanguageVariable = taskReasonDescriptionWithSelectedLanguage;
                outputVariablesList.add(outputVariables);
            }
        }
        return outputVariablesList;
    }
    @NamespaceAccessible
    public class InputVariables {
        @invocableVariable
        public String selectedErrorCodeLanguageApiNameFormula;
        @invocableVariable
        public String taskIssueReasonMappedToFlowErrorCodes;
    }
    @NamespaceAccessible
    public class OutputVariables {
        @invocableVariable
        public String taskReasonDescriptionWithSelectedLanguageVariable;
    }
}