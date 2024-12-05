@NamespaceAccessible
public with sharing class ReportTriggerHandler {
    
    private static String objectTypeName = 'Report';
    private static String condition;
    @NamespaceAccessible
    public static List<Syntilio.DataHubModel> handleTrigger(System.TriggerOperation operationType, Map<Id, Syntilio__MedicalReport__c> oldMap, Map<Id, Syntilio__MedicalReport__c> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return null;
        }
        Syntilio__TriggerEnablerConfiguration__mdt reportTriggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('ReportTrigger');
        if(reportTriggerEnablerConfiguration == null || reportTriggerEnablerConfiguration.Syntilio__UseCustomTrigger__c){
            return null;
        }

        switch on operationType {
            when AFTER_DELETE {
                if(reportTriggerEnablerConfiguration.Syntilio__AfterDelete__c){
                    condition = reportTriggerEnablerConfiguration.Syntilio__AfterDeleteCondition__c;
                    return handleAfterDelete(oldMap, newMap);
                }
            }
            when AFTER_INSERT {
                if(reportTriggerEnablerConfiguration.Syntilio__AfterInsert__c){
                    condition = reportTriggerEnablerConfiguration.Syntilio__AfterInsertCondition__c;
                    return handleInsertUpdate(oldMap, newMap, false);
                }
            }
            when AFTER_UPDATE {
                if(reportTriggerEnablerConfiguration.Syntilio__AfterUpdate__c){
                    condition = reportTriggerEnablerConfiguration.Syntilio__AfterUpdateCondition__c;
                    return handleInsertUpdate(oldMap, newMap, true);
                }
            }
            when BEFORE_DELETE {
                if(reportTriggerEnablerConfiguration.Syntilio__BeforeDelete__c){}
            }
            when BEFORE_INSERT {
                if(reportTriggerEnablerConfiguration.Syntilio__BeforeInsert__c){}
            }
            when BEFORE_UPDATE {
                if(reportTriggerEnablerConfiguration.Syntilio__BeforeUpdate__c){}
            }
            when else {
                return null;
            }
        }
        return null;
    }
    @NamespaceAccessible
    public static List<Syntilio.DataHubModel> handleInsertUpdate(Map<Id, Syntilio__MedicalReport__c> oldMap, Map<Id, Syntilio__MedicalReport__c> newMap, Boolean isUpdate) {
        try{
            if(oldMap == null && newMap == null){
                return null;
            }
            List<Syntilio__DataHubSyncInfo__c> fieldsToPush = Syntilio.DataHubSynchronisation.getDataHubSyncInfoFields('Syntilio__MedicalReport__c', 'Push', null);
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
            for (Syntilio__MedicalReport__c reportRecord : newMap.values()){
                Id reportId = reportRecord.Id;
                String reportQuery = 'SELECT Id, ' + String.join(fieldNamesList, ', ') + ' FROM Syntilio__MedicalReport__c WHERE Id = :reportId';
                if(condition != null){
                    reportQuery += ' AND ' + condition;
                }
                reportQuery += ' WITH SECURITY_ENFORCED';
                List<Syntilio__MedicalReport__c> reportsFound = Database.query(reportQuery);
                if(reportsFound.size() == 0){
                    continue;
                }
                Syntilio__MedicalReport__c report = reportsFound[0];

                if(isUpdate && !Syntilio.DataHubUtilities.isSomeFieldsChanged(fieldNamesList, oldMap.get(reportRecord.Id), reportRecord)){
                    continue;
                }
                
                List<Contact> contactsFound = [SELECT Id, AccountId FROM Contact WHERE Id = :reportRecord.Syntilio__ContactId__c WITH SECURITY_ENFORCED];
                if(contactsFound.isEmpty()){
                    continue;
                }
                Contact contactFound = contactsFound[0];
                Map<String, List<Syntilio__ExternalId__c>> contactExternalSystemId = Syntilio.DataHubUtilities.getSObjectExternalIdsMap('Contact', contactFound.Id, externalSystems);
                if(contactExternalSystemId == null){
                    continue;
                }
                Map<String, List<Syntilio__ExternalId__c>> reportExternalSystemId;
                if(isUpdate){
                    reportExternalSystemId = Syntilio.DataHubUtilities.getSObjectExternalIdsMap(objectTypeName, reportRecord.Id, null);
                    if(reportExternalSystemId == null){
                        continue;
                    }
                }

                List<Syntilio.DataHubModel.Destination> destinationRecordList = Syntilio.DataHubUtilities.getDestinationList(contactFound.AccountId, externalSystems);

                if(destinationRecordList.size() == 0){
                    continue;
                }

                Map<String, Object> reportMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(report));



                Map<String, Object> reportBody = new Map<String, Object>();
                reportBody.put('AccountId', contactFound.AccountId);
                reportBody.put('ContactId', contactFound.Id);
                reportBody.put('Id', reportId);
                if(!Test.isRunningTest()){
                    User employee = [SELECT Id, EmployeeNumber FROM User WHERE Id =: report.CreatedById LIMIT 1];
                    String employeeId = employee.EmployeeNumber;
                    reportBody.put('EmployeeId', employeeId);                    
                }
                for(Syntilio.DataHubModel.Destination destination : destinationRecordList){
                    if(contactExternalSystemId.get(destination.technology) == null || contactExternalSystemId.get(destination.technology).isEmpty() 
                        || (isUpdate && (reportExternalSystemId.get(destination.technology) == null || reportExternalSystemId.get(destination.technology) == null))){
                        continue;
                    }
                    Map<String, Object> destinationBody = new Map<String, Object>();
                    for(Syntilio__ExternalId__c externalId : contactExternalSystemId.get(destination.technology)){
                        destinationBody.put(externalId.Name, externalId.Syntilio__Id__c);
                    }
                    if(isUpdate){
                        for(Syntilio__ExternalId__c externalId : reportExternalSystemId.get(destination.technology)){
                            destinationBody.put(externalId.Name, externalId.Syntilio__Id__c);
                        }
                    }
                    destinationBody.put('ExternalIdName', reportRecord.Name);
                    List<String> fields = externalSystemFieldNames.get(destination.technology);
                    for(String field : fields){
                        String firstField = field.split('\\.')[0];
                        destinationBody.put(firstField, reportMap.get(firstField));
                    }
                    String destinationKey = String.isBlank(destination.destinationName)? destination.technology : destination.destinationName + '_' + destination.technology;
                    reportBody.put(destinationKey, destinationBody);
                }
                
                List<Object> objectBodyList = new List<Object>();
                objectBodyList.add(reportBody);
                
                Syntilio.DataHubModel dataHubModel = new Syntilio.DataHubModel();
                dataHubModel.destinations = destinationRecordList;
                dataHubModel.objectsBody = objectBodyList;
                
                String dataHubModelObjectBodySerialized = JSON.serializePretty(dataHubModel.objectsBody);
                String dataHubModelDestinationsSerialized = JSON.serializePretty(dataHubModel.destinations);
                if(!Test.isRunningTest()){
                    if(isUpdate){
                        Syntilio.DataHubCalloutHandler.initiatePutCallout(objectTypeName, dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized);
                    }else{
                        Syntilio.DataHubCalloutHandler.initiatePostCallout(objectTypeName, dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized);
                    }
                }
                datahubModels.add(dataHubModel);
            }
            return datahubModels;
        }catch(Exception e){
            Syntilio.HandleException.logException(e); 
        }
        return null;
    }

    @NamespaceAccessible
    public static List<Syntilio.DataHubModel> handleAfterDelete(Map<Id, Syntilio__MedicalReport__c> oldMap, Map<Id, Syntilio__MedicalReport__c> newMap) {

        try{
            if(oldMap == null && newMap == null){
                return null;
            }
            List<Syntilio__ExternalId__c> externalIdsToDelete = new List<Syntilio__ExternalId__c>();
            List<Syntilio.DataHubModel> datahubModels = new List<Syntilio.DataHubModel>();
            for (Syntilio__MedicalReport__c reportRecord : oldMap.values()){
                Id reportId = reportRecord.Id;
                String reportQuery = 'SELECT Id FROM Syntilio__MedicalReport__c WHERE Id = :reportId AND isDeleted = true';
                if(condition != null){
                    reportQuery += ' AND ' + condition;
                }
                reportQuery += ' WITH SECURITY_ENFORCED';
                reportQuery += ' ALL ROWS';

                List<Syntilio__MedicalReport__c> reportsFound = Database.query(reportQuery);
                if(reportsFound.size() == 0){
                    continue;
                }
                Syntilio__MedicalReport__c report = reportsFound[0];

                List<Contact> contactsFound = [SELECT Id, AccountId FROM Contact WHERE Id = :reportRecord.Syntilio__ContactId__c WITH SECURITY_ENFORCED];
                if(contactsFound.isEmpty()){
                    continue;
                }
                Contact contactFound = contactsFound[0];

                Map<String, List<Syntilio__ExternalId__c>> reportExternalSystemId = Syntilio.DataHubUtilities.getSObjectExternalIdsMap(objectTypeName, reportRecord.Id, null);
                if(reportExternalSystemId == null){
                    continue;
                }

                List<Syntilio.DataHubModel.Destination> destinationRecordList = Syntilio.DataHubUtilities.getDestinationList(contactFound.AccountId, null);

                if(destinationRecordList.size() == 0){
                    continue;
                }
                
                Map<String, Object> reportBody = new Map<String, Object>();
                reportBody.put('AccountId', contactFound.AccountId);
                reportBody.put('ContactId', contactFound.Id);
                reportBody.put('Id', reportId);

                for(Syntilio.DataHubModel.Destination destination : destinationRecordList){
                    if(reportExternalSystemId.get(destination.technology) == null || reportExternalSystemId.get(destination.technology) == null){
                        continue;
                    }

                    Map<String, Object> destinationBody = new Map<String, Object>();
                    for(Syntilio__ExternalId__c externalId : reportExternalSystemId.get(destination.technology)){
                        destinationBody.put(externalId.Name, externalId.Syntilio__Id__c);
                    }
                    String destinationKey = String.isBlank(destination.destinationName)? destination.technology : destination.destinationName + '_' + destination.technology;
                    reportBody.put(destinationKey, destinationBody);
                }
                
                List<Object> objectBodyList = new List<Object>();
                objectBodyList.add(reportBody);
                
                Syntilio.DataHubModel dataHubModel = new Syntilio.DataHubModel();
                dataHubModel.destinations = destinationRecordList;
                dataHubModel.objectsBody = objectBodyList;
                
                String dataHubModelObjectBodySerialized = JSON.serializePretty(dataHubModel.objectsBody);
                String dataHubModelDestinationsSerialized = JSON.serializePretty(dataHubModel.destinations);
                Syntilio.DataHubCalloutHandler.initiateDeleteCallout(objectTypeName, dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized);

                List<Syntilio__ExternalId__c> relatedExternalIds = [SELECT Id FROM Syntilio__ExternalId__c WHERE Syntilio__RelatedSalesforceInternalId__c = :reportId WITH SECURITY_ENFORCED];
                externalIdsToDelete.addAll(relatedExternalIds);
                datahubModels.add(dataHubModel);
            }
            
            Syntilio.UpsertToDatabase.deleteAction(externalIdsToDelete, false);
            return datahubModels;
        }catch(Exception e){
            Syntilio.HandleException.logException(e); 
        }
        return null;
    }
}