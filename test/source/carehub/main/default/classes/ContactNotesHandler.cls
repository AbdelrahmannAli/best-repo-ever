@NamespaceAccessible
public with sharing class ContactNotesHandler {

	@NamespaceAccessible
    public static void handleTrigger(System.TriggerOperation operationType, Map<Id, Case> oldMap, Map<Id, Case> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return;
        }
        Syntilio__TriggerEnablerConfiguration__mdt triggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('CaseContactNotesTrigger');
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
            syncContactNotes(new List<Id>(contacts.keySet()));
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }

    @AuraEnabled
    public static String getCaseContactNotes(Id caseId) {
        try {
            String caseContactSerialized = Syntilio.DataHubUtilities.getCaseContactId(caseId);
            Case caseContact = (Case) JSON.deserialize(caseContactSerialized, Case.class);
            List<Syntilio__ContactNote__c> contactNotesList = getContactNotes(caseContact.ContactId);
            ResponseMessage responseMessage = new ResponseMessage(
                contactNotesList,
                contactNotesList.size() == 0 ? 'Contact has no notes' : 'Retrieved contact notes successfully',
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

    @NamespaceAccessible
    public static List<Syntilio__ContactNote__c> getContactNotes(Id contactId) {
        Date todayDate = Date.today();
        List<Syntilio__ContactNote__c> contactNotesList = [
            SELECT Id, Name, CreatedDate, Syntilio__Content__c, Syntilio__Author__c
            FROM Syntilio__ContactNote__c
            WHERE Syntilio__ContactId__c = :contactId
            AND Syntilio__StartDate__c <= :todayDate
            AND (Syntilio__EndDate__c = null OR Syntilio__EndDate__c >= :todayDate)
            WITH SECURITY_ENFORCED
            ORDER BY Syntilio__ExternalUpdatedAt__c ASC
            LIMIT 5
        ];
        return contactNotesList;
    }
    @NamespaceAccessible
    public static List<String> getContactNoteIds(Map<String, Object> synchronisationHandlerOutput){
        List<Object> saveResults = (List<Object>) synchronisationHandlerOutput.get('saveResults');
        List<String> ids = new List<String>();
        for(Object result : saveResults) {
            ids.add(((Database.SaveResult)result).getId());
        }
        return ids;
    }

    @AuraEnabled
    public static void manualSyncContactNotes(Id clientId){
        syncContactNotes(new List<Id>{clientId});
    }

    @NamespaceAccessible
    @future(callout=true)
    public static void syncContactNotes(List<Id> contactIds) {
        List<Contact> contacts;
        try{
            contacts = getContacts(contactIds);
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

        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Syntilio__ContactNote__c');
        Map<String, Object> externalIdPerContact = Syntilio.DataHubUtilities.getExternalIdPerContact(contactIds);
        List<String> contactNoteIds = new List<String>();

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
                        apiResponse =  Syntilio.DataHubCallout.onGet('contactnotes', '?client_id=' + contactExternalId, destinationsModelSerialized);
                    } else {
                        apiResponse = new HttpResponse();
                        apiResponse.setBody('{"Test_Dest": {"Syntilio__Content__c": "Test", "ExternalIds": []}}');
                    }
                    Map<String, Object> mappedUpsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Syntilio__ContactNote__c', apiResponse, false);
                    if(mappedUpsertion.isEmpty()){
                        SyntilioException.throwError('Contact Notes insertion failed');
                    }
                    contactNoteIds.addAll(getContactNoteIds(mappedUpsertion));
                } catch (Exception e) {
                    Syntilio.CareHubUtilities.notifyLwc('', 'ContactNotes' , Syntilio.CareHubUtilities.status.Failure.name());
                    Syntilio.HandleException.LogException(e);   
                }
            }
        }
        
        deleteDeletedContactNotes(contactNoteIds, contactIds);
        Syntilio.ResponseMessage response = new Syntilio.ResponseMessage(null, 'Contact Notes synced successfully', ResponseMessage.MessageType.SUCCESS);
        Syntilio.CareHubUtilities.notifyLwc('', 'ContactNotes' , Syntilio.CareHubUtilities.status.Success.name());
    }

    private static void deleteDeletedContactNotes(List<String> contactNoteIds, List<Id> contactId) {
        List<Syntilio__ContactNote__c> contactNotesToDelete = [
            SELECT Id 
            FROM Syntilio__ContactNote__c 
            WHERE Syntilio__ContactId__c IN :contactId AND Id NOT IN :contactNoteIds
            WITH SECURITY_ENFORCED
        ];
        List<String> contactNoteIdsToDelete = Syntilio.DataHubUtilities.sObjectListToIdList(contactNotesToDelete);
        List<Syntilio__ExternalId__c> externalIdsToDelete = [
            SELECT Id 
            FROM Syntilio__ExternalId__c 
            WHERE Syntilio__ContactId__c IN :contactId 
            AND Syntilio__RelatedSalesforceInternalId__c IN :contactNoteIdsToDelete
            WITH SECURITY_ENFORCED
        ];
        Syntilio.UpsertToDatabase.deleteAction(externalIdsToDelete, false);
        Syntilio.UpsertToDatabase.deleteAction(contactNotesToDelete,false);
    }
}