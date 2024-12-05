trigger OrderItemUpdateRemainingMinutes on Syntilio__CallLog__c (after insert) {
      
      for (Syntilio__CallLog__c callLog : Trigger.new) {
          Try{
              String duration = callLog.Syntilio__Duration__c;
              Integer hours = Integer.valueOf(duration.substring(0, duration.indexOf(':')));
              Integer minutes = Integer.valueOf(duration.substring(duration.indexOf(':') + 1, duration.indexOf(':') + 3));
              Double seconds = Integer.valueOf(duration.substring(duration.indexOf(':') + 4, duration.indexOf(':') + 6));
              Double totalMinutes = hours * 60 + minutes + (seconds / 60);
              List<Contact> contact = [SELECT Id FROM Contact WHERE Id IN (SELECT ContactId FROM Case WHERE Id = :callLog.Syntilio__CaseId__c)];
              if (contact.size() == 0) {
                  return;
              }
              
              List<OrderItem> orderItems = [SELECT RemainingMinutes__c, Product2.Syntilio__Minutes__c FROM OrderItem WHERE OrderId IN (SELECT Id FROM Order WHERE BillToContactId = :contact[0].Id AND Status = 'Activated') LIMIT 1];
              for (OrderItem orderItem : orderItems) {
                  if (orderItem.RemainingMinutes__c == null) {
                      // As initially remaining minutes should be equal to total minutes
                      orderItem.RemainingMinutes__c = orderItem.Product2.Syntilio__Minutes__c - totalMinutes < 0 ? 0 : orderItem.Product2.Syntilio__Minutes__c - totalMinutes;
                  } else {
                      // here remaining minutes already exist so we need to subtract the total minutes from remaining minutes
                      orderItem.RemainingMinutes__c = orderItem.RemainingMinutes__c - totalMinutes < 0 ? 0 : orderItem.RemainingMinutes__c - totalMinutes;
                  }
              }

              OrderRemainingTimeHandler.notifyLWC();
              update orderItems;        
          }catch(Exception e){
              Syntilio.HandleException.logException(e);
          }
      }
  }