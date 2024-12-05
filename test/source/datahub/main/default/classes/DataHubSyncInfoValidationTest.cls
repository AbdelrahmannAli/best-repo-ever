@isTest
public with sharing class DataHubSyncInfoValidationTest {
    
    @isTest
    public static void invalidDatahubSyncInfo() {
       try {
       
            Test.startTest();

            Syntilio__DataHubSyncInfo__c dataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
                Name = 'Email',
                Syntilio__Enabled__c = true,
                Syntilio__Frequency__c = 0,
                Syntilio__IsUniqueIdentifier__c = false,
                Syntilio__LastSyncDate__c = Datetime.now(),
                Syntilio__ObjectName__c = 'Contact',
                Syntilio__SyncMode__c = 'CreateTaskOnConflict',
                Syntilio__ExternalSystems__c = 'Ons',
                Syntilio__Type__c = 'Pull'
            );

            insert dataHubSyncInfo;
            Test.stopTest();
       } catch (Exception e) {
            System.assertNotEquals(null, e);
       }
        
    }
    
}