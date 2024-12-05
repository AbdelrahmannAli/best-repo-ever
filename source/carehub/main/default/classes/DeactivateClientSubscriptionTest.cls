@isTest
public with sharing class DeactivateClientSubscriptionTest {
    
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
        return [SELECT Id FROM Product2];
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
        
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
			new Map<String, Object>{
				'AccountId' => newAccount.Id
			}
        );
        
        Contract newContract = Syntilio.CareHubTestDataFactory.createContract(
            new Map<String, Object>{
                'ContractTerm' => 300,
                'AccountId' => newAccount.Id
            }
        );
        List<SObject> toInsert = new List<SObject>();
        toInsert.add(contact);
        toInsert.add(newContract);
        insert toInsert;
        
        newContract.Status = 'Activated';
        update newContract;
        
        
        List<Product2> products = new List<Product2>{
            Syntilio.CareHubTestDataFactory.createProduct2(
                new Map<String, Object>{
                    'Name' => 'Product Without Video',
                	'Syntilio__AddOns__c' => 'Audio;Telephone',
                	'Family' => 'Subscriptions'
                }
            ),
            Syntilio.CareHubTestDataFactory.createProduct2(
                new Map<String, Object>{
                    'Name' => 'Product With Video',
                	'Syntilio__AddOns__c' => 'Audio;Telephone;Video',
                	'Family' => 'Subscriptions'
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
        
    @isTest
    static void deactivateClientTest_Success() {        
        createSubscriptionData();
        
        Id accountId = getAccount().Id;
        Id contractId = getContract().Id;
        Id contactId = getContact().Id;
        List<Product2> products = getProducts();
        Id subscriptionId = products[0].Id;
        Id subscriptionId2 = products[1].Id;
        
        Date dateInstance = Date.today();
        Date nextMonthDate = dateInstance.addMonths(1);
        Date effectiveDate = nextMonthDate.toStartOfMonth();

        PricebookEntry standardPriceBookEntry = getPricebookEntry(subscriptionId, Test.getStandardPricebookId());          
        
        Order insertedOrder = Syntilio.CareHubTestDataFactory.createOrder(
            new Map<String, Object>{
                'AccountId' => accountId,
                'ContractId' => contractId,
                'BillToContactId' => contactId   
            }
        );
        insert insertedOrder;
        
        OrderItem orderItem = Syntilio.CareHubTestDataFactory.createOrderItem(
            new Map<String, Object>{
                'Product2Id' => subscriptionId,
                'OrderId' => insertedOrder.Id,
                'PricebookEntryId' => standardPriceBookEntry.Id,
                'ListPrice' => standardPriceBookEntry.UnitPrice,
                'UnitPrice' => standardPriceBookEntry.UnitPrice
            }
		);
		insert orderItem;
        
        DeactivateClientSubscription.InputVariables inputVariable = new DeactivateClientSubscription.InputVariables();
        inputVariable.recordId = contactId; 
        inputVariable.endDate = null; 
        
        List<DeactivateClientSubscription.InputVariables> inputParams = new List<DeactivateClientSubscription.InputVariables>();
        inputParams.add(inputVariable);        
        
        Test.startTest();
        List<String> result = Syntilio.DeactivateClientSubscription.DeactivateClient(inputParams);
        Test.stopTest();
        
        
        System.assertEquals(1, result.size());
        System.assertEquals('', result[0]);
        
    }

    @isTest
    public static void deactivateClientTest_Exception() {
        Syntilio.DeactivateClientSubscription.InputVariables inputVariable = new Syntilio.DeactivateClientSubscription.InputVariables();
        inputVariable.recordId = 'unknownId';
        inputVariable.endDate = null; 
        List<DeactivateClientSubscription.InputVariables> inputParams = new List<DeactivateClientSubscription.InputVariables>();
        inputParams.add(inputVariable);
        Test.startTest();
        List<String> result = Syntilio.DeactivateClientSubscription.DeactivateClient(inputParams);
        Test.stopTest();
        
        System.assertEquals(null, result);
    } 
    
}