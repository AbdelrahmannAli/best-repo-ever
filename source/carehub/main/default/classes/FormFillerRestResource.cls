@Deprecated
@RestResource(UrlMapping='/FormFiller')
global with sharing class FormFillerRestResource {
    @Deprecated
    @HttpGet
    global static void onGetForm() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String protocolId = req.params.get('protocolId');
        String caseId = req.params.get('caseId');
		Map<String, Object> results = Syntilio.FormFillerHandler.getProtocolResultsMap(protocolId, caseId);

        String outputString = Syntilio.FormBuilderHandler.handleGetForm(protocolId);
        Syntilio.ResponseMessage output = Syntilio.ResponseMessage.deserialize(outputString);
        res.statusCode = output.isSuccess? 200 : 400;
        res.addHeader('Content-Type', 'application/json');

        if(output.message != null){
            res.responseBody = Blob.valueOf(output.message);
        } else if(output.data != null){
            Map<String, Object> body = new Map<String, Object>();
            Map<String, Object> survey = (Map<String, Object>) JSON.deserializeUntyped((String) output.data);
            body.put('survey', survey);
            if(results != null){
                body.put('results', results);
            }
            res.responseBody = Blob.valueOf(JSON.serialize(body));
        }
    }
    @Deprecated
    @HttpPost
    global static void onPostForm() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String protocolId = req.params.get('protocolId');
        String caseId = req.params.get('caseId');
        String body = req.requestBody.toString();
        String outputString = Syntilio.FormFillerHandler.handlePostForm(body, protocolId, caseId);
        Syntilio.ResponseMessage output = Syntilio.ResponseMessage.deserialize(outputString);
        res.statusCode = output.isSuccess? 200 : 400;
        if(output.message != null){
            res.responseBody = Blob.valueOf(output.message);
        }
    }
}