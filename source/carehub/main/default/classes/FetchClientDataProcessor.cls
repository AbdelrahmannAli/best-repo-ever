@NamespaceAccessible
public with sharing class FetchClientDataProcessor {

    @NamespaceAccessible
    public static Map<String, List<Syntilio.FetchClientModel>> filterClients(List<Syntilio.FetchClientModel> fetchClientModelList, String externalSystem, String accountId) {
        List<Syntilio__ExternalId__c> clientsExternalIds = [
            SELECT Syntilio__ExternalSystemId__r.Syntilio__ApiName__c, Syntilio__Id__c FROM Syntilio__ExternalId__c 
            WHERE Name = 'clientId' AND Syntilio__ExternalSystemId__r.Syntilio__ApiName__c = :externalSystem 
            AND Syntilio__ContactId__r.AccountId = :accountId
            WITH SECURITY_ENFORCED
        ];

        Set<String> clientIds = new Set<String>();

        for (Syntilio__ExternalId__c clientExternalId : clientsExternalIds) {
            clientIds.add(clientExternalId.Syntilio__Id__c);
        }

        List<Syntilio.FetchClientModel> notExistingClients = new List<Syntilio.FetchClientModel>();
        List<Syntilio.FetchClientModel> existingClients = new List<Syntilio.FetchClientModel>();

        for(Syntilio.FetchClientModel client: fetchClientModelList) {
            String clientId = client.externalIds[0].Syntilio__Id__c;
            if (clientIds.contains(clientId)) {
                existingClients.add(client);
                continue;
            }
            clientIds.add(clientId);
            notExistingClients.add(client);
        }
        Map<String, List<Syntilio.FetchClientModel>> result = new Map<String, List<Syntilio.FetchClientModel>>();
        result.put('existing', existingClients);
        result.put('notExisting', notExistingClients);
        return result;
    }

    @NamespaceAccessible
    public static ResponseMessage insertContacts(List<Syntilio.FetchClientModel> fetchClientModelList, String externalSystem, String accountId) {
        try {
            Map<String, Object> response;
            List<Contact> contactsToBeInserted = new List<Contact>();
            Id contactRecordTypeId;
            
            // List<Account> recordInternalOwnerId = new List<Account>([SELECT OwnerId FROM Account WHERE Id =: accountId WITH SECURITY_ENFORCED]);

            User recordInternalOwner = [SELECT Id FROM User WHERE Name = 'Automated Process' WITH SECURITY_ENFORCED LIMIT 1];

            contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
            for (Syntilio.FetchClientModel client : fetchClientModelList) {
                client.contact.AccountId = accountId;
                client.contact.RecordTypeId = contactRecordTypeId;
                client.contact.OwnerId = recordInternalOwner.Id;
                contactsToBeInserted.add(client.contact);
            }

            if (contactsToBeInserted.size() == 0) {
                ResponseMessage responseMessage = new ResponseMessage(
                    null,
                    'No new clients to be inserted',
                    ResponseMessage.MessageType.INFO
                );
                return responseMessage;
            }

            
            List<Database.SaveResult> insertedContacts = Syntilio.UpsertToDatabase.insertAction(contactsToBeInserted, false);
            List<Id> accountIds = new List<Id>();

            for (Integer i = 0; i < insertedContacts.size(); i++) {
                accountIds.add(accountId);
            }

            Syntilio.CareHubUtilities.createTasks(insertedContacts, 'Account', accountIds, 'Error while inserting clients', 'High');

            Map<Id, Syntilio.FetchClientModel> fetchClientModelMap = new Map<Id, Syntilio.FetchClientModel>();
            for (Syntilio.FetchClientModel model : fetchClientModelList) {
                fetchClientModelMap.put(model.contact.Id, model);
            }
            
            List<Syntilio.FetchClientModel> insertedFetchClientModel = new List<Syntilio.FetchClientModel>();
            List<Id> insertedIds = new List<Id>();
            Boolean isFailed = false;
            
            for (Database.SaveResult contact : insertedContacts) {
                if (!contact.isSuccess()) {
                    isFailed = true;
                    continue;
                }
                
                Id insertedId = contact.getId();
                insertedIds.add(insertedId);
                
                // Retrieve the corresponding FetchClientModel from the map
                if (fetchClientModelMap.containsKey(insertedId)) {
                    insertedFetchClientModel.add(fetchClientModelMap.get(insertedId));
                }
            }

            ResponseMessage responseMessage;
            if (isFailed) {
                responseMessage = new ResponseMessage(
                    new Map <String, Object>{
                        'ids' => insertedIds,
                        'insertedClients' => insertedFetchClientModel
                    },
                    'Some records insertion failed due to missing required fields in the client data.',
                    Syntilio.ResponseMessage.MessageType.WARNING
                );
            } else {
                responseMessage = new ResponseMessage(
                    new Map <String, Object>{
                        'ids' => insertedIds,
                        'insertedClients' => insertedFetchClientModel
                    },
                    'Clients inserted successfully',
                    Syntilio.ResponseMessage.MessageType.SUCCESS
                );
            }
            return responseMessage;
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
        return new ResponseMessage(null, 'Error while inserting clients', ResponseMessage.MessageType.ERROR);
    }

    @NamespaceAccessible
    public static ResponseMessage insertExternalIds(List<Syntilio.FetchClientModel> responseList, List<Id> insertedClient, String externalSystem) {
        try {
            ResponseMessage externalSystemIdResponse = Syntilio.CareHubUtilities.getExternalSystemId(externalSystem);
            if (externalSystemIdResponse.type == ResponseMessage.MessageType.ERROR) {
                return externalSystemIdResponse;
            }
            String externalSystemId = (String) externalSystemIdResponse.data;
            List<Syntilio__ExternalId__c> externalIdsToBeInserted = new List<Syntilio__ExternalId__c>();
            for (Integer i = 0; i < responseList.size(); i++) {
                List<Syntilio__ExternalId__c> clientExternalIds = responseList[i].externalIds;
                for (Syntilio__ExternalId__c externalIdRecord : clientExternalIds){
                    if(externalIdRecord != null && externalIdRecord.Name != null && externalIdRecord.Name != ''){
                        externalIdRecord.Syntilio__ExternalSystemId__c = externalSystemId;          
                        externalIdRecord.Syntilio__ContactId__c = insertedClient[i];
                        externalIdsToBeInserted.add(externalIdRecord);
                    }
                }
            }
            if (externalIdsToBeInserted.size() == 0) {
                ResponseMessage responseMessage = new ResponseMessage(
                    null,
                    'No new external ids to be inserted',
                    ResponseMessage.MessageType.INFO
                );
                return responseMessage;
            }
            List<Database.SaveResult> insertedExternalIds = Syntilio.UpsertToDatabase.insertAction(externalIdsToBeInserted, false);
            Syntilio.CareHubUtilities.createTasks(insertedExternalIds, 'Contact', insertedClient, 'Error while inserting external ids',  'High');
            return new ResponseMessage(null, 'External ids inserted successfully', ResponseMessage.MessageType.SUCCESS);
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
        return new ResponseMessage(null, 'Error while inserting external ids', ResponseMessage.MessageType.ERROR);
    }

    @AuraEnabled
    public static String getClientsFromDB(String accountId, String externalSystem) {
        
        if (accountId == null || externalSystem == null) {
            return JSON.serialize(new ResponseMessage('', 'Account Id or External System is null', ResponseMessage.MessageType.ERROR));
        }

        try {
            ResponseMessage externalSystemIdResponse = Syntilio.CareHubUtilities.getExternalSystemId(externalSystem);
            String externalSystemId = (String) externalSystemIdResponse.data;
            

            List<Schema.Location> locations = [SELECT Id, Syntilio__LocationId__c, Name FROM Location WHERE Syntilio__AccountId__c = :accountId AND Syntilio__ExternalSystemId__c = :externalSystemId AND ParentLocationId = null WITH SECURITY_ENFORCED];
            Id sfLocationId = locations[0].Id;
            
            List<Syntilio__ContactToLocation__c> contactsToLocationsForLocationId = [SELECT Syntilio__ContactId__c FROM Syntilio__ContactToLocation__c WHERE Syntilio__LocationId__c = :sfLocationId WITH SECURITY_ENFORCED];
            Set<Id> sfContactIds = new Set<Id>();
            
            for (Syntilio__ContactToLocation__c contactToLocation : contactsToLocationsForLocationId) {
                sfContactIds.add(contactToLocation.Syntilio__ContactId__c);
            }
            List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, MobilePhone, GenderIdentity, Birthdate FROM Contact WHERE Id IN :sfContactIds WITH SECURITY_ENFORCED];
            List<Syntilio__ContactToLocation__c> contactsToLocationsForContactIds = [SELECT Syntilio__ContactId__c, Syntilio__LocationId__c FROM Syntilio__ContactToLocation__c WHERE Syntilio__ContactId__c IN :sfContactIds WITH SECURITY_ENFORCED];

            Map<Id, Set<Id>> contactLocations = new Map<Id, Set<Id>>();
            Set<Id> locationSfIds = new Set<Id>();
            
            for (Syntilio__ContactToLocation__c contactToLocation : contactsToLocationsForContactIds) {
                Id contactId = contactToLocation.Syntilio__ContactId__c;
                Id locationId = contactToLocation.Syntilio__LocationId__c;
                locationSfIds.add(locationId);
                if (contactLocations.containsKey(contactId)) {
                    Set<Id> locationIds = contactLocations.get(contactId);
                    locationIds.add(locationId);
                    contactLocations.put(contactId, locationIds);
                } else {
                    Set<Id> locationIds = new Set<Id>();
                    locationIds.add(locationId);
                    contactLocations.put(contactId, locationIds);
                }
            }

            List<Schema.Location> locationsList = [SELECT Id, Name, Syntilio__LocationId__c FROM Location WHERE Id IN :locationSfIds WITH SECURITY_ENFORCED];

            Map<Id, Schema.Location> locationSfIdToLocationMap = new Map<Id, Schema.Location>();
            for (Schema.Location location : locationsList) {
                locationSfIdToLocationMap.put(location.Id, location);
            }

            List<Object> contactsList = new List<Object>();
            for (Contact contact : contacts) {
                Map<String, Object> contactMap = new Map<String, Object>();
                contactMap.put('firstName', contact.FirstName);
                contactMap.put('lastName', contact.LastName);
                contactMap.put('emailAddress', contact.Email);
                contactMap.put('mobilePhone', contact.MobilePhone);
                contactMap.put('gender', contact.GenderIdentity);
                contactMap.put('birthdate', contact.Birthdate);
                String clientLocations = '';
                Set<Id> locationIds = contactLocations.get(contact.Id);
                List<Object> locationsListForContact = new List<Object>();
                for (Id locationId : locationIds) {
                    Schema.Location location = locationSfIdToLocationMap.get(locationId);
                    clientLocations = clientLocations + location.Name + ', ';
                }
                clientLocations = clientLocations.removeEnd(', ');
                contactMap.put('locations', clientLocations);
                contactsList.add(contactMap);
            }
            ResponseMessage responseMessage = new ResponseMessage(JSON.serialize(contactsList), 'Success', ResponseMessage.MessageType.SUCCESS);
            return responseMessage.serialize();
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
        ResponseMessage responseMessage = new ResponseMessage('', 'Error while getting clients from db', ResponseMessage.MessageType.ERROR);
        return responseMessage.serialize();
    }

}