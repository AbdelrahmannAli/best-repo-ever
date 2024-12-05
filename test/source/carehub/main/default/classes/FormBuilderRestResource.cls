@Deprecated
@RestResource(UrlMapping='/FormBuilder/*')
global with sharing class FormBuilderRestResource {
    @Deprecated
    @HttpGet
    global static void onGetForm() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String protocolId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        String outputString = Syntilio.FormBuilderHandler.handleGetForm(protocolId);
        Syntilio.ResponseMessage output = Syntilio.ResponseMessage.deserialize(outputString);
        res.statusCode = output.isSuccess? 200 : 400;
        res.addHeader('Content-Type', 'application/json');
        if(output.message != null){
            res.responseBody = Blob.valueOf(output.message);
        } else if(output.data != null){
            res.responseBody = Blob.valueOf((String) output.data);
        }
    }
    @Deprecated
    @HttpPost
    global static void onPostForm() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String protocolId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
        String body = req.requestBody.toString();
        String outputString = Syntilio.FormBuilderHandler.handlePostForm(body, protocolId);
        Syntilio.ResponseMessage output = Syntilio.ResponseMessage.deserialize(outputString);
        res.statusCode = output.isSuccess? 200 : 400;
        if(output.message != null){
            res.responseBody = Blob.valueOf(output.message);
        }
    }
}