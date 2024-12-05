@RestResource(urlMapping='/AuthSessions/*')
global with sharing class AuthSessionRestResource {

    @HttpGet @Deprecated
    global static void onGetAuthSessions() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String loginHistoryId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        List<AuthSession> authSessions = [
            SELECT Id
            FROM AuthSession 
            WHERE LoginHistoryId = :loginHistoryId
            ORDER BY LastModifiedDate DESC 
            LIMIT 1
        ];
        res.statusCode = authSessions.size() > 0? 200 : 404;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(authSessions));
    }
}