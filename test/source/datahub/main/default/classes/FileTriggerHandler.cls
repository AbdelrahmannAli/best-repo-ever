public with sharing class FileTriggerHandler {
    
    private static String objectTypeName = 'File';
    private static String condition;

    public static List<Syntilio.DataHubModel> handleTrigger(System.TriggerOperation operationType, Map<Id, ContentVersion> oldMap, Map<Id, ContentVersion> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return null;
        }
        Syntilio__TriggerEnablerConfiguration__mdt fileTriggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('FileTrigger');
        if(fileTriggerEnablerConfiguration == null || fileTriggerEnablerConfiguration.Syntilio__UseCustomTrigger__c){
            return null;
        }

        switch on operationType {
            when AFTER_DELETE {
                if(fileTriggerEnablerConfiguration.Syntilio__AfterDelete__c){}
            }
            when AFTER_INSERT {
                if(fileTriggerEnablerConfiguration.Syntilio__AfterInsert__c){
                    condition = fileTriggerEnablerConfiguration.Syntilio__AfterInsertCondition__c;
                    return handleAfterInsert(oldMap, newMap);
                }
            }
            when AFTER_UPDATE {
                if(fileTriggerEnablerConfiguration.Syntilio__AfterUpdate__c){}
            }
            when BEFORE_DELETE {
                if(fileTriggerEnablerConfiguration.Syntilio__BeforeDelete__c){}
            }
            when BEFORE_INSERT {
                if(fileTriggerEnablerConfiguration.Syntilio__BeforeInsert__c){}
            }
            when BEFORE_UPDATE {
                if(fileTriggerEnablerConfiguration.Syntilio__BeforeUpdate__c){}
            }
            when else {
                return null;
            }
        }
        return null;
    }

    public static List<Syntilio.DataHubModel> handleAfterInsert(Map<Id, ContentVersion> oldMap, Map<Id, ContentVersion> newMap) {
        try{
            if(oldMap == null && newMap == null){
                return null;
            }
            List<Syntilio.DataHubModel> datahubModels = new List<Syntilio.DataHubModel>();
            for (ContentVersion contentVersionRecord : newMap.values()){
                Id contentVersionId = contentVersionRecord.Id;
                String contentVersionQuery = 'SELECT Id, VersionData, Title, FileType FROM ContentVersion WHERE Id = :contentVersionId';
                if(condition != null){
                    contentVersionQuery += ' AND ' + condition;
                }
                contentVersionQuery += ' WITH SECURITY_ENFORCED';
                List<ContentVersion> pdfsFound = Database.query(contentVersionQuery);
                if(pdfsFound.size() == 0){
                    continue;
                }
                ContentVersion pdf = pdfsFound[0];
            
                List<Case> caseRecords = [SELECT Id, ContactId, AccountId FROM Case WHERE Id = :contentVersionRecord.FirstPublishLocationId WITH SECURITY_ENFORCED];
                if(caseRecords.isEmpty()){
                    continue;
                }
                Case caseRecord = caseRecords[0];
    
                
                Blob pdfBlob = pdf.VersionData;
                String base64PDF = EncodingUtil.base64Encode(pdfBlob);
    
                List<Syntilio.DataHubModel.Destination> destinationRecordList = Syntilio.DataHubUtilities.getDestinationList(caseRecord.AccountId, null);
                if(destinationRecordList.size() == 0){
                    continue;
                }
    
                Set<String> externalSystems = new Set<String>();
                for(Syntilio.DataHubModel.Destination destination : destinationRecordList){
                    externalSystems.add(destination.technology);
                }
    
                if(destinationRecordList.size() == 0){
                    continue;
                }
    
                Map<String, List<Syntilio__ExternalId__c>> contactExternalSystemId = Syntilio.DataHubUtilities.getSObjectExternalIdsMap('Contact', caseRecord.ContactId, externalSystems);
                if(contactExternalSystemId == null){
                    continue;
                }
    
                Map<String, Object> requestBody = new Map<String, Object>();
                requestBody.put('AccountId', caseRecord.AccountId);
                requestBody.put('ContactId', caseRecord.ContactId);
                requestBody.put('Id', pdf.Id);
    
                for(Syntilio.DataHubModel.Destination destination : destinationRecordList){
                    if(contactExternalSystemId.get(destination.technology) == null || contactExternalSystemId.get(destination.technology).isEmpty()){
                        continue;
                    }
                    Map<String, String> fileDetails = new Map<String, String>();
                    for(Syntilio__ExternalId__c externalId : contactExternalSystemId.get(destination.technology)){
                        fileDetails.put(externalId.Name, externalId.Syntilio__Id__c);
                    }
                    fileDetails.put('ExternalIdName', pdf.Title + '.' + pdf.FileType.toLowercase());
                    fileDetails.put('fileName', pdf.Title + '.' + pdf.FileType.toLowercase());
                    fileDetails.put('fileContent', base64PDF);
                    String destinationKey = String.isBlank(destination.destinationName)? destination.technology : destination.destinationName + '_' + destination.technology;
                    requestBody.put(destinationKey, fileDetails);
                }
                List<Object> objectBodyList = new List<Object>();
                objectBodyList.add(requestBody);
                
                Syntilio.DataHubModel dataHubModel = new Syntilio.DataHubModel();
                dataHubModel.destinations = destinationRecordList;
                dataHubModel.objectsBody = objectBodyList;
                
                String dataHubModelObjectBodySerialized = JSON.serializePretty(dataHubModel.objectsBody);
                String dataHubModelDestinationsSerialized = JSON.serializePretty(dataHubModel.destinations);
                
                DataHubCalloutHandler.initiatePostCallout(objectTypeName, dataHubModelObjectBodySerialized, dataHubModelDestinationsSerialized);
            	datahubModels.add(dataHubModel);
            }
            return datahubModels;
        }catch(Exception e){
            Syntilio.HandleException.logException(e); 
        }
        return null;
    }
}