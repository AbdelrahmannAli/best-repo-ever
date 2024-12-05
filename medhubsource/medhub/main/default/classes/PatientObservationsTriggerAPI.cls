@RestResource(urlMapping='/observation') //"/services/apexrest/Syntilio/Observation"
global with sharing class PatientObservationsTriggerAPI {
    
    @HttpPost
    global static void doPostObservations() {
        List <CareObservation> patientCareObservationRecordsDeserialized = new List <CareObservation> ();
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;
        
        if(RestRequest.requestBody == null){
            restResponse.addHeader('Content-Type', 'application/json');        
            restResponse.statusCode = 400;
            restResponse.responseBody = blob.valueOf('{ "success" : false, "message" : "Missing required body that includes patient care observations"}');
            return;
        }
        
        try {
            String requestBody = restRequest.requestBody.toString();
            patientCareObservationRecordsDeserialized = (List<CareObservation>)JSON.deserialize(requestBody, List<CareObservation>.class);
        } catch(Exception e){
            restResponse.addHeader('Content-Type', 'application/json');        
            restResponse.statusCode = 400;
            restResponse.responseBody = blob.valueOf('{ "success" : false, "message" : "Invalid format for patient care observations"}');
            return;
        }
        
        if(patientCareObservationRecordsDeserialized != null && !patientCareObservationRecordsDeserialized.isEmpty()){
            List<Database.SaveResult> databaseSaveResultList = UpsertToDatabase.insertAction(patientCareObservationRecordsDeserialized, false);
            Map<Boolean, List<Object>> databaseResultMap = UpsertToDatabase.getDmlActionStatus(databaseSaveResultList, null);
            if (!databaseResultMap.containsKey(false)) {
                restResponse.statusCode = 200;
                restResponse.addHeader('Content-Type', 'application/json');
                restResponse.responseBody = Blob.valueOf('{ "success" : true, "message" : "Successfully inserted patient care observations"}');
            }
            else {
                restResponse.addHeader('Content-Type', 'application/text');        
                restResponse.statusCode = 500;
                restResponse.responseBody = blob.valueOf('{ "success" : false, "message" : "Internal Server Error"}');
                return;
            }
            
        }
    }
}