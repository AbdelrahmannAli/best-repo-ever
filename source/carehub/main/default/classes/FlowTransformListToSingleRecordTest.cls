@isTest
public with sharing class FlowTransformListToSingleRecordTest {
    
    private static List<Account> createAccounts() {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 3; i++){
            accountList.add(Syntilio.CareHubTestDataFactory.createAccount(null));
        }
        insert accountList;
        return accountList;
    }
    
    @isTest
    static void transformAccountsListToSingleRecordTest_StartingIndex() {
        List<Syntilio.FlowTransformListToSingleRecord.OutputVariables> outputVariablesList;
        List<Account> accountList = createAccounts();
        
        List<Syntilio.FlowTransformListToSingleRecord.InputVariables> inputVariablesList = new List<Syntilio.FlowTransformListToSingleRecord.InputVariables>();
        Syntilio.FlowTransformListToSingleRecord.InputVariables inputVariable = new Syntilio.FlowTransformListToSingleRecord.InputVariables();
        inputVariable.incomingSobjectCollection = accountList;
        inputVariable.indexOfRecordToBeReturned = 0;
        inputVariablesList.add(inputVariable);
        
        Test.startTest();
        outputVariablesList = Syntilio.FlowTransformListToSingleRecord.execute(inputVariablesList);
        Test.stopTest();
        
        System.assertEquals(accountList[0].Id, outputVariablesList[0].ouputSingleRecord.Id);
    }

    @isTest
    static void transformAccountsListToSingleRecordTest_LastIndex() {
        List<Syntilio.FlowTransformListToSingleRecord.OutputVariables> outputVariablesList;
        List<Account> accountList = createAccounts();
        
        List<Syntilio.FlowTransformListToSingleRecord.InputVariables> inputVariablesList = new List<Syntilio.FlowTransformListToSingleRecord.InputVariables>();
        Syntilio.FlowTransformListToSingleRecord.InputVariables inputVariable = new Syntilio.FlowTransformListToSingleRecord.InputVariables();
        inputVariable.incomingSobjectCollection = accountList;
        inputVariable.indexOfRecordToBeReturned = 2;
        inputVariablesList.add(inputVariable);
        
        Test.startTest();
        outputVariablesList = Syntilio.FlowTransformListToSingleRecord.execute(inputVariablesList);
        Test.stopTest();
        
        System.assertEquals(accountList[2].Id, outputVariablesList[0].ouputSingleRecord.Id);
    }

    @isTest
    static void transformAccountsListToSingleRecordTest_NullValue() {
        List<Syntilio.FlowTransformListToSingleRecord.OutputVariables> outputVariablesList;
        
        Test.startTest();
        List<Syntilio.FlowTransformListToSingleRecord.InputVariables> inputVariablesList;
        outputVariablesList = Syntilio.FlowTransformListToSingleRecord.execute(inputVariablesList);
        Test.stopTest();
        
        System.assertEquals(null, outputVariablesList);
    }
  
    @isTest
    static void transformAccountsListToSingleRecordTest_Exception() {
        List<Syntilio.FlowTransformListToSingleRecord.OutputVariables> outputVariablesList;
        Syntilio.FlowTransformListToSingleRecord.raiseException = true;
        
        Test.startTest();
        List<Syntilio.FlowTransformListToSingleRecord.InputVariables> inputVariablesList = new List<Syntilio.FlowTransformListToSingleRecord.InputVariables>();
        outputVariablesList = Syntilio.FlowTransformListToSingleRecord.execute(inputVariablesList);
        Test.stopTest();
        
        Syntilio.FlowTransformListToSingleRecord.raiseException = false;
		
		System.assertEquals(0, outputVariablesList.size());        
    }
}