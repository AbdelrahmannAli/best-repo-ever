global with sharing class FetchAllClientsHandler implements callable {
    private static String jobName = 'FetchAllClientsHandler';

    public static void fetchAllClients() {
        Account twb = [
            SELECT Id, Name
            FROM Account WHERE Syntilio__ApiName__c = 'Twb'
        ]; 

        ID contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();

        String accountId = twb.Id;
        List<String> accountIds = new List<String>();
        accountIds.add(accountId);
        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Contact');
        Map<String, Set<String>> viableExternalSystemsPerAccount = viableExternalSystemsPerAccountId.get(accountId);
        List<String> viableExternalSystems = new List<String>(viableExternalSystemsPerAccount.get(accountId));
        List<Syntilio.DataHubModel.Destination> destList = Syntilio.DataHubUtilities.getDestinationList(accountId, new Set<String>(viableExternalSystems));
        String destinationsModelSerialized = JSON.serializePretty(destList);
        HttpResponse locationsApiResponse = Syntilio.DataHubCallout.onGet('allcontacts', '', destinationsModelSerialized);
        Map<String, Object> responseDeserialized = (Map<String, Object>) JSON.deserializeUntyped(locationsApiResponse.getBody());
        
        List<String> locationIds = new List<String>();
        for (String key : responseDeserialized.keySet()) {
            Map<String, Object> locationsMap = (Map<String, Object>) responseDeserialized.get(key);
            List<Object> clientsList = (List<Object>) locationsMap.get('clients');
            for (Object client : clientsList) {
                locationIds.add('' + (Integer) client);
                if(locationIds.size() == 150){
                    Database.executeBatch(new FetchClientsBatch(locationIds, destinationsModelSerialized, contactRecordTypeId,accountId), 50);
                    locationIds.clear();
                }
            }
        }
    } 

    public static Object handlePostActionsRecursively(
        Syntilio.DataHubModel.Destination destination, 
        Map<String, Object> responseDeserialized,
        List<Map<String, Object>> responsesToLog
    ){
        String destinationKey = String.isBlank(destination.destinationName)? destination.technology : destination.destinationName + '_' + destination.technology;
        Map<String, Object> destinationResponse;
        try{
            destinationResponse = (Map<String, Object>) responseDeserialized.get(destinationKey);
        }catch(Exception e){
            return responseDeserialized.get(destinationKey);
        }
        if(!destinationResponse.containsKey('postAction')){
			return responseDeserialized;
		}
		String postAction = (String) destinationResponse.get('postAction');
        String resultSerialized = JSON.serialize(destinationResponse.get('result'));

		HttpResponse postActionResponse = Syntilio.SyntilioHttpClient.getInstance().post(
            '/dynamic/' + postAction.toLowercase(), 
			resultSerialized, 
            new Map<String, String>{'Destinations' => destinationKey}
		);
        responsesToLog.add(new Map<String, Object>{
            'destinations' => destinationKey,
			'response' => postActionResponse,
			'objectTypeName' => postAction.toLowercase(),
			'action' => 'POST',
			'objectsBodySerialized' => resultSerialized,
			'queryParameters' => '' 
		});
        return handlePostActionsRecursively(destination, (Map<String, Object>) JSON.deserializeUntyped(postActionResponse.getBody()), responsesToLog);
    }
    
    global static HttpResponse onGetWithoutAuditTrails(String objectTypeName, String queryParameters, String destinationsModelSerialized) {
        if(String.isBlank(objectTypeName)){
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 11 , 'onGet', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        List<Map<String, Object>> responsesToLog = new List<Map<String, Object>>();
        try{
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
                
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().get('/dynamic/' + objectTypeName.toLowercase(), queryParameters, destinationsHeaders);
            Map<String, Object> responseDeserialized = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            try{
                for(Syntilio.DataHubModel.Destination destination : dataHubModelDestinationsList){
                    String destinationKey = String.isBlank(destination.destinationName)? destination.technology : destination.destinationName + '_' + destination.technology;
                    Object finalResult = handlePostActionsRecursively(destination, responseDeserialized, responsesToLog);
                    responseDeserialized.put(destinationKey, finalResult);
            	}
            	response.setBody(JSON.serialize(responseDeserialized));
            }catch(Exception postActionException){
            }
        }catch(Exception e){
            Syntilio.HandleException.LogException(e);
        }
        return response;
    }

    global Object call(String action, Map<String, Object> arguments) {
        switch on action.toLowerCase() {
            when 'onget' {
              return Syntilio.DataHubCallout.onGet((String)arguments.get('objectTypeName'), (String)arguments.get('queryParameters'), (String)arguments.get('destinationsModelSerialized'));
            }
            when 'ongetwithcallback' {
                return Syntilio.DataHubCallout.onGetWithCallback((String)arguments.get('objectTypeName'), (String)arguments.get('queryParameters'), (String)arguments.get('destinationsModelSerialized'), (Map<String, Object>)arguments.get('callbackArguments'), (Syntilio.Callback)arguments.get('callback'));
            }
            when 'onpost' {
                return Syntilio.DataHubCallout.onPost((String)arguments.get('objectTypeName'), (String)arguments.get('objectsBodySerialized'), (String)arguments.get('destinationsModelSerialized'));
            }
            when 'onput' {
                return Syntilio.DataHubCallout.onPut((String)arguments.get('objectTypeName'), (String)arguments.get('objectsBodySerialized'), (String)arguments.get('destinationsModelSerialized'));
            }
            when 'onpatch' {
                return Syntilio.DataHubCallout.onPatch((String)arguments.get('objectTypeName'), (String)arguments.get('objectsBodySerialized'), (String)arguments.get('destinationsModelSerialized'));
            }
            when 'ondelete' {
                return Syntilio.DataHubCallout.onDelete((String)arguments.get('objectTypeName'), (String)arguments.get('objectsBodySerialized'), (String)arguments.get('destinationsModelSerialized'));
            }
            when 'onhead' {
                return Syntilio.DataHubCallout.onHead((String)arguments.get('objectTypeName'), (String)arguments.get('objectsBodySerialized'), (String)arguments.get('destinationsModelSerialized'));
            }
            when else {
				Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'action ' + action + ' not implemented', 'Method in not implemented in the callable interface', 25, 'call', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
                return null;
            }
          }
    }

    @AuraEnabled
    public static void fetchAllClientsGenerator(Integer fromClient, Integer toClient, Integer chunkSize) {
        Account twb = [
            SELECT Id, Name
            FROM Account WHERE Syntilio__ApiName__c = 'Twb'
        ];

        ID contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();

        String accountId = twb.Id;
        List<String> accountIds = new List<String>();
        accountIds.add(accountId);
        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Contact');
        Map<String, Set<String>> viableExternalSystemsPerAccount = viableExternalSystemsPerAccountId.get(accountId);
        List<String> viableExternalSystems = new List<String>(viableExternalSystemsPerAccount.get(accountId));
        List<Syntilio.DataHubModel.Destination> destList = Syntilio.DataHubUtilities.getDestinationList(accountId, new Set<String>(viableExternalSystems));
        String destinationsModelSerialized = JSON.serializePretty(destList);
        List<String> clientsIds = new List<String>();
        List<String> clientsIdsFetch = new List<String>();
        for (Integer i = fromClient; i <= toClient; i++) 
            clientsIds.add('' + i);
        
        for (String clientId : clientsIds) {
            clientsIdsFetch.add('' + clientId);
            if(clientsIdsFetch.size() == chunkSize){
                Database.executeBatch(new FetchClientsBatch(clientsIdsFetch, destinationsModelSerialized, contactRecordTypeId,accountId), 50);
                clientsIdsFetch.clear();
            }
        }
    }    
}