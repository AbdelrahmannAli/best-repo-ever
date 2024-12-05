@NamespaceAccessible
public with sharing class ClientCasesController {
    
    @AuraEnabled
    public static String getClientCases(Id clientId){
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        List<Case> cases = [SELECT Id, CaseNumber, Subject, Syntilio__Event__r.Syntilio__Code__c, Owner.Alias FROM Case WHERE ContactId = :clientId WITH SECURITY_ENFORCED];

        List<Id> casesIds = new List<Id>();
        for(Case c : cases){
            casesIds.add(c.Id);
        }

        Map<String, String> casesDuration = getCasesDuration(casesIds);
        // Map<String, Decimal> casesEventCode = getCasesEventCode(cases);
        for(Case c : cases){
            Map<String, Object> caseMap = new Map<String, Object>();
            caseMap.put('caseId', c.Id);
            caseMap.put('caseNumber', c.CaseNumber);
            caseMap.put('subject', c.Subject);
            caseMap.put('duration', casesDuration.get(c.Id));
            caseMap.put('createdBy', c.Owner.Alias);
            caseMap.put('eventCode', c.Syntilio__Event__r.Syntilio__Code__c);
            result.add(caseMap);
        }

        ResponseMessage responseMessage = new ResponseMessage(
            result,
            'Cases found',
            ResponseMessage.MessageType.SUCCESS
        );
        return responseMessage.serialize();
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getClients() {
        Map<String,Object> result = new Map<String,Object>();
        Id clientContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
        List<Contact> contacts = [SELECT Id, FirstName, LastName,Birthdate,MailingStreet,MailingPostalCode FROM Contact WHERE RecordTypeId =: clientContactRecordTypeId WITH SECURITY_ENFORCED];
        result.put('contacts', JSON.serialize(contacts));
        List<Syntilio__ExternalId__c> externalIds = [
            SELECT Syntilio__Id__c, Syntilio__ContactId__c
            FROM Syntilio__ExternalId__c
            WHERE Name = 'identificationNo'
            WITH SECURITY_ENFORCED
        ];
        result.put('externalIds', JSON.serialize(externalIds));
        return result;
    }

    @AuraEnabled
    public static List<Syntilio__ExternalSystem__c> getExternalSystems () {
        List <Syntilio__ExternalSystem__c> externalSystemNames = [SELECT Name , Syntilio__MedicalOverviewUrl__c, Syntilio__ChatUrl__c FROM Syntilio__ExternalSystem__c WITH SECURITY_ENFORCED LIMIT 1000];
        return externalSystemNames;
      }
    @AuraEnabled
      public static String getRedirectURL (Id caseId , String externalSystemName , String redirect) {
        List<Case> requested_case = [SELECT ContactId FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        String redirectUrl = redirect;
        if (requested_case.size() == 0) {
            redirectURL = null;
            return null;
        }
        Syntilio__ExternalId__c[] contactExternalId = [
          	SELECT Syntilio__Id__c 
            FROM Syntilio__ExternalId__c
            WHERE Syntilio__ContactId__c = :requested_case[0].ContactId AND Name = 'clientId' AND Syntilio__RelatedSalesforceInternalId__c = null 
            AND Syntilio__ExternalSystemId__r.Name =: externalSystemName
            WITH SECURITY_ENFORCED
        ];

        if(contactExternalId.size() == 0) {
            redirectURL = null;
            return null;
        }
       	redirectURL = redirectUrl.replace('client_id',contactExternalId[0].Syntilio__Id__c );
        return redirectUrl;
    }

    @AuraEnabled(cacheable=false)
    public static Boolean getCaseTabClosureConfirmation() {
        Syntilio__CareHubAppConfiguration__mdt careHubAppConfiguration = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        Boolean caseTabClosureConfirmation = Boolean.valueOf(careHubAppConfiguration.Syntilio__CaseTabClosureConfirmation__c);
        return caseTabClosureConfirmation;
    }
    
    @AuraEnabled(cacheable=false)
    public static Integer getListViewAutoRefreshDuration() {
        Syntilio__CareHubAppConfiguration__mdt careHubAppConfiguration = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        Integer autoRefreshInterval = Integer.valueOf(careHubAppConfiguration.Syntilio__ListViewAutoRefreshDuration__c);
        return autoRefreshInterval;
    }
    @AuraEnabled(cacheable=false)
    public static String getAutoRefreshInterval() {
        Syntilio__CareHubAppConfiguration__mdt careHubAppConfiguration = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        String autoRefreshInterval = String.valueOf(careHubAppConfiguration.Syntilio__AutoRefreshInterval__c);
        return autoRefreshInterval;
    }

    @AuraEnabled
    public static Object getClientAppoinments(Id clientId) {
        List<Id> contactIds = new List<Id> ();
        contactIds.add(clientId);
        Date today = Date.today();
        // Date oneMonthFromNow = today.addMonths(1);
        Date eightDaysFromNow = today.addDays(8);
        Object appointments = Syntilio.AppointmentHandler.syncAppointments(contactIds,today,eightDaysFromNow);
        return appointments;
    }
    @AuraEnabled
    public static List<Syntilio__ContactContactRelationship__c> getCaseContactCareCircleMembers(Id clientId){
        Id careCircleMemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareCircle').getRecordTypeId();
        List <Syntilio__ContactContactRelationship__c> careCircleMembers = [SELECT Syntilio__RelatedContactId__r.Salutation, Syntilio__RelatedContactId__r.Name,Syntilio__RelatedContactId__r.Email,
                                                                            Syntilio__RelatedContactId__r.Phone, Syntilio__RelatedContactId__r.LastModifiedDate, 
                                                                            Syntilio__ContactContactRelationship__c.Syntilio__Relationship__c, 
                                                                            Syntilio__ContactContactRelationship__c.Syntilio__RelationshipType__c,Syntilio__ContactContactRelationship__c.Syntilio__Order__c 
                                                                            FROM Syntilio__ContactContactRelationship__c
                                                                            WHERE Syntilio__RelatedContactId__r.RecordTypeId = :careCircleMemberRecordTypeId
                                                                            AND Syntilio__ContactId__r.Id = :clientId WITH SECURITY_ENFORCED ORDER BY Syntilio__ContactContactRelationship__c.Syntilio__Order__c ASC  ];
        return careCircleMembers;
    }

    @NamespaceAccessible
    public static Map<String, Decimal> getCasesEventCode(List<Case> cases) {
        Set<Id> casesIds = new Set<Id>();
        for(Case c : cases){
            casesIds.add(c.Id);
        }
        List<Case> casesWithEvent = [SELECT Syntilio__Event__r.Syntilio__Code__c FROM Case WHERE Id IN :casesIds WITH SECURITY_ENFORCED];
        Map<String, Decimal> casesEventCode = new Map<String, Decimal>();
        for(Case c : casesWithEvent){
            casesEventCode.put(c.Id, c.Syntilio__Event__r.Syntilio__Code__c);
        }
        return casesEventCode;
    }
    @NamespaceAccessible
    public static Map<String, String> getCasesDuration(List<Id> casesIds){
        Map<String, String> casesDuration = new Map<String, String>();
        List<Syntilio__CallLog__c> transcripts = [SELECT Syntilio__Duration__c, Syntilio__CaseId__c FROM Syntilio__CallLog__c WHERE Syntilio__CaseId__c IN :casesIds WITH SECURITY_ENFORCED];
        for(Syntilio__CallLog__c transcript : transcripts){
            casesDuration.put(transcript.Syntilio__CaseId__c, casesDuration.get(transcript.Syntilio__CaseId__c) != null ? casesDuration.get(transcript.Syntilio__CaseId__c) + ', ' + transcript.Syntilio__Duration__c : transcript.Syntilio__Duration__c );
        }
        return casesDuration;
    }

    @AuraEnabled
    public static string getCaseContactId(Id caseId){
        return Syntilio.CareHubUtilities.getCaseContactId(caseId);
    }

    @AuraEnabled
    public static string getCaseSuggested(Id clientId){
        return Syntilio.CareHubUtilities.getCaseSuggested(clientId);
    }

    @AuraEnabled(cacheable=false)
    public static String getAllContacts(){
        List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Birthdate, MailingStreet, MailingPostalCode 
            FROM Contact  
            WITH SECURITY_ENFORCED
        ];

        return JSON.serialize(contacts);
    }

    @AuraEnabled(cacheable=false)
    public static String getAllGroups(){
        String query = 'Care Circle';
        List<Syntilio__Group__c> callerGroups = [
            SELECT Id,Name
            FROM Syntilio__Group__c
            WHERE Syntilio__ObjectType__c =: query
            WITH SECURITY_ENFORCED
        ];

        return JSON.serialize(callerGroups);
    }

    @AuraEnabled
    public static string getCaseContactExternalSystem(Id caseId){
        List <Case> caseList = [SELECT AccountId FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        if(caseList[0].AccountId == null) {
            return null;
        }
        String accountId = caseList[0].AccountId;
        List<String> accountExternalSystem = Syntilio.CareHubUtilities.getAccountExternalSystems(accountId);
        if (accountExternalSystem.size() == 0){
            return null;
        }
        return accountExternalSystem[0];
    }

    @AuraEnabled
    public static Map<String, String> getCaseStatus(Id caseId){
        List <Case> caseStatus = [SELECT Status, OwnerId, Syntilio__Event__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        Syntilio__CareHubAppConfiguration__mdt  careHubAppConfiguration = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        if(caseStatus.size() == 0) {
            return null;
        }

        Map<String, String> result = new Map<String, String>();
        result.put('status', caseStatus[0].Status);
        result.put('owner', caseStatus[0].OwnerId);
        result.put('event', caseStatus[0].Syntilio__Event__c);
        result.put('customMetadata', careHubAppConfiguration.Syntilio__CaseClosurebyCaseOwnersandProfiles__c);
        result.put('enableNonOwnerClosing',String.valueOf(careHubAppConfiguration.Syntilio__CaseClosureByNonCaseOwners__c));
        result.put('enableEventClosing',String.valueOf(careHubAppConfiguration.Syntilio__CaseClosureWithEvents__c));
        return result;
    }

    @AuraEnabled
    public static string setCaseStatus(Id caseId, String status){
        List <Case> caseRecord = [SELECT Status FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];

        
        if(caseRecord.size() == 0) {
            return null;
        }

        caseRecord[0].Status = status;
        
        List<Database.SaveResult> updatedCases = Syntilio.UpsertToDatabase.updateAction(caseRecord, false);
        
        return caseRecord[0].Status;
    }

    @AuraEnabled
    public static void updateCaseContactId(Id caseId , String clientId){
        Syntilio.CareHubUtilities.updateCaseContactId(caseId,clientId);
    }
    @AuraEnabled
    public static void updateCaseCaller(Id caseId , String callerId){
        Syntilio.CareHubUtilities.updateCaseCaller(caseId,callerId);
    }
    @AuraEnabled
    public static void updateCaseCallerGroup(Id caseId , String callerGroupId){
        Syntilio.CareHubUtilities.updateCaseCallerGroup(caseId,callerGroupId);
    }
    
    @AuraEnabled
    public static List<Syntilio__SyntilioEvent__c> getContactEvents(Id recordId){
        List<Syntilio__SyntilioEvent__c> eventsList = new List<Syntilio__SyntilioEvent__c>();
        try{
            String sObjectType = Syntilio.DataHubUtilities.getSobjectFromId(recordId);
            Id contactId = recordId;
            if(sObjectType.toLowerCase() == 'case'){
                contactId = [
                    SELECT ContactId
                    FROM Case
                    WHERE Id = :recordId
                    WITH SECURITY_ENFORCED
            		LIMIT 1
                ].ContactId;
        	}
            eventsList = [
                SELECT Name, CreatedDate, Syntilio__EventCode__c
                FROM Syntilio__SyntilioEvent__c
                WHERE Syntilio__ContactId__c = :contactId
                WITH SECURITY_ENFORCED
            ];
            return eventsList;
        }catch(Exception e){
            return eventsList;
        }
    }
    
    @AuraEnabled
    public static String getCaseEventCode(Id caseId){
        try{
            Case caseFound = [
                SELECT Syntilio__Event__r.Syntilio__Code__c
                FROM Case
                WHERE Id = :caseId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            String eventCode = caseFound.Syntilio__Event__r.Syntilio__Code__c.toString();
            return eventCode;
        }catch(Exception e){
            return null;
        }
    }

    @AuraEnabled
    public static Id createCase() {
        Case newCase = new Case();
        if (!Test.isRunningTest()){
            Id caseEventCode = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1012].Id;
            Id defaultCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();
            newCase.Syntilio__Event__c = caseEventCode;
            newCase.RecordTypeId = defaultCaseRecordTypeId;
        }
        List<Case> newCases = new List<Case>();
        newCases.add(newCase);
        List<Database.SaveResult> insertedCases = Syntilio.UpsertToDatabase.insertAction(newCases, false);
        return newCase.Id;
    }

    @AuraEnabled
    public static Id setCaseOwner(Id caseId, Id ownerId) {
        List<Case> caseToUpdate = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        if(caseToUpdate.size() == 0) {
            return null;
        }
        caseToUpdate[0].OwnerId = ownerId;
        List<Database.SaveResult> updatedCases = Syntilio.UpsertToDatabase.updateAction(caseToUpdate, false);
        return caseToUpdate[0].OwnerId;
    }

    @AuraEnabled
    public static List<Syntilio__EventConfiguration__c> getAllEvents(){
        List<Syntilio__EventConfiguration__c> eventsList = new List<Syntilio__EventConfiguration__c>();
        eventsList = [
            SELECT Id, Name
            FROM Syntilio__EventConfiguration__c
            WITH SECURITY_ENFORCED
        ];
        if(eventsList.size() == 0) {
            return null;
        }
        return eventsList;
    }

    @AuraEnabled
    public static string setCaseEvent(Id caseId, Id eventId){
        List <Case> caseRecord = [SELECT Id FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
        if(caseRecord.size() == 0) {
            return null;
        }
        caseRecord[0].Syntilio__Event__c = eventId;
        List<Database.SaveResult> updatedCases = Syntilio.UpsertToDatabase.updateAction(caseRecord, false);
        return caseRecord[0].Id;
    }
}