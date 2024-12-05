@isTest
public with sharing class CallValidityCheckTest {
    @isTest 
    static void testCallValidityCheck() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestURI = '/services/apexrest/CallValidityCheck'; 
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf('{"phoneNumber": "1234567890"}'); 


        Test.startTest();
        RestContext.request = request;
        RestContext.response = response;
        CallValidityCheck.updateCallValidity();        
        Test.stopTest();
    }
}