public with sharing class GetCaseContact {
    @AuraEnabled(cacheable=true)
    public static Contact getContactData(String caseId) {
        Case caseRecord;
        try {
            caseRecord = [
                SELECT ContactId, Contact.Name, Contact.Syntilio__UserId__c, Contact.Birthdate, 
                       Contact.MailingAddress
                FROM Case
                WHERE Id = :caseId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        } catch (Exception e) {
            return null;
        }
        
        if (caseRecord.ContactId == null) {
            return null;
        }

        Syntilio__ExternalId__c externalId;
        try {
            externalId = [
                SELECT Syntilio__Id__c, Syntilio__ContactId__c
                FROM Syntilio__ExternalId__c
                WHERE Name = 'identificationNo' AND Syntilio__ContactId__c = :caseRecord.ContactId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
        } catch (Exception e) {
            return caseRecord.Contact;
        }
        caseRecord.Contact.Syntilio__UserId__c = externalId.Syntilio__Id__c;

        return caseRecord.Contact;
    }
}
