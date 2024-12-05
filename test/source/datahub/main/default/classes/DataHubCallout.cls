/*************************************************************************   
@description Class is responsible for all the external Callouts through DataHub package*/
global with sharing class DataHubCallout implements callable{
    @TestVisible private static Boolean raiseException = false;
    
    /*************************************************************************   
@description The Get method in the DataHub package. It recieves three parameters, the synchronised object name, queryParameters and the intended target destinations to get such information.
-> If synchronised object name is empty, then the callout will not be performed and an exception log will be created
-> Only query parameters can be received to added in the http request 
-> It calls the composeDestinations method then uses the SyntilioHttpClient to send a get http request*/
    global static HttpResponse onGet(String objectTypeName, String queryParameters, String destinationsModelSerialized) {
        if(String.isBlank(objectTypeName)){
            //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 11 , 'onGet', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        List<Map<String, Object>> responsesToLog = new List<Map<String, Object>>();
        try{
            if(Test.isRunningTest() && Syntilio.DataHubCallout.raiseException == true) {
                throw new DmlException();
            }
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
                
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().get('/dynamic/' + objectTypeName.toLowercase(), queryParameters, destinationsHeaders);
            responsesToLog.add(new Map<String, Object>{
               'destinations' => destinations,
               'response' => response,
               'objectTypeName' => objectTypeName,
               'action' => 'GET',
               'objectsBodySerialized' => '',
               'queryParameters' => queryParameters 
            });
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
            
            logResponses(responsesToLog);

            if (response.getStatusCode() >= 400) {
                Syntilio.HandleException.logExceptionAsString('DataHubCallout Bad Response', 'Response code: ' + response.getStatusCode() + ', ResponseBody: ' + response.getBody(), String.valueOf(response), 29, 'onGet', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            }
        }catch(Exception e){
            Syntilio.HandleException.LogException(e);
        }
        return response;
    }
    
    private static Object handlePostActionsRecursively(
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
    
    private static void logResponses(List<Map<String, Object>> responsesToLog){
        String namespacePrefix = '';
        List<Organization> org = [SELECT NamespacePrefix FROM Organization WITH SECURITY_ENFORCED LIMIT 1000];
        if (org.size() > 0) {
            namespacePrefix = org[0].NamespacePrefix;
        }
        List<Syntilio__AuditTrail__c> auditTrails = new List<Syntilio__AuditTrail__c>();
		for(Map<String, Object> responseToLog : responsesToLog){
            Syntilio__AuditTrail__c log = new Syntilio__AuditTrail__c(
                Syntilio__Source__c = namespacePrefix,
                Syntilio__Destination__c = (String) responseToLog.get('destinations'),
                Syntilio__Status__c = String.valueOf(((HttpResponse)responseToLog.get('response')).getStatusCode()),
                Syntilio__Endpoint__c = '/dynamic/' + (String) responseToLog.get('objectTypeName'),
                Syntilio__ActionName__c = (String) responseToLog.get('action'),
                Syntilio__RequestBody__c = (String) responseToLog.get('objectsBodySerialized'),
                Syntilio__QueryParams__c = (String) responseToLog.get('queryParameters'),
                Syntilio__ResponseBody__c = ((HttpResponse)responseToLog.get('response')).getBody(),
                Syntilio__Timestamp__c = Datetime.now()
            );
            auditTrails.add(log);
        }
        Syntilio.UpsertToDatabase.insertAction(auditTrails,false);
    }

    global static HttpResponse onGetWithCallback(String objectTypeName, String queryParameters, String destinationsModelSerialized, Map<String, Object> callbackArguments, Syntilio.Callback callback) {
        if(String.isBlank(objectTypeName)){
            //String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, String source
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 11 , 'onGet', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        try{
            if(Test.isRunningTest() && Syntilio.DataHubCallout.raiseException == true) {
                throw new DmlException();
            }
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
                
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().get('/dynamic/' + objectTypeName.toLowercase(), queryParameters, destinationsHeaders);
            Syntilio.DataHubCallout.logCallOuts(destinations, String.valueOf(response.getStatusCode()), objectTypeName, 'GET', '', queryParameters, response.getBody());

            if (response.getStatusCode() >= 400) { 
                Syntilio.HandleException.logExceptionAsString('DataHubCallout Bad Response', 'Response code: ' + response.getStatusCode() + ', ResponseBody: ' + response.getBody(), String.valueOf(response), 29, 'onGet', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            }
            if(callback != null){
                if(callbackArguments == null){
                    callbackArguments = new Map<String, Object>();
                }
                callbackArguments.put('response', response);
                callback.execute(callbackArguments);
            }
            
        }catch(Exception e){
            Syntilio.HandleException.LogException(e);
        }
        return response;
    }
    
    /*************************************************************************   
@description The Post method in the DataHub package. It recieves three parameters, the synchronised object name, serialized object body and the intended target destinations to get such information.
-> If synchronised object name is empty, then the callout will not be performed and an exception log will be created
-> Any query or path parameters must be recieved in the format of object body (payload) of the http request 
-> It calls the composeDestinations method then uses the SyntilioHttpClient to send a post http request*/
    global static HttpResponse onPost(String objectTypeName, String objectsBodySerialized, String destinationsModelSerialized) {
        if(String.isBlank(objectTypeName)){
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 46 , 'onPost', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        try{
            if(Test.isRunningTest() && Syntilio.DataHubCallout.raiseException == true) {
                throw new DmlException();
            }
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().post('/dynamic/' + objectTypeName.toLowercase(), objectsBodySerialized, destinationsHeaders);
            
            Syntilio.DataHubCallout.logCallOuts(destinations, String.valueOf(response.getStatusCode()), objectTypeName, 'POST', objectsBodySerialized, '', response.getBody());

            if (response.getStatusCode() >= 400) { 
                Syntilio.HandleException.logExceptionAsString('DataHubCallout Bad Response', 'Response code: ' + response.getStatusCode() + ', ResponseBody: ' + response.getBody(), String.valueOf(response), 65, 'onPost', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            }
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return response;
    }
    
    
    /*************************************************************************   
@description The Put method in the DataHub package. It recieves three parameters, the synchronised object name, serialized object body and the intended target destinations to get such information.
-> If synchronised object name is empty, then the callout will not be performed and an exception log will be created
-> Any query or path parameters must be recieved in the format of object body (payload) of the http request 
-> It calls the composeDestinations method then uses the SyntilioHttpClient to send a put http request*/
    global static HttpResponse onPut(String objectTypeName, String objectsBodySerialized, String destinationsModelSerialized) {
        if(String.isBlank(objectTypeName)){
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 83 , 'onPut', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        try{
            if(Test.isRunningTest() && Syntilio.DataHubCallout.raiseException == true) {
                throw new DmlException();
            }
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().put('/dynamic/'+ objectTypeName.toLowercase(), objectsBodySerialized, destinationsHeaders);
            
            Syntilio.DataHubCallout.logCallOuts(destinations, String.valueOf(response.getStatusCode()), objectTypeName, 'PUT', objectsBodySerialized, '', response.getBody());
            
            if (response.getStatusCode() >= 400) { 
                Syntilio.HandleException.logExceptionAsString('DataHubCallout Bad Response', 'Response code: ' + response.getStatusCode() + ', ResponseBody: ' + response.getBody(), String.valueOf(response), 102, 'onPut', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            }
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return response;
    }
    
    /*************************************************************************   
@description The Patch method in the DataHub package. It recieves three parameters, the synchronised object name, serialized object body and the intended target destinations to get such information.
-> If synchronised object name is empty, then the callout will not be performed and an exception log will be created
-> Any query or path parameters must be recieved in the format of object body (payload) of the http request 
-> It calls the composeDestinations method then uses the SyntilioHttpClient to send a patch http request*/
    global static HttpResponse onPatch(String objectTypeName, String objectsBodySerialized, String destinationsModelSerialized) {
        if(String.isBlank(objectTypeName)){
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 119 , 'DataHubCallout onPatch method', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        try{
            if(Test.isRunningTest() && Syntilio.DataHubCallout.raiseException == true) {
                throw new DmlException();
            }
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().patch('/dynamic/'+ objectTypeName.toLowercase(), objectsBodySerialized, destinationsHeaders);
            
            Syntilio.DataHubCallout.logCallOuts(destinations, String.valueOf(response.getStatusCode()), objectTypeName, 'PATCH', objectsBodySerialized, '', response.getBody());
            
            if (response.getStatusCode() >= 400) { 
                Syntilio.HandleException.logExceptionAsString('DataHubCallout Bad Response', 'Response code: ' + response.getStatusCode() + ', ResponseBody: ' + response.getBody(), String.valueOf(response), 138, 'onPatch', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            }
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return response;
    }
    
    /*************************************************************************   
@description The Delete method in the DataHub package. It recieves three parameters, the synchronised object name, serialized object body and the intended target destinations to get such information.
-> If synchronised object name is empty, then the callout will not be performed and an exception log will be created
-> Any query or path parameters must be recieved in the format of object body (payload) of the http request 
-> It calls the composeDestinations method then uses the SyntilioHttpClient to send a delete http request*/
    global static HttpResponse onDelete(String objectTypeName, String objectsBodySerialized, String destinationsModelSerialized) {
        if(String.isBlank(objectTypeName)){
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 155 , 'DataHubCallout onDelete method', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        try{
            if(Test.isRunningTest() && Syntilio.DataHubCallout.raiseException == true) {
                throw new DmlException();
            }
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().del('/dynamic/' + objectTypeName.toLowercase(), objectsBodySerialized, destinationsHeaders);
            
            Syntilio.DataHubCallout.logCallOuts(destinations, String.valueOf(response.getStatusCode()), objectTypeName, 'DELETE', objectsBodySerialized, '', response.getBody());
            
            if (response.getStatusCode() >= 400) { 
                Syntilio.HandleException.logExceptionAsString('DataHubCallout Bad Response', 'Response code: ' + response.getStatusCode() + ', ResponseBody: ' + response.getBody(), String.valueOf(response), 174, 'onDelete', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            }
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return response;
    }
    
    /*************************************************************************   
@description The Delete method in the DataHub package. It recieves three parameters, the synchronised object name, serialized object body and the intended target destinations to get such information.
-> If synchronised object name is empty, then the callout will not be performed and an exception log will be created
-> Any query or path parameters must be recieved in the format of object body (payload) of the http request 
-> It calls the composeDestinations method then uses the SyntilioHttpClient to send a head http request*/
    global static HttpResponse onHead(String objectTypeName, String objectsBodySerialized, String destinationsModelSerialized) {
        if(String.isBlank(objectTypeName)){
            Syntilio.HandleException.logExceptionAsString('DataHubCallout Exception', 'Invalid objectTypeName', 'objectTypeName is empty or null' , 191 , 'onHead', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            return null;
        }
        
        HttpResponse response;
        List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList;
        String destinations;
        try{
            if(Test.isRunningTest() && Syntilio.DataHubCallout.raiseException == true) {
                throw new DmlException();
            }
            if(!String.isBlank(destinationsModelSerialized)){
                dataHubModelDestinationsList = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(destinationsModelSerialized, List<Syntilio.DataHubModel.Destination>.class);
                destinations = DataHubDestinations.composeDestinations(dataHubModelDestinationsList);
            }
            Map<String, String> destinationsHeaders = new Map<String, String>();
            
            if(!String.isBlank(destinations)){
                destinationsHeaders.put('Destinations', destinations);
            }
            
            response = Syntilio.SyntilioHttpClient.getInstance().head('/dynamic/' + objectTypeName.toLowercase(), objectsBodySerialized, destinationsHeaders);
            
            Syntilio.DataHubCallout.logCallOuts(destinations, String.valueOf(response.getStatusCode()), objectTypeName, 'HEAD', objectsBodySerialized, '', response.getBody());
            
            if (response.getStatusCode() >= 400) { 
                Syntilio.HandleException.logExceptionAsString('DataHubCallout Bad Response', 'Response code: ' + response.getStatusCode() + ', ResponseBody: ' + response.getBody(), String.valueOf(response), 210, 'onHead', 'DataHubCallout', 'Syntilio', Syntilio.HandleException.ExceptionSource.Apex.name());
            }
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return response;
    }

    public static void logCallOuts(String destinations, String statusCode, String objectTypeName, String action, String objectsBodySerialized, String queryParameters, String responseBody){
        String endpoint = '/dynamic/' + objectTypeName.toLowercase();
        String namespacePrefix = '';
        List<Organization> org = [SELECT NamespacePrefix FROM Organization WITH SECURITY_ENFORCED LIMIT 1000];
        if (org.size() > 0) {
            namespacePrefix = org[0].NamespacePrefix;
        }
        Syntilio.AuditTrailController.log(namespacePrefix, destinations, statusCode, endpoint, action, objectsBodySerialized, queryParameters, responseBody);
    }
    /*************************************************************************   
@description The call method provides functionality that other classes or packages can utilize and build upon.
-> String action which reflects the behavior for the method to exhibit.
-> Map<String,Object> arguments which reflects the arguments to be used by the specified action.*/
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
}