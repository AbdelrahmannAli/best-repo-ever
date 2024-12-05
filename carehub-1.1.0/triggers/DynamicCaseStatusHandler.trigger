trigger DynamicCaseStatusHandler on Case (before update) {
    
    Syntilio__TriggerEnablerConfiguration__mdt dynamicCaseStatusTriggerEnablerConfiguration = Syntilio__TriggerEnablerConfiguration__mdt.getInstance('DynamicCaseStatusHandlerTrigger');
    if(!Test.isRunningTest() && (dynamicCaseStatusTriggerEnablerConfiguration == null || dynamicCaseStatusTriggerEnablerConfiguration.Syntilio__UseCustomTrigger__c || dynamicCaseStatusTriggerEnablerConfiguration.Syntilio__BeforeInsert__c == false)){
        return;
    }
    
    for (Case caseRecord : Trigger.new) {
        if(caseRecord.Status == 'Closed') {
            List<Map<String, Object>> protocols = Syntilio.CaseProtocolHandler.getProtocols(caseRecord.Id);
            for(Map<String, Object> protocol : protocols) {
                if(protocol.get('status') != 'finished'){
                    caseRecord.addError('There are still unfinished protocols. Please completed them before closing the case.');
                    break;
                }
            }
        }
    }
}