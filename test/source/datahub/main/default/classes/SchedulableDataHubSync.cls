// This the schedulable class for the cronjob specified by the user to synchronise data using DataHubSyncInfo
global  with sharing class SchedulableDataHubSync implements Schedulable {
    @Deprecated
    global static String objectName =  'Contact';
    @NamespaceAccessible
    public with sharing class SchedulableDataHubSyncGetCallback implements Syntilio.Callback {
        public void execute(Map<String, Object> arguments){
            try{
                String objectName = (String) arguments.get('objectName');
                HttpResponse response = (HttpResponse) arguments.get('response');
                Map<String,Object> synchronisationResponse = (Map<String,Object>) Syntilio.DataHubSynchronisation.synchronizationHandler(objectName, response, true);
            }catch(Exception e){
                Syntilio.HandleException.logException(e);
            }
        }
    }

    global  void execute(SchedulableContext schedulableContext) {
        futureExecute();
    }
    global  static void futureExecute(){
        try{
            Datetime now = Datetime.now();
            // Get the fields that should be synced now where NextSyncDate <= now
            List<Syntilio__DataHubSyncInfo__c> fieldsToSync = Syntilio.DataHubSynchronisation.getDataHubSyncInfoFields(null, 'Pull', now);
            if(fieldsToSync.size() == 0){
                return;
            }

            // Get Set of externalSystems to sync from fieldsToSync
            Set<String> externalSystems = new Set<String>();
            Syntilio.DataHubUtilities.setupExternalSystemsAndPushMap(fieldsToSync, null, null, null, externalSystems);
            
            // Get destination for each account using AccountExternalSystemAssociation
            List<Syntilio.DataHubModel.Destination> destinationRecordList = Syntilio.DataHubUtilities.getDestinationListAllAccounts(externalSystems);
            String destinationsModelSerialized = JSON.serializePretty(destinationRecordList);
            
            // Get unique object names from fieldsToSync and attach the field that has the minimum LastSyncDate
            Map<String, Syntilio__DataHubSyncInfo__c> objectNamesLastSync = new Map<String, Syntilio__DataHubSyncInfo__c>();
            for(Syntilio__DataHubSyncInfo__c fieldToSync : fieldsToSync){
                if(objectNamesLastSync.get(fieldToSync.Syntilio__ObjectName__c) == null 
                    || fieldToSync.Syntilio__LastSyncDate__c < objectNamesLastSync.get(fieldToSync.Syntilio__ObjectName__c).Syntilio__LastSyncDate__c){
                    objectNamesLastSync.put(fieldToSync.Syntilio__ObjectName__c, fieldToSync);
                }
            }
            Map<String, HttpResponse> responsesMap = new Map<String, HttpResponse>();

            // Loop over the unique object names to synchronise 
            // (this is done using sending requests in a loop but should be handled by SyntilioApi using Batch request)
            for(String objectName : objectNamesLastSync.keySet()){
                // Format Object Name for the SyntilioAPI Request to find in Azure Table Storage
                // Example Contact -> Contacts, Syntilio__MedicalReport__c -> Reports
                String formattedObjectName = objectName.replace('Syntilio__', '').replace('__c', '') + 's';
                // Send query params anyway
                String formattedDatetime = objectNamesLastSync.get(objectName).Syntilio__LastSyncDate__c.format('yyyy-MM-dd\'T\'HH:mm:ss');
                String queryParams = '?since=' + formattedDatetime;

                Map<String, Object> callbackArguments = new Map<String, Object>{
                    'objectName' => objectName
                };
                // Call the future function for each request
                Syntilio.SchedulableDataHubSync.calloutExternalSystems(formattedObjectName, queryParams, destinationsModelSerialized, JSON.serializePretty(callbackArguments));
            }
        }catch (Exception e){
            Syntilio.HandleException.LogException(e);
        }
    }

    @future(callout=true)
    private static void calloutExternalSystems(String objectTypeName, String queryParameters, String destinationsModelSerialized, String serializedArguments){
        Map<String, Object> callbackArguments = (Map<String, Object>) JSON.deserializeUntyped(serializedArguments);
        HttpResponse response = Syntilio.DataHubCallout.onGetWithCallback(objectTypeName, queryParameters , destinationsModelSerialized, callbackArguments, new SchedulableDataHubSyncGetCallback());
    }

}