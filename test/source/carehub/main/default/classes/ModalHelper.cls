public with sharing class ModalHelper {
    @AuraEnabled
    public static void publishRefreshEvent(Id caseId, String message) {
        Syntilio__Notification__e refreshEvent = new Syntilio__Notification__e(
            Syntilio__CaseId__c = caseId,
            Syntilio__Message__c = message
        );
        EventBus.publish(refreshEvent);
    }
}