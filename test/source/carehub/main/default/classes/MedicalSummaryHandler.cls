@NamespaceAccessible
public with sharing class MedicalSummaryHandler {

    @NamespaceAccessible
    public static void handleTrigger(System.TriggerOperation operationType, Map<Id, Case> oldMap, Map<Id, Case> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return;
        }
        Syntilio__TriggerEnablerConfiguration__mdt triggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('CaseMedicalSummaryTrigger');
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
            syncContactMedicalSummaries(new List<Id>(contacts.keySet()));
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }

    @AuraEnabled
    public static String getContactSafetyBadges(Id objectId) {
        try {
            String objectType = Syntilio.CareHubUtilities.getSobjectFromId(objectId);
            String contactId = objectId;
            if(objectType.toLowerCase() != 'case' && objectType.toLowerCase() != 'contact'){
                throw new HandledException('the Id must be either a Case or Contact Id');
            }
            if(objectType.toLowerCase() == 'case'){
                List<Case> cases = [SELECT ContactId FROM Case WHERE Id = :objectId WITH SECURITY_ENFORCED];
                if(cases.size() == 0){
                    return null;
                }
                contactId = cases[0].ContactId;
            }
            String resuscitationDecision = getContactResuscitationDecision(contactId);
            List<Syntilio__ContactAlert__c> alerts = getContactAlerts(contactId);
            Map<String, Object> result = new Map<String, Object>{
              'resuscitationDecision' => resuscitationDecision,
              'alerts' => alerts
            };
            ResponseMessage responseMessage = new ResponseMessage(
                result,
                'Retrieved contact safety badges successfully',
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
    public static String getContactResuscitationDecision(Id contactId){
        List<Syntilio__MedicalPolicy__c> policies = [
            SELECT Syntilio__ResuscitationDecision__c 
            FROM Syntilio__MedicalPolicy__c
            WHERE Syntilio__ContactId__c = :contactId
            AND Syntilio__MostRecent__c = true
            WITH SECURITY_ENFORCED
        ];
        if(policies.size() == 0){
            return null;
        }
        return policies[0].Syntilio__ResuscitationDecision__c;
    }
    
    @NamespaceAccessible
    public static List<Syntilio__ContactAlert__c> getContactAlerts(Id contactId){
        List<Syntilio__ContactAlert__c> alerts = [
            SELECT Name, Syntilio__Description__c, Syntilio__Icon__c 
            FROM Syntilio__ContactAlert__c
            WHERE Syntilio__ContactId__c = :contactId
            AND Syntilio__Active__c = true
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate DESC
        ];
        return alerts;
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
    
    @NamespaceAccessible
    @future(callout=true)
    public static void syncContactMedicalSummaries(List<Id> contactIds) {
        List<Contact> contacts = getContacts(contactIds);
        try{   
            if(contacts.size() == 0){
                return;
            }
        } catch (Exception e) {
            Syntilio.CareHubUtilities.notifyLwc('', 'ContactNotes' , Syntilio.CareHubUtilities.status.Failure.name());
            Syntilio.HandleException.LogException(e);
            return;
        }

        Set<String> accountIds = new Set<String>();
        for(Contact contact : contacts){
            accountIds.add(contact.AccountId);
        }
        Map<String, Map<String, Set<String>>> policyViableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Syntilio__MedicalPolicy__c');
        Map<String, Map<String, Set<String>>> alertViableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Syntilio__ContactAlert__c');

        Map<String, Object> externalIdPerContact = Syntilio.DataHubUtilities.getExternalIdPerContact(contactIds);
        List<String> contactNoteIds = new List<String>();
        for(Contact contact : contacts) {
            Set<String> policyExternalSystems = new Set<String>();
            Set<String> alertExternalSystems = new Set<String>();
            Map<String, Set<String>> policyViableExternalSystemsPerContactAccount = policyViableExternalSystemsPerAccountId.get(contact.AccountId);
            Map<String, Set<String>> alertViableExternalSystemsPerContactAccount = alertViableExternalSystemsPerAccountId.get(contact.AccountId);
            Set<Id> accounts = new Set<Id>();
            if(policyViableExternalSystemsPerContactAccount == null){
                continue;
            }
            for(String accountId : policyViableExternalSystemsPerContactAccount.keySet()){
                policyExternalSystems.addAll(policyViableExternalSystemsPerContactAccount.get(accountId));
                accounts.add((Id) accountId);
            }
            if(alertViableExternalSystemsPerContactAccount == null){
                continue;
            }
            for(String accountId : alertViableExternalSystemsPerContactAccount.keySet()){
                alertExternalSystems.addAll(alertViableExternalSystemsPerContactAccount.get(accountId));
                accounts.add((Id) accountId);
            }

            for (Id accountId : accounts){
                try {
                    if(policyExternalSystems == null || policyExternalSystems.size() == 0 ) 
                        SyntilioException.throwError('No viable external systems');
        
                    if(alertExternalSystems == null || alertExternalSystems.size() == 0 ) 
                        SyntilioException.throwError('No viable external systems');
        
                    Boolean noPolicy = (policyExternalSystems == null || policyExternalSystems.size() == 0);
                    Boolean noAlert = (alertExternalSystems == null || alertExternalSystems.size() == 0);
                        
                    if(noPolicy && noAlert) 
                        SyntilioException.throwError('External System not found');
                    List<String> viableExternalSystems = new List<String>();
                    String query = '';
                    if(!noPolicy){
                        viableExternalSystems.addAll(policyExternalSystems);
                        query += '&medical_policy=true&resuscitation_decision=true';
                    }
                    if(!noAlert){
                        viableExternalSystems.addAll(alertExternalSystems);
                        query += '&alerts=true';            
                    }
        
                    List<Syntilio.DataHubModel.Destination> destList = Syntilio.DataHubUtilities.getDestinationList(accountId, new Set<String>(viableExternalSystems));
                        
        
                    String destinationsModelSerialized = JSON.serializePretty(destList);
                    String contactExternalId = (String) externalIdPerContact.get(contact.Id);
                    if(contactExternalId == null || contactExternalId == '') {
                        SyntilioException.throwError('No contact externalId found');
                    }
                    query = '?client_id=' + contactExternalId + query;
                    HttpResponse apiResponse;
                    if(!Test.isRunningTest()){
                        apiResponse =  Syntilio.DataHubCallout.onGet('medicalsummaries', query, destinationsModelSerialized);
                    } else {
                        apiResponse = new HttpResponse();
                        apiResponse.setBody('{"Test_ES": {"policy": {}, "alerts": []}}');
                    }
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(apiResponse.getBody());
        
                    Map<String, Object> policyMap = new Map<String, Object>();
                    Map<String, Object> alertsMap = new Map<String, Object>();
                    for(String destinationKey : responseMap.keySet()){
                        if(!noPolicy){
                            policyMap.put(destinationKey, ((Map<String, Object>) responseMap.get(destinationKey)).get('policy'));
                        }
                        if(!noAlert){
                            alertsMap.put(destinationKey, ((Map<String, Object>) responseMap.get(destinationKey)).get('alerts'));
                        }
                    }
                    if(!noPolicy){
                        apiResponse.setBody(JSON.serialize(policyMap));
                        Map<String, Object> mappedUpsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Syntilio__MedicalPolicy__c', apiResponse, false);
                    }
                    if(!noAlert){
                        apiResponse.setBody(JSON.serialize(alertsMap));
                        Map<String, Object> mappedUpsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Syntilio__ContactAlert__c', apiResponse, false);
                    }
                    ResponseMessage response = new ResponseMessage(null, 'Medical Summaries synced successfully', ResponseMessage.MessageType.SUCCESS);
                    Syntilio.CareHubUtilities.notifyLWC(response.serialize(), 'SafetyBadges' , Syntilio.CareHubUtilities.Status.Success.name());
                } catch (Exception e) {
                    Syntilio.CareHubUtilities.notifyLWC('', 'SafetyBadges' , Syntilio.CareHubUtilities.Status.Failure.name());
                    Syntilio.HandleException.LogException(e);
                }
            }

            
        }
    }
    
    @NamespaceAccessible
    public static void handleMedicalPolicyTrigger(
        System.TriggerOperation operationType, 
        Map<Id, Syntilio__MedicalPolicy__c> oldMap, 
        Map<Id, Syntilio__MedicalPolicy__c> newMap) {
            List<Syntilio__MedicalPolicy__c> policiesToUpdate = new List<Syntilio__MedicalPolicy__c>();
            for (Syntilio__MedicalPolicy__c medicalPolicy : newMap.values()) {
                if(!medicalPolicy.Syntilio__MostRecent__c){
                    continue;
                }
                Id contactId = medicalPolicy.Syntilio__ContactId__c;
                Id medicalPolicyId = medicalPolicy.Id;
                List<Syntilio__MedicalPolicy__c> activePolicies = [
                    SELECT Id 
                    FROM Syntilio__MedicalPolicy__c 
                    WHERE Syntilio__ContactId__c = :contactId
                    AND Syntilio__MostRecent__c = true
                    AND Id != :medicalPolicyId
                    WITH SECURITY_ENFORCED
                ];
                for(Syntilio__MedicalPolicy__c policy : activePolicies) {
                    policy.Syntilio__MostRecent__c = false;
                }
                policiesToUpdate.addAll(activePolicies);
            }
            Syntilio.UpsertToDatabase.updateAction(policiesToUpdate,false);
    }
    
    @NamespaceAccessible
    public static void handleContactAlertTrigger(
        System.TriggerOperation operationType, 
        Map<Id, Syntilio__ContactAlert__c> oldMap, 
        Map<Id, Syntilio__ContactAlert__c> newMap) {
            Map<Id, List<Id>> contactToContactAlertIds = new Map<Id, List<Id>>();
            for (Syntilio__ContactAlert__c contactAlert : newMap.values()) {
                Id contactId = contactAlert.Syntilio__ContactId__c;
                List<Id> contactAlerts = contactToContactAlertIds.get(contactId);
                if(contactAlerts == null) {
                    contactAlerts = new List<Id>();
                }
                contactAlerts.add(contactAlert.Id);
                contactToContactAlertIds.put(contactId, contactAlerts);
            }
            List<Syntilio__ContactAlert__c> contactAlertsToUpdate = new List<Syntilio__ContactAlert__c>();
            for(Id contactId : contactToContactAlertIds.keySet()) {
                List<Id> idsList = contactToContactAlertIds.get(contactId);
                contactAlertsToUpdate.addAll([
                    SELECT Id 
                    FROM Syntilio__ContactAlert__c
                    WHERE Syntilio__ContactId__c = :contactId
                    AND Syntilio__Active__c = true
                    AND Id NOT IN :idsList
                    WITH SECURITY_ENFORCED
                ]);
            }
            for(Syntilio__ContactAlert__c contactAlert : contactAlertsToUpdate) {
                contactAlert.Syntilio__Active__c = false;
            }
            Syntilio.UpsertToDatabase.updateAction(contactAlertsToUpdate,false);
    }
}