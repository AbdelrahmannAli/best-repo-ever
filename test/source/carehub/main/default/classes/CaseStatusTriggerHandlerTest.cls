@IsTest
public with sharing class CaseStatusTriggerHandlerTest {
    @IsTest
    static void caseClosedByNonOwner() {
        User testUser = Syntilio.CareHubTestDataFactory.createUser(null);
        insert testUser;
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case 1', 
                'Status' => 'New',
                'Priority' => 'Normal',
                'OwnerId'=> testUser.Id
			}
        );
        insert testCase;
        Case caseTest = [SELECT Id, Status, OwnerId FROM Case LIMIT 1];
        Map<Id, Case> oldMap = new Map<Id, Case>{ caseTest.Id => caseTest.clone() };
        caseTest.Status = 'Closed';
        Map<Id, Case> newMap = new Map<Id, Case>{ caseTest.Id => caseTest };
        Syntilio__CareHubAppConfiguration__mdt config = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        Test.startTest();
        CaseStatusTriggerHandler.handleTrigger(oldMap, newMap);
        Test.stopTest();
    }

    @IsTest
    static void caseClosedWithEvent() {
        User testUser = Syntilio.CareHubTestDataFactory.createUser(null);
        insert testUser;
        Syntilio__EventConfiguration__c eventConfig = Syntilio.CareHubTestDataFactory.createEventConfiguration(
            new Map<String, Object>{'Syntilio__Code__c' => 789}
        );
        insert eventConfig;
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case 1', 
                'Status' => 'New',
                'Priority' => 'Normal',
                'OwnerId'=> testUser.Id,
                'Syntilio__Event__c'=>eventConfig.Id
			}
        );
        insert testCase;
        Case caseTest = [SELECT Id, Status, OwnerId, Syntilio__Event__c FROM Case LIMIT 1];
        Map<Id, Case> oldMap = new Map<Id, Case>{ caseTest.Id => caseTest.clone() };
        caseTest.Status = 'Closed';
        Map<Id, Case> newMap = new Map<Id, Case>{ caseTest.Id => caseTest };
        Syntilio__CareHubAppConfiguration__mdt config = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        Test.startTest();
        CaseStatusTriggerHandler.handleTrigger(oldMap, newMap);
        Test.stopTest();
    }
}