public with sharing class WorkOrderApex {

    public ServiceAppointment appointment {get;set;} 
    public Id caseRecordId {get;set;}
    public Case currentCase {get;set;}
    public Contact caseContact {get; set;}
    public Id serviceTerritoryId {get; set;}
    
    public WorkOrderApex(Apexpages.StandardController controller) {
        caseRecordId = ApexPages.CurrentPage().getparameters().get('id');
    
        currentCase = [SELECT Id, AccountId, CaseNumber, AssetId, ContactId FROM CASE WHERE Id= :caseRecordId];
        caseContact = [SELECT Id, FirstName, LastName, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, AccountId, Email, Phone FROM Contact WHERE Id= :currentCase.ContactId];
        serviceTerritoryId = [SELECT Id FROM ServiceTerritory WHERE Name= :caseContact.MailingCity].Id;

        appointment = new ServiceAppointment();
        appointment.ServiceTerritoryId = serviceTerritoryId;
        appointment.ContactId = currentCase.ContactId;
        
    }
    
    public Pagereference dmlOperation() {
        WorkOrder newWorkOrder= new WorkOrder(CaseId=caseRecordId, Priority='Critical', contactId= currentCase.ContactId , accountId=currentCase.AccountId, assetId=currentCase.AssetId, ServiceTerritoryId=serviceTerritoryId);
        insert newWorkOrder;

        appointment.ParentRecordId = newWorkOrder.Id;

        return null;
        // return newWorkOrder.Id;
        //return null;
    }

    public Pagereference saveAppointment() {
        insert appointment;

        return null;
    }
}
