@NamespaceAccessible
public with sharing class ReportHandler {
    @TestVisible private static List<Syntilio__Notification__e> eventList = new List<Syntilio__Notification__e>();
    @TestVisible private static Boolean raiseException = false;

    @NamespaceAccessible
    public static void handleTrigger(System.TriggerOperation operationType, Map<Id, Case> oldMap, Map<Id, Case> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return;
        }
        Syntilio__TriggerEnablerConfiguration__mdt triggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('CaseReportTrigger');
        if(triggerEnablerConfiguration == null || triggerEnablerConfiguration.Syntilio__UseCustomTrigger__c || triggerEnablerConfiguration.Syntilio__AfterInsert__c == false){
            return;
        }
        switch on operationType {
            when AFTER_INSERT {
                if(triggerEnablerConfiguration.Syntilio__AfterInsert__c){
                    handleAfterInsert(oldMap, newMap);
                }
            }
            when AFTER_UPDATE {
                if(triggerEnablerConfiguration.Syntilio__AfterUpdate__c){
                    handleAfterInsert(oldMap, newMap);
                }
            }
        }
        return;
    }

    @NamespaceAccessible
    public static void handleAfterInsert(Map<Id, Case> oldMap , Map<Id, Case> newMap){
        try {
            Map<Id, Boolean> contacts = new Map<Id, Boolean>(); 
            for (Case caseRecord : newMap.values()){
                Id contactId = caseRecord.ContactId;
                if(contacts.containsKey(contactId)){
                    continue;
                }
                contacts.put(contactId, true);
            }
            syncReports(new List<Id>(contacts.keySet()));

        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }
    
    @NamespaceAccessible
    public static String getContactReport(Id caseId) {
        try {
            if(Test.isRunningTest() && Syntilio.ReportHandler.raiseException == true) {
                throw new DmlException();
            }
            String caseContactSerialized = Syntilio.DataHubUtilities.getCaseContactId(caseId);
            Case caseContact = (Case) JSON.deserialize(caseContactSerialized, Case.class);
            List<Map<String, Object>> reportList = Syntilio.ReportHandler.getReports(caseContact.ContactId, caseId);
            ResponseMessage responseMessage = new ResponseMessage(
                reportList,
                reportList.size() == 0 ? 'Contact has no reports' : 'Retrieved contact reports successfully',
                ResponseMessage.MessageType.SUCCESS
            );
            return responseMessage.serialize();
        } catch (Exception e) {
            ResponseMessage responseMessage = new ResponseMessage(
                null,
                'An unexpected error occured ' + e.getMessage(),
                ResponseMessage.MessageType.ERROR
            );
            return responseMessage.serialize();
        }
    }
    @NamespaceAccessible
    public static List<Map<String, Object>> getReports(Id contactId, Id caseId) {
        List<Syntilio__MedicalReport__c> reportList = [
            SELECT LastModifiedDate, Syntilio__ExternalUpdatedAt__c, Syntilio__Author__c, Syntilio__Comments__c, Syntilio__AuthorRole__c, CreatedBy.Name, Syntilio__Flagged__c
            FROM Syntilio__MedicalReport__c
            WHERE Syntilio__ContactId__c = :contactId
            WITH SECURITY_ENFORCED
        ];

        Map<String, Object> reportMap = Syntilio.DataHubUtilities.listToMap('Id', null, reportList);
        List<String> reportIdList = new List<String>(reportMap.keySet());

        List<Syntilio__ExternalId__c> reportExternalIdList = [
            SELECT Syntilio__RelatedSalesforceInternalId__c, 
            	Syntilio__ExternalSystemId__c, Syntilio__ExternalSystemId__r.Name,
            	Syntilio__Account__c, Syntilio__Account__r.Name
            FROM Syntilio__ExternalId__c
            WHERE Syntilio__RelatedSalesforceInternalId__c IN :reportIdList
            WITH SECURITY_ENFORCED
        ];
        
        Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();
        for(Syntilio__ExternalId__c externalId : reportExternalIdList){
            Syntilio__MedicalReport__c report = (Syntilio__MedicalReport__c) reportMap.remove(externalId.Syntilio__RelatedSalesforceInternalId__c);
            Map<String, Object> reportMapped;
            if(result.containsKey(report.Id)){
                reportMapped = result.get(report.Id);
            } else {
                reportMapped = new Map<String, Object>{
                    'Id' => report.Id,
                    'Syntilio__ExternalUpdatedAt__c' => report.Syntilio__ExternalUpdatedAt__c,
                    'Syntilio__Author__c' => report.Syntilio__Author__c,
                    'Syntilio__Comments__c' => report.Syntilio__Comments__c,
                    'Syntilio__AuthorRole__c' => report.Syntilio__AuthorRole__c,
                    'Syntilio__Flagged__c' => report.Syntilio__Flagged__c,
                    'AccountId' => externalId.Syntilio__Account__c,
                    'AccountName' => externalId.Syntilio__Account__r.Name,
                    'CreatedByName' => report.CreatedBy.Name,
                    'ExternalSystems' => new List<Map<String, Object>>()
            	};
            }
            List<Map<String, Object>> externalSystemsList = (List<Map<String, Object>>) reportMapped.get('ExternalSystems');
            externalSystemsList.add(
                new Map<String, Object>{
					'Id' => externalId.Syntilio__ExternalSystemId__c,
					'Name' => externalId.Syntilio__ExternalSystemId__r.Name
				}
            );
            reportMapped.put('ExternalSystems', externalSystemsList);
            result.put(report.Id, reportMapped);
        }
        Case caseRetrieved = [SELECT Id, AccountId FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        String accountName = '';
        Id accountId;
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :caseRetrieved.AccountId WITH SECURITY_ENFORCED LIMIT 1];

        if(!accounts.isEmpty()){
            accountId = accounts[0].Id;
            accountName = accounts[0].Name;
        }


        String externalSystemName = '';
        Id externalSystemId ;
        List<Syntilio__AccountExternalSystemAssociation__c> assocRecords = [
            SELECT Syntilio__ExternalSystemId__c,Syntilio__ExternalSystemId__r.Name 
            FROM Syntilio__AccountExternalSystemAssociation__c 
            WHERE Syntilio__AccountId__c = :caseRetrieved.AccountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if (!assocRecords.isEmpty()) {
            externalSystemName = assocRecords[0].Syntilio__ExternalSystemId__r.Name;
            externalSystemId = assocRecords[0].Syntilio__ExternalSystemId__c;
        }
        List<Map<String, Object>> externalSystems = new List<Map<String, Object>>();
        externalSystems.add(
                new Map<String, Object>{
					'Id' => externalSystemId,
					'Name' => externalSystemName
				}
        );
        for(Object reportObject : reportMap.values()){
            Syntilio__MedicalReport__c report = (Syntilio__MedicalReport__c) reportObject;
            Map<String, Object> reportMapped = new Map<String, Object>{
                'Id' => report.Id,
				'Syntilio__ExternalUpdatedAt__c' => report.LastModifiedDate,
				'Syntilio__Comments__c' => report.Syntilio__Comments__c,
                'Syntilio__Author__c' => report.Syntilio__Author__c,
                'Syntilio__AuthorRole__c' => report.Syntilio__AuthorRole__c,
                'Syntilio__Flagged__c' => report.Syntilio__Flagged__c,
                'CreatedByName' => report.CreatedBy.Name,
                'AccountId' => accountId,
                'AccountName' => accountName,
                'ExternalSystems' => externalSystems
			};
            result.put(report.Id, reportMapped);
        }
        return result.values();
    }

    @NamespaceAccessible
    public static List<Contact> getContacts(List<Id> contactIds) {
        List<Contact> contactList = [
            SELECT AccountId
            FROM Contact
            WHERE Id IN :contactIds
            WITH SECURITY_ENFORCED
        ];
        return contactList;
    }

    @AuraEnabled
    public static void manualSyncReports(Id clientId){
        syncReports(new List<Id>{clientId});
    }

    @NamespaceAccessible
    @future(callout=true)
    public static void syncReports(List<Id> contactIds) {
        List<Contact> contacts;
        try{
            contacts = getContacts(contactIds);
            if(contacts.size() == 0){
                return;
            }
        } catch (Exception e) {
            Syntilio.CareHubUtilities.notifyLwc('', 'ReportHandler' , Syntilio.CareHubUtilities.status.Failure.name());
            Syntilio.HandleException.LogException(e);   
            return;
        }

        Set<String> accountIds = new Set<String>();
        for(Contact contact : contacts){
            accountIds.add(contact.AccountId);
        }

        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Syntilio__MedicalReport__c');
        Map<String, Object> externalIdPerContact = Syntilio.DataHubUtilities.getExternalIdPerContact(contactIds);
        
        for(Contact contact : contacts) {
            Map<String, Set<String>> viableExternalSystemsPerContactAccount = viableExternalSystemsPerAccountId.get(contact.AccountId);
            if(viableExternalSystemsPerContactAccount == null) {
                continue;
            }
            for(String accountId : viableExternalSystemsPerContactAccount.keySet()){
                if(viableExternalSystemsPerContactAccount.get(accountId).size() == 0) {
                    continue;
                }
                try {
                    List<String> viableExternalSystems = new List<String>(viableExternalSystemsPerContactAccount.get(accountId));
                if(viableExternalSystems == null || viableExternalSystems.size() == 0 ) 
                    SyntilioException.throwError('No viable external systems');
                
                List<Syntilio.DataHubModel.Destination> destList = Syntilio.DataHubUtilities.getDestinationList(accountId, new Set<String>(viableExternalSystems));
                String destinationsModelSerialized = JSON.serializePretty(destList);
                
                String contactExternalId = (String) externalIdPerContact.get(contact.Id);
                if(contactExternalId == null || contactExternalId == '') {
                    SyntilioException.throwError('No contact externalId found');
                }
                HttpResponse apiResponse =  Syntilio.DataHubCallout.onGet('report', '?client_id=' + contactExternalId, destinationsModelSerialized);
                
                Map<String, Object> mappedUpsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Syntilio__MedicalReport__c', apiResponse, false);
                if(mappedUpsertion.isEmpty()){
                    SyntilioException.throwError('Reports insertion failed');
                }
            } catch (Exception e) {
                Syntilio.CareHubUtilities.notifyLWC('','ReportHandler',Syntilio.CareHubUtilities.Status.Failure.name());
                Syntilio.HandleException.LogException(e);
}
            }
        }
        ResponseMessage response = new ResponseMessage(null, 'Reports cmp needs refresh', ResponseMessage.MessageType.SUCCESS);
        Syntilio.CareHubUtilities.notifyLWC('','ReportHandler',Syntilio.CareHubUtilities.Status.SUCCESS.name());
    }

    @AuraEnabled
    public static List<Object> getExpertiseGroup(String accountId, String externalSystem) {
        List<Object> expertiseGroups = new List<Object>();
        List<Syntilio.DataHubModel.Destination> destList;
        try {
            destList = Syntilio.DataHubUtilities.getDestinationList(accountId, new Set<String>{externalSystem});
        } catch (Exception e) {
            Syntilio.HandleException.logException(e, 'getExpertiseGroup');
            throw new AuraHandledException('Error retrieving destination list: ' + e.getMessage());
        }
        String destinationsModelSerialized;
        try {
            destinationsModelSerialized = JSON.serializePretty(destList);
        } catch (Exception e) {
            Syntilio.HandleException.logException(e, 'getExpertiseGroup');
            throw new AuraHandledException('Error serializing destination list: ' + e.getMessage());
        }

        HttpResponse result;
        try {
            result = Syntilio.DataHubCallout.onGet('expertisegroups', '', destinationsModelSerialized);
        } catch (Exception e) {
            Syntilio.HandleException.logException(e, 'getExpertiseGroup');
            throw new AuraHandledException('Error during HTTP callout: ' + e.getMessage());
        }

        if (result.getStatusCode() == 200) {
            try {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
                for (String destination : responseMap.keySet()) {
                    Object innerMapObject = responseMap.get(destination);
                    if (innerMapObject instanceof Map<String, Object>) {
                        Map<String, Object> innerMap = (Map<String, Object>) innerMapObject;
                        if (innerMap.containsKey('expertiseGroups')) {
                            expertiseGroups = (List<Object>) innerMap.get('expertiseGroups');
                        }
                    }
                }
            } catch (Exception e) {
                Syntilio.HandleException.logException(e, 'getExpertiseGroup');
            }
        } 

        return expertiseGroups;
    }

    @AuraEnabled
    public static List<Object> getExpertiseProfiles(String accountId, String externalSystem) {
        List<Object> expertiseProfiles = new List<Object>();
        List<Syntilio.DataHubModel.Destination> destList;
        try {
            destList = Syntilio.DataHubUtilities.getDestinationList(accountId, new Set<String>{externalSystem});
        } catch (Exception e) {
            Syntilio.HandleException.logException(e, 'getExpertiseProfiles');
            throw new AuraHandledException('Error retrieving destination list: ' + e.getMessage());
        }
        String destinationsModelSerialized;
        try {
            destinationsModelSerialized = JSON.serializePretty(destList);
        } catch (Exception e) {
            Syntilio.HandleException.logException(e, 'getExpertiseProfiles');
            throw new AuraHandledException('Error serializing destination list: ' + e.getMessage());
        }

        HttpResponse result;
        try {
            result = Syntilio.DataHubCallout.onGet('expertiseprofiles', '', destinationsModelSerialized);
        } catch (Exception e) {
            Syntilio.HandleException.logException(e, 'getExpertiseProfiles');
            throw new AuraHandledException('Error during HTTP callout: ' + e.getMessage());
        }

        if (result.getStatusCode() == 200) {
            try {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
                for (String destination : responseMap.keySet()) {
                    Object innerMapObject = responseMap.get(destination);
                    if (innerMapObject instanceof Map<String, Object>) {
                        Map<String, Object> innerMap = (Map<String, Object>) innerMapObject;
                        if (innerMap.containsKey('expertiseProfiles')) {
                            expertiseProfiles = (List<Object>) innerMap.get('expertiseProfiles');
                        }
                    }
                }
            } catch (Exception e) {
                Syntilio.HandleException.logException(e, 'getExpertiseProfiles');
            }
        } 

        return expertiseProfiles;
    }

    
}