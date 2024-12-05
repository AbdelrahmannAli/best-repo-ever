@isTest
public with sharing class AuthSessionRestResourceTest {
    @testSetup
    static void setup() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Syntilio__AuthToken__c = 'testAuthToken'
        );
        insert testCase;
    }

    @isTest
    private static List<AuthSession> getAuthSessions() {
        return [
            SELECT Id, LoginHistoryId 
            FROM AuthSession 
            WHERE UsersId = :UserInfo.getUserId() 
            ORDER BY LastModifiedDate DESC
        ];
    }
    
    @isTest
    static void onGetAuthSessions_Success(){
        List<AuthSession> authSessions = getAuthSessions();
        AuthSession authSession = null;
        if(authSessions.size() > 0){
            authSession = authSessions[0];
        }
        
        String loginHistoryId = authSession != null? authSession.LoginHistoryId : null;
        
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        restRequest.requestURI = '/services/apexrest/Syntilio/AuthSessions/' + loginHistoryId;
        restRequest.httpMethod = 'GET';
        
        RestContext.request = restRequest;
        RestContext.response= restResponse;
        
        Test.startTest();
        Syntilio.AuthSessionRestResource.onGetAuthSessions();
        Test.stopTest(); 
        
        if(loginHistoryId != null){
            System.assertEquals(200, restResponse.statusCode);
        }
    }
    
    @isTest
    static void onGetFormTest_Failure(){
        List<AuthSession> authSessions = getAuthSessions();
        AuthSession authSession = null;
        if(authSessions.size() > 0){
            authSession = authSessions[0];
        }
        
        String sessionId = authSession != null? authSession.Id : null;
        
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        
        restRequest.requestURI = '/services/apexrest/Syntilio/AuthSessions/' + sessionId;
        restRequest.httpMethod = 'GET';
        
        RestContext.request = restRequest;
        RestContext.response= restResponse;
        
        Test.startTest();
        Syntilio.AuthSessionRestResource.onGetAuthSessions();
        Test.stopTest(); 
        
        if(sessionId != null){
            System.assertEquals(404, restResponse.statusCode);
        }
        
    }
}