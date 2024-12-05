@NamespaceAccessible
public with sharing class FetchClientsController {
    @TestVisible static Boolean inTest = false;
    @TestVisible private static List<Syntilio__Notification__e> eventList = new List<Syntilio__Notification__e>();
    
    @AuraEnabled
    public static void notifyLwcWithFetchedClients(String message) {
        Syntilio__Notification__e notification = new Syntilio__Notification__e();
        notification.Syntilio__Message__c = message;
        Syntilio.FetchClientsController.eventList.add(notification);
        EventBus.publish(notification);
    }
    
    @AuraEnabled //MAIN Controller method that is called from the LWC compoenent //later enhancement we can receive the externalSystem id and avoid quering it
    public static String getClients(String accountId, String externalSystem) {
        try {
            Syntilio.FetchClientsController.fetchClients(accountId, externalSystem);
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
        ResponseMessage response = new ResponseMessage(
            '',
            'Please verify the accuracy of the provided location and external system data. If the issue persists, contact your system administrator for assistance.',
            ResponseMessage.MessageType.ERROR
        );
        return response.serialize();
    }
    @NamespaceAccessible
    public static void addParentLocationToClients(List<Syntilio.FetchClientModel> clients, String accountId, String externalSystem) {
        Schema.Location parentLocation = Syntilio.CareHubUtilities.getParentLocation(accountId, externalSystem);
        for (Syntilio.FetchClientModel client : clients) {
            client.locations.add(parentLocation);
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getSessionId() {
        return UserInfo.getSessionId();
    }
    
    @future(callOut=true)
    @AuraEnabled
    public static void fetchClients(String accountId, String externalSystem) {
        Syntilio.DataHubSyncModel.isSyncing = true;
        List<Account> account = [SELECT Syntilio__ApiName__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED];
        String apiName = account[0].Syntilio__ApiName__c;

        ResponseMessage responseMessage = Syntilio.CareHubUtilities.getLocationId(accountId, externalSystem);
        
        if (responseMessage.type == Syntilio.ResponseMessage.MessageType.ERROR) {
            notifyLwcWithFetchedClients(responseMessage.serialize());
            Syntilio.DataHubSyncModel.isSyncing = false;
            return;
        }
        
        String locationId = (String) responseMessage.data;
        fetchClientsByLocation(locationId, externalSystem, apiName, accountId);
    }

    @AuraEnabled
    public static void fetchClientsByLocation(String locationId, String externalSystem, String apiName, String accountId) {
        Syntilio.DataHubSyncModel.isSyncing = true;
        String endpoint = 'clienttest';
        String queryParams = '?clientId=' + locationId;
        
        List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
        destinationRecord.technology = externalSystem;
        destinationRecord.destinationName = apiName;
        destinationRecordList.Add(destinationRecord);
        
        String serializedDestinationRecordList = JSON.serialize(destinationRecordList);
        HttpResponse response = FetchAllClientsHandler.onGetWithoutAuditTrails(endpoint, queryParams, serializedDestinationRecordList);

        if(response.getStatusCode() == 500)
            response = FetchAllClientsHandler.onGetWithoutAuditTrails(endpoint, queryParams, serializedDestinationRecordList);

        String responseKey = String.isBlank(destinationRecord.destinationName)? destinationRecord.technology : destinationRecord.destinationName + '_' + destinationRecord.technology;
        Object responseObj = JSON.deserializeUntyped(response.getBody());
        Map<String, Object> responseObjMap = (Map<String, Object>) responseObj;
        
        List<Object> responseList = (List<Object>) responseObjMap.get(responseKey);
        if(!responseList.isEmpty()){
            string responseListStr = JSON.serialize(responseList);
            if(!Syntilio.FetchClientsController.inTest){
                handleFetchClients(responseListStr, accountId, externalSystem);
            }
        }
        
        // if(response.getStatusCode() >= 400 || response.getStatusCode() == 0) {
        //     ResponseMessage responseMsg = new ResponseMessage(
        //         '',
        //         'The request has failed due to issues with the external system or integration. Please contact your system admin.',
        //         Syntilio.ResponseMessage.MessageType.ERROR
        //     );
        //     notifyLwcWithFetchedClients(responseMsg.serialize());
        //     Syntilio.DataHubSyncModel.isSyncing = false;
        //     return;
        // }
        
        Syntilio.DataHubSyncModel.isSyncing = false;
    }
    
    @NamespaceAccessible
    public static void handleFetchClients(String responseBodyStr, String accountId, String externalSystem) {
        List<Object> responseBodyList = (List<Object>) JSON.deserializeUntyped(responseBodyStr);
        List<Syntilio.FetchClientModel> fetchClientModelList = (List<Syntilio.FetchClientModel>) JSON.deserialize(JSON.serialize(responseBodyList), List<Syntilio.FetchClientModel>.class);
        Map<String, String> resultMap = new Map<String, String>();
 
        List<Account> account = [SELECT Id, Syntilio__LastFetchedDate__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED];
        if (account.size() == 0) {
            return;
        }

        Map<String, List<Syntilio.FetchClientModel>> filteredClients = Syntilio.FetchClientDataProcessor.filterClients(fetchClientModelList, externalSystem, accountId);
        List<Syntilio.FetchClientModel> notExistingClients = filteredClients.get('notExisting');
        List<Syntilio.FetchClientModel> existingClients = filteredClients.get('existing');
        
        ResponseMessage insertedContactsResponse = Syntilio.FetchClientDataProcessor.insertContacts(notExistingClients, externalSystem, accountId);
        if (insertedContactsResponse.type == ResponseMessage.MessageType.ERROR || insertedContactsResponse.type == ResponseMessage.MessageType.INFO) {
            notifyLwcWithFetchedClients(insertedContactsResponse.serialize());
            return;
        }

        Map<String, Object> insertedContacts = (Map<String, Object>) insertedContactsResponse.data;
        List<Id> insertedContactsIds = (List<Id>) insertedContacts.get('ids');
        List<Syntilio.FetchClientModel> updatedClients = (List<Syntilio.FetchClientModel>) insertedContacts.get('insertedClients');
        
        ResponseMessage insertedExternalIdsResponse = Syntilio.FetchClientDataProcessor.insertExternalIds(updatedClients, insertedContactsIds, externalSystem);
        if (insertedExternalIdsResponse.type == ResponseMessage.MessageType.ERROR) {
            notifyLwcWithFetchedClients(insertedExternalIdsResponse.serialize());
            return;
        }

    //    addParentLocationToClients(updatedClients, accountId, externalSystem);
        
        ResponseMessage locationsResponse = Syntilio.FetchClientLocationDataProcessor.filterExistingLocations(updatedClients, externalSystem, accountId);
        if (locationsResponse.type == ResponseMessage.MessageType.ERROR) {
            notifyLwcWithFetchedClients(locationsResponse.serialize());
            return;
        }

        List<Schema.Location> locations = (List<Schema.Location>) locationsResponse.data;
        
        ResponseMessage insertedLocationsResponse = Syntilio.FetchClientLocationDataProcessor.insertLocations(locations, insertedContactsIds);
        if (insertedLocationsResponse.type == ResponseMessage.MessageType.ERROR) {
            notifyLwcWithFetchedClients(insertedLocationsResponse.serialize());
            return;
        }
        
        ResponseMessage connectContactsToLocationsResponse = Syntilio.FetchClientLocationDataProcessor.connectContactsToLocations(updatedClients, externalSystem, accountId);
        if (connectContactsToLocationsResponse.type == ResponseMessage.MessageType.ERROR) {
            notifyLwcWithFetchedClients(connectContactsToLocationsResponse.serialize());
            return;
        }
        notifyLwcWithFetchedClients(JSON.serialize(new ResponseMessage(
            '',
            '',
            ResponseMessage.MessageType.SUCCESS
        )));
        
        account[0].Syntilio__LastFetchedDate__c = Date.today();
        Syntilio.UpsertToDatabase.updateAction(account,false);
    }
    
}