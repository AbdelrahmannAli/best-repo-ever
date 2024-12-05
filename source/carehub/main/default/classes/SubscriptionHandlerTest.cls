@isTest
public with sharing class SubscriptionHandlerTest {
    private static Account getAccount() {
        return [SELECT Id FROM Account LIMIT 1];
    }
    
    private static Contact getContact() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    private static Contract getContract() {
        return [SELECT Id FROM Contract LIMIT 1];
    }
    
    private static List<Product2> getProducts() {
        return [SELECT Id, Syntilio__AddOns__c FROM Product2];
    }
    
    private static PricebookEntry getPricebookEntry(Id productId, Id priceBookId) {
        return [
            SELECT Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id = :productId AND Pricebook2Id = :priceBookId
            LIMIT 1
        ];
    }
    
    private static void createSubscriptionData() {
        Date contractStartDate = Date.today().addMonths(-12).toStartOfMonth();
        
        Account newAccount = Syntilio.CareHubTestDataFactory.createAccount(null);
        insert newAccount;
        
        List<Contact> contacts = new List<Contact>{
            Syntilio.CareHubTestDataFactory.createContact(
                new Map<String, Object>{
                	'LastName' => 'LastName 0',
                    'AccountId' => newAccount.Id
				}
            ),
            Syntilio.CareHubTestDataFactory.createContact(
                new Map<String, Object>{
                	'LastName' => 'LastName 1',
                    'AccountId' => newAccount.Id
				}
            )
        };
        
        Contract newContract = Syntilio.CareHubTestDataFactory.createContract(
            new Map<String, Object>{
                'StartDate' => contractStartDate,
                'ContractTerm' => 300,
                'AccountId' => newAccount.Id
            }
        );
        List<SObject> toInsert = new List<SObject>();
        toInsert.addAll(contacts);
        toInsert.add(newContract);
        insert toInsert;
        
        newContract.Status = 'Activated';
        update newContract;
        
        
        List<Product2> products = new List<Product2>{
            Syntilio.CareHubTestDataFactory.createProduct2(
                new Map<String, Object>{
                	'Name' => 'Subscription without video',
                    'Family' => 'Subscriptions',
                    'Syntilio__AddOns__c' => 'Audio;Telephone'
				}
            ),
            Syntilio.CareHubTestDataFactory.createProduct2(
                new Map<String, Object>{
                	'Name' => 'Subscription with video',
                    'Family' => 'Subscriptions',
                    'Syntilio__AddOns__c' => 'Audio;Telephone;Video'
				}
            )
        };
        insert products;
        
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        for(Product2 product :products) {
            priceBookEntries.add(Syntilio.CareHubTestDataFactory.createPriceBookEntry(
                new Map<String, Object>{
                    'Product2Id' => product.Id
                }
            ));
        }
        insert priceBookEntries;
    }
    
    private static Order createOrderWithOrderItems() {
        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
		
        Date dateInstance = Date.today();
        Date effectiveDate = dateInstance.addDays(-1);
        
        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionId, Test.getStandardPricebookId());          

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem);
		
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder, orderItems);
        return draftOrder;
    }

    @TestSetup
    static void setUp(){
        createSubscriptionData();
    }
    
    @isTest
    static void schedulerExecuteTest() {
        
        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
        Id subscriptionId2 = products[1].Id;

        Date dateInstance = Date.today();
        Date lastMonth = dateInstance.addMonths(-1).toStartOfMonth();
        
        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionId, Test.getStandardPricebookId());          

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        insert draftOrder;
		
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'OrderId' => draftOrder.Id,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice,
                'ServiceDate' => null
            }
		);
		insert draftOrderItem;
		
        Order activatedOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId(),
                'EndDate' => dateInstance
            }
        );
        insert activatedOrder;
        
        OrderItem activatedOrderItem1 = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'OrderId' => activatedOrder.Id,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice,
                'ServiceDate' => null
            }
		);
        activatedOrder.Status = Syntilio.SubscriptionHandler.OrderStatus.Activated.name();
        upsert new List<SObject>{activatedOrderItem1, activatedOrder};
        
            
        Order activatedOrder2 = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId(),
                'EndDate' => dateInstance.addDays(2)
            }
        );
        insert activatedOrder2;
        
        OrderItem activatedOrderItem2 = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'OrderId' => activatedOrder2.Id,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice,
                'ServiceDate' => dateInstance,
                'EndDate' => dateInstance
            }
		);
        activatedOrder2.Status = Syntilio.SubscriptionHandler.OrderStatus.Activated.name();
        upsert new List<SObject>{activatedOrderItem2, activatedOrder2};
        
        Test.startTest();
        Syntilio.SubscriptionHandler.schedulerExecute();
        Test.stopTest();
        
        List<Task> reminderTasks = [SELECT Id FROM Task WHERE WhatId = :draftOrder.Id ];
        Order toBeEnded = [SELECT Status FROM Order WHERE Id = :activatedOrder.Id ];
        Order toBeEnded2 = [SELECT Status FROM Order WHERE Id = :activatedOrder2.Id ];
               
        System.assert(reminderTasks.size() > 0);
        System.assertEquals(Syntilio.SubscriptionHandler.OrderStatus.Ended.name(), toBeEnded.Status);
        System.assertEquals(Syntilio.SubscriptionHandler.OrderStatus.Ended.name(), toBeEnded2.Status);
    }

    @isTest
    static void getSubscriptionTypesTest() {
		Test.startTest();
        String subscriptionTypes = Syntilio.SubscriptionHandler.getSubscriptionTypes();
        Test.stopTest();

        System.assertNotEquals(null, subscriptionTypes);
    }

    @isTest
    static void isVideoCallingAllowedTest_Allowed() {

        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionWithVideoId = products[1].Id;
		
        Date dateInstance = Date.today();
        Date effectiveDate = dateInstance.addDays(-1);
        
        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionWithVideoId, Test.getStandardPricebookId());          

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionWithVideoId,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem);
		
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder, orderItems);
        
        draftOrder.Status = Syntilio.SubscriptionHandler.OrderStatus.Activated.name();
        update draftOrder;
        
        Test.startTest();
        Boolean isVideoCallingAllowed = Syntilio.SubscriptionHandler.isVideoCallingAllowed(contactId);
        Test.stopTest();
        
		System.assertEquals(true, isVideoCallingAllowed);
    }
	
    @isTest
    static void isVideoCallingAllowedTest_NotAllowed() {

        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
		
        Date dateInstance = Date.today();
        Date effectiveDate = dateInstance.addDays(-1);
        
        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionId, Test.getStandardPricebookId());          

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem);
		
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder, orderItems);
        
        Test.startTest();
        Boolean isVideoCallingAllowed = Syntilio.SubscriptionHandler.isVideoCallingAllowed(contactId);
        Test.stopTest();

		System.assertEquals(false, isVideoCallingAllowed);
    }

    @isTest
    static void isVideoCallingAllowedTest_NoSubscription() {
		
        Id contactId = getContact().Id;
        Test.startTest();
        Boolean isVideoCallingAllowed = Syntilio.SubscriptionHandler.isVideoCallingAllowed(contactId);
        Test.stopTest();
        
		System.assertEquals(false, isVideoCallingAllowed);
    }

    @isTest
    static void getPricebooksTest() {
		
        Pricebook2 pricebook = Syntilio.CareHubTestDataFactory.createPricebook2(null);
        insert pricebook;
        
		Test.startTest();
        String pricebooksResult = Syntilio.SubscriptionHandler.getPricebooks();
        Test.stopTest();
        
        Map<String, Object> pricebooksMap = (Map<String, Object>) JSON.deserializeUntyped(pricebooksResult);
        List<Object> pricebooks = (List<Object>) pricebooksMap.get('data');

        System.assert(pricebooks.size() > 0);
    }

    @isTest
    static void getPricebooksTest_RaiseException() {
        Syntilio.SubscriptionHandler.raiseException = true;
        
        Test.startTest();
        String pricebooksResult = Syntilio.SubscriptionHandler.getPricebooks();
        Test.stopTest();
        
        Syntilio.ResponseMessage pricebookMsg =  Syntilio.ResponseMessage.deserialize(pricebooksResult);
        System.assertNotEquals(null, pricebookMsg);
        System.assertEquals(false, pricebookMsg.isSuccess);
    }
 
    @isTest
    static void getFirstCancellationDateTest_RaiseException() {
        Syntilio.SubscriptionHandler.raiseException = true;
        
        Id contactId = getContact().Id;

		Test.startTest();
        Date result = Syntilio.SubscriptionHandler.getFirstCancellationDate(contactId);
        Test.stopTest();
        
        System.assertEquals(null, result);
    }   

    @isTest
    static void getClientOrdersTest_RaiseException() {
        Syntilio.SubscriptionHandler.raiseException = true;
		
        Id contactId = getContact().Id;
        
		Test.startTest();
        String ordersResult = Syntilio.SubscriptionHandler.getClientOrders(contactId);
        Test.stopTest();
        
        Syntilio.ResponseMessage ordersResultMsg =  Syntilio.ResponseMessage.deserialize(ordersResult);
        System.assertNotEquals(null, ordersResultMsg);
        System.assertEquals(false, ordersResultMsg.isSuccess);
    }

    @isTest
    static void getProductsTest_RaiseException() {
        Syntilio.SubscriptionHandler.raiseException = true;
        
		Test.startTest();
        String result = Syntilio.SubscriptionHandler.getProducts(null);
        Test.stopTest();
        
        Syntilio.ResponseMessage resultMsg =  Syntilio.ResponseMessage.deserialize(result);
        System.assertNotEquals(null, resultMsg);
        System.assertEquals(false, resultMsg.isSuccess);
    }
  
    @isTest
    static void getClientOrdersTest() {
        
        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;

        Date dateInstance = Date.today();
        Date effectiveDate = dateInstance.addDays(-1);
        
        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionId, Test.getStandardPricebookId());

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        insert draftOrder;
        
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'OrderId' => draftOrder.Id,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
		insert draftOrderItem;
        
        Test.startTest();
        String ordersResult = Syntilio.SubscriptionHandler.getClientOrders(contactId);
        Test.stopTest();
        
        Map<String, Object> ordersMap = (Map<String, Object>) JSON.deserializeUntyped(ordersResult);
        List<Object> orders = (List<Object>) ordersMap.get('data');

        System.assertEquals(1, orders.size());
    }
   
    @isTest
    static void createOrderTest_WithOrderItems() {

        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
		
        Date dateInstance = Date.today();
        Date effectiveDate = dateInstance.addDays(-1);
        
        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionId, Test.getStandardPricebookId());          

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem);
		
        Test.startTest();
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder, orderItems);
        Test.stopTest();
        
        List<Order> ordersFound = [SELECT Id FROM Order];
        List<OrderItem> orderItemsFound = [SELECT Id FROM OrderItem];

        System.assertEquals(1, ordersFound.size());
        System.assertEquals(1, orderItemsFound.size());
    }
  
    @isTest
    static void updateOrderTest_WithOrderItems() {

        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
        Id subscriptionId2 = products[1].Id;
		
        Date dateInstance = Date.today();
        Date effectiveDate = dateInstance.addDays(-1);
        
        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionId, Test.getStandardPricebookId());          

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem);
		
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder, orderItems);
        
        draftOrder.Syntilio__ActivationReminder__c = 1;
        
        OrderItem draftOrderItem2 = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId2,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);

        orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem2);
        
        Test.startTest();
        String updateResult = Syntilio.SubscriptionHandler.updateOrder(draftOrder, orderItems);
        Test.stopTest();

        List<Order> ordersFound = [SELECT Id, Syntilio__ActivationReminder__c FROM Order];
        List<OrderItem> orderItemsFound = [SELECT Id, Quantity FROM OrderItem];
        
        System.assertEquals(1, ordersFound.size());
        System.assertEquals(1, orderItemsFound.size());
        System.assertEquals(1, ordersFound[0].Syntilio__ActivationReminder__c);
        System.assertEquals(1, orderItemsFound[0].Quantity);
    }

    @isTest
    static void updateOrderStatusTest() {
        
		Order draftOrder = createOrderWithOrderItems();
        Date dateInstance = Date.today();
        
        Test.startTest();
        
        Syntilio.SubscriptionHandler.updateOrderStatus(draftOrder.Id, Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name(), null);
        List<Order> ordersFoundAfterCancel = [SELECT Id, Status FROM Order];
        
        Syntilio.SubscriptionHandler.updateOrderStatus(draftOrder.Id, Syntilio.SubscriptionHandler.OrderStatus.Draft.name(), null);
        List<Order> ordersFoundAfterDraft = [SELECT Id, Status FROM Order];
        
        Syntilio.SubscriptionHandler.updateOrderStatus(draftOrder.Id, Syntilio.SubscriptionHandler.OrderStatus.Activated.name(), null);
        List<Order> ordersFoundAfterActivate = [SELECT Id, Status, EffectiveDate FROM Order];
        
        Syntilio.SubscriptionHandler.updateOrderStatus(draftOrder.Id, Syntilio.SubscriptionHandler.OrderStatus.Ended.name(), dateInstance.addDays(5));        
        List<Order> ordersFoundAfterEnd = [SELECT Id, Status, EndDate FROM Order];

        Test.stopTest();
        
        System.assertEquals(1, ordersFoundAfterCancel.size());
        System.assertEquals(1, ordersFoundAfterDraft.size());
        System.assertEquals(1, ordersFoundAfterActivate.size());
        System.assertEquals(1, ordersFoundAfterEnd.size());
        System.assertEquals(Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name(), ordersFoundAfterCancel[0].Status);
        System.assertEquals(Syntilio.SubscriptionHandler.OrderStatus.Draft.name(), ordersFoundAfterDraft[0].Status);
        System.assertEquals(Syntilio.SubscriptionHandler.OrderStatus.Activated.name(), ordersFoundAfterActivate[0].Status);
        System.assertEquals(dateInstance, ordersFoundAfterActivate[0].EffectiveDate);
        System.assertEquals(Syntilio.SubscriptionHandler.OrderStatus.Activated.name(), ordersFoundAfterEnd[0].Status);
        System.assertEquals(dateInstance.addDays(5), ordersFoundAfterEnd[0].EndDate);
    }

	@isTest
    static void endOrderItemTest() {
		
		Order draftOrder = createOrderWithOrderItems();
        OrderItem draftOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
        Date dateInstance = Date.today();

        Test.startTest();
        Syntilio.SubscriptionHandler.endOrderItem(draftOrderItem.Id, dateInstance);
        Test.stopTest();
        
        List<OrderItem> orderItemsFound = [SELECT Id, EndDate FROM OrderItem];

        System.assertEquals(1, orderItemsFound.size());
        System.assertEquals(dateInstance, orderItemsFound[0].EndDate);
    }
 
    @isTest
    static void endAllOrdersTest() {
        Id contactId = getContact().Id;
        
		Order draftOrder = createOrderWithOrderItems();
        Date dateInstance = Date.today();

        Order draftOrder2 = draftOrder.clone();
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder2, new List<OrderItem>());
        
        Syntilio.SubscriptionHandler.updateOrderStatus(draftOrder.Id, Syntilio.SubscriptionHandler.OrderStatus.Activated.name(), null);
        
        Test.startTest();
        Syntilio.SubscriptionHandler.endAllOrders(contactId, dateInstance);
        Test.stopTest();
        
        List<Order> ordersFound = [SELECT Id, EndDate FROM Order];
        List<OrderItem> orderItemsFound = [SELECT Id, EndDate FROM OrderItem];

        System.assertEquals(2, ordersFound.size());
        System.assertEquals(dateInstance, ordersFound[0].EndDate);
        System.assertEquals(1, orderItemsFound.size());
        System.assertEquals(dateInstance, orderItemsFound[0].EndDate);
    }
   
    @isTest
    static void getOrdersTest() {
        
		Order draftOrder = createOrderWithOrderItems();
        
        Test.startTest();
        List<Order> orders = Syntilio.SubscriptionHandler.getOrders(Syntilio.SubscriptionHandler.OrderStatus.Draft.name());
        Test.stopTest();

        System.assertEquals(1, orders.size());
    }
      
    @isTest
    static void getClientTest() {
        Id contactId = getContact().Id;

		Test.startTest();
        Contact returnedContact = SubscriptionHandler.getClient(contactId);
        Test.stopTest();

        System.assertEquals(contactId, returnedContact.Id);
    }
 
    @isTest
    static void finalizeChangeRequestsTest_Activated() {
		
		Order draftOrder = createOrderWithOrderItems();
        OrderItem draftOrderItem = [SELECT Id FROM OrderItem];
        
        draftOrder.Status = Syntilio.SubscriptionHandler.OrderStatus.Activated.name();
        update draftOrder;
        
		Test.startTest();
        Syntilio.SubscriptionHandler.finalizeChangeRequests(draftOrderItem, draftOrder);
        Test.stopTest();
        
        OrderItem finalizedOrderItem = [SELECT Id, EndDate FROM OrderItem];
        Order finalizedOrder = [SELECT Id, EndDate, Status FROM Order];
        Date lastDayOfMonth = Syntilio.SubscriptionHandler.getLastDayOfMonth();

        System.assertNotEquals(null, draftOrder.Id);
        System.assertEquals(lastDayOfMonth, finalizedOrder.EndDate);
        System.assertEquals(lastDayOfMonth, finalizedOrderItem.EndDate);
    }
    
    @isTest
	static void finalizeChangeRequestsTest() {
		
        Order draftOrder = createOrderWithOrderItems();
        OrderItem draftOrderItem = [SELECT Id FROM OrderItem];
        
        Test.startTest();
        Syntilio.SubscriptionHandler.finalizeChangeRequests(draftOrderItem, draftOrder);
        Test.stopTest();
        
        OrderItem finalizedOrderItem = [SELECT Id, EndDate FROM OrderItem];
        Order finalizedOrder = [SELECT Id, EndDate, Status FROM Order];
        Date lastDayOfMonth = Syntilio.SubscriptionHandler.getLastDayOfMonth();

        System.assertNotEquals(null, draftOrderItem.Id);
        System.assertEquals(null, finalizedOrder.EndDate);
        System.assertEquals(SubscriptionHandler.OrderStatus.Cancelled.name(), finalizedOrder.Status);
        System.assertEquals(null, finalizedOrderItem.EndDate);
    }

    @isTest
    static void getClientOrderTest() {

        Order draftOrder = createOrderWithOrderItems();
        Id accountId = getAccount().Id;
        Id contactId = getContact().Id;
        
        Test.startTest();
        Order clientOrder = Syntilio.SubscriptionHandler.getClientOrder(contactId, Syntilio.SubscriptionHandler.OrderStatus.Draft.name());
        Test.stopTest();

        System.assertNotEquals(null, clientOrder.Id);
        System.assertEquals(contactId, clientOrder.BillToContactId);
        System.assertEquals(accountId, clientOrder.AccountId);
        System.assertEquals(Syntilio.SubscriptionHandler.OrderStatus.Draft.name(), clientOrder.Status);
    }

    @isTest
    static void getOrderItemTest() {
       
        Order draftOrder = createOrderWithOrderItems();
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
        
        Test.startTest();
        OrderItem relatedOrderProduct = Syntilio.SubscriptionHandler.getOrderItem(draftOrder);
        Test.stopTest();

        System.assertEquals(subscriptionId, relatedOrderProduct.Product2Id);
        System.assertEquals(draftOrder.Id, relatedOrderProduct.OrderId);
    }

    @isTest
    static void getOrderItemTestNull() {
        
        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;

        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        insert draftOrder;
        
		Test.startTest();
        OrderItem relatedOrderProduct = Syntilio.SubscriptionHandler.getOrderItem(draftOrder);
        Test.stopTest();

        System.assertEquals(null, relatedOrderProduct);
    }
        
    @isTest
    static void getSubscriptionsTest() {
		Test.startTest();
        String output = Syntilio.SubscriptionHandler.getSubscriptions('Subscriptions');
        Test.stopTest();
        
        Syntilio.ResponseMessage outputMsg = Syntilio.ResponseMessage.deserialize(output);
        List<Object> subscriptions = (List<Object>) outputMsg.data;
        
        System.assertEquals(2, subscriptions.size());
    }

    @isTest
    static void getLastDayOfMonthTest() {
        Integer year = Date.today().addMonths(1).year(); 
        Integer month = Date.today().addMonths(1).month(); 
        Integer day = 1;
        Date lastDayOfMonthDate = date.newInstance(year, month, day);
        
		Test.startTest();
        Date testLastDayOfMonth = Syntilio.SubscriptionHandler.getLastDayOfMonth().addDays(1);
        Test.stopTest();

        System.assertEquals(lastDayOfMonthDate, testLastDayOfMonth);
    }

    @isTest
    public static void clientInactiveDateTest_Today() {
        Id contactId = getContact().Id;
        Order draftOrder = createOrderWithOrderItems();

        draftOrder.Status = Syntilio.SubscriptionHandler.OrderStatus.Cancelled.name();
        update draftOrder;

		Test.startTest();
        Date firstCancellationDate = SubscriptionHandler.clientInactiveDate(contactId);
        Test.stopTest();
        
        System.assertEquals(Date.today(), firstCancellationDate);
    }
   
    @isTest
    public static void clientInactiveDateTest_Null() {
        Id contactId = getContact().Id;
        Order draftOrder = createOrderWithOrderItems();
        
		Test.startTest();
        Date firstCancellationDate = SubscriptionHandler.clientInactiveDate(contactId);
        Test.stopTest();

        System.assertEquals(null, firstCancellationDate);
    }
  
    @isTest
    public static void getCaseInfoTest() {

        Id contactId = getContact().Id;
		
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'ContactId' => contactId
            }
        );
		insert newCase;
        
		Test.startTest();
        Case out = Syntilio.SubscriptionHandler.getCaseInfo(newCase.Id);
        Test.stopTest();
        
        System.assertEquals(newCase.ContactId, out.ContactId);
    }
      
    @isTest
    public static void logExceptionTest() {
		Test.startTest();
        String result = Syntilio.SubscriptionHandler.createOrder(new Order(), new List<OrderItem>());  
        Test.stopTest();
        
        Syntilio.ResponseMessage responseMessage = Syntilio.ResponseMessage.deserialize(result);
        
        System.assertEquals(false, responseMessage.isSuccess);
        System.assertEquals('Contact not found', responseMessage.message);
    }

    @isTest
    public static void createOrderTest_AccountWithoutContract() {
        
        Account newAccount = Syntilio.CareHubTestDataFactory.createAccount(
            new Map<String, Object>{
                'Name' => 'test account'
            }
        );
        insert newAccount;
        Contact newContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'LastName' => 'contact last name',
                'AccountId' => newAccount.Id
            }
        );
        insert newContact;
        
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
        
        Date dateInstance = Date.today();
        
        Order draftOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => newAccount.Id,
                'BillToContactId' => newContact.Id,
                'Pricebook2Id' => Test.getStandardPricebookId()
            }
        );
        
        OrderItem draftOrderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId
            }
		);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem);
        
        Test.startTest();
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder, orderItems);
        Test.stopTest();

		ResponseMessage responseMessage = ResponseMessage.deserialize(result);
        System.assertEquals(false, responseMessage.isSuccess);
        System.assertEquals('Client account has no valid contracts, create a contract for the account and try again', responseMessage.message);
    }

    @isTest
    public static void getOrderProductTest() {
        Order draftOrder = createOrderWithOrderItems();
        String expectedAddOns = getProducts()[0].Syntilio__AddOns__c;
        
		Test.startTest();
        String actualAddOns = Syntilio.SubscriptionHandler.getOrderProduct(draftOrder.Id);
        Test.stopTest();
        
        System.assertEquals(expectedAddOns, actualAddOns);
    }
  
	@isTest
    public static void getProductsTest() {

		Pricebook2 pricebook = Syntilio.CareHubTestDataFactory.createPricebook2(
            new Map<String, Object> {
                'Name' => 'Test Pricebook2'
            }
        );
        insert pricebook;
        
		Test.startTest();
        String result = Syntilio.SubscriptionHandler.getProducts(pricebook.Id);
        Test.stopTest();
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        List<Object> products = (List<Object>) resultMap.get('data');
        System.assertEquals(0, products.size());
    }
}