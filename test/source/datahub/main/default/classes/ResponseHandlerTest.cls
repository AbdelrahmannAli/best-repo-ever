@isTest
public with sharing class ResponseHandlerTest {
    
    @testSetup
    public static void setup(){
        Account twbAccount = new Account(
                Name = 'Twb',
            	Syntilio__ApiName__c = 'Twb'
       	);
        insert twbAccount;
        Syntilio__ExternalSystem__c onsSystem = new Syntilio__ExternalSystem__c(
            Name = 'Ons',
            Syntilio__ApiName__c = 'Ons'
        );
        insert onsSystem;
        Syntilio__AccountExternalSystemAssociation__c twbAccountAssociation = new Syntilio__AccountExternalSystemAssociation__c(
            Name = 'Twb_Ons',
            Syntilio__AccountId__c = twbAccount.Id,
            Syntilio__ExternalSystemId__c = onsSystem.Id
        );
        insert twbAccountAssociation;
    }
    
	@isTest
    public static void handlePostResponse_test(){        
        try{
            
        	String objectTypeName = 'Contact';
			Map<String, Object> oneResponse = new Map<String, Object>();
            List<Object> resultIds = new List<Object>();
            Map<String, Object> resultId = new Map<String, Object>();
            resultId.put('Name', 'clientId');
            resultId.put('Id', '1234');
            resultIds.add(resultId);
            oneResponse.put('ResultIds', resultIds);
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('Twb_Ons', oneResponse);
            
            Map<String, Object> oneRequest = new Map<String, Object>();
            oneRequest.put('FirstName', 'Test First');
            oneRequest.put('LastName', 'Test Last');
            oneRequest.put('Email', 'test@testemail.com');
            List<Object> requestBody = new List<Object>();
            Map<String, Object> bigRequest = new Map<String, Object>();
            bigRequest.put('Twb_Ons', oneRequest);
            requestBody.add(bigRequest);
            
            List<Syntilio.DataHubModel.Destination> destinations = new List<Syntilio.DataHubModel.Destination>();
            Syntilio.DataHubModel.Destination destination = new Syntilio.DataHubModel.Destination();
            destination.technology = 'Ons';
            destination.destinationName = 'Twb';
            destinations.add(destination);
            
            String dataHubModelObjectBodySerialized = JSON.serializePretty(requestBody);
            String dataHubModelDestinationsSerialized = JSON.serializePretty(destinations);

            Test.startTest();
            Syntilio.ResponseHandler.handlePostResponse(objectTypeName, dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized, responseMap);
            Test.stopTest(); 
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__ExternalId__c> externalIds = [SELECT Id FROM Syntilio__ExternalId__c];
        System.assertNotEquals(0, externalIds.size());
    }
}