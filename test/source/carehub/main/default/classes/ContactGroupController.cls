@NamespaceAccessible
public with sharing class ContactGroupController {
    
    @AuraEnabled
    public static string getContactsGroup(String caseId){

        if (caseId == null || caseId == '') {
            return new ResponseMessage(
                null,
                'Case Id is required',
                Syntilio.ResponseMessage.MessageType.ERROR
            ).serialize();
        }

        List<Case> caseRecords = [SELECT ContactId, Contact.RecordTypeId FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];

        Id contactId = caseRecords[0].ContactId;

        List<RecordType> records = [SELECT Id FROM RecordType WHERE (DeveloperName = 'SharedDevice' OR DeveloperName = 'CareCircle') AND SObjectType = 'Contact' WITH SECURITY_ENFORCED];
        List<Id> recordTypeIds = new List<Id>();

        for (RecordType record : records) {
            recordTypeIds.add(record.Id);
        }

        if (!recordTypeIds.contains(caseRecords[0].Contact.RecordTypeId)) {
            return new ResponseMessage(
                null,
                'Contact record type is not Shared Device or Care Team',
                Syntilio.ResponseMessage.MessageType.ERROR
            ).serialize();
        }

        List <Syntilio__GroupMember__c> groups = [SELECT Syntilio__GroupId__c FROM Syntilio__GroupMember__c WHERE Syntilio__ContactId__c = :contactId WITH SECURITY_ENFORCED];

        if (groups.isEmpty()) {
            return new ResponseMessage(
                null,
                'No group found for this contact',
                Syntilio.ResponseMessage.MessageType.ERROR
            ).serialize();
        }
        
        Syntilio__GroupMember__c groupMember = groups[0];

        List<Syntilio__GroupMember__c> contactsWithSameGroup = [SELECT Syntilio__ContactId__c, Syntilio__ContactId__r.Name FROM Syntilio__GroupMember__c WHERE Syntilio__GroupId__c = :groupMember.Syntilio__GroupId__c AND Syntilio__ContactId__r.RecordTypeId NOT IN :recordTypeIds WITH SECURITY_ENFORCED];
        ResponseMessage responseMsg = new ResponseMessage(
            contactsWithSameGroup,
            'success',
            Syntilio.ResponseMessage.MessageType.SUCCESS
        );

        return responseMsg.serialize();
    }
}