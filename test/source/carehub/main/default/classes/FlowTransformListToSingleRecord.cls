@namespaceAccessible
public with sharing class FlowTransformListToSingleRecord {
    @TestVisible private static Boolean raiseException = false;
    
    @invocableMethod(label='Flow Transform Collections to Single Record')
    public static List<OutputVariables> execute (List<InputVariables> inputVariables) {
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        try {
            if(Test.isRunningTest() && Syntilio.FlowTransformListToSingleRecord.raiseException == true) 
                throw new  DmlException();        
            if(inputVariables == null)
                return null;
            
            sObject sobjectRecordWithSpecificIndex;
            
            for(InputVariables inputVariable : inputVariables){
                
                sobjectRecordWithSpecificIndex = inputVariable.incomingSobjectCollection[inputVariable.indexOfRecordToBeReturned != null ?inputVariable.indexOfRecordToBeReturned : 0];
                
                OutputVariables outputVariables = new OutputVariables();
                outputVariables.ouputSingleRecord = sobjectRecordWithSpecificIndex;
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
        public List<sObject> incomingSobjectCollection;
        @invocableVariable
        public Integer indexOfRecordToBeReturned;
    }
    
    @NamespaceAccessible
    public class OutputVariables {
        @invocableVariable
        public sObject ouputSingleRecord;
    }
}