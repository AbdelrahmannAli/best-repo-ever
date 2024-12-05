global class PatientObservationsCallout {
    
    @future(callout=true)
    global static void getPatientObservations(String caseId){
        List<CareObservation> careObservationRecordsDeserializedFromResponse;
        
        try{
            PatientObservationsService patientObservationsService = new PatientObservationsService();
            ObservationRequestModel observationRequestModelRecord = patientObservationsService.getPatientDetails(caseId);
            HttpResponse response = SyntilioHttpClient.getInstance().get('/fhir/observation?userId=' + observationRequestModelRecord.userId + '&obsevartionsFromDate=' + observationRequestModelRecord.obsevartionsFromDate +  '&obsevartionsTillDate=' + observationRequestModelRecord.obsevartionsTillDate + '&supplierName=' + observationRequestModelRecord.supplierName+ '&observationCodeSet=' + observationRequestModelRecord.observationCodeSet, '', null);//needs to be changed with the datahub api        
            
            if (response.getStatusCode() == 200) { 
                careObservationRecordsDeserializedFromResponse = (List<CareObservation>)JSON.deserialize(response.getBody(), List<CareObservation>.class);
            }
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        if(careObservationRecordsDeserializedFromResponse != null)
            UpsertToDatabase.insertAction(careObservationRecordsDeserializedFromResponse, false);
    }
}