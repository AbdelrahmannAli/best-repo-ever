@NamespaceAccessible
public with sharing class FetchClientLocationDataProcessor {
    
    @NamespaceAccessible
    public static ResponseMessage filterExistingLocations(List<Syntilio.FetchClientModel> fetchClientModelList, String externalSystem, String accountId) {
        // ResponseMessage locationIdResponse = Syntilio.CareHubUtilities.getLocationId(accountId, externalSystem);
        
        // if (locationIdResponse.type == Syntilio.ResponseMessage.MessageType.ERROR) {
        //     return locationIdResponse;
        // }
        
        // String locationIdStr = (String) locationIdResponse.data;
        // List<Schema.Location> locationSfIds = [SELECT Id FROM Location WHERE Syntilio__LocationId__c = :locationIdStr WITH SECURITY_ENFORCED];
        // if (locationSfIds.size() == 0) {
        //     return new ResponseMessage(
        //         '',
        //         'No location found',
        //         Syntilio.ResponseMessage.MessageType.ERROR
        //     );
        // }
        
        // Id locationSfId = locationSfIds[0].Id;
        Set<String> locationIds = new Set<String>();
        List<Schema.Location> newLocations = new List<Schema.Location>();
        
        List<Schema.Location> existingLocations = [SELECT Id, Syntilio__LocationId__c FROM Location WHERE Syntilio__ExternalSystemId__r.Syntilio__ApiName__c = :externalSystem AND Syntilio__AccountId__c = :accountId WITH SECURITY_ENFORCED];
        List<String> existingLocationIds = new List<String>();
        for (Schema.Location existingLocation : existingLocations) {
            existingLocationIds.add((String)existingLocation.Syntilio__LocationId__c);
        }
        
        List<Schema.Location> combinedLocations = new List<Schema.Location>();
        
        for (Syntilio.FetchClientModel client: fetchClientModelList) {
            if(client.locations != null && !client.locations.isEmpty())
                combinedLocations.addAll(client.locations);
        }
        
        for (Schema.Location location: combinedLocations) {
            String locationId = location.Syntilio__LocationId__c;
            if (locationIds.contains(locationId) || existingLocationIds.contains(locationId)) {
                continue;
            }
            locationIds.add(locationId);
            // location.ParentLocationId = locationSfId;
            location.Syntilio__AccountId__c = accountId;
            location.Syntilio__ExternalSystemId__c = (String) Syntilio.CareHubUtilities.getExternalSystemId(externalSystem).data;
            newLocations.add(location);
        }
        return new ResponseMessage(
            newLocations,
            'Locations filtered',
            Syntilio.ResponseMessage.MessageType.SUCCESS
        );
    }
    
    
    @NamespaceAccessible
    public static ResponseMessage insertLocations(List<Schema.Location> locations, List<Id> clientIds) {
        if (locations.size() == 0) return new ResponseMessage(
            '',
            'No new locations to insert',
            Syntilio.ResponseMessage.MessageType.SUCCESS
        );
        
        List<Database.SaveResult> insertedLocations = Syntilio.UpsertToDatabase.insertAction(locations, false);            
        
        Syntilio.CareHubUtilities.createTasks(insertedLocations, 'Location', clientIds, 'Error while inserting locations',  'High');
        
        Boolean allLocationsFailed = true;
        
        for (Database.SaveResult insertedLocation : insertedLocations) {
            allLocationsFailed = allLocationsFailed && !insertedLocation.isSuccess();
        }
        
        if (allLocationsFailed) {
            return new ResponseMessage(
                '',
                'Failed to insert locations',
                Syntilio.ResponseMessage.MessageType.ERROR
            );
        } else {
            return new ResponseMessage(
                '',
                'Some locations failed to be inserted',
                Syntilio.ResponseMessage.MessageType.WARNING
            );
        }
    }
    
    @NamespaceAccessible
    public static ResponseMessage connectContactsToLocations(List<Syntilio.FetchClientModel> clients, String externalSystem, String accountId) {
        try {
            ResponseMessage externalSystemIdResponse = Syntilio.CareHubUtilities.getExternalSystemId(externalSystem);
            if (externalSystemIdResponse.type == Syntilio.ResponseMessage.MessageType.ERROR) {
                return externalSystemIdResponse;
            }
            String externalSystemId = (String) externalSystemIdResponse.data;
            List<Syntilio__ExternalId__c> externalIds = [SELECT Syntilio__Id__c, Syntilio__ContactId__c FROM Syntilio__ExternalId__c WHERE Name LIKE '%clientId%' AND Syntilio__ExternalSystemId__c = :externalSystemId WITH SECURITY_ENFORCED];
            
            Map<String, Id> externalIdToSfIdMap = new Map<String, Id>();
            for (Syntilio__ExternalId__c externalId : externalIds) {
                externalIdToSfIdMap.put(externalId.Syntilio__Id__c, externalId.Syntilio__ContactId__c);
            }
            
            List<Schema.Location> locations = [SELECT Id, Syntilio__LocationId__c FROM Location WHERE Syntilio__AccountId__c = :accountId AND Syntilio__ExternalSystemId__c = :externalSystemId WITH SECURITY_ENFORCED];
            Map<String, Id> locationIdToSfIdMap = new Map<String, Id>();
            for (Schema.Location location : locations) {
                locationIdToSfIdMap.put((String)location.Syntilio__LocationId__c, location.Id);
            }
            
            List<Syntilio__ContactToLocation__c> contactToLocations = new List<Syntilio__ContactToLocation__c>();
            for (FetchClientModel client: clients) {
                // Skip if there are no associated locations
                if (client.locations == null || client.locations.isEmpty()) {
                    continue;
                }
                
                for (Schema.Location location: client.locations) {
                    String clientId = client.externalIds[0].Syntilio__Id__c;
                    String locationId = location.Syntilio__LocationId__c;
                    
                    if (String.isBlank(locationId) || String.isBlank(clientId)) {
                        continue; // Avoid creating locations for clients or locations that don't exist.
                    }
                    
                    Id locationSfId = locationIdToSfIdMap.get(locationId);
                    Id clientSfId = externalIdToSfIdMap.get(clientId);
                    
                    if (clientSfId == null || locationSfId == null) {
                        continue; // Avoid creating locations for clients or locations that don't exist.
                    }
                    
                    Syntilio__ContactToLocation__c contactToLocation = new Syntilio__ContactToLocation__c();
                    contactToLocation.Syntilio__ContactId__c = clientSfId;
                    contactToLocation.Syntilio__IsMainLocation__c = true;
                    contactToLocation.Syntilio__LocationId__c = locationSfId;
                    contactToLocations.add(contactToLocation);
                }
            }
            
            if (contactToLocations.size() == 0) {
                return new ResponseMessage(
                    '',
                    'No new contact to location connections to insert',
                    Syntilio.ResponseMessage.MessageType.SUCCESS
                );
            }
            
            List<Database.SaveResult> insertedContactToLocations = Syntilio.UpsertToDatabase.insertAction(contactToLocations, false);
            List<String> contactIds = new List<String>();
            for (Syntilio__ContactToLocation__c contactToLocation : contactToLocations) {
                contactIds.add((String)contactToLocation.Syntilio__ContactId__c);
            }
            Syntilio.CareHubUtilities.createTasks(insertedContactToLocations, 'Contact', contactIds, 'Error while connecting contact to locations', 'High');
            return new ResponseMessage(
                null,
                'Contact to location connections inserted',
                Syntilio.ResponseMessage.MessageType.SUCCESS
            );
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
        return new ResponseMessage(
            null,
            'Error while connecting contact to locations',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
    }
    
}