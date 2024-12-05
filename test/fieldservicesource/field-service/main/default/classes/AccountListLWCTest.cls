@isTest
public with sharing class AccountListLWCTest {
    @isTest
    public static void getAccounts_Test() {

        try{
            Test.startTest();
            Account accountToBeInserted = Syntilio.DataHubTestDataFactory.createAccount(null);
            insert accountToBeInserted;
            // Syntilio.CareHubTestDataFactory.createAccountRecords(null, null, null, 1);
            // Syntilio.DataHubTestDataFactory.createTestRecord('Account', null);
            List<Account> accountList = Syntilio.AccountListLWC.getAccounts();
              
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.LogException(e);
        }
       	List<Account> accountListAfterCreation = [SELECT Id FROM Account];
        system.assertEquals(1, accountListAfterCreation.size());
    }
}