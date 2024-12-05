@isTest @NamespaceAccessible
public with sharing class FetchClientsCalloutResponse implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest request) {
        
        String calloutAPIEndpointMock = Syntilio.CheckEnvironmentType.checkCustomMetadata('syntilioapi');

        System.assertEquals(calloutAPIEndpointMock + '/clientslocations?locationId=4', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());
        
        HttpResponse response = new HttpResponse();
        String responseBody = '{"clients":[{"id":111,"firstName":"Test","lastName":"Client1","emailAddress":"test1@example.com","mobilePhone":"1234567890"},{"id":222,"firstName":"Test","lastName":"Client2","emailAddress":"test2@example.com","mobilePhone":"1234567890"}],"locations":[{"id":123,"clientId":111},{"id":123,"clientId":222}]}';
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(200);
        return response;
    }
}