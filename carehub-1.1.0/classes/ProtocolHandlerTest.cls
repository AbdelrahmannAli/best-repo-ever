@isTest
public with sharing class ProtocolHandlerTest {
    
    private static Case getCase(){
        return [SELECT Id FROM Case LIMIT 1];
    }
    
    private static List<Syntilio__ProtocolActionRelation__c> getProtocolActionsRelations(List<Id> relationIds) {
        String query = 'SELECT Id, Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c, Syntilio__Order__c, Syntilio__Protocol__c FROM Syntilio__ProtocolActionRelation__c';
        if (relationIds != null && relationIds.size() >= 1) {
            query += ' WHERE Id IN :relationIds';
        }
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = Database.query(query);
        return protocolActionsRelationList;
    }
    
    @testSetup
    static void setupTestData() {
        
        Id medicalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();
        
        Syntilio__EventConfiguration__c eventCode = Syntilio.CareHubTestDataFactory.createEventConfiguration(
            new Map<String, Object>{
                'Name' => 'High Blood Pressure',
        		'Syntilio__Code__c' => 1001
            }
        );
        insert eventCode;
        
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Syntilio__Event__c' => eventCode.Id,
        		'Status' => 'Not Started',
                'RecordTypeId' => medicalCaseRecordTypeId
            }
        );
        
        Syntilio__Protocol__c  newProtocol = Syntilio.CareHubTestDataFactory.createProtocol(null);
        
        List<Syntilio__ProtocolAction__c> protocolActionsList = new List<Syntilio__ProtocolAction__c>{
            Syntilio.CareHubTestDataFactory.createProtocolAction(
                new Map<String, Object>{
                    'Name' => 'newProtocolActionTest1',
                    'Syntilio__TypeApiName__c' => 'testProtocolActionApiName1'
                }
            ),
            Syntilio.CareHubTestDataFactory.createProtocolAction(
                new Map<String, Object>{
                    'Name' => 'newProtocolActionTest2',
                    'Syntilio__TypeApiName__c' => 'testProtocolActionApiName2'
                }
            )
        };
        List<SObject> toInsert = new List<SObject>();
        toInsert.add(newCase);
        toInsert.add(newProtocol);
        toInsert.addAll(protocolActionsList);
        insert toInsert;
        
        Syntilio__ProtocolActivator__c caseActivator = Syntilio.CareHubTestDataFactory.createProtocolActivator(
            new Map<String, Object>{
                'Syntilio__Event__c' => eventCode.Id,
                'Syntilio__Protocol__c' => newProtocol.Id
			}
        );
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = new List<Syntilio__ProtocolActionRelation__c>{
            Syntilio.CareHubTestDataFactory.createProtocolActionRelation(
                new Map<String, Object>{
                    'Syntilio__Order__c' => Syntilio.ProtocolHandler.getNextOrder(newProtocol.Id),
                    'Syntilio__Protocol__c' => newProtocol.Id,
                    'Syntilio__ProtocolAction__c' => protocolActionsList[0].Id
                }
            ),
            Syntilio.CareHubTestDataFactory.createProtocolActionRelation(
                new Map<String, Object>{
                    'Syntilio__Order__c' => Syntilio.ProtocolHandler.getNextOrder(newProtocol.Id),
                    'Syntilio__Protocol__c' => newProtocol.Id,
                    'Syntilio__ProtocolAction__c' => protocolActionsList[1].Id
                }
            )
        };
        
        List<Syntilio__Group__c> groupList = new List<Syntilio__Group__c>{
            Syntilio.CareHubTestDataFactory.createGroup(
                new Map<String, Object>{
                    'Name' => 'patient group',
                    'Syntilio__ObjectType__c' => 'Contact'
                }
        	),
            Syntilio.CareHubTestDataFactory.createGroup(
                new Map<String, Object>{
                    'Name' => 'event code group',
                    'Syntilio__ObjectType__c' => 'Event Configuration'
                }
        	)
		};
        
        toInsert = new List<SObject>();
        toInsert.add(caseActivator);
        toInsert.addAll(protocolActionsRelationList);
        toInsert.addAll(groupList);
        insert toInsert;
        
        Syntilio__GroupMember__c groupMemeber = Syntilio.CareHubTestDataFactory.createGroupMember(
            new Map<String, Object>{
                'Syntilio__EventConfigurationId__c' => eventCode.Id,
				'Syntilio__GroupId__c' => groupList[1].Id
			}
        );
        insert groupMemeber;
    }
    
    @isTest
    static void getFlowTest_CorrectActionFlows() {
        Case requestedCase = getCase();

        Test.startTest();
        String caseActions =  Syntilio.ProtocolHandler.getFlow(requestedCase.Id, false);
        Test.stopTest();
        
        List<Object> unserializedActions = ( List<Object>) JSON.deserializeUntyped(caseActions);
        System.assertEquals(2, unserializedActions.size());
    }

    @isTest
    static void getFlowTest_CorrectActionFlowsOrder() {
        Case requestedCase = getCase();
        
        Test.startTest();
        String caseActions =  Syntilio.ProtocolHandler.getFlow(requestedCase.Id, false);
        Test.stopTest();
        
        List<Syntilio__ProtocolActionRelation__c> unserializedActions = (List<Syntilio__ProtocolActionRelation__c>) JSON.deserialize(caseActions, List<Syntilio__ProtocolActionRelation__c>.class);
        System.assertEquals(2, unserializedActions.size());
        System.assertEquals('testProtocolActionApiName1', unserializedActions[0].Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c);
        System.assertEquals('testProtocolActionApiName2', unserializedActions[1].Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c);
    }

    @isTest
    static void removeAllTest() {
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        List<String> removalList = new List<String>{'testProtocolActionApiName2'};
            
        Test.startTest();
        List<Syntilio__ProtocolActionRelation__c> removedObjectList = Syntilio.ProtocolHandler.removeAll(protocolActionsRelationList, removalList);
        Test.stopTest();       
        
        System.assertEquals(1, removedObjectList.size());
    }

    @isTest
    static void getFinishedOrUnfinishedCaseActionsTest_CaseFinishedActions() {
        Case requestedCase = getCase();
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio.ProtocolHandler.insertCaseProtocolActionResult(requestedCase.Id, protocolActionsRelationList);
        
        List<Syntilio__ProtocolActionResult__c> protocolActionResults = [
            SELECT  Syntilio__FlowStatus__c, Syntilio__Case__c, Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c 
            FROM Syntilio__ProtocolActionResult__c
            WHERE Syntilio__Case__c = :requestedCase.Id
        ];
        
        protocolActionResults[0].Syntilio__FlowStatus__c = 'FINISHED';
        update protocolActionResults[0];
        
        Test.startTest();
        List<String> finishedCaseActions = Syntilio.ProtocolHandler.getFinishedOrUnfinishedCaseActions(requestedCase.Id, True, True, True);
        Test.stopTest();
        
        System.assertEquals(1, finishedCaseActions.size());
        System.assertEquals(protocolActionResults[0].Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c, finishedCaseActions[0]);
    }
    
	@isTest
    static void getFinishedOrUnfinishedCaseActionsTest_CaseUnfinishedActions() {
        Case requestedCase = getCase();
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio.ProtocolHandler.insertCaseProtocolActionResult(requestedCase.Id, protocolActionsRelationList);
        
        List<Syntilio__ProtocolActionResult__c> protocolActionResults = [
            SELECT  Syntilio__FlowStatus__c, Syntilio__Case__c, Syntilio__ProtocolAction__r.Syntilio__TypeApiName__c 
            FROM Syntilio__ProtocolActionResult__c
            WHERE Syntilio__Case__c = :requestedCase.Id
        ];
                
        List<String> unfinishedCaseActions = Syntilio.ProtocolHandler.getFinishedOrUnfinishedCaseActions(requestedCase.Id, False, True, True);
        
        System.assertEquals(2, unfinishedCaseActions.size());
    }
 
    @isTest
    static void insertCaseProtocolActionResultTest() {
        Case requestedCase = getCase();
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Test.startTest();
        Syntilio.ProtocolHandler.insertCaseProtocolActionResult(requestedCase.Id, protocolActionsRelationList);
        Test.stopTest();
        
        List<Syntilio__ProtocolActionResult__c> protocolActionResults = [
            SELECT  Syntilio__FlowStatus__c, Syntilio__Case__c, Syntilio__ProtocolAction__c 
            FROM Syntilio__ProtocolActionResult__c
            WHERE Syntilio__Case__c = :requestedCase.Id
        ];
        
        System.assertEquals(2, protocolActionResults.size());
    }

    @isTest
    static void updateCaseProtocolActionResultTest() {
        Case requestedCase = getCase();
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio.ProtocolHandler.insertCaseProtocolActionResult(requestedCase.Id, protocolActionsRelationList);
        
        Test.startTest();
        Syntilio.ProtocolHandler.updateCaseProtocolActionResult(requestedCase.Id, protocolActionsRelationList[0].Syntilio__ProtocolAction__c , 'FINISHED' );
        
        List<Syntilio__ProtocolActionResult__c> caseProtocolActionResult = [
            SELECT Syntilio__FlowStatus__c 
            FROM Syntilio__ProtocolActionResult__c
            WHERE Syntilio__Case__c= :requestedCase.Id AND
            Syntilio__ProtocolAction__c = :protocolActionsRelationList[0].Syntilio__ProtocolAction__c 
            AND Syntilio__FlowStatus__c = 'FINISHED'
            LIMIT 1
        ];
        
        Boolean protocolIsFound = caseProtocolActionResult.size() > 0;
        
        System.assertEquals(True, protocolIsFound);
    }
  
    @isTest
    static void updateProtocolActionRelationTest_Success() {
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio__ProtocolActionRelation__c firstRelation = protocolActionsRelationList[0];
        Decimal nextOrder = Syntilio.ProtocolHandler.getNextOrder(firstRelation.Syntilio__Protocol__c);
        firstRelation.Syntilio__Order__c = nextOrder - 1;  
        
        Test.startTest();
        update firstRelation;
        Test.stopTest();
        
       	List<Syntilio__ProtocolActionRelation__c> newProtocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(newProtocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        System.assertEquals(firstRelation.Syntilio__Order__c, newProtocolActionsRelationList[0].Syntilio__Order__c );
    }
     
    @isTest
    static void updateProtocolActionRelationTest_Failure0() {

        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio__ProtocolActionRelation__c firstRelation = protocolActionsRelationList[0];
        Decimal nextOrder = Syntilio.ProtocolHandler.getNextOrder(firstRelation.Syntilio__Protocol__c);
        firstRelation.Syntilio__Order__c = firstRelation.Syntilio__Order__c - 1;    
        
        Test.startTest();
        Database.SaveResult databaseResult = Database.update(firstRelation, false);
        Test.stopTest();
        
        List<Syntilio__ProtocolActionRelation__c> newProtocolActionsRelationList = getProtocolActionsRelations(new List<Id>{firstRelation.Id});
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        System.assertEquals(false, databaseResult.isSuccess());
        System.assert(databaseResult.getErrors().size() > 0);
        System.assert(databaseResult.getErrors()[0].getMessage().contains('Order value must be greater than 0'));        
    }
     
    @isTest
    static void updateProtocolActionRelationTest_HigherOrder() {
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio__ProtocolActionRelation__c firstRelation = protocolActionsRelationList[0];
        Decimal nextOrder = Syntilio.ProtocolHandler.getNextOrder(firstRelation.Syntilio__Protocol__c);
        firstRelation.Syntilio__Order__c = firstRelation.Syntilio__Order__c + 25;    
        
        Test.startTest();
        Database.SaveResult databaseResult = Database.update(firstRelation, false);
        Test.stopTest();
        
        System.assertEquals(true, databaseResult.isSuccess());
        
        List<Syntilio__ProtocolActionRelation__c> newProtocolActionsRelationList = getProtocolActionsRelations(new List<Id>{firstRelation.Id});
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        String condition = 'Syntilio__Protocol__c = ' + '\'' + firstRelation.Syntilio__Protocol__c + '\'';
        Decimal nextOrderValue = Syntilio.CareHubUtilities.getNextOrder(
            'Syntilio__ProtocolActionRelation__c',
            true,
            condition
        );
        
        System.assertEquals(nextOrderValue, newProtocolActionsRelationList[0].Syntilio__Order__c );
    }
 
    @isTest
    public static void deleteProtocolActionRelationTest_Success() {
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio__ProtocolActionRelation__c firstRelation = protocolActionsRelationList[0];
        Decimal secondRelationOrder = protocolActionsRelationList[1].Syntilio__Order__c;
        Id secondRelationOrderId = protocolActionsRelationList[1].Id;
        
        Test.startTest();
        Database.DeleteResult databaseResult = Database.delete(firstRelation, false);
        Test.stopTest();
        
        System.assertEquals(true, databaseResult.isSuccess());  
        
        List<Syntilio__ProtocolActionRelation__c> newProtocolActionsRelationList = getProtocolActionsRelations(new List<Id>{secondRelationOrderId});
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        System.assertEquals(1, newProtocolActionsRelationList.size());
        System.assertEquals(1, newProtocolActionsRelationList[0].Syntilio__Order__c );
    }

    @isTest
    public static void updateProtocolActionRelationTest_NoChange() {

        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio__ProtocolActionRelation__c firstRelation = protocolActionsRelationList[0];
        
        Test.startTest();
        Database.SaveResult databaseResult = Database.update(firstRelation, false);
        Test.stopTest();
        
        System.assertEquals(true, databaseResult.isSuccess());
        
        List<Syntilio__ProtocolActionRelation__c> newProtocolActionsRelationList = getProtocolActionsRelations(new List<Id>{firstRelation.Id});
        System.assert(newProtocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        System.assertEquals(firstRelation.Syntilio__Order__c, newProtocolActionsRelationList[0].Syntilio__Order__c );
    }

    @isTest
    public static void insertProtocolActionRelationTest_ExistingOrder() {
        
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio__ProtocolActionRelation__c newRelation = protocolActionsRelationList[0].clone(false, false, true);
        Decimal nextOrder = Syntilio.ProtocolHandler.getNextOrder(newRelation.Syntilio__Protocol__c);
        newRelation.Syntilio__Order__c = nextOrder - 1;    
        
        Test.startTest();
        Database.SaveResult databaseResult = Syntilio.UpsertToDatabase.insertAction(newRelation, false);
        Test.stopTest();
        
        System.assertEquals(true, databaseResult.isSuccess());

        List<Syntilio__ProtocolActionRelation__c> newProtocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(newProtocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        System.assert(newProtocolActionsRelationList.size() > 2, 'New protocol action relations not inserted.');
        System.assertEquals(newRelation.Syntilio__Order__c, newProtocolActionsRelationList[2].Syntilio__Order__c);
    }
  
    @isTest
    public static void insertProtocolActionRelationTest_HigherOrder() {
        List<Syntilio__ProtocolActionRelation__c> protocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(protocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        Syntilio__ProtocolActionRelation__c newRelation = protocolActionsRelationList[0].clone(false, false, true);
        Decimal nextOrder = Syntilio.ProtocolHandler.getNextOrder(newRelation.Syntilio__Protocol__c);
        newRelation.Syntilio__Order__c = nextOrder + 25;    
        
        Test.startTest();
        Database.SaveResult databaseResult = Syntilio.UpsertToDatabase.insertAction(newRelation, false);
        Test.stopTest();
        
        System.assertEquals(true, databaseResult.isSuccess());
        
        List<Syntilio__ProtocolActionRelation__c> newProtocolActionsRelationList = getProtocolActionsRelations(null);
        System.assert(newProtocolActionsRelationList.size() > 0, 'No test protocol action relations found.');
        
        System.assert(newProtocolActionsRelationList.size() > 2, 'New protocol action relations not inserted.');
        System.assertEquals(nextOrder, newProtocolActionsRelationList[2].Syntilio__Order__c);
    }
}