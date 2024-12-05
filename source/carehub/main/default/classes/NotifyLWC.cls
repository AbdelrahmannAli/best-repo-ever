@Deprecated
@RestResource(UrlMapping='/NotifyLWC')
global with sharing class NotifyLWC {
    @Deprecated
    @HttpPost
    global static void onPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try{
            String body = req.requestBody.toString();
            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(body);
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('LWC Notified' + body);
        } catch(Exception e) {
			res.statusCode = 400;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf('Failed to notify LWC');            
        }
    }
}