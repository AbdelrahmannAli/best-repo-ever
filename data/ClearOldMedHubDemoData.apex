List<Entitlement> oldEntitlementRecords = new List<Entitlement>([SELECT Id FROM Entitlement]);
delete oldEntitlementRecords;


List<HealthCondition> oldHealthConditionRecords = new List<HealthCondition>([SELECT Id FROM HealthCondition]);
delete oldHealthConditionRecords;


List<Syntilio__MedicalCondition__c> oldMedicalConditionRecords = new List<Syntilio__MedicalCondition__c>([SELECT Id FROM Syntilio__MedicalCondition__c]);
delete oldMedicalConditionRecords;

List<TimeSlot> oldTimeSlotRecords = new List<TimeSlot>([SELECT Id FROM TimeSlot]);
delete oldTimeSlotRecords;


List<Syntilio__CareOperatingHours__c> oldOperatingHoursRecords = new List<Syntilio__CareOperatingHours__c>([SELECT Id FROM Syntilio__CareOperatingHours__c]);
delete oldOperatingHoursRecords;


List<CareOrganizationContractRelation__c> oldCareOrganizationContractRelationRecords = new List<CareOrganizationContractRelation__c>([SELECT Id FROM CareOrganizationContractRelation__c]);
delete oldCareOrganizationContractRelationRecords;

List<Task> oldTaskRecords = new List<Task>([SELECT Id FROM Task]);
delete oldTaskRecords;


List<CareObservationComponent> oldCareObservationComponentRecords = new List<CareObservationComponent>([SELECT Id FROM CareObservationComponent]);
delete oldCareObservationComponentRecords;


List<CareObservation> oldCareObservationRecords = new List<CareObservation>([SELECT Id FROM CareObservation]);
delete oldCareObservationRecords;


List<HealthcareProvider> oldHealthcareProviderRecords = new List<HealthcareProvider>([SELECT Id FROM HealthcareProvider]);
delete oldHealthcareProviderRecords;


List<CareMetricTarget> oldCareMetricTargetRecords = new List<CareMetricTarget>([SELECT Id FROM CareMetricTarget]);
delete oldCareMetricTargetRecords;


List<CodeSetBundle> oldCodeSetBundleRecords = new List<CodeSetBundle>([SELECT Id FROM CodeSetBundle]);
delete oldCodeSetBundleRecords;


List<CodeSet> oldCodeSetRecords = new List<CodeSet>([SELECT Id FROM CodeSet]);
delete oldCodeSetRecords;


List<UnitOfMeasure> oldUnitOfMeasureRecords = new List<UnitOfMeasure>([SELECT Id FROM UnitOfMeasure]);
delete oldUnitOfMeasureRecords;


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


List<Syntilio__SyntilioEvent__c> oldSyntilioEventRecords = new List<Syntilio__SyntilioEvent__c>([SELECT Id FROM Syntilio__SyntilioEvent__c]);
delete oldSyntilioEventRecords;


List<Syntilio__QuestionnaireQuestion__c> oldQuestionnaireQuestionRecords = new List<Syntilio__QuestionnaireQuestion__c>([SELECT Id FROM Syntilio__QuestionnaireQuestion__c]);
delete oldQuestionnaireQuestionRecords;


List<Syntilio__Question__c> oldQuestionRecords = new List<Syntilio__Question__c>([SELECT Id FROM Syntilio__Question__c]);
delete oldQuestionRecords;


List<Syntilio__Questionnaire__c> oldQuestionnaireRecords = new List<Syntilio__Questionnaire__c>([SELECT Id FROM Syntilio__Questionnaire__c]);
delete oldQuestionnaireRecords;


List<Syntilio__Exception__c> oldExceptionRecords = new List<Syntilio__Exception__c>([SELECT Id FROM Syntilio__Exception__c]);
delete oldExceptionRecords;