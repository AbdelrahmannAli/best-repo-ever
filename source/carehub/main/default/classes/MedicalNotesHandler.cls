@NamespaceAccessible
public with sharing class MedicalNotesHandler {

    @NamespaceAccessible
    public static void handleTrigger(System.TriggerOperation operationType, Map<Id, Case> oldMap, Map<Id, Case> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return;
        }
        Syntilio__TriggerEnablerConfiguration__mdt triggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('CaseMedicalNotesTrigger');
        if(!Test.isRunningTest() && (triggerEnablerConfiguration == null || triggerEnablerConfiguration.Syntilio__UseCustomTrigger__c || triggerEnablerConfiguration.Syntilio__AfterInsert__c == false)){
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
            syncMedicalNotes(new List<Id>(contacts.keySet()));
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }

    @AuraEnabled
    public static String getContactMedicalNotes(Id contactId) {
        try {
            List<Syntilio__MedicalNote__c> medicalNotesList = [
                SELECT Id, Name, CreatedDate, Syntilio__Comments__c
                FROM Syntilio__MedicalNote__c
                WHERE Syntilio__ContactId__c = :contactId
                WITH SECURITY_ENFORCED
                ORDER BY Syntilio__ExternalUpdatedAt__c ASC
                LIMIT 5
            ];
            ResponseMessage responseMessage = new ResponseMessage(
                medicalNotesList,
                medicalNotesList.size() == 0 ? 'Contact has no medical notes' : 'Retrieved contact medical notes successfully',
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
    public static void manualSyncMedicalNotes(Id clientId){
        syncMedicalNotes(new List<Id>{clientId});
    }
    
    @NamespaceAccessible
    @future(callout=true)
    public static void syncMedicalNotes(List<Id> contactIds) {
        List<Contact> contacts;
        try{
            contacts = getContacts(contactIds);
            if(contacts.size() == 0){
                return;
            }
        } catch (Exception e) {
            Syntilio.CareHubUtilities.notifyLwc('', 'MedicalNotes' , Syntilio.CareHubUtilities.status.Failure.name());
            Syntilio.HandleException.LogException(e);   
            return;
        }

        Set<String> accountIds = new Set<String>();
        for(Contact contact : contacts){
            accountIds.add(contact.AccountId);
        }

        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Syntilio__MedicalNote__c');
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
                    HttpResponse apiResponse;
                    if(!Test.isRunningTest()){
                        apiResponse =  Syntilio.DataHubCallout.onGet('medicalnotes', '?client_id=' + contactExternalId, destinationsModelSerialized);
                    } else {
                        apiResponse = new HttpResponse();
                        apiResponse.setBody('{"Test_Dest": {"Syntilio__Relationship__c": {}, "ExternalIds": []}}');
                    }
                    Map<String, Object> mappedUpsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Syntilio__MedicalNote__c', apiResponse, false);
                    if(mappedUpsertion.isEmpty()){
                        SyntilioException.throwError('Medical Notes insertion failed');
                    }
                } catch (Exception e) {
                    Syntilio.CareHubUtilities.notifyLwc('', 'MedicalNotes' , Syntilio.CareHubUtilities.status.Failure.name());
                    Syntilio.HandleException.LogException(e);   
                }
            }   
        }
        ResponseMessage response = new ResponseMessage(null, 'Medical Notes synced successfully', ResponseMessage.MessageType.SUCCESS);
        Syntilio.CareHubUtilities.notifyLwc(response.serialize(), 'MedicalNotes' ,  Syntilio.CareHubUtilities.status.SUCCESS.name());
    }
}