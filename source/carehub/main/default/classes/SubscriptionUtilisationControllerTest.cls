@isTest
public with sharing class SubscriptionUtilisationControllerTest {
    
    private static Account getAccount() {
        return [SELECT Id FROM Account LIMIT 1];
    }
    
    private static Contact getContact() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    private static List<Contact> getContacts() {
        return [SELECT Id FROM Contact];
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
        
        OrderItem draftOrderItem2 = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId2,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(draftOrderItem);
        orderItems.add(draftOrderItem2);
		
        String result = Syntilio.SubscriptionHandler.createOrder(draftOrder, orderItems);
        return draftOrder;
    }

    @testSetup
    public static void setupTestData() {
        createSubscriptionData(); 
    }

    @isTest
    static void getAccountContactsTest() {

        Id accountId = getAccount().Id;
        List<Contact> contactList = getContacts();
        
        Test.startTest();
        Map<Id, Contact> contactsMap =  Syntilio.SubscriptionUtilisationController.getAccountContacts(accountId);
        Test.stopTest();
        
        System.assertEquals(2, contactsMap.size());
        System.assert(contactsMap.get(contactList[0].Id) != null);
    }

    @isTest
    static void getLastModifiedByAliasTest() {
        User anyUser = [SELECT Id, Alias FROM User LIMIT 1];

        Test.startTest();
        String userAlias =  Syntilio.SubscriptionUtilisationController.getLastModifiedByAlias(anyUser.Id);
        Test.stopTest();
        
        System.assertEquals(anyUser.Alias, userAlias);
    }

    @isTest
    static void listClientsSubscriptionsUtilisationTest() {

        Id accountId = getAccount().Id;
        
        Order draftOrder = createOrderWithOrderItems();
        
        Test.startTest();
        List<Map<String, Object>> subscriptionsList =  Syntilio.SubscriptionUtilisationController.listClientsSubscriptionsUtilisation(accountId);
        Test.stopTest();
        
        System.assert(subscriptionsList.size() > 0);
    }

    @isTest
    static void checkRecordTypeTest_Contact() {

        Id contactId = getContact().Id;
        
        Test.startTest();
        String recordType = Syntilio.SubscriptionUtilisationController.checkRecordType(contactId);
        Test.stopTest();
        
        System.assertEquals('Contact', recordType);
    }

    @isTest
    static void checkRecordTypeTest_Account() {
        Id accountId = getAccount().Id;
        
        Test.startTest();
        String recordType = Syntilio.SubscriptionUtilisationController.checkRecordType(accountId);
        Test.stopTest();
        
        System.assertEquals('Account', recordType);
    }
    
    @isTest
    static void getContactsOrderItemsMapTest_AccountId() {
        
        Id accountId = getAccount().Id;
        Id contactId = getContact().Id;
        
        Order draftOrder = createOrderWithOrderItems();
        
        Test.startTest();
        Map<Id, List<OrderItem>> contactsOrderItemsMap = Syntilio.SubscriptionUtilisationController.getContactsOrderItemsMap(accountId, null);
        Test.stopTest();

        System.assert(contactsOrderItemsMap.containsKey(contactId));
        System.assert(contactsOrderItemsMap.get(contactId).size() > 0);
    }
    
    @isTest
    static void getContactsOrderItemsMapTest_ContactId() {
        
        Id contactId = getContact().Id;
        
        Order draftOrder = createOrderWithOrderItems();
        
        Test.startTest();
        Map<Id, List<OrderItem>> contactsOrderItemsMap = Syntilio.SubscriptionUtilisationController.getContactsOrderItemsMap(null, contactId);
        Test.stopTest();

        System.assert(contactsOrderItemsMap.containsKey(contactId));
        System.assert(contactsOrderItemsMap.get(contactId).size() > 0);
    }
    
    @isTest
    static void getContactsOrderItemsMapTest_AccountIdAndContactId() {
        
        Id accountId = getAccount().Id;
        Id contactId = getContact().Id;
        
        Order draftOrder = createOrderWithOrderItems();
        
        Test.startTest();
        Map<Id, List<OrderItem>> contactsOrderItemsMap = Syntilio.SubscriptionUtilisationController.getContactsOrderItemsMap(accountId, contactId);
        Test.stopTest();

        System.assert(contactsOrderItemsMap.containsKey(contactId));
        System.assert(contactsOrderItemsMap.get(contactId).size() > 0);
    }
}