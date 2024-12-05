global class FetchClientsBatch implements Database.Batchable<String>, Database.AllowsCallouts {
    private List<String> locationIds;
    private String destinationsModelSerialized;
    private Id contactRecordTypeId;
    private Id accountId;

    public FetchClientsBatch(List<String> locationIds, String destinationsModelSerialized, Id contactRecordTypeId,Id accountId) {
        this.locationIds = locationIds;
        this.destinationsModelSerialized = destinationsModelSerialized;
        this.contactRecordTypeId = contactRecordTypeId;
        this.accountId = accountId;
    }

    global Iterable<String> start(Database.BatchableContext bc) {
        return locationIds;
    }

    global void execute(Database.BatchableContext bc, List<String> scope) {
        String clientId = String.join(scope, ',');
        System.debug('clientId ' + clientId);
        Syntilio.FetchClientsController.fetchClientsByLocation(clientId, 'Ons', 'Twb', accountId); 
    }

    global void finish(Database.BatchableContext bc) {
    }
}
