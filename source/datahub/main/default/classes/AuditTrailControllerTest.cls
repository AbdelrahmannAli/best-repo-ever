@isTest
public with sharing class AuditTrailControllerTest {
    @isTest
    public static void testLog() {
        String source = 'Test Source';
        String destination = 'Test Destination';
        String status = 'Test Status';
        String endpoint = 'Test Endpoint';
        String actionMethod = 'GET';
        String requestBody = 'Test Request Body';
        String queryParams = 'Test Query Params';
        String responseBody = 'Test Response Body';

        Test.startTest();
        Syntilio.AuditTrailController.log(source, destination, status, endpoint, actionMethod, requestBody, queryParams, responseBody);
        Test.stopTest();

        List<Syntilio__AuditTrail__c> logs = [SELECT Syntilio__Source__c, Syntilio__Destination__c, Syntilio__Status__c, Syntilio__Endpoint__c, Syntilio__ActionName__c, Syntilio__RequestBody__c, Syntilio__QueryParams__c, Syntilio__ResponseBody__c FROM Syntilio__AuditTrail__c WITH SECURITY_ENFORCED];
        System.assertEquals(1, logs.size());
        System.assertEquals(source, logs[0].Syntilio__Source__c);
        System.assertEquals(destination, logs[0].Syntilio__Destination__c);
        System.assertEquals(status, logs[0].Syntilio__Status__c);
        System.assertEquals(endpoint, logs[0].Syntilio__Endpoint__c);
        System.assertEquals(actionMethod, logs[0].Syntilio__ActionName__c);
        System.assertEquals(requestBody, logs[0].Syntilio__RequestBody__c);
        System.assertEquals(queryParams, logs[0].Syntilio__QueryParams__c);
        System.assertEquals(responseBody, logs[0].Syntilio__ResponseBody__c);
    }

    @isTest
    public static void testLogWithEmptyActionMethod() {
        String source = 'Test Source';
        String destination = 'Test Destination Destination Destination Destination Destination Destination Destination Destination Test Destination Destination Destination Destination Destination Destination Destination Destination Test Destination Destination Destination Destination Destination Destination Destination Destination';
        String status = 'Test Status';
        String endpoint = 'Test Endpoint';
        String actionMethod = '';
        String requestBody = 'Test Request Body';
        String queryParams = 'Test Query Params';
        String responseBody = 'Test Response Body';

        Test.startTest();
        try {
            Syntilio.AuditTrailController.log(source, destination, status, endpoint, actionMethod, requestBody, queryParams, responseBody);
        } catch (Exception e) {
            System.assertEquals('Action method name cannot be empty', e.getMessage());
        }
        Test.stopTest();

        List<Syntilio__AuditTrail__c> logs = [SELECT Id FROM Syntilio__AuditTrail__c];
        System.assertEquals(0, logs.size());
    }
    
}