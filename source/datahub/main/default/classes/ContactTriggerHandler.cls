//This class is not a part of the package, it's only added to do rounds to integration test scenarios. This is implemented differently for each client. 
/*************************************************************************   
@description In this class, it checks whether contact trigger is enabled or not based on client choice to know whether to proceed. There are different function based on whether the trigger was afterDelete, afterinsert, afterUpdate, etc...
under each method, the method takes in the old data and new data from trigger and creates a model based on that of the dynamic api*/
public with sharing class ContactTriggerHandler {

    private static String objectTypeName = 'Contact';
    private static String condition;
    
    public static List<Syntilio.DataHubModel> handleTrigger(System.TriggerOperation operationType, Map<Id, Contact> oldMap, Map<Id, Contact> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return null;
        }
        Syntilio__TriggerEnablerConfiguration__mdt contactTriggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('ContactTrigger');
        if(contactTriggerEnablerConfiguration == null || contactTriggerEnablerConfiguration.Syntilio__UseCustomTrigger__c){
            return null;
        }

        switch on operationType {
            when AFTER_DELETE {
                if(contactTriggerEnablerConfiguration.Syntilio__AfterDelete__c){}
            }
            when AFTER_INSERT {
                if(contactTriggerEnablerConfiguration.Syntilio__AfterInsert__c){
                    condition = contactTriggerEnablerConfiguration.Syntilio__AfterInsertCondition__c;
                    return handleInsertUpdate(oldMap, newMap, false);
                }
            }
            when AFTER_UPDATE {
                if(contactTriggerEnablerConfiguration.Syntilio__AfterUpdate__c){
                    condition = contactTriggerEnablerConfiguration.Syntilio__AfterUpdateCondition__c;
                    return handleInsertUpdate(oldMap, newMap, true);
                }
            }
            when BEFORE_DELETE {
                if(contactTriggerEnablerConfiguration.Syntilio__BeforeDelete__c){}
            }
            when BEFORE_INSERT {
                if(contactTriggerEnablerConfiguration.Syntilio__BeforeInsert__c){}
            }
            when BEFORE_UPDATE {
                if(contactTriggerEnablerConfiguration.Syntilio__BeforeUpdate__c){}
            }
            when else {
            }
        }
        return null;
    }

    public static List<Syntilio.DataHubModel> handleInsertUpdate(Map<Id, Contact> oldMap, Map<Id, Contact> newMap, Boolean isUpdate) {
        try{
            if(oldMap == null && newMap == null){
                return null;
            }
            List<Syntilio__DataHubSyncInfo__c> fieldsToPush = Syntilio.DataHubSynchronisation.getDataHubSyncInfoFields('Contact', 'Push', null);
            if(fieldsToPush.size() == 0){
                return null;
            }

            Set<String> fieldNamesListSet = new Set<String>();
            Map<String, List<String>> externalSystemFieldNames = new Map<String, List<String>>();
            Map<String, Syntilio__DataHubSyncInfo__c> fieldsToPushMap = new Map<String, Syntilio__DataHubSyncInfo__c>();
            Set<String> externalSystems = new Set<String>();

            Syntilio.DataHubUtilities.setupExternalSystemsAndPushMap(fieldsToPush, fieldNamesListSet, externalSystemFieldNames, fieldsToPushMap, externalSystems);
            List<String> fieldNamesList = new List<String>(fieldNamesListSet);
            List<Syntilio.DataHubModel> datahubModels = new List<Syntilio.DataHubModel>();
            for (Contact contactRecord : newMap.values()){
                Id contactId = contactRecord.Id;
                String contactQuery = 'SELECT Id, ' + String.join(fieldNamesList, ', ') + ' FROM Contact WHERE Id = :contactId';
                if(condition != null){
                    contactQuery += ' AND ' + condition;
                }
                contactQuery += ' WITH SECURITY_ENFORCED';
                List<Contact> contactsFound = Database.query(contactQuery);
                if(contactsFound.size() == 0){
                    continue;
                }
                Contact contact = contactsFound[0];

                Map<String, List<Syntilio__ExternalId__c>> contactExternalSystemId;
                if(isUpdate){
                    if(!Syntilio.DataHubUtilities.isSomeFieldsChanged(fieldNamesList, oldMap.get(contactRecord.Id), contactRecord)){
                        continue;
                    }
                    contactExternalSystemId = Syntilio.DataHubUtilities.getSObjectExternalIdsMap(objectTypeName, contactRecord.Id, externalSystems);
                    if(contactExternalSystemId == null){
                        continue;
                    }
                }
    
                List<Syntilio.DataHubModel.Destination> destinationRecordList = Syntilio.DataHubUtilities.getDestinationList(contactRecord.AccountId, externalSystems);
    
                if(destinationRecordList.size() == 0){
                    continue;
                }
    
                Map<String, Object> contactMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(contact));
    
                Map<String, Object> contactBody = new Map<String, Object>();
                contactBody.put('AccountId', contactRecord.AccountId);
                contactBody.put('Id', contactId);
    
                for(Syntilio.DataHubModel.Destination destination : destinationRecordList){
                    Map<String, Object> destinationBody = new Map<String, Object>();
                    if(isUpdate){
                        if(contactExternalSystemId.get(destination.technology) == null || contactExternalSystemId.get(destination.technology).isEmpty()){
                            continue;
                        }
                        for(Syntilio__ExternalId__c externalId : contactExternalSystemId.get(destination.technology)){
                            destinationBody.put(externalId.Name, externalId.Syntilio__Id__c);
                        }
                    }
                    List<String> fields = externalSystemFieldNames.get(destination.technology);
                    for(String field : fields){
                        String firstField = field.split('\\.')[0];
                        destinationBody.put(firstField, contactMap.get(firstField));
                    }
                    String destinationKey = String.isBlank(destination.destinationName)? destination.technology : destination.destinationName + '_' + destination.technology;
                    contactBody.put(destinationKey, destinationBody);
                }
                
                List<Object> objectBodyList = new List<Object>();
                objectBodyList.add(contactBody);
                
                Syntilio.DataHubModel dataHubModel = new Syntilio.DataHubModel();
                dataHubModel.destinations = destinationRecordList;
                dataHubModel.objectsBody = objectBodyList;
                
                String dataHubModelObjectBodySerialized = JSON.serializePretty(dataHubModel.objectsBody);
                String dataHubModelDestinationsSerialized = JSON.serializePretty(dataHubModel.destinations);
                if(isUpdate){
                    DataHubCalloutHandler.initiatePutCallout(objectTypeName, dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized);
                    if(isAddressChanged(oldMap.get(contactRecord.Id), contactRecord)){
                        DataHubCalloutHandler.initiatePostCallout('ContactAddress', dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized);
                    }
                }else{
                    DataHubCalloutHandler.initiatePostCallout(objectTypeName, dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized);
                }
                
                datahubModels.add(dataHubModel);
            }
            return datahubModels;
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return null;
    }



    public static boolean isAddressChanged(Contact oldContact, Contact newContact){
        Boolean streetChanged = oldContact.MailingStreet != newContact.MailingStreet;
        Boolean postalCodeChanged = oldContact.MailingPostalCode != newContact.MailingPostalCode;
        Boolean cityChanged = oldContact.MailingCity != newContact.MailingCity;
        Boolean countryChanged = oldContact.MailingCountry != newContact.MailingCountry;
        Boolean stateChanged = oldContact.MailingState != newContact.MailingState;
        return streetChanged || postalCodeChanged || cityChanged || countryChanged || stateChanged;
    }
}