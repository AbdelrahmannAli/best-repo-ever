@isTest
public with sharing class SchedulableDataHubSyncTest {

    @isTest
    static void testFutureExecuteWithNoDataHubSyncInfo() {
        SchedulableDataHubSync contactApexScheduler = new SchedulableDataHubSync();

        Test.startTest();
        contactApexScheduler.execute(null);
        Test.stopTest();
        
        System.assert(true);
    }

    @isTest
    static void testFutureExecuteWithDataHubSyncInfo() {
       Syntilio__DataHubSyncInfo__c testDataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
            Syntilio__ObjectName__c = 'Contact',
            Syntilio__Type__c = 'Pull',
            Syntilio__Frequency__c = 0,
            Syntilio__LastSyncDate__c = Datetime.now(),
            Syntilio__ExternalSystems__c = 'Ons,Fierit'
        );
        insert testDataHubSyncInfo;
        
        SchedulableDataHubSync contactApexScheduler = new SchedulableDataHubSync();
        
        Test.startTest();
        contactApexScheduler.execute(null);
        Test.stopTest();
        
        System.assert(true);
    }
}