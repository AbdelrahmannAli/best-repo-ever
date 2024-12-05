List<Opportunity> oldOpportunityRecords = new List<Opportunity>([SELECT Id FROM Opportunity]);
delete oldOpportunityRecords;

List<Entitlement> oldEntitlementRecords = new List<Entitlement>([SELECT Id FROM Entitlement]);
delete oldEntitlementRecords;


List<TimeSlot> oldTimeSlotRecords = new List<TimeSlot>([SELECT Id FROM TimeSlot]);
delete oldTimeSlotRecords;

List<ServiceTerritory> oldServiceTerritoryRecords = new List<ServiceTerritory>([SELECT Id FROM ServiceTerritory]);
delete oldServiceTerritoryRecords;

List<Syntilio__CareOperatingHours__c> oldOperatingHoursRecords = new List<Syntilio__CareOperatingHours__c>([SELECT Id FROM Syntilio__CareOperatingHours__c]);
delete oldOperatingHoursRecords;


List<Syntilio__CareOrganizationContractRelation__c> oldCareOrganizationContractRelationRecords = new List<Syntilio__CareOrganizationContractRelation__c>([SELECT Id FROM Syntilio__CareOrganizationContractRelation__c]);
delete oldCareOrganizationContractRelationRecords;


List<Task> oldTaskRecords = new List<Task>([SELECT Id FROM Task]);
delete oldTaskRecords;


List<Case> oldCaseRecords = new List<Case>([SELECT Id FROM Case]);
delete oldCaseRecords;

List<OrderItem> oldOrderItem = new List<OrderItem>([SELECT Id FROM OrderItem]);
delete oldOrderItem;

List<Order> oldOrder = new List<Order>([SELECT Id FROM Order]);
delete oldOrder;


List<Pricebook2> oldPricebook2 = new List<Pricebook2>([SELECT Id FROM Pricebook2 WHERE IsStandard = false]);
delete oldPricebook2;


List<Product2> oldProductRecords = new List<Product2>([SELECT Id FROM Product2]);
delete oldProductRecords;


List<Asset> oldAssetRecords = new List<Asset>([SELECT Id FROM Asset]);
delete oldAssetRecords;

List<Syntilio__ContactToLocation__c> oldontactToLocation = new List<Syntilio__ContactToLocation__c>([SELECT Id FROM Syntilio__ContactToLocation__c]);
delete oldontactToLocation;


List<Syntilio__ContactContactRelationship__c> oldContactContactRelationshipRecords = new List<Syntilio__ContactContactRelationship__c>([SELECT Id FROM Syntilio__ContactContactRelationship__c]);
delete oldContactContactRelationshipRecords;

List<Contact> oldContactRecords = new List<Contact>([SELECT Id FROM Contact]);
delete oldContactRecords;

List<AccountContactRelation> oldAccountContactRelationRecords = new List<AccountContactRelation>([SELECT Id FROM AccountContactRelation]);
delete oldAccountContactRelationRecords;

List<Syntilio__AccountExternalSystemAssociation__c> oldAccountExternalSystemAssociation = new List<Syntilio__AccountExternalSystemAssociation__c>([SELECT Id FROM Syntilio__AccountExternalSystemAssociation__c]);
delete oldAccountExternalSystemAssociation;

List<Syntilio__ExternalSystem__c> oldAccountExternalSystem = new List<Syntilio__ExternalSystem__c>([SELECT Id FROM Syntilio__ExternalSystem__c]);
delete oldAccountExternalSystem;

List<Syntilio__ExternalId__c> oldAccountExternalId = new List<Syntilio__ExternalId__c>([SELECT Id FROM Syntilio__ExternalId__c]);
delete oldAccountExternalId;

List<Account> oldAccountRecords = new List<Account>([SELECT Id FROM Account]);
delete oldAccountRecords;


List<Syntilio__Exception__c> oldExceptionRecords = new List<Syntilio__Exception__c>([SELECT Id FROM Syntilio__Exception__c]);
delete oldExceptionRecords;

