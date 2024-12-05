trigger DataHubSyncInfoValidation on Syntilio__DataHubSyncInfo__c (before insert, before update) {
    for (Syntilio__DataHubSyncInfo__c dataHubSyncInfo : Trigger.new) {
        try {
            if(!Test.isRunningTest()){
            	Syntilio.DataHubSynchronisation.validate(dataHubSyncInfo);
	        }
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            if (dataHubSyncInfo != null) {
                dataHubSyncInfo.addError('Something went wrong');
            }
        }
    }
}