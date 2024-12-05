global class PatientObservationsCalloutExtension {
    private Id caseRecordId ;
    final ApexPages.StandardController controller;
    
    global PatientObservationsCalloutExtension(ApexPages.StandardController controller)
    {
        this.controller = controller;
    }
    global PageReference makePatientObservationsCallout()
    {
        try{
            this.caseRecordId = ApexPages.CurrentPage().getparameters().get('Id');
            if(this.caseRecordId != null)
            	PatientObservationsCallout.getPatientObservations(caseRecordId);
        }
        catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return controller.view();
    }
}