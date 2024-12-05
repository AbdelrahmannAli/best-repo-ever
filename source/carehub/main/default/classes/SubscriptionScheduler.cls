@NamespaceAccessible
public with sharing class SubscriptionScheduler implements Schedulable {
    @NamespaceAccessible
    public void execute(SchedulableContext SC) {
        Syntilio.SubscriptionHandler.schedulerExecute();
    }
}