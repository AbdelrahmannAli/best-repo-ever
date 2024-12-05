global with sharing class PatientObservationsService{    
    global PatientObservationsService(){}
    
   	@testVisible global static IEventConfigurationMdt eventConfigurationMdt = new EventConfigurationMdt();
    
       global ObservationRequestModel getPatientDetails(String caseId){
        if (caseId == null || String.isEmpty(caseId))
            return null;
        
        Case caseRecord = new Case();
        Integer observationsPeriodInDays;
        try{
            caseRecord = [SELECT Id, Syntilio__CodeSet__c, Product.Syntilio__Supplier__c, Syntilio__EventCode__c FROM Case WHERE Id =: caseId];
            Syntilio__EventConfiguration__c eventConfigurationMdtRecord =  eventConfigurationMdt.getEventConfigurationMdt(caseRecord.Syntilio__EventCode__c);
            observationsPeriodInDays = Integer.valueOf(eventConfigurationMdtRecord.Syntilio__ObservationsPeriod__c);
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        
        ObservationRequestModel observationRequestModelRecord = new ObservationRequestModel();
        //observationRequestModelRecord.userId = caseRecord.; needs migration of userID
        observationRequestModelRecord.obsevartionsFromDate = String.valueOf(Date.today().addDays(-observationsPeriodInDays));
        observationRequestModelRecord.obsevartionsTillDate = String.valueOf(Date.today());
        observationRequestModelRecord.supplierName = caseRecord.Product.Syntilio__Supplier__c;
        observationRequestModelRecord.observationCodeSet = caseRecord.Syntilio__CodeSet__c;
        return observationRequestModelRecord;
    }    
}