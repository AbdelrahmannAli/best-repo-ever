@NamespaceAccessible
public with sharing class AppointmentHandler {
    
    @invocableMethod(label='Get External System Appointments')
    public static void getExternalSystemAppointments(List<InputVariables> inputVariables){
        List<Id> contactIds = new List<Id>();
        Date fromDate;
        Date toDate;
        for(InputVariables inputVariable : inputVariables){
            contactIds.add(inputVariable.contactId);
            fromDate = inputVariable.fromDate;
            toDate = inputVariable.toDate;
        }
        syncContactAppointments(contactIds, fromDate, toDate);
        syncAppointments(contactIds, fromDate, toDate);
    }

    @NamespaceAccessible
    public static void handleTrigger(System.TriggerOperation operationType, Map<Id, Case> oldMap, Map<Id, Case> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return;
        }
        Syntilio__TriggerEnablerConfiguration__mdt triggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('CaseAppointmentsTrigger');
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
            Date today = Date.today();
            Date oneMonthLater = today.addMonths(1);
            Map<Id, Boolean> contacts = new Map<Id, Boolean>(); 
            for (Case caseRecord : newMap.values()){
                Id contactId = caseRecord.ContactId;
                if(contacts.containsKey(contactId)){
                    continue;
                }
                contacts.put(contactId, true);
            }
            syncContactAppointments(new List<Id>(contacts.keySet()),today,oneMonthLater);
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }
    
    public class InputVariables {
        @invocableVariable
        public Date fromDate;
        @invocableVariable
        public Date toDate;
        @invocableVariable
        public Id contactId;
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


    @future(callout=true)
    public static void syncContactAppointments(List<Id> contactIds, Date fromDate, Date toDate) {
        List<Contact> contacts;
        try{
            contacts = getContacts(contactIds);
            if(contacts.size() == 0){
                return;
            }
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return;
        }

        Set<String> accountIds = new Set<String>();
        for(Contact contact : contacts){
            accountIds.add(contact.AccountId);
        }

        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Event');
        Map<String, Object> externalIdPerContact = Syntilio.DataHubUtilities.getExternalIdPerContact(contactIds);

        for(Contact contact : contacts) {
            Map<String, Set<String>> viableExternalSystemsPerContactAccount = new Map<String, Set<String>>();
            viableExternalSystemsPerContactAccount = viableExternalSystemsPerAccountId.get(contact.AccountId);
            if (viableExternalSystemsPerContactAccount != null){
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
            
                        String query = '?client_id=' + contactExternalId 
                            + '&valid_from=' + DateTime.newInstance(fromDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
                            + '&valid_to=' + DateTime.newInstance(toDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                        HttpResponse apiResponse;
                        if(!Test.isRunningTest()){
                            apiResponse =  Syntilio.DataHubCallout.onGet('event', query, destinationsModelSerialized);
                        } else {
                            apiResponse = new HttpResponse();
                            apiResponse.setBody('{"Test_Dest": {"Syntilio__Relationship__c": {}, "ExternalIds": []}}');
                        }
                        Map<String, Object> mappedUpsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Event', apiResponse, false);
                        ResponseMessage response = new ResponseMessage(null, 'Appointments synced successfully', ResponseMessage.MessageType.SUCCESS);
                    } catch (Exception e) {
                        Syntilio.HandleException.LogException(e);
                    }
                }
            }
        }
    }
    
    @AuraEnabled
    public static Object syncAppointments(List<Id> contactIds, Date fromDate, Date toDate) {
        List<Contact> contacts;
        Object appointments = new List<Object>();

        try{
            contacts = getContacts(contactIds);
            if(contacts.size() == 0){
                return appointments;
            }
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return appointments;
        }

        Set<String> accountIds = new Set<String>();
        for(Contact contact : contacts){
            accountIds.add(contact.AccountId);
        }

        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Event');
        Map<String, Object> externalIdPerContact = Syntilio.DataHubUtilities.getExternalIdPerContact(contactIds);

        for(Contact contact : contacts) {
            Map<String, Set<String>> viableExternalSystemsPerContactAccount = new Map<String, Set<String>>();
            viableExternalSystemsPerContactAccount = viableExternalSystemsPerAccountId.get(contact.AccountId);
            if (viableExternalSystemsPerContactAccount != null){
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
            
                        String query = '?client_id=' + contactExternalId 
                            + '&valid_from=' + DateTime.newInstance(fromDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
                            + '&valid_to=' + DateTime.newInstance(toDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                        HttpResponse apiResponse;
                        if(!Test.isRunningTest()){
                            apiResponse =  Syntilio.DataHubCallout.onGet('event', query, destinationsModelSerialized);
                        } else {
                            apiResponse = new HttpResponse();
                            apiResponse.setBody('{"Test_Dest": {"Syntilio__Relationship__c": {}, "ExternalIds": []}}');
                        }
                        if (apiResponse.getStatusCode() == 200) {
                            try {
                                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(apiResponse.getBody());
                                for (String destination : responseMap.keySet()) {
                                    Object innerMapObject = responseMap.get(destination);
                                    return innerMapObject;
                                }
                            } catch (Exception e) {
                                Syntilio.HandleException.logException(e, 'syncContactAppointmentsTest');
                            }
                        } 
                        return appointments;
                    } catch (Exception e) {
                        Syntilio.HandleException.LogException(e);
                    }
                }
            }
        }
        return appointments;
    }
}