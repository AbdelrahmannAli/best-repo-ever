@isTest
public with sharing class MockPatientObservationsCalloutResponse implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        
        Account accountRecord = [SELECT Id, Name FROM Account];
        CodeSet codeSetRecord = [SELECT Id FROM CodeSet];
        UnitOfMeasure unitOfMeasureRecord = [SELECT Id FROM UnitOfMeasure];
        
        String calloutAPIEndpointMock = Syntilio.CheckEnvironmentType.checkCustomMetadata('syntilioapi');
        
        System.assertEquals(calloutAPIEndpointMock + '/fhir/observation?userId=1&obsevartionsFromDate=' + String.valueOf(Date.today().addDays(-3)) + '&obsevartionsTillDate=' + String.valueOf(Date.today()) +'&supplierName=AppSupplier&observationCodeSet=bp', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[ { "name":"Fhir Observation d86821b1-a5e5-491f-b002-651e99a37c54", "attributes":{ "type":"CareObservation", "referenceId":"Refab9f7421-3ef6-4017-bfa6-74e5455a1267" }, "basedOnId":null, "partOfId":null, "observationStatus":"Final", "codeId":"' + codeSetRecord +'", "additionalCode1Id":null, "additionalCode2Id":null, "observedSubjectId":"' + accountRecord +'", "encounterId":null, "effectiveDateTime":null, "endDateTime":null, "issuedDateTime":null, "observerId":null, "observedValueType":"Quantity", "observedValueNumerator":null, "observedValueDenominator":null, "observedValueUnitId":"' + unitOfMeasureRecord +'", "numericValue":95.0, "observedValueText":"", "isOutcomePositive":false, "observationStartTime":null, "observationEndTime":null, "valueInterpretation":null, "bodySiteId":null, "methodId":null, "deviceId":null, "lowerBaselineValue":null, "baselineUnitId":null, "upperBaselineValue":null, "baselineValueText":null, "relatedObservationId":null, "derivationSourceId":null, "isMonitoredRemotely":true }]');
        response.setStatusCode(200);
        return response;
    }
}