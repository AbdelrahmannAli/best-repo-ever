public with sharing class CreateWorkOrderRecordLWC {

    @AuraEnabled
    public static String createWorkOrderRecord(WorkOrder newRecord){
    insert newRecord;
    return newRecord.Id;
}
}
