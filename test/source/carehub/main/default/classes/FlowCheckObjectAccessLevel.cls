@namespaceAccessible
public with sharing class FlowCheckObjectAccessLevel {
    @TestVisible private static Boolean raiseException = false;
    
    @invocableMethod(label='Flow Check Object Access Level')
    public static List<OutputVariables> execute (List<InputVariables> inputVariables) {
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        try {
            if(Test.isRunningTest() && Syntilio.FlowCheckObjectAccessLevel.raiseException == true) 
                throw new  DmlException();
            if(inputVariables == null)
                return null;
            for(InputVariables inputVariable : inputVariables){
                OutputVariables outputVariables = new OutputVariables();
                outputVariables.objectAccessBoolean = Syntilio.DataHubUtilities.isObjectAccessible(inputVariable.incomingObjectName, null);
                outputVariablesList.add(outputVariables);
            }
        } catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return outputVariablesList;
    }
    
    @NamespaceAccessible
    public class InputVariables {
        @invocableVariable
        public String incomingObjectName;
    }
    
    @NamespaceAccessible
    public class OutputVariables {
        @invocableVariable
        public Boolean objectAccessBoolean;
    }
}