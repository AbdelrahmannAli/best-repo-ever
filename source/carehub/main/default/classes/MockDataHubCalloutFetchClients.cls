@namespaceAccessible @isTest
public with sharing class MockDataHubCalloutFetchClients implements HttpCalloutMock {
    
    @NamespaceAccessible public String method { get; set; }
    @NamespaceAccessible public String objectTypeName { get; set; }
    @NamespaceAccessible public String objectBody { get; set; }
    @NamespaceAccessible public Map<String, Object> responseBody { get; set; }

    @NamespaceAccessible 
    public MockDataHubCalloutFetchClients(String method, String objectTypeName, String objectBody, Map<String, Object> responseBody) {
        this.method = method;
        this.objectTypeName = objectTypeName;
        this.objectBody = objectBody;
        this.responseBody = responseBody;
    }
    
    @NamespaceAccessible
    public HTTPResponse respond(HTTPRequest request) {
        String calloutAPIEndpointMock = CheckEnvironmentType.checkCustomMetadata('syntilioapi');
            
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if(this.objectBody.contains('404')) {
            response.setStatusCode(404);
        } else {
            response.setStatusCode(200);
        }

        response.setBody(JSON.serialize(responseBody));
        return response;
    }
}