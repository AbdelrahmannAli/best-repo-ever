List<Opportunity> oldOpportunityRecords = new List<Opportunity>([SELECT Id FROM Opportunity]);
delete oldOpportunityRecords;

List<Entitlement> oldEntitlementRecords = new List<Entitlement>([SELECT Id FROM Entitlement]);
delete oldEntitlementRecords;


List<Task> oldTaskRecords = new List<Task>([SELECT Id FROM Task]);
delete oldTaskRecords;


List<Case> oldCaseRecords = new List<Case>([SELECT Id FROM Case]);
delete oldCaseRecords;


List<Product2> oldProductRecords = new List<Product2>([SELECT Id FROM Product2]);
delete oldProductRecords;


List<Asset> oldAssetRecords = new List<Asset>([SELECT Id FROM Asset]);
delete oldAssetRecords;


List<Contact> oldContactRecords = new List<Contact>([SELECT Id FROM Contact]);
delete oldContactRecords;


List<AccountContactRelation> oldAccountContactRelationRecords = new List<AccountContactRelation>([SELECT Id FROM AccountContactRelation]);
delete oldAccountContactRelationRecords;


List<Account> oldAccountRecords = new List<Account>([SELECT Id FROM Account]);
delete oldAccountRecords;


List<Syntilio__Exception__c> oldExceptionRecords = new List<Syntilio__Exception__c>([SELECT Id FROM Syntilio__Exception__c]);
delete oldExceptionRecords;

List<Syntilio__DataHubSyncInfo__c> oldDataHubSyncInfoRecords = new List<Syntilio__DataHubSyncInfo__c>([SELECT Id FROM Syntilio__DataHubSyncInfo__c]);
delete oldDataHubSyncInfoRecords;