List<Syntilio__SyntilioEvent__c> oldSyntilioEventRecords = new List<Syntilio__SyntilioEvent__c>([SELECT Id FROM Syntilio__SyntilioEvent__c]);
delete oldSyntilioEventRecords;

List<Syntilio__DataHubSyncInfo__c> oldDataHubSyncInfoRecords = new List<Syntilio__DataHubSyncInfo__c>([SELECT Id FROM Syntilio__DataHubSyncInfo__c]);
delete oldDataHubSyncInfoRecords;

List<Syntilio__ServiceZipCode__c> oldServiceZipCodeRecords = new List<Syntilio__ServiceZipCode__c>([SELECT Id FROM Syntilio__ServiceZipCode__c]);
delete oldServiceZipCodeRecords;

List<Syntilio__QuestionnaireQuestion__c> oldQuestionnaireQuestionRecords = new List<Syntilio__QuestionnaireQuestion__c>([SELECT Id FROM Syntilio__QuestionnaireQuestion__c]);
delete oldQuestionnaireQuestionRecords;


List<Syntilio__Question__c> oldQuestionRecords = new List<Syntilio__Question__c>([SELECT Id FROM Syntilio__Question__c]);
delete oldQuestionRecords;


List<Syntilio__Questionnaire__c> oldQuestionnaireRecords = new List<Syntilio__Questionnaire__c>([SELECT Id FROM Syntilio__Questionnaire__c]);
delete oldQuestionnaireRecords;

List<Syntilio__ProtocolActionResultComponent__c> oldProtocolActionResultComponent = new List<Syntilio__ProtocolActionResultComponent__c>([SELECT Id FROM Syntilio__ProtocolActionResultComponent__c]);
delete oldProtocolActionResultComponent;

List<Syntilio__ProtocolActionResult__c> oldProtocolActionResult = new List<Syntilio__ProtocolActionResult__c>([SELECT Id FROM Syntilio__ProtocolActionResult__c]);
delete oldProtocolActionResult;

List<Syntilio__ProtocolActionRelation__c> oldProtocolActionRelation = new List<Syntilio__ProtocolActionRelation__c>([SELECT Id FROM Syntilio__ProtocolActionRelation__c]);
delete oldProtocolActionRelation;

List<Syntilio__ProtocolAction__c> oldProtocolAction = new List<Syntilio__ProtocolAction__c>([SELECT Id FROM Syntilio__ProtocolAction__c]);
delete oldProtocolAction;

List<Syntilio__ProtocolActivator__c> oldProtocolActivator = new List<Syntilio__ProtocolActivator__c>([SELECT Id FROM Syntilio__ProtocolActivator__c]);
delete oldProtocolActivator;

List<Syntilio__Protocol__c> oldProtocol = new List<Syntilio__Protocol__c>([SELECT Id FROM Syntilio__Protocol__c]);
delete oldProtocol;

List<Syntilio__EventConfiguration__c> oldEventConfiguration = new List<Syntilio__EventConfiguration__c>([SELECT Id FROM Syntilio__EventConfiguration__c]);
delete oldEventConfiguration;

List<Schema.Location> oldLocation = new List<Schema.Location>([SELECT Id FROM Location]);
delete oldLocation;

List<Syntilio__AuditTrail__c> oldAuditTrail = new List<Syntilio__AuditTrail__c>([SELECT Id FROM Syntilio__AuditTrail__c]);
delete oldAuditTrail;

List<Contract> oldContract = new List<Contract>([SELECT Id FROM Contract]);
delete oldContract;

List<Syntilio__GroupMember__c> oldGroupMemberAssociation = new List<Syntilio__GroupMember__c>([SELECT Id FROM Syntilio__GroupMember__c]);
delete oldGroupMemberAssociation;

List<Syntilio__Group__c> oldGroup = new List<Syntilio__Group__c>([SELECT Id FROM Syntilio__Group__c]);
delete oldGroup;
