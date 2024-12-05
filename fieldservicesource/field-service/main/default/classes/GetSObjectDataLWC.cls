public with sharing class GetSObjectDataLWC {
    
    @AuraEnabled(cacheable=true)
    public static List<ServiceAppointment> getServiceAppointment(Id contactId){
        if(contactId == null) {
            return null;
        }
        List<ServiceAppointment> serviceAppointment = [select id, dueDate,AppointmentNumber, EarliestStartTime, ContactId, Address, AppointmentType, Description, Status, ParentRecordId from ServiceAppointment where ContactId= :contactId ];

        return serviceAppointment;
    }

    @AuraEnabled
    public static Contact getContactData(Id contactId){
        Contact contact = [select AccountId,Birthdate, Email, Phone, LastName,MailingCity, MailingCountry, MailingState,MailingStreet,MailingPostalCode,Title  from Contact where Id = :contactId];

        return contact;
    }

    @AuraEnabled
    public static Case getCaseInfo(Id caseId) {
        Case wantedCase = [select AssetId, AccountId from Case where Id= :caseId];
        return wantedCase;
    }

    @AuraEnabled
    public static ServiceTerritory getTerritoryId(String city) {
            ServiceTerritory serviceTerritory = [select Id from ServiceTerritory where Name= :city];
            return serviceTerritory;
    }
}
