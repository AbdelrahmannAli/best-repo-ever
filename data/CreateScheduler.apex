String cronExp = '0 0 * * ?';
System.schedule('SubscriptionHandler', cronExp, new Syntilio.SubscriptionScheduler());   