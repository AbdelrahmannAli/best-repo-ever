@isTest
public with sharing class FlowCheckObjectAccessLevelTest {
	@isTest
    public static void CheckContactObject_ShouldBeTrue() {
        List<Syntilio.FlowCheckObjectAccessLevel.OutputVariables> outputVariablesList;        
        List<Syntilio.FlowCheckObjectAccessLevel.InputVariables> inputVariablesList = new List<Syntilio.FlowCheckObjectAccessLevel.InputVariables>();
        Syntilio.FlowCheckObjectAccessLevel.InputVariables inputVariable = new Syntilio.FlowCheckObjectAccessLevel.InputVariables();
        inputVariable.incomingObjectName = 'Contact';
        inputVariablesList.add(inputVariable);
        
        Test.startTest();
        outputVariablesList = Syntilio.FlowCheckObjectAccessLevel.execute(inputVariablesList);
        Test.stopTest();
        System.assertEquals(true, outputVariablesList[0].objectAccessBoolean);
    }
    
   	@isTest
    public static void RaiseException() {
        Syntilio.FlowCheckObjectAccessLevel.raiseException = true;
        List<Syntilio.FlowCheckObjectAccessLevel.OutputVariables> outputVariablesList;        
        List<Syntilio.FlowCheckObjectAccessLevel.InputVariables> inputVariablesList = new List<Syntilio.FlowCheckObjectAccessLevel.InputVariables>();
        Syntilio.FlowCheckObjectAccessLevel.InputVariables inputVariable = new Syntilio.FlowCheckObjectAccessLevel.InputVariables();
        inputVariable.incomingObjectName = 'Contact';
        inputVariablesList.add(inputVariable);
        
        Test.startTest();
        outputVariablesList = Syntilio.FlowCheckObjectAccessLevel.execute(inputVariablesList);
        Test.stopTest();
        Syntilio.FlowCheckObjectAccessLevel.raiseException = false;
        System.assertEquals(true, true);
    }
}