public with sharing class OrderRemainingTimeHandler {
    @AuraEnabled
    public static String getRemainingTime(String caseId){
        Try{
            List<Contact> contact = [SELECT Id FROM Contact WHERE Id IN (SELECT ContactId FROM Case WHERE Id = :caseId)];

            if (contact.size() == 0){
                return new Syntilio.ResponseMessage(
                    0,
                    'No contact found for this case',
                    Syntilio.ResponseMessage.MessageType.WARNING
                ).serialize();
            }
            List<OrderItem> orderItems = [SELECT RemainingMinutes__c, Product2.Syntilio__Minutes__c FROM OrderItem WHERE OrderId IN (SELECT Id FROM Order WHERE BillToContactId = :contact[0].Id AND Status = 'Activated')];
            if (orderItems.size() == 0){
                return new Syntilio.ResponseMessage(
                    0,
                    'No minutes available',
                    Syntilio.ResponseMessage.MessageType.WARNING
                ).serialize();
            }
            OrderItem orderItem = orderItems[0];
            Map<String, Object> result = new Map<String, Object>();
            result.put('remainingMinutes', orderItem.RemainingMinutes__c);
            result.put('productMinutes', orderItem.Product2.Syntilio__Minutes__c);
            
            
            Syntilio.ResponseMessage response = new Syntilio.ResponseMessage(
                result,
                '',
                Syntilio.ResponseMessage.MessageType.SUCCESS
            );

            return response.serialize();
        }catch(Exception e){
        	Syntilio.HandleException.logException(e);
            return null;
        }
    }
    
    public static void notifyLWC() {
        Syntilio__Notification__e notification = new Syntilio__Notification__e();
        EventBus.publish(notification);
    }
}