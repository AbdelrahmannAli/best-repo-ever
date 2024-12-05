@NamespaceAccessible
public with sharing class CaseStatusTriggerHandler {
    @NamespaceAccessible
    public static void handleTrigger(Map<Id, Case> oldMap , Map<Id, Case> newMap){
        Syntilio__CareHubAppConfiguration__mdt careHubAppConfiguration = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        Boolean caseClosureByNonOwnersAllowed = careHubAppConfiguration.Syntilio__CaseClosureByNonCaseOwners__c;
        Boolean caseClosureWithEventAllowed = careHubAppConfiguration.Syntilio__CaseClosureWithEvents__c;

        List<Syntilio__Notification__e> eventsToPublish = new List<Syntilio__Notification__e>();

        for (Id caseId : newMap.keySet()) {
            Case newCase = newMap.get(caseId);
            Case oldCase = oldMap.get(caseId);

            if (newCase.Status == 'Closed' && oldCase.Status != 'Closed') {
                if (caseClosureByNonOwnersAllowed && oldCase.OwnerId != UserInfo.getUserId()) {
                    eventsToPublish.add(new Syntilio__Notification__e(
                        Syntilio__CaseId__c = newCase.Id,
                        Syntilio__Message__c = 'The case was closed by a non-owner.',
                        Syntilio__Status__c = oldCase.Status,
                        Syntilio__Target__c = newCase.Status,
                        Syntilio__TargetUserId__c = UserInfo.getUserId()
                    ));
                }

                if (caseClosureWithEventAllowed && String.isBlank(newCase.Syntilio__Event__c)) {
                    eventsToPublish.add(new Syntilio__Notification__e(
                        Syntilio__CaseId__c = newCase.Id,
                        Syntilio__Message__c = 'The case has no event.',
                        Syntilio__Status__c = oldCase.Status,
                        Syntilio__Target__c = newCase.Status,
                        Syntilio__TargetUserId__c = UserInfo.getUserId()
                    ));
                }
            }
        }

        if (!eventsToPublish.isEmpty()) {
            EventBus.publish(eventsToPublish);
        }
    }
}