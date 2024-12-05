@namespaceAccessible @isTest
public with sharing class MockNotSuccessfulDataHubCallout implements HttpCalloutMock {
    
    @NamespaceAccessible public String method { get; set; }
    @NamespaceAccessible public String objectTypeName { get; set; }
    @NamespaceAccessible public String objectBody { get; set; }
    @NamespaceAccessible public Integer statusCode { get; set; }

    @NamespaceAccessible
    public MockNotSuccessfulDataHubCallout(String method, String objectTypeName, String objectBody, Integer statusCode) {
        this.method = method;
        this.objectTypeName = objectTypeName;
        this.objectBody = objectBody;
        this.statusCode = statusCode;
    }
    
    @NamespaceAccessible
    public HTTPResponse respond(HTTPRequest request) {
        
        String calloutAPIEndpointMock = Syntilio.CheckEnvironmentType.checkCustomMetadata('syntilioapi');
        System.assertEquals(method, request.getMethod());
        if(method != 'GET'){
        	System.assertEquals(calloutAPIEndpointMock + '/dynamic/' + objectTypeName.toLowerCase(), request.getEndpoint());
        	System.assertEquals(this.objectBody, request.getBody());
        }else
        	System.assertEquals(calloutAPIEndpointMock + '/dynamic/' + objectTypeName.toLowerCase() + objectBody, request.getEndpoint());

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ { "Success": false, "Message": "Reason Phrase: Not Found, Error: Response status code does not indicate success: 404 (Not Found).", "Data": null, "ProviderName": "Salesforce:ExpertcareDev", "StatusCode": 404, "ExcludedMappings": { "Id": "01140rbjrfvnhm", "Phone": "+31-238728372", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" } } ]');
        response.setStatusCode(statusCode);
        return response;
    }
}