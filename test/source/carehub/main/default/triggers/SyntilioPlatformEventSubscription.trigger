trigger SyntilioPlatformEventSubscription on Syntilio__SyntilioPlatformEvent__e (after insert) {
    
    for (Syntilio__SyntilioPlatformEvent__e syntilioPlatformEvent : Trigger.New){
        
        Map<String, Object> flowInputs = new Map<String, Object>();
        
        flowInputs.put('parentAssetId',  syntilioPlatformEvent.Syntilio__SubAssetId__c != null ? syntilioPlatformEvent.Syntilio__AssetId__c : null);
        flowInputs.put('assetId', syntilioPlatformEvent.Syntilio__SubAssetId__c != null ? syntilioPlatformEvent.Syntilio__SubAssetId__c : syntilioPlatformEvent.Syntilio__AssetId__c );
        flowInputs.put('assetDescription', syntilioPlatformEvent.Syntilio__AssetDescription__c);
        flowInputs.put('eventCode', syntilioPlatformEvent.Syntilio__EventCode__c);
        flowInputs.put('supplierEventCode', syntilioPlatformEvent.Syntilio__SupplierEventCode__c);
        flowInputs.put('assetIndex', syntilioPlatformEvent.Syntilio__SubAssetIndex__c);
        flowInputs.put('product', syntilioPlatformEvent.Syntilio__Product__c);
        flowInputs.put('userId', syntilioPlatformEvent.Syntilio__UserId__c);
        flowInputs.put('eventId', syntilioPlatformEvent.Syntilio__EventId__c);
        flowInputs.put('timeStamp', syntilioPlatformEvent.Syntilio__TimeStamp__c);
        flowInputs.put('phone', syntilioPlatformEvent.Syntilio__Phone__c);
        
        try {
            Flow.Interview.Event_Handler runSyntilioEventHandlerFlow = new Flow.Interview.Event_Handler(flowInputs);
            runSyntilioEventHandlerFlow.Start();
        } catch(Exception e){
        }
        
    }
    
}