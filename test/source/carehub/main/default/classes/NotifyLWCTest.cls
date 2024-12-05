@isTest
public with sharing class NotifyLWCTest {
	@isTest
    static void onPostTest_Success(){
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/NotifyLWC';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf('{"message": "notification"}');

        RestContext.request = restRequest;
        RestContext.response = restResponse;

        Test.startTest();
        Syntilio.NotifyLWC.onPost();
        Test.stopTest(); 

        System.assertEquals(200, restResponse.statusCode);
    }

    @isTest
    static void onPostTest_Failure(){
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();

        restRequest.requestURI = '/services/apexrest/Syntilio/NotifyLWC';
        restRequest.httpMethod = 'POST';
        restRequest.requestBody = Blob.valueOf('{');

        RestContext.request = restRequest;
        RestContext.response = restResponse;

        Test.startTest();
        Syntilio.NotifyLWC.onPost();
        Test.stopTest(); 

        System.assertEquals(400, restResponse.statusCode);
    }
}