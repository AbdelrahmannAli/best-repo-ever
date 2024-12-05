@IsTest
public with sharing class HttpClientMock implements HttpCalloutMock {

    public String method { get; set; }
    public string salesforceNamedCredentialsApiUrl { get; set; }

    public HttpClientMock(String method, string salesforceNamedCredentialsApiName) {
        this.method = method;
       	this.salesforceNamedCredentialsApiUrl = salesforceNamedCredentialsApiName != null? CheckEnvironmentType.checkCustomMetadata(salesforceNamedCredentialsApiName) : '';
    }
    
    public HttpClientMock(String method) {
        this(method, null);
    }

    public HttpResponse respond(HttpRequest req) {
        System.assertEquals(method, req.getMethod());
        string endpoint = salesforceNamedCredentialsApiUrl + HttpClientTest.ENDPOINT;
        System.assertEquals(endpoint, req.getEndpoint());

        if(method != 'GET' && method != 'HEAD' && method != 'DELETE') {
            System.assertEquals(HttpClientTest.PAYLOAD_REQUEST, req.getBody());
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(HttpClientTest.PAYLOAD_RESPONSE);
        res.setStatusCode(200);
        return res;
    }
    
}