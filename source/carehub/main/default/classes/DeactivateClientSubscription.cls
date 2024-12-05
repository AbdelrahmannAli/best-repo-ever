@NamespaceAccessible
public with sharing class DeactivateClientSubscription {

    @invocableMethod(label='DeactivateClientApex' callout='true')
    public static List<String> DeactivateClient(List<InputVariables> inputParams){
        try{
            List<String> output = new List<String>();
            String endAllOrdersOutputString = Syntilio.SubscriptionHandler.endAllOrders(inputParams[0].recordId, inputParams[0].endDate);
            Map<String,Object> endAllOrdersOutputMap = (Map<String,Object>) JSON.deserializeUntyped(endAllOrdersOutputString);
            String outputStr = '';
            if(endAllOrdersOutputMap.get('isSuccess') == false){
                outputStr = (String) endAllOrdersOutputMap.get('error');
            }
            output.add(outputStr);
            return output;
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return null;
        } 
    }

    @NamespaceAccessible
    public with sharing class InputVariables {
        @invocableVariable
        public String recordId;
        @invocableVariable
        public Date endDate;
    } 
}