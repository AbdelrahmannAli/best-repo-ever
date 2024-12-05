@NamespaceAccessible
public with sharing class SubscriptionHandler {
    // Create a trigger to make sure a drafted order cannot be deleted if linked to pending order
    @TestVisible private static Boolean raiseException = false;
    private static String jobName = 'SubscriptionHandler';
    public Enum OrderStatus { Draft, Activated, Cancelled, Ended }
    
    @NamespaceAccessible
    public static boolean isVideoCallingAllowed(Id clientId) {
            List<OrderItem> orderItems = [
                SELECT Id, Product2.Syntilio__AddOns__c 
                FROM OrderItem 
                WHERE Order.BillToContactId = :clientId
                    AND Order.Status = :Syntilio.SubscriptionHandler.OrderStatus.Activated.name()
                    AND Product2Id IN (
                        SELECT Id 
                        FROM Product2 
                        WHERE Syntilio__AddOns__c INCLUDES ('Video')
                    )
                    WITH SECURITY_ENFORCED
            ];
            return orderItems.size() > 0;
    }

    // This scheduler executes every day to check for Draft orders and create a reminder for them
    // depending on the ActivationReminder value in days.
    // It also updates the status for all the orders that have EndDate > TODAY to 'ENDED'
    @AuraEnabled
    public static void schedulerExecute() {
        try {
            Date today = Date.today();
            // Get all draft Orders with start date >= today
            List<Order> draftedOrders = [
                SELECT Id, EffectiveDate, Syntilio__ActivationReminder__c
                FROM Order
                WHERE EffectiveDate >= :today
                AND Syntilio__ActivationReminder__c != null
                AND Status = :Syntilio.SubscriptionHandler.OrderStatus.Draft.name()
                WITH SECURITY_ENFORCED
            ];
            List<Task> reminderTasks = new List<Task>();
            for(Order draftOrder: draftedOrders){
                // If the Order start date is (Activation Reminder) days from today, create a Task
                Date reminderDay = today.addDays(Integer.valueOf(draftOrder.Syntilio__ActivationReminder__c));
                if(draftOrder.EffectiveDate == reminderDay){
                    Task newTask = Syntilio.DataHubUtilities.createTask(
                        'order', 
                        draftOrder.Id, 
                        'Activation Reminder', 
                        'This order is starting on ' + draftOrder.EffectiveDate + ' and needs to be activated!', 
                        'High'
                    );
                    reminderTasks.add(newTask);
                }
            }
            List<Database.SaveResult> insertedTasks =  Syntilio.UpsertToDatabase.insertAction(reminderTasks, false);
            
            // Get all orders with End Date <= today and have not yet been updated to Ended
            List<Order> endedOrders = [
                SELECT Id, Status 
                FROM Order 
                WHERE EndDate <= :today
                AND Status != :Syntilio.SubscriptionHandler.OrderStatus.Ended.name()
                WITH SECURITY_ENFORCED
            ];
            for(Order endedOrder: endedOrders){
                endedOrder.Status = Syntilio.SubscriptionHandler.OrderStatus.Ended.name();
            }
            List<Database.SaveResult> updatedOrders =  Syntilio.UpsertToDatabase.updateAction(endedOrders, false);

            // Get all Order Items with End Date <= today and have not yet been updated to Ended
            List<OrderItem> endedOrderItems = [
                SELECT Id, EndDate, OrderId
                FROM OrderItem 
                WHERE EndDate <= :today
                AND Order.Status != :Syntilio.SubscriptionHandler.OrderStatus.Ended.name()
                WITH SECURITY_ENFORCED
            ];
            List<Order> ordersToUpdate = new List<Order>();
            // For each order item, get its order and check if all related order items are ended
            for(OrderItem endedOrderItem: endedOrderItems){
                List<Order> ordersFound = [
                    SELECT Id, Status
                    FROM Order
                    WHERE Id = :endedOrderItem.OrderId
                    WITH SECURITY_ENFORCED
                ];
                if(ordersFound.size() > 0){
                    Order orderToUpdate = ordersFound[0];
                    // If all related order items are ended, update order status to Ended
                    if(checkIfAllOrderItemsEnded(orderToUpdate.Id)){
                        orderToUpdate.Status = Syntilio.SubscriptionHandler.OrderStatus.Ended.name();
                        ordersToUpdate.add(orderToUpdate);
                    }
                }
            }
            List<Database.SaveResult> updatedOrders2 =  Syntilio.UpsertToDatabase.updateAction(ordersToUpdate, false);
        } catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        } 
    }
    @NamespaceAccessible
    public static Boolean checkIfAllOrderItemsEnded(Id orderId){
        Date today = Date.today();
        List<OrderItem> orderItems = [
            SELECT Id, EndDate
            FROM OrderItem
            WHERE OrderId = :orderId
            AND (EndDate = null OR EndDate > :today)
            WITH SECURITY_ENFORCED
        ];
        return orderItems.size() == 0;
    }
    
    @AuraEnabled
    public static Contact getClient(Id clientId) {
            List<Contact> client = [
                SELECT Id, AccountId, Name, LastName, FirstName, Email
                FROM Contact
                WHERE Id = :clientId
                WITH SECURITY_ENFORCED
            ];
            
            if(client.size() > 0) return client[0];
            return null;
    }
    @NamespaceAccessible
    public static Contract getAccountContract(Id accountId) {
            List<Contract> contracts = [
                SELECT Id
                FROM Contract 
                WHERE Contract.AccountId = :accountId
                WITH SECURITY_ENFORCED
            ];

            return contracts.size() == 0 ? null : contracts[0];
        
    }
    @NamespaceAccessible
    public static String getOrderProduct(Id orderId) {
        List<OrderItem> orderProducts = [
                SELECT Id, Product2.Syntilio__AddOns__c
                FROM OrderItem
                WHERE OrderId = :orderId      
                WITH SECURITY_ENFORCED
        ];
        
        return orderProducts.size() == 0 ? null : orderProducts[0].Product2.Syntilio__AddOns__c;
    }

    @AuraEnabled
    public static Order getClientOrder(Id clientId, String status) {
        try{
            // Each client has only one active order 
            // This function returns an active order if any
            // There should be a validation trigger to make sure that each client has only one active order
            List<Order> clientOrder = [
                SELECT Id, Name, Status, AccountId, BillToContactId, ContractId, EndDate, EffectiveDate 
                FROM Order
                WHERE BillToContactId = :clientId AND Status = :status
                WITH SECURITY_ENFORCED
            ];
            
            if(clientOrder.size() > 0) {
                return clientOrder[0];
            }
            
            if(clientOrder.size() > 1) {
                // raise an issue (log exception), a client should only have 1 order
                // create a trigger to validate this before insert
            }
            
            return null;
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return null;
        } 
    }
    
    @AuraEnabled
    public static List<Order> getOrders(String status) {
        try{  
            date todayDate = date.today();
            
            List<Order> draftedOrders = [
                SELECT Id, AccountId, BillToContactId, EffectiveDate, Status, EndDate
                FROM Order
                WHERE Status = :status
                WITH SECURITY_ENFORCED
            ];
            
            return draftedOrders;
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return null;
        } 
    }
    @NamespaceAccessible
    public static void finalizeChangeRequests(OrderItem orderProduct, Order order) {
        try{
            Date lastDayOfMonth = Syntilio.SubscriptionHandler.getLastDayOfMonth();
            if(order != null) {
                if(order.Status == Syntilio.SubscriptionHandler.OrderStatus.Draft.name()){
                    order.Status = Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name();
                } else {
                    order.EndDate = lastDayOfMonth;
                    order.Status = Syntilio.SubscriptionHandler.OrderStatus.Ended.name();
                }
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(order);
            Syntilio.UpsertToDatabase.updateAction(sObjectList,false);
            }
            if(orderProduct != null) {
                if(order != null && order.Status != Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name()){
                    orderProduct.EndDate = lastDayOfMonth;
                    List<SObject> sObjectList = new List<SObject>();
                    sObjectList.add(orderProduct);
                    Syntilio.UpsertToDatabase.updateAction(sObjectList,false);                }
            }
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        } 
    }
    @NamespaceAccessible
    public static Date getLastDayOfMonth() {
            Date todayDate = date.today(); 
            Integer year = todayDate.year(); 
            Integer month = todayDate.month(); 
            
            Date lastDayOfMonth = date.newInstance(year, month, Date.daysInMonth(year, month));
            return lastDayOfMonth;
    }
    
    @NamespaceAccessible
    public static OrderItem getOrderItem(Order order) {
        try{
            Id orderId = order.Id;
            Date todayDate = Date.today() ; 
            
            List<OrderItem> orderitem = [
                SELECT Id, OrderId, Product2Id, ServiceDate, EndDate
                FROM OrderItem
                WHERE OrderId = :orderId
                WITH SECURITY_ENFORCED
            ];
            
            if(orderitem.size() > 0) {
                return orderitem[0];
            }
            return null;
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return null;
        } 
    }

    // Gets all the pricebooks
    @AuraEnabled
    public static String getPricebooks() {
        Syntilio.ResponseMessage result;
        try{
            if(Test.isRunningTest() && Syntilio.SubscriptionHandler.raiseException == true) {
                throw new  DmlException();
            }
            List<Pricebook2> pricebooks = [SELECT Id, Name FROM Pricebook2 WITH SECURITY_ENFORCED LIMIT 1000 ];

            result = new Syntilio.ResponseMessage(true, pricebooks, '');
            return result.serialize();
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
            return result.serialize();
        } 
    }

    // Gets all the Active Subscription products that are related to a Pricebook
    @AuraEnabled
    public static String getProducts(String pricebookId) {
        Syntilio.ResponseMessage result;
        try{
            if(Test.isRunningTest() && Syntilio.SubscriptionHandler.raiseException == true) {
                throw new  DmlException();
            }
            List<Product2> products = [
                SELECT Id, Name, Family, ProductCode, (SELECT Id, UnitPrice FROM PricebookEntries WHERE IsActive = true LIMIT 1)
                FROM Product2
                WHERE IsActive = true
                AND Syntilio__IsSubscription__c = true
                AND Id IN (SELECT Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pricebookId)
                WITH SECURITY_ENFORCED
            ];

            result = new Syntilio.ResponseMessage(true, products, '');
            return result.serialize();
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
            return result.serialize();
        } 
    }

    // by sewefy
    @AuraEnabled
    public static String getClientOrders(String contactId) {
        Syntilio.ResponseMessage result;
        try{
            List<String> statusList = new List<String>();
            statusList.add(Syntilio.SubscriptionHandler.OrderStatus.Draft.name());
            statusList.add(Syntilio.SubscriptionHandler.OrderStatus.Activated.name());
            List<Order> orders = [
                SELECT Id, Status, OrderNumber, Pricebook2Id, EndDate, EffectiveDate, BillToContactId, Syntilio__ActivationReminder__c,
                (SELECT Id, Product2Id, ServiceDate, EndDate, Quantity FROM OrderItems)
                FROM Order
                WHERE Status IN :statusList
                WITH SECURITY_ENFORCED
            ];

            result = new Syntilio.ResponseMessage(true, orders, '');
            return result.serialize();
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
            return result.serialize();
        } 
    }

    // Creates an Order record and Order Items record with its Id
    @AuraEnabled
    public static String createOrder(Order order, List<OrderItem> orderItems){
        Syntilio.ResponseMessage result = null;
        SObjectException error = new SObjectException();
        Savepoint sp = Database.setSavepoint();
        try {
            Contact contactFound = getClient(order.BillToContactId);
            if(contactFound == null) {
                error.setMessage('Contact not found');
                throw error;
            }
            order.AccountId = contactFound.AccountId;
            order.Status = Syntilio.SubscriptionHandler.OrderStatus.Draft.name();
            Contract contract = getAccountContract(contactFound.AccountId);
            if(contract == null) {
                result = new Syntilio.ResponseMessage(false, null, 'Client account has no valid contracts, create a contract for the account and try again');
                return result.serialize(); 
            }
            order.ContractId = contract.Id;
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(order);
            Syntilio.UpsertToDatabase.insertAction(sObjectList,false);
            for(OrderItem orderItem: orderItems){
                orderItem.OrderId = order.Id;
            }
            
            List<Database.SaveResult> saveResults = Syntilio.UpsertToDatabase.insertAction(orderItems, true);
            for(Database.SaveResult saveResult: saveResults){
                if(!saveResult.isSuccess()){
                    List<String> saveResultSplit = saveResult.getErrors()[0].getMessage().split(',');
                    error.setMessage(saveResultSplit[saveResultSplit.size() -1]);
                    throw error;
                }
            }
            result = new Syntilio.ResponseMessage(true, null, 'Success');
        } catch (Exception e) {
            Database.rollback(sp);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
        } 
        return result.serialize();
    }

    // Updates the order items on an order, deletes order items that do not exist in the input list,
    // and creates the order items that exist in the input list but not in the database
    @AuraEnabled
    public static String updateOrder(Order order, List<OrderItem> orderItems){
        Syntilio.ResponseMessage result = null;
        SObjectException error = new SObjectException();
        try {
            Contact contactFound = getClient(order.BillToContactId);
            if(contactFound == null) {
                error.setMessage('Contact not found');
                throw error;
            }
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(order);
            Syntilio.UpsertToDatabase.updateAction(sObjectList,false);
            if(orderItems != null){
                List<OrderItem> oldOrderItems = [
                    SELECT Id, OrderId, Product2Id 
                    FROM OrderItem 
                    WHERE OrderId = :order.Id WITH SECURITY_ENFORCED];
                List<Id> newOrderItemIds = new List<Id>();
                for(OrderItem orderItem: orderItems){
                    newOrderItemIds.add(orderItem.Product2Id);
                }
                List<OrderItem> toBeDeleted = new List<OrderItem>();
                for(OrderItem orderItem: oldOrderItems){
                    if(!newOrderItemIds.contains(orderItem.Product2Id)){
                        toBeDeleted.add(orderItem);
                    }
                }
                if(toBeDeleted.size() > 0){
                    Syntilio.UpsertToDatabase.deleteAction(toBeDeleted,false);
                    }
                for(OrderItem orderItem: orderItems){
                    if(orderItem.Id == null){
                        orderItem.OrderId = order.Id;
                    }
                }
                List<Database.UpsertResult> upsertResults = Syntilio.UpsertToDatabase.upsertAction(orderItems, false);
                for(Database.UpsertResult upsertResult: upsertResults){
                    if(!upsertResult.isSuccess()){
                        List<String> upsertResultSplit = upsertResult.getErrors()[0].getMessage().split(',');
                        error.setMessage(upsertResultSplit[upsertResultSplit.size() -1]);
                        throw error;
                    }
                }
            }
            result = new Syntilio.ResponseMessage(true, null, 'Success');
        } catch (Exception e) {
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
        } 
        return result.serialize();
    }

    @AuraEnabled
    public static String updateOrderStatus(Id orderId, String status, Date endDate){
        Syntilio.ResponseMessage result = null;
        SObjectException error = new SObjectException();
        Savepoint sp = Database.setSavepoint();
        try {
            Date today = Date.today();
            if(endDate == null){
                endDate = today;
            }
            List<Order> ordersFound = [
                SELECT Id, EffectiveDate, Status
                FROM Order
                WHERE Id = :orderId
                WITH SECURITY_ENFORCED
            ];
            if(ordersFound.size() == 0){
                error.setMessage('Order not found');
                throw error;
            } 
            Order order = ordersFound[0];
            if(status == Syntilio.SubscriptionHandler.OrderStatus.Ended.name()){
                // If start date is greater than the passed end date, set the start date to be = the end date
                if(order.EffectiveDate > endDate){
                    order.EffectiveDate = endDate;
                }
                order.EndDate = endDate;
            }else if(status == Syntilio.SubscriptionHandler.OrderStatus.Activated.name()){
                // Update the start date and activated date to be today's date
                order.EffectiveDate = today;
                order.ActivatedDate = today;
            }
            // We need to update the status right away for all statuses except for the "Ended" status,
            // if the endDate is not = to today, we don't need to set the status to ended because it will
            // be ended on the input endDate
            if( (status == Syntilio.SubscriptionHandler.OrderStatus.Ended.name() && endDate == today) || status != Syntilio.SubscriptionHandler.OrderStatus.Ended.name()) {
                order.Status = status;
            }
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(order);
            Syntilio.UpsertToDatabase.updateAction(sObjectList,false);
            result = new Syntilio.ResponseMessage(true, null, 'Success');
        } catch (Exception e) {
            Database.rollback(sp);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
        } 
        return result.serialize();
    }

    // Update the order item's end date to the input end date
    @AuraEnabled
    public static String endOrderItem(Id orderItemId, Date endDate){
        Syntilio.ResponseMessage result = null;
        SObjectException error = new SObjectException();
        Savepoint sp = Database.setSavepoint();
        try {
            Date today = Date.today();
            if(endDate == null){
                endDate = today;
            }
            List<OrderItem> orderItemsFound = [
                SELECT Id, ServiceDate, EndDate, OrderId 
                FROM OrderItem
                WHERE Id = :orderItemId
                WITH SECURITY_ENFORCED
            ];
            if(orderItemsFound.size() == 0){
                error.setMessage('Order not found');
                throw error;
            } 
            OrderItem orderItem = orderItemsFound[0];
            if(orderItem.ServiceDate > endDate){
                orderItem.ServiceDate = endDate;
            }
            orderItem.EndDate = endDate;
            // just update the orderItem with the date and the scheduler will check if all order items
            // on the same order ended then it will update the order to Ended 
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(OrderItem);
            Syntilio.UpsertToDatabase.updateAction(sObjectList,false);   
            result = new Syntilio.ResponseMessage(true, null, 'Success');
        } catch (Exception e) {
            Database.rollback(sp);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
        } 
        return result.serialize();
    }

    @AuraEnabled
    public static String endAllOrders(Id contactId, Date endDate){
        Syntilio.ResponseMessage result = null;
        SObjectException error = new SObjectException();
        Savepoint sp = Database.setSavepoint();
        try {
            Date today = Date.today();
            if(endDate == null){
                endDate = today;
            }
            List<String> statusList = new List<String>();
            statusList.add(Syntilio.SubscriptionHandler.OrderStatus.Activated.name());
            statusList.add(Syntilio.SubscriptionHandler.OrderStatus.Draft.name());
            // Get all activated or draft orders
            List<Order> contactOrders = [
                SELECT Id, EffectiveDate, EndDate, Status, ActivatedDate
                FROM Order
                WHERE BillToContactId = :contactId
                AND Status IN :statusList
                WITH SECURITY_ENFORCED
            ];
            List<Order> ordersToUpdate = new List<Order>();
            for(Order oneOrder: contactOrders){
                String updateStatus = '';
                if(oneOrder.Status == Syntilio.SubscriptionHandler.OrderStatus.Draft.name()){
                    // Draft -> Cancelled
                    oneOrder.Status = Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name();
                    ordersToUpdate.add(oneOrder);
                }else if(oneOrder.EndDate == null || endDate == today || oneOrder.EndDate > endDate){
                    if(oneOrder.EffectiveDate > endDate){
                        oneOrder.EffectiveDate = endDate;
                    }
                    oneOrder.EndDate = endDate;
                    if(endDate == today){
                        oneOrder.Status = Syntilio.SubscriptionHandler.OrderStatus.Ended.name();
                    }
                    ordersToUpdate.add(oneOrder);
                }
            }
            List<Database.SaveResult> updatedOrders =  Syntilio.UpsertToDatabase.updateAction(ordersToUpdate, true);
            result = new Syntilio.ResponseMessage(true, null, 'Success');
        } catch (Exception e) {
            Database.rollback(sp);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
        } 
        return result.serialize();
    }

    @AuraEnabled
    public static String getSubscriptionTypes() {
        Syntilio.ResponseMessage result;
        try{
            String objectName = 'Product2';
            String fieldName = 'Family';
            
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();
            
            List<String> subscriptionTypesList = new List<String>();
      
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
                
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                subscriptionTypesList.add(picklistEntry.getValue());
            }
            
            result = new Syntilio.ResponseMessage(true, subscriptionTypesList, '');
            return result.serialize();
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
            return result.serialize();
        } 
    }

    @AuraEnabled
    public static String getSubscriptions(String subscriptionType) {
        Syntilio.ResponseMessage result;
        try{
            String query = 'SELECT Id, Name, Family ' +
            'FROM Product2 '; 
        
            query += 'WHERE ';
            if(!subscriptionType.equals('all')) {
                query += ' Family = :subscriptionType AND ';
            }
            query += ' Syntilio__IsSubscription__c = true';
            query += ' WITH SECURITY_ENFORCED';
        
            List<Product2> subscriptions = Database.query(query);

            result = new Syntilio.ResponseMessage(true, subscriptions, '');
            return result.serialize();
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            result = new Syntilio.ResponseMessage(false, null, e.getMessage());
            return result.serialize();
        } 
    }

    // Checks if any order items are conflicting with the input order item in terms of Dates
    @NamespaceAccessible
    public static String orderItemHasConflicts(OrderItem orderItem){
        List<Order> ordersFound = [SELECT Id, BillToContactId FROM Order WHERE Id = :orderItem.OrderId WITH SECURITY_ENFORCED ];
        if(ordersFound.size() == 0){
            return 'Order not found!';
        }
        Order relatedOrder = ordersFound[0]; 
        List<String> statusList = new List<String>();
        statusList.add(Syntilio.SubscriptionHandler.OrderStatus.Ended.name());
        statusList.add(Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name());
        // Get all Order Items with the same Product2 Id and status not Ended nor Cancelled
        List<OrderItem> orderItemsFound = [
            SELECT Id, Product2Id, Product2.Name, ServiceDate, EndDate 
            FROM OrderItem 
            WHERE Product2Id = :orderItem.Product2Id
            AND OrderId != :orderItem.OrderId
            AND Order.BillToContactId = :relatedOrder.BillToContactId
            AND Order.Status NOT IN :statusList
            WITH SECURITY_ENFORCED
        ];
        for(OrderItem oldOrderItem: orderItemsFound){
            Boolean conflicting = areConflicting(oldOrderItem, orderItem);
            if(conflicting){
                return 'The dates chosen for ' + oldOrderItem.Product2.Name 
                    + ' are conflicting with another ' + oldOrderItem.Product2.Name + ' subscription!';
            }
        }
        return null;
    }
    @NamespaceAccessible
    public static Boolean areConflicting(OrderItem oldOrderItem, OrderItem newOrderItem){
        Boolean conflicting = firstOrderItemConflictsWithSecond(oldOrderItem, newOrderItem) 
                                || firstOrderItemConflictsWithSecond(newOrderItem, oldOrderItem);
        return conflicting;
    }
    @NamespaceAccessible
    public static Boolean firstOrderItemConflictsWithSecond(OrderItem firstOrderItem, OrderItem secondOrderItem){
        if(firstOrderItem.EndDate == null) {
            if(secondOrderItem.ServiceDate >= firstOrderItem.ServiceDate) {
                return true;
            }
        } else {
            if(secondOrderItem.ServiceDate >= firstOrderItem.ServiceDate && secondOrderItem.ServiceDate <= firstOrderItem.EndDate) {
                return true;
            }
        }
        return false;
    }
    @NamespaceAccessible
    public static Date getFirstCancellationDate(Id clientId) {
        try{
            if(Test.isRunningTest() && Syntilio.SubscriptionHandler.raiseException == true) {
                throw new DmlException();
            }
            List<Order> orders = [
                SELECT Id, EndDate
                FROM Order
                WHERE (Order.Status =: Syntilio.SubscriptionHandler.OrderStatus.Ended.name() OR 
                        Order.Status =: Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name()) 
                        AND BillToContactId = :clientId
                WITH SECURITY_ENFORCED
                ORDER BY Order.EndDate ASC
                LIMIT 1
            ];
            if(orders.size() == 0){
                return null;
            }
            if(orders[0].EndDate == null){
                return Date.today();
            }
            Date returnDate = orders[0].EndDate;
            returnDate = returnDate;
            return returnDate;
        }catch (Exception e) {
            Syntilio.HandleException.LogException(e);
            return null;
        } 
    }

    @AuraEnabled
    public static Date clientInactiveDate(Id clientId) {
        Order clientActiveOrder = Syntilio.SubscriptionHandler.getClientOrder(clientId, Syntilio.SubscriptionHandler.OrderStatus.Activated.name());
        Order clientPendingOrder = Syntilio.SubscriptionHandler.getClientOrder(clientId, Syntilio.SubscriptionHandler.OrderStatus.Draft.name());
        
        if(clientActiveOrder == null && clientPendingOrder == null){
            return getFirstCancellationDate(clientId);
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Case getCaseInfo(Id caseId) {
        List<Case> cases = [
            SELECT Id, ContactId 
            FROM Case 
            WHERE Case.Id = :caseId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if(cases.size() == 0){
            return null;
        }
        return cases[0];
    }

}
