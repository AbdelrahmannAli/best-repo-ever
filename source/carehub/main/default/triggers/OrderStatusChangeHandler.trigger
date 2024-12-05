trigger OrderStatusChangeHandler on Order (before update) {
    List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
    List<OrderItem> orderItems = [
        SELECT Id, ServiceDate, EndDate, OrderId 
        FROM OrderItem 
        WHERE OrderId IN :Trigger.newMap.keySet()
    ];
    for (Order order : Trigger.new) {
        Date today = Date.today();
        Date endDate = order.EndDate;
        String status = order.Status;
        Order oldOrder = Trigger.oldMap.get(order.Id);
        Boolean endDateChanged = oldOrder.EndDate != endDate;
        Boolean statusChanged = oldOrder.Status != status;

        for(OrderItem one: orderItems){
            if(one.OrderId != order.Id){
                continue;
            }
            Boolean updated = false;
            if(statusChanged && status == Syntilio.SubscriptionHandler.OrderStatus.Activated.name()){
                if(one.ServiceDate < today){
                    one.ServiceDate = today;
                }
                updated = true;
            }
            if(endDateChanged){
                if(endDate == today || one.ServiceDate > endDate){
                    one.ServiceDate = endDate;
                }
                if(one.EndDate == null || endDate == today || one.EndDate > endDate){
                    one.EndDate = endDate;
                }
                updated = true;
            }
            if(updated){
                orderItemsToUpdate.add(one);
            }
        }
    }
    Syntilio.UpsertToDatabase.updateAction(orderItemsToUpdate, true);
}