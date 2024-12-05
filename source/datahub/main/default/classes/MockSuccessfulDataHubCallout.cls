@namespaceAccessible @isTest
public with sharing class MockSuccessfulDataHubCallout implements HttpCalloutMock {
    
    @NamespaceAccessible public String method { get; set; }
    @NamespaceAccessible public String objectTypeName { get; set; }
    @NamespaceAccessible public String objectBody { get; set; }
    @NamespaceAccessible public String responseBody { get; set; }
    
    @NamespaceAccessible 
    public MockSuccessfulDataHubCallout(String method, String objectTypeName, String objectBody, String responseBody) {
        this.method = method;
        this.objectTypeName = objectTypeName;
        this.objectBody = objectBody;
        this.responseBody = responseBody;
    }

    @NamespaceAccessible 
    public MockSuccessfulDataHubCallout(String method, String objectTypeName, String objectBody) {
        this.method = method;
        this.objectTypeName = objectTypeName;
        this.objectBody = objectBody;
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
        if(objectTypeName == 'contact')
            response.setBody('[ { "StatusCode": 200, "Success": true, "Message": "Reason Phrase: OK, Error: ", "responseData": { "id": 4214, "firstName": "", "identificationNo": "4214", "dateOfBirth": "1960-07-15T00:00:00", "preferredNameType": "0", "lastName": "Jansen", "birthName": "Jansen", "partnerName": "none", "initials": "W", "prefix": "", "birthNamePrefix": "", "partnerNamePrefix": "", "gender": "U", "emailAddress": "jansen@nl.com", "mobilePhone": "23232232", "updatedAt": "2022-12-05T16:08:56+00:00", "createdAt": "2022-12-05T16:01:47+00:00", "givenName": "", "civilStatus": 0, "hometown": "", "nationality": "", "language": "", "religion": "none", "careAllocations": [], "secretClient": false, "uuid": "a489b408-b198-407a-9fa0-e302567c5256" }, "ProviderName": "Salesforce:ExpertcareDev", "StatusCode": 200, "ExcludedMappings": { "Id": "01140rbjrfvnhm", "Phone": "+31-238728372", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" } } ]');
        else if(objectTypeName == 'file')
            response.setBody('[ { "StatusCode": 200, "Success": true, "Message": "Reason Phrase: OK, Error: ", "responseData": { "uploadId": "8e964fef-06be-43e3-88a7-f0c9c48583dc" }, "ProviderName": "Ons", "StatusCode": 200, "ExcludedMappings": {} } ]');
        else if(objectTypeName == 'clientlocations')
            response.setBody('[ { "StatusCode": 200, "Success": true, "Message": "Reason Phrase: OK, Error: ", "responseData": { "locations": [{"name": "Location 1", "id": 1}, {"name": "Location 2", "id": 2}] }, "ProviderName": "Ons", "StatusCode": 200, "ExcludedMappings": {} } ]');
        else if(objectTypeName == 'Syntilio__MedicalReport__c')
            response.setBody('{"Twb_Ons": []}');
        else if(objectTypeName == 'postalcodeinfo')
            response.setBody(this.responseBody != null? this.responseBody : '{"ZipCodeStack": [{"code": "3067", "countryCode": "NL", "city": "Amsterdam", "state": "Zuid-Holland"}]}');
        else
            response.setBody('[ { "StatusCode": 200, "Success": true, "Message": "Reason Phrase: OK, Error: ", "responseData": {}, "ProviderName": "Ons", "StatusCode": 200, "ExcludedMappings": {} } ]');
        response.setStatusCode(200);
        return response;
    }
}