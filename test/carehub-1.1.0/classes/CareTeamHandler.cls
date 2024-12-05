@NamespaceAccessible
public with sharing class CareTeamHandler {
    
    
    @AuraEnabled(cacheable=true)
    public static Contact getPatientData(Id contactId) {
        Contact patientData = [
            SELECT Id, Name, AccountId, MailingPostalCode 
            FROM Contact WHERE Id = :contactId
        ];
        
        return patientData;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getCareTeams(Id caseId) {       
        Map<String,Object> careTeamsData = new Map<String,Object>();
        Syntilio.ResponseMessage result;
        Case requestedCase = [
            SELECT Id, ContactId, CreatedDate, Syntilio__CareTeam__c FROM Case WHERE Id = :caseId
        ];
        
        if(requestedCase.ContactId == null) {
            result = new Syntilio.ResponseMessage(false, null, 'Requested Case may have not been assigned to a patient');
            return result.serialize();
        }
        
        Contact patientData = Syntilio.CareTeamHandler.getPatientData(requestedCase.ContactId);
        List<Id> orgInContractList = Syntilio.CareTeamHandler.getAllCareOrgsInContract(patientData.AccountId);
        
        Id careTeamRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareTeam').getRecordTypeId();
        List<Contact> allCareTeams = [
            SELECT Id, Name, Phone, HomePhone, DoNotCall, MobilePhone, Account.Name
            FROM Contact
            WHERE AccountId IN :orgInContractList AND RecordTypeId = :careTeamRecordTypeId
        ];
        
        List<Contact> careTeams = new List<Contact>();
        List<Contact> careOrgCareTeams = new List<Contact>();
        
        for(Contact careTeam : allCareTeams) {
            if(careTeam.AccountId == patientData.AccountId) {
                careOrgCareTeams.add(careTeam);
            }
            Boolean isCareTeamWorkingThisZipCode = isCareTeamWorkingThisZipCode(careTeam.Id, requestedCase, patientData.MailingPostalCode);
            Boolean isCareTeamAvailable = isCareTeamAvailable(careTeam.Id, requestedCase);
            
            if(isCareTeamWorkingThisZipCode && isCareTeamAvailable){
                careTeams.add(careTeam);
            }
        }
        
        careTeamsData.put('parentCareOrgId', patientData.AccountId);
        careTeamsData.put('careOrgTeams', careOrgCareTeams);
        careTeamsData.put('allCareTeams', careTeams);
		result = new Syntilio.ResponseMessage(true, careTeamsData, '');
        return result.serialize();        
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isCareTeamAvailable(Id careTeamId, Case requestedCase) {
        
        Date todaysDate = Date.today();
        DateTime todaysDateTime = DateTime.now();
        Datetime caseCreatedDate = requestedCase.CreatedDate;
        Time caseCreatedTime = caseCreatedDate.time();
        
        String dayOfWeek = todaysDateTime.format('EEEE');
        Integer availableTimeSlots = [
            SELECT COUNT()
            FROM Syntilio__CareTimeSlot__c
            WHERE (Syntilio__DayOfWeek__c = :dayOfWeek
                   AND Syntilio__StartTime__c <= :caseCreatedTime
                   AND Syntilio__EndTime__c >= :caseCreatedTime) AND Syntilio__CareOperatingHoursId__c IN (
                       SELECT Id
                       FROM Syntilio__CareOperatingHours__c
                       WHERE Syntilio__CareTeam__c = :careTeamId
                       AND (Syntilio__StartDate__c = null OR Syntilio__StartDate__c <= :todaysDate)
                       AND (Syntilio__EndDate__c = null OR Syntilio__EndDate__c >= :todaysDate)
                   )
        ];
        
        if(availableTimeSlots > 0){
            return true;
        }
        
        return false;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isCareTeamWorkingThisZipCode(Id careTeamId, Case requestedCase, String mailingPostalCode) {
        Syntilio__ServiceZipCode__c[] serviceZipCodeList = [
            SELECT Name, Syntilio__ZipCode__c
            FROM Syntilio__ServiceZipCode__c
            WHERE Syntilio__ContactId__c = :careTeamId
        ];
        if (serviceZipCodeList.size() == 0 || mailingPostalCode == null) {
            return true;
        }
        
        for (Syntilio__ServiceZipCode__c zipCode : serviceZipCodeList) {
            if(zipCode.Syntilio__ZipCode__c != null && zipCode.Syntilio__ZipCode__c.equalsIgnoreCase(mailingPostalCode)){
                return true;
            } 
        }
        return false;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Id> getAllCareOrgsInContract(Id accountId) {
        Set<Id> careOrgsInContract = new Set<Id>();
        Date todaysDate = System.today();
        
        careOrgsInContract.add(accountId);
        for (Syntilio__CareOrganizationContractRelation__c record : [
            SELECT Syntilio__MainAccount__c, Syntilio__CounterPartyAccount__c, Syntilio__StartDate__c, Syntilio__EndDate__c
            FROM Syntilio__CareOrganizationContractRelation__c 
            WHERE (
                Syntilio__CounterPartyAccount__c = :accountId
                OR Syntilio__MainAccount__c = :accountId 
            ) 
            AND (
                (Syntilio__StartDate__c <= :todaysDate OR Syntilio__StartDate__c = null)
                OR (Syntilio__EndDate__c  >=  :todaysDate OR Syntilio__EndDate__c = null)
            )
        ])
        {
            careOrgsInContract.add(record.Syntilio__MainAccount__c);
            careOrgsInContract.add(record.Syntilio__CounterPartyAccount__c);
        }
        List<Id> returnList = new List<Id>(careOrgsInContract);
        return returnList;
    }
    
    @AuraEnabled(cacheable=false)
    public static void updateCaseCareTeamId(Id caseId, Id newCareTeamId) {
        Case requestedCase = [
            SELECT Id, Syntilio__CareTeam__c 
            FROM Case 
            WHERE Id = :caseId
        ];
        
        requestedCase.Syntilio__CareTeam__c = newCareTeamId;
        update requestedCase;
    }
    
    
}