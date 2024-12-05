@NamespaceAccessible
public with sharing class SubscriptionUtilisationController {
    @AuraEnabled
    public static List<Map<String, Object>> listClientsSubscriptionsUtilisation(Id accountId){
        List<Map<String, Object>> clientsSubscriptionsUtilisation = new List<Map<String, Object>>();
        Map<Id, List<OrderItem>> contactsOrderItemsMap = Syntilio.SubscriptionUtilisationController.getContactsOrderItemsMap(accountId, null);
        Map<Id, Contact> contactsMap = Syntilio.SubscriptionUtilisationController.getAccountContacts(accountId);
        for(Id contactId : contactsOrderItemsMap.keySet()){
            Map<String, Object> clientSubscriptionsUtilisation = new Map<String, Object>();
            clientSubscriptionsUtilisation.put('contact', contactsMap.get(contactId));
            clientSubscriptionsUtilisation.put('orderItems', contactsOrderItemsMap.get(contactId));
            clientsSubscriptionsUtilisation.add(clientSubscriptionsUtilisation);
        }
        return clientsSubscriptionsUtilisation;
    }

    @AuraEnabled
    public static Map<Id, List<OrderItem>> getContactsOrderItemsMap(Id accountId, Id contactId){
        String query = 'SELECT Id, Product2.Syntilio__Minutes__c, Product2.Name, Product2.LastModifiedBy.Name, Order.OrderNumber, Order.ActivatedDate, Order.Status, ServiceDate, EndDate, Order.BillToContactId, LastModifiedDate FROM OrderItem WHERE OrderId IN (SELECT Id FROM Order WHERE';
        
        if(accountId != null && contactId != null){
            query += ' BillToContactId = :contactId AND AccountId = :accountId';
        } else if(accountId != null){
            query += ' AccountId = :accountId';
        } else if(contactId != null){
            query += ' BillToContactId = :contactId';
        }

        query += ')';
        query += ' WITH SECURITY_ENFORCED';

        List<OrderItem> orderItems = Database.query(query);
        Map<Id, List<OrderItem>> contactsOrderItemsMap = new Map<Id, List<OrderItem>>();
        for(OrderItem orderItem : orderItems){
            if(contactsOrderItemsMap.containsKey(orderItem.Order.BillToContactId)){
                contactsOrderItemsMap.get(orderItem.Order.BillToContactId).add(orderItem);
            }else{
                contactsOrderItemsMap.put(orderItem.Order.BillToContactId, new List<OrderItem>{orderItem});
            }
        }
        return contactsOrderItemsMap;
    }

    public static String getLastModifiedByAlias(Id lastModifiedById){
        String alias = '';
        if(lastModifiedById != null){
            alias = [SELECT Alias FROM User WHERE Id = :lastModifiedById].Alias;
        }
        return alias;
    }


    public static Map<Id, Contact> getAccountContacts(Id accountId){
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();
        for(Contact contact : [SELECT Id, Name FROM Contact WHERE AccountId = :accountId WITH SECURITY_ENFORCED ]){
            contactsMap.put(contact.Id, contact);
        }
        return contactsMap;
    }

    @AuraEnabled
    public static String checkRecordType(Id recordId) {
        String recordType = '';
        String query = 'SELECT RecordType.Name FROM Contact WHERE Id = :recordId';
        List<Contact> contactList = Database.query(query);
        if(contactList.size() > 0){
            recordType = 'Contact';
        }else{
            query = 'SELECT RecordType.Name FROM Account WHERE Id = :recordId';
            List<Account> accountList = Database.query(query);
            if(accountList.size() > 0){
                recordType = 'Account';
            }
        }
        return recordType;
    }
}