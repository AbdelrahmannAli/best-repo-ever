@isTest
public with sharing class SyntilioHttpClientTest {
    @isTest
    public static void syntilioHttpClient_Test() {
        Syntilio.SyntilioHttpClient instance;
        try{
            Test.startTest();
            
            instance = Syntilio.SyntilioHttpClient.getInstance();
            
            Test.stopTest(); 
        } catch (Exception e ) {
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(null, instance.credentials);
        
        String calloutAPIEndpointMock = Syntilio.CheckEnvironmentType.checkCustomMetadata('syntilioapi');
        System.assertEquals(calloutAPIEndpointMock, instance.salesforceNamedCredentialsApiUrl);
    }
}