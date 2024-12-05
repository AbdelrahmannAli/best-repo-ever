@namespaceAccessible
public with sharing class AuditTrailController {

    @namespaceAccessible
    public static void log(String source, String destination, String status, String endpoint, String actionMethod, String requestBody, String queryParams, String responseBody) {
        Syntilio__AuditTrail__c log = new Syntilio__AuditTrail__c();
        log.Syntilio__Source__c = source;
        log.Syntilio__Destination__c = destination;
        log.Syntilio__Status__c = status;
        log.Syntilio__Endpoint__c = endpoint;
        log.Syntilio__ActionName__c = actionMethod;
        log.Syntilio__RequestBody__c = requestBody;
        log.Syntilio__QueryParams__c = queryParams;
        log.Syntilio__ResponseBody__c = responseBody;
        log.Syntilio__Timestamp__c = Datetime.now();
        try {
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(log);
            Syntilio.UpsertToDatabase.insertAction(sObjectList,false);
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }
}