@isTest
public with sharing class MockRegisterNewClientResponse implements HttpCalloutMock {


    public String method { get; set; }
    public Integer statusCode { get; set; }
    public String responseBody { get; set; }


    public MockRegisterNewClientResponse(String method, Integer statusCode, String responseBody) {
        this.method = method;
        this.statusCode = statusCode;
        this.responseBody = responseBody; 
    }

    public HTTPResponse respond(HTTPRequest request) {
        
        String calloutAPIEndpointMock = Syntilio.CheckEnvironmentType.checkCustomMetadata('syntilioapi');

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(statusCode);
        return response;
    }
}