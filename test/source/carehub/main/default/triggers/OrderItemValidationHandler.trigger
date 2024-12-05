trigger OrderItemValidationHandler on OrderItem (before insert, before update) {
    for (OrderItem orderItem : Trigger.new) {
        String conflicts = Syntilio.SubscriptionHandler.orderItemHasConflicts(orderItem);
        if(conflicts != null) {
            orderItem.addError(conflicts);
        }
    }
}