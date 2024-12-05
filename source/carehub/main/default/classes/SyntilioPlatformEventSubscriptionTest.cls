@isTest
public with sharing class SyntilioPlatformEventSubscriptionTest {
    
    private static Syntilio__EventConfiguration__c getEventConfiguration() {
        return [SELECT Syntilio__Code__c FROM Syntilio__EventConfiguration__c LIMIT 1];
    }
    
    private static Contact getContact() {
        return [SELECT Phone FROM Contact LIMIT 1];
    }
    
    @testSetup
    static void setup() {
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(null);
        Syntilio__EventConfiguration__c eventCode = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert new List<SObject>{contact, eventCode};
    }
    
    @isTest
    static void syntilioPlatformEventSubscriptionTest_LaunchEventHanlderFlowShouldCreateCase() {
        Syntilio__EventConfiguration__c eventConfiguration = getEventConfiguration();
        Contact contactRecord = getContact();
        
        Syntilio__SyntilioPlatformEvent__e syntilioPlatformEvent = Syntilio.CareHubTestDataFactory.createSyntilioPlatformEvent(
            new Map<String, Object>{
                'Syntilio__EventCode__c' => eventConfiguration.Syntilio__Code__c,
                'Syntilio__Phone__c' => contactRecord.Phone 
            }
        );
        
        Test.startTest();           
        Database.SaveResult saveResult = EventBus.publish(syntilioPlatformEvent);
        Test.getEventBus().deliver();
        Test.stopTest();
        
        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(true, saveResult.isSuccess());
    }

    @isTest
    static void syntilioPlatformEventSubscriptionTest_LaunchEventHanlderFlowShouldNotCreateCase() {
        Syntilio__EventConfiguration__c eventConfiguration = getEventConfiguration();
        
        Syntilio__SyntilioPlatformEvent__e syntilioPlatformEvent = Syntilio.CareHubTestDataFactory.createSyntilioPlatformEvent(
            new Map<String, Object>{
                'Syntilio__EventCode__c' => eventConfiguration.Syntilio__Code__c
            }
        );
        
        Test.startTest();          
        Database.SaveResult saveResult = EventBus.publish(syntilioPlatformEvent);
        Test.getEventBus().deliver();
        Test.stopTest();
           
        List<Case> cases = [SELECT Id FROM Case];
        System.assertEquals(true, saveResult.isSuccess());
        System.assertEquals(0, cases.size());
    }
}