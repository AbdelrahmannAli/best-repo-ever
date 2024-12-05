@isTest
public with sharing class PatientObservationsTriggerAPITest{
    
    @isTest
    public static void PatientObservationsTriggerAPITest_ValidRequest_ShouldSuccessfullyInsertCareObservations_Test(){
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        Long datetimeAfterForObservationsOfTestData;
        
        restRequest.requestURI = '/services/apexrest/Syntilio/observation';
        restRequest.httpMethod = 'POST';
        
        RestContext.request = restRequest;
        RestContext.response= restResponse;
        
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);

            
            Account accountRecord = [SELECT Id, Name FROM Account];
            CodeSet codeSetRecord = [SELECT Id FROM CodeSet];
            UnitOfMeasure unitOfMeasureRecord = [SELECT Id FROM UnitOfMeasure];
            
            datetimeAfterForObservationsOfTestData = MedHubTestDataFactory.waitXNumberOfSeconds(1000);
            
            restRequest.requestBody = blob.valueOf('[ { "name":"Fhir Observation d86821b1-a5e5-491f-b002-651e99a37c54", "attributes":{ "type":"CareObservation", "referenceId":"Refab9f7421-3ef6-4017-bfa6-74e5455a1267" }, "observationStatus":"Final", "codeId":"' + codeSetRecord.Id +'","additionalCode1Id":null, "additionalCode2Id":null, "observedSubjectId":"' + accountRecord.Id +'", "effectiveDateTime":null, "observedValueType":"Quantity", "observedValueUnitId":"' + unitOfMeasureRecord.Id +'", "numericValue":95.0, "isOutcomePositive":false, "isMonitoredRemotely":true }]');
            PatientObservationsTriggerAPI.doPostObservations();
            
            Test.stopTest(); 
            
        }catch(Exception e){
        }
       	
        List<CareObservation> patientCareObservationRecordsInserted = [SELECT Id, Name, CreatedDate FROM CareObservation WHERE CreatedDate >=: DateTime.valueOf(datetimeAfterForObservationsOfTestData)]; 

        System.assertEquals(200, restResponse.statusCode);
        System.assertEquals(1, patientCareObservationRecordsInserted.size());
    }
    
    @isTest
    public static void PatientObservationsTriggerAPITest_InValidRequest_ShouldReturn_MissingRequestBody_Test(){
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        Long datetimeAfterForObservationsOfTestData;
        
        restRequest.requestURI = '/services/apexrest/Syntilio/observation';
        restRequest.httpMethod = 'POST';
        
        RestContext.request = restRequest;
        RestContext.response= restResponse;
        
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);

            
            Account accountRecord = [SELECT Id, Name FROM Account];
            CodeSet codeSetRecord = [SELECT Id FROM CodeSet];
            UnitOfMeasure unitOfMeasureRecord = [SELECT Id FROM UnitOfMeasure];
            
            datetimeAfterForObservationsOfTestData = MedHubTestDataFactory.waitXNumberOfSeconds(1000);
            
            PatientObservationsTriggerAPI.doPostObservations();
            
            Test.stopTest(); 
            
        }catch(Exception e){
        }
                
        List<CareObservation> patientCareObservationRecordsInserted = [SELECT Id, Name, CreatedDate FROM CareObservation WHERE CreatedDate >=: DateTime.valueOf(datetimeAfterForObservationsOfTestData)]; 
        String restResponseString = restResponse.responseBody.toString();
        
        System.assertEquals(400, restResponse.statusCode);
        System.assertEquals('{ "success" : false, "message" : "Missing required body that includes patient care observations"}', restResponseString);
        System.assertEquals(0, patientCareObservationRecordsInserted.size());
    }
    
    @isTest
    public static void PatientObservationsTriggerAPITest_InValidRequest_ShouldReturn_InvalidFormatOfObservations_Test(){
        RestRequest restRequest = new RestRequest();
        RestResponse restResponse = new RestResponse();
        Long datetimeAfterForObservationsOfTestData;
        
        restRequest.requestURI = '/services/apexrest/Syntilio/observation';
        restRequest.httpMethod = 'POST';
        
        RestContext.request = restRequest;
        RestContext.response= restResponse;
        
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);
            
            datetimeAfterForObservationsOfTestData = MedHubTestDataFactory.waitXNumberOfSeconds(1000);
            
            restRequest.requestBody = blob.valueOf('{ "resourceType":"Observation", "id":"example", "status":"final", "category":[ { "coding":[ { "system":"http://terminology.hl7.org/CodeSystem/observation-category", "code":"vital-signs", "display":"Vital Signs" } ] } ], "code":{ "coding":[ { "system":"http://loinc.org", "code":"29463-7", "display":"Body Weight" }, { "system":"http://loinc.org", "code":"3141-9", "display":"Body weight Measured" }, { "system":"http://snomed.info/sct", "code":"27113001", "display":"Body weight" }, { "system":"http://acme.org/devices/clinical-codes", "code":"body-weight", "display":"Body Weight" } ] }, "subject":{ "reference":"Patient/example" }, "encounter":{ "reference":"Encounter/example" }, "effectiveDateTime":"2016-03-28", "valueQuantity":{ "value":185, "unit":"lbs", "system":"http://unitsofmeasure.org", "code":"[lb_av]" } }');
            PatientObservationsTriggerAPI.doPostObservations();
            
            Test.stopTest(); 
            
        }catch(Exception e){
        }
                
        List<CareObservation> patientCareObservationRecordsInserted = [SELECT Id, Name, CreatedDate FROM CareObservation WHERE CreatedDate >=: DateTime.valueOf(datetimeAfterForObservationsOfTestData)]; 
        String restResponseString = restResponse.responseBody.toString();
        
        System.assertEquals(400, restResponse.statusCode);
        System.assertEquals('{ "success" : false, "message" : "Invalid format for patient care observations"}', restResponseString);
        System.assertEquals(0, patientCareObservationRecordsInserted.size());
    }
    
    @isTest
    public static void PatientObservationsTriggerAPITest_ShouldLogException_Test(){
        RestRequest restRequest = new RestRequest(); 
        RestResponse restResponse = new RestResponse();
        Long datetimeAfterForObservationsOfTestData;
        
        restRequest.requestURI = '/services/apexrest/Syntilio/observation';
        restRequest.httpMethod = 'POST';
        
        RestContext.request = restRequest;
        RestContext.response= restResponse;
        
        try{
            Test.startTest();
            
            List<Contact> contactRecordsList = MedHubTestDataFactory.createContactRecords(1);
            MedHubTestDataFactory.createCareObservationsRelatedRecords(contactRecordsList[0].AccountId);

            
            Account accountRecord = [SELECT Id, Name FROM Account];
            CodeSet codeSetRecord = [SELECT Id FROM CodeSet];
            UnitOfMeasure unitOfMeasureRecord = [SELECT Id FROM UnitOfMeasure];
            
            datetimeAfterForObservationsOfTestData = MedHubTestDataFactory.waitXNumberOfSeconds(1000);
            
            restRequest.requestBody = blob.valueOf('[ { "name":"Fhir Observation d86821b1-a5e5-491f-b002-651e99a37c54", "attributes":{ "type":"CareObservation", "referenceId":"Refab9f7421-3ef6-4017-bfa6-74e5455a1267" }, "observationStatus":"Final", "codeId":"' + accountRecord.Id +'","additionalCode1Id":null, "additionalCode2Id":null, "observedSubjectId":"' + accountRecord.Id +'", "effectiveDateTime":null, "observedValueType":"Quantity", "observedValueUnitId":"' + accountRecord.Id +'", "numericValue":95.0, "isOutcomePositive":false, "isMonitoredRemotely":true }]');
            PatientObservationsTriggerAPI.doPostObservations();
            
            Test.stopTest(); 
            
        }catch(Exception e){
        }
       	
        List<CareObservation> patientCareObservationRecordsInserted = [SELECT Id, Name, CreatedDate FROM CareObservation WHERE CreatedDate >=: DateTime.valueOf(datetimeAfterForObservationsOfTestData)]; 
        
        System.assertEquals(500, restResponse.statusCode);
        System.assertEquals(0, patientCareObservationRecordsInserted.size());
    }
}