@NamespaceAccessible
public with sharing class RegisterNewClientsController {
    @NamespaceAccessible
    public static ResponseMessage fetchClient(String clientId, String accountId, String externalSystem) {
        try {
            Syntilio.DataHubSyncModel.isSyncing = true;
            ResponseMessage responseMessage = Syntilio.CareHubUtilities.getLocationId(accountId, externalSystem);
            String locationId = (String) responseMessage.data;
            
            List<Account> account = [SELECT Syntilio__ApiName__c FROM Account WHERE Id = :accountId WITH SECURITY_ENFORCED ];
            String apiName = account[0].Syntilio__ApiName__c;   

            String endpoint = 'client';
            String queryParams = '?clientId=' + clientId + '&locationId=' + locationId;

            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
            destinationRecord.destinationName = apiName;
            destinationRecord.technology = externalSystem;
            destinationRecordList.Add(destinationRecord);
            String serializedDestinationRecordList = JSON.serialize(destinationRecordList);

            HttpResponse response = Syntilio.DataHubCallout.onGet(endpoint, queryParams, serializedDestinationRecordList);
            if (response.getStatusCode() >= 300 || response.getStatusCode() == 0) {
                String message = response.getStatusCode() == 401 ? 'Org is not authorized to make this action' : 'Error while fetching client';
                if(response.getStatusCode() == 404) {
                    message = 'Client not found';
                }
                Syntilio.HandleException.logExceptionAsString('Invalid response', message, response.getBody(), 19, 'fetchClient', 'RegisterNewClientsController', 'Syntilio', 'Apex');
                Syntilio.DataHubSyncModel.isSyncing = false;
                return new ResponseMessage(
                    null,
                    message,
                    Syntilio.ResponseMessage.MessageType.ERROR
                );
            }
            String responseKey = destinationRecord.destinationName + '_' + destinationRecord.technology;
            Object responseObj = JSON.deserializeUntyped(response.getBody());
            Map<String, Object> responseObjMap = (Map<String, Object>) responseObj;
            
            List<Object> responseList = (List<Object>) responseObjMap.get(responseKey);
            string responseListStr = JSON.serialize(responseList);

            List<Object> responseBodyList = (List<Object>) JSON.deserializeUntyped(responseListStr);
            List<Syntilio.FetchClientModel> fetchClientModelList = (List<Syntilio.FetchClientModel>) JSON.deserialize(JSON.serialize(responseBodyList), List<Syntilio.FetchClientModel>.class);

            if (fetchClientModelList == null || fetchClientModelList.size() == 0) {
                Syntilio.HandleException.logExceptionAsString('Error while fetching client:', 'No client found with the given id', response.getBody(), 40, 'fetchClient', 'RegisterNewClientsController', 'Syntilio', 'Apex');
                Syntilio.DataHubSyncModel.isSyncing = false;
                return new ResponseMessage(
                    null,
                    'No client found with the given id',
                    Syntilio.ResponseMessage.MessageType.ERROR
                );
            }
            Syntilio.DataHubSyncModel.isSyncing = false;
            return new ResponseMessage(
                (List<Syntilio.FetchClientModel>)fetchClientModelList,
                'Client fetched successfully',
                Syntilio.ResponseMessage.MessageType.SUCCESS
            );
        } catch (Exception e) {
            Syntilio.HandleException.logException(e);
        }
        Syntilio.DataHubSyncModel.isSyncing = false;
        return new ResponseMessage(
            null,
            'Error while fetching client',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
    }

    @AuraEnabled
    public static String getClientInfo(String clientId, String accountId, String externalSystem) {
        try {
            Boolean clientExistence = checkClientExistence(clientId, accountId, externalSystem);

            if (clientExistence) {
                ResponseMessage responseMessage = new ResponseMessage(
                    '',
                    'Client already exists',
                    Syntilio.ResponseMessage.MessageType.ERROR
                );
                return responseMessage.serialize();
            }

            ResponseMessage fetchClientRes = fetchClient(clientId, accountId, externalSystem);
            List<Syntilio.FetchClientModel> fetchClient = (List<Syntilio.FetchClientModel>) fetchClientRes.data;
            String msgStr = fetchClientRes.message;

            if (fetchClientRes.type == ResponseMessage.MessageType.ERROR) {
                return fetchClientRes.serialize();
            }

            return new ResponseMessage(
                JSON.serialize(fetchClient.get(0)),
                'Client fetched successfully',
                Syntilio.ResponseMessage.MessageType.SUCCESS
            ).serialize();
        } catch (Exception e) {
            Syntilio.HandleException.logException(e);
        }

        return new ResponseMessage(
            '',
            'Error while geting clients info',
            Syntilio.ResponseMessage.MessageType.ERROR
        ).serialize();
    }

    @NamespaceAccessible
    public static Boolean checkClientExistence(String clientId, String accountId, String externalSystem) {

        ResponseMessage externalSystemIdresponse = Syntilio.CareHubUtilities.getExternalSystemId(externalSystem);
        Id externalSystemId = (Id) externalSystemIdresponse.data;
        List<Syntilio__ExternalId__c> clients = [SELECT Id FROM Syntilio__ExternalId__c WHERE Name = 'clientId' AND Syntilio__Id__c = :clientId AND Syntilio__ContactId__r.AccountId = :accountId AND Syntilio__ExternalSystemId__c = :externalSystemId WITH SECURITY_ENFORCED];
        if (clients.size() > 0) {
            return true;
        }
        return false;
    }


    @AuraEnabled
    public static String createContact(String client, String externalSystem, String accountId) {
        try {
            if (client == null || client == '') {
                return new ResponseMessage(
                    '',
                    'Client is required',
                    Syntilio.ResponseMessage.MessageType.ERROR
                ).serialize();
            }
            Syntilio.FetchClientModel fetchClientModel = (Syntilio.FetchClientModel) JSON.deserialize(client, Syntilio.FetchClientModel.class);
            ResponseMessage insertedContactsResponse = Syntilio.FetchClientDataProcessor.insertContacts(new List<FetchClientModel>{fetchClientModel}, externalSystem, accountId);
            Map<String, Object> insertedContacts = (Map<String, Object>) insertedContactsResponse.data;
            List<Id> insertedIds = (List<Id>) insertedContacts.get('ids');
            Syntilio.FetchClientDataProcessor.insertExternalIds(new List<FetchClientModel>{fetchClientModel}, insertedIds, externalSystem);
            
            ResponseMessage locationsResponse = Syntilio.FetchClientLocationDataProcessor.filterExistingLocations(new List<FetchClientModel>{fetchClientModel}, externalSystem, accountId);
            List<Schema.Location> locations = (List<Schema.Location>) locationsResponse.data;
            Syntilio.FetchClientLocationDataProcessor.insertLocations(locations, insertedIds);
            Syntilio.FetchClientLocationDataProcessor.connectContactsToLocations(new List<FetchClientModel>{fetchClientModel}, externalSystem, accountId);
            return new ResponseMessage(
                '',
                'Client created successfully',
                Syntilio.ResponseMessage.MessageType.SUCCESS
            ).serialize();
        } catch (Exception e) {
            Syntilio.HandleException.logException(e);
        }
        return new ResponseMessage(
            '',
            'Error while creating client',
            Syntilio.ResponseMessage.MessageType.ERROR
        ).serialize();
    }
}