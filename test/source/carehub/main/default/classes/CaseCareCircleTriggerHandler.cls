@namespaceAccessible
public with sharing class CaseCareCircleTriggerHandler {

    private static String objectTypeName = 'Contact';
    @NamespaceAccessible
    public static List<Syntilio.DataHubModel> handleTrigger(System.TriggerOperation operationType, Map<Id, Case> oldMap, Map<Id, Case> newMap){
        if(Syntilio.DataHubSyncModel.isSyncing){
            return null;
        }
        Syntilio__TriggerEnablerConfiguration__mdt contactTriggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('CaseCareCircleTrigger');
        if(contactTriggerEnablerConfiguration == null || contactTriggerEnablerConfiguration.Syntilio__UseCustomTrigger__c){
            return null;
        }
        switch on operationType {
            when AFTER_INSERT {
                if(contactTriggerEnablerConfiguration.Syntilio__AfterInsert__c){
                    handleAfterInsert(oldMap, newMap);
                }
            }
            when AFTER_UPDATE {
                if(contactTriggerEnablerConfiguration.Syntilio__AfterUpdate__c){
                    handleAfterInsert(oldMap, newMap);
                }
            }
        }
        return null;
    }
    @NamespaceAccessible
    public static List<Contact> getContacts(List<Id> contactIds) {
        List<Contact> contactList = [
            SELECT Name, AccountId
            FROM Contact
            WHERE Id IN :contactIds
            WITH SECURITY_ENFORCED
        ];
        return contactList;
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
            syncContactRelations(new List<Id>(contacts.keySet()));
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }
    @NamespaceAccessible
    public static List<String> getContactIdsInserted(Map<String, Object> careCircleMembersInsertion){
        List<Object> contactIdsInserted = (List<Object>)careCircleMembersInsertion.get('ids');
        List<String> ids = new List<String>();
        if(contactIdsInserted == null){
            return ids;
        }
        for(Object result : contactIdsInserted) {
            ids.add(((Database.SaveResult)result).getId());
        }
        return ids;
    }

    @NamespaceAccessible
    public static Map <String, List<String>> getExternalIdsInserted(Map<String, Object> careCircleMembersInsertion, Map<String, Object> allExternalSystemsMap, Map<String, Object> allAccountsMap){
        List<Object> externalCareCircleIds = (List<Object>) careCircleMembersInsertion.get('externalIds');
        Map<String, List<String>> destinationMap = new Map <String, List<String>>();

        if(externalCareCircleIds == null){
            return destinationMap;
        }

        for(Object result : externalCareCircleIds) {
            Syntilio__ExternalId__c oneCareCircle = (Syntilio__ExternalId__c) result; 
            String externalSystemApiName = (String) allExternalSystemsMap.get(oneCareCircle.Syntilio__ExternalSystemId__c);
            String accountApiName = (String) allAccountsMap.get(oneCareCircle.Syntilio__Account__c);

            String destinationKey = String.isBlank(accountApiName)? externalSystemApiName : accountApiName + '_' + externalSystemApiName;
            List<String> externalIdsInserted = destinationMap.get(destinationKey);
            if(externalIdsInserted == null){
                externalIdsInserted = new List<String>();
            }
            externalIdsInserted.add(oneCareCircle.Syntilio__Id__c);
            destinationMap.put(String.isBlank(accountApiName)? externalSystemApiName : accountApiName + '_' + externalSystemApiName, externalIdsInserted);
        }
        return destinationMap;
    }

    @AuraEnabled
    public static void manualSyncContactRelations(Id clientId){
            Syntilio.CaseCareCircleTriggerHandler.syncContactRelations(new List<Id>{clientId});
    }

    @NamespaceAccessible
    @future(callout=true)
    public static void syncContactRelations(List<Id> contactIds) {
        Map<String, Object> responseDeserialized = new Map<String, Object>();
        List<Contact> contacts;
        try{
            contacts = getContacts(contactIds);
            if(contacts.size() == 0){
                return;
            }
        } catch (Exception e) {
            Syntilio.CareHubUtilities.notifyLwc('', 'CareCircle' , Syntilio.CareHubUtilities.status.Failure.name());
            Syntilio.HandleException.LogException(e);
            return;
        }

        Set<String> accountIds = new Set<String>();
        for(Contact contact : contacts){
            accountIds.add(contact.AccountId);
        }
        Map<String, Map<String, Set<String>>> viableExternalSystemsPerAccountId = Syntilio.DataHubUtilities.getViableExternalSystemsPerAccount(new List<String>(accountIds), 'Contact');
        Map<String, Object> externalIdPerContact = Syntilio.DataHubUtilities.getExternalIdPerContact(contactIds);
        
        Set<String> combinedViableExternalSystems = new Set<String>();
        for(String accountId : viableExternalSystemsPerAccountId.keySet()){
            Map<String, Set<String>> accountViableExternalSystems = viableExternalSystemsPerAccountId.get(accountId);
            for(String systemName :
            	accountViableExternalSystems.keySet()
            ){
                combinedViableExternalSystems.addAll(accountViableExternalSystems.get(systemName));
            }
        }
        List<Syntilio__ExternalSystem__c> allExternalSystems = [
            SELECT Syntilio__ApiName__c 
            FROM Syntilio__ExternalSystem__c 
            WHERE Syntilio__ApiName__c IN :combinedViableExternalSystems 
            WITH SECURITY_ENFORCED 
        ];
        Map<String, Object> allExternalSystemsMap = Syntilio.DataHubUtilities.listToMap('Id', 'Syntilio__ApiName__c', allExternalSystems);
		
        List<Account> allAccounts = [
            SELECT Syntilio__ApiName__c 
            FROM Account
            WHERE Id IN :accountIds
            WITH SECURITY_ENFORCED 
        ];
        Map<String, Object> allAccountsMap = Syntilio.DataHubUtilities.listToMap('Id', 'Syntilio__ApiName__c', allAccounts);

        for(Contact contact : contacts) {
            Map<String, Set<String>> viableExternalSystemsPerContactAccount = new Map<String, Set<String>>();
            viableExternalSystemsPerContactAccount = viableExternalSystemsPerAccountId.get(contact.AccountId);
            if(viableExternalSystemsPerContactAccount != null && viableExternalSystemsPerContactAccount.size() > 0){
            for(String accountId : viableExternalSystemsPerContactAccount.keySet()){
                try {
                    String externalId = (String) externalIdPerContact.get(contact.Id);
                    String contactName = contact.Name;
                    List<String> viableExternalSystems = new List<String>(viableExternalSystemsPerContactAccount.get(accountId));
                    if(viableExternalSystems == null || viableExternalSystems.size() == 0 ) 
                        {
                        Syntilio.CareHubUtilities.notifyLwc('' , 'CareCircle' ,Syntilio.CareHubUtilities.Status.Failure.name());
                        SyntilioException.throwError('No viable external systems');
                    }
    
                    List<Syntilio.DataHubModel.Destination> destList = Syntilio.DataHubUtilities.getDestinationList(contact.AccountId, new Set<String>(viableExternalSystems));
                    String destinationsModelSerialized = JSON.serializePretty(destList);
                    String careCircleMemberContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareCircle').getRecordTypeId();
                    HttpResponse apiResponse;
                    if(!Test.isRunningTest()){
                        apiResponse =  Syntilio.DataHubCallout.onGet('contactrelations','?client_id=' + externalId +'&carecircleid=' + careCircleMemberContactRecordTypeId + '&contactid=' + contact.Id, destinationsModelSerialized);
                    } else {
                        apiResponse = new HttpResponse();
                        apiResponse.setBody('{"Test_ES":[{"ExternalIds":[{"Name":"careCircleclientId","Syntilio__Id__c":"10899"}],"MailingCountry":"NL","Phone":"0630740018","Syntilio__Relationship__c":"Eerste relatie / contactpersoon","Syntilio__RelationshipType__c":"Informal","LastName":"Dhr. Freek ","Name":"TESTCONTACT","Syntilio__Id__c":"10899"}]}');
                    }
                    responseDeserialized = (Map<String, Object>) JSON.deserializeUntyped(apiResponse.getBody());
                    Map<String, Object> careCircleMembersInsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Contact', apiResponse, false);   
                    Map<String, List<String>> destinationMap = getExternalIdsInserted(careCircleMembersInsertion, allExternalSystemsMap, allAccountsMap);
                    List<String> ids = getContactIdsInserted(careCircleMembersInsertion);
        
        
                    for (String destination : responseDeserialized.keySet()) {
                        List<Object> response = (List<Object>) responseDeserialized.get(destination);
                        List<String> careCircleExternalIds = (List<String>) destinationMap.get(destination);
                        List<Object> allCareCircleMembers = new List<Object>();
                        allCareCircleMembers.addAll(response);
                        Integer relatedContactIndex = 0;
                        for(Integer idIndex = 0; idIndex < allCareCircleMembers.size();idIndex++){
                            Map<String, Object> oneCareCircleMember = (Map<String, Object>) allCareCircleMembers[idIndex];
                            String syntilioId = (String) oneCareCircleMember.get('Syntilio__Id__c');
                            if (careCircleExternalIds.contains(syntilioId)){
                                oneCareCircleMember.put('Syntilio__RelatedContactId__c', ids[relatedContactIndex]);
                                relatedContactIndex++;
                                oneCareCircleMember.put('Name', 'Care circle member related to ' + contactName );
                                oneCareCircleMember.put('Syntilio__Order__c', null);
                            }
                        }
                    }
                    String serializedResponse = JSON.serialize(responseDeserialized);
                    apiResponse.setBody(serializedResponse);
                    Map<String, Object> newResponse = (Map<String, Object>) JSON.deserializeUntyped(apiResponse.getBody());
                    Map<String, Object> contactToContactRelationshipInsertion = Syntilio.DataHubSynchronisation.synchronizationHandler('Syntilio__ContactContactRelationship__c', apiResponse, false); 
                    Syntilio.CareHubUtilities.notifyLwc('' , 'CareCircle' , Syntilio.CareHubUtilities.Status.Success.name());   
                } catch (Exception e) {
                    if(!Test.isRunningTest()){
                        for (String destination : responseDeserialized.keySet()) {
                            List<Object> response = (List<Object>) responseDeserialized.get(destination);
                            if(response.size() > 0){
                                Syntilio.CareHubUtilities.notifyLwc('' , 'CareCircle' ,Syntilio.CareHubUtilities.Status.Warning.name());
                                return;
                            }
                        }
                        Syntilio.HandleException.LogException(e);
                        Syntilio.CareHubUtilities.notifyLwc('' , 'CareCircle' ,Syntilio.CareHubUtilities.Status.Failure.name());
                    }
                    Syntilio.HandleException.LogException(e);
                }
            }
        }
        else {
            Syntilio.CareHubUtilities.notifyLwc('' , 'CareCircle' ,Syntilio.CareHubUtilities.Status.Failure.name());
        }
        }
    }
}