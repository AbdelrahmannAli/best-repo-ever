@isTest
public with sharing class MedHubTestDataFactory {
    
    public static void createAccountRecords (Integer numberOfAccountsToBeCreated) {
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();
        List<Account> accountRecordsList = new List<Account>();
        
        for (Integer i = 0; i < numberOfAccountsToBeCreated; i++) {
            Account individualAccount = new Account(
                Name = 'John Nasser' + String.valueOf(i),
                Phone = '+31-223344556' + String.valueOf(i),
                BillingStreet = 'Street 2',
                BillingCity = 'Amsterdam',
                BillingState = 'Noord Holland',
                BillingPostalCode = '2222',
                BillingCountry = 'Nederland',
                ShippingStreet = 'Street 2',
                ShippingCity = 'Amsterdam',
                ShippingState = 'Noord Holland',
                ShippingPostalCode = '2222',
                ShippingCountry = 'Nederland',
                RecordTypeId = accountRecordTypeId
            );
            
            accountRecordsList.add(individualAccount);
        }
        insert accountRecordsList;
    }
    
    public static List<Contact> createContactRecords (Integer numberOfContactsToBeCreated) {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();
        List<Contact> contactRecordsList = new List<Contact>();
        
        for (Integer i = 0; i < numberOfContactsToBeCreated; i++) {
            Contact individualContact = new Contact(
                Salutation = 'Mr.',
                FirstName = 'Jansen',
                LastName = String.valueOf(i),
                Phone = '+31-223344556' + String.valueOf(i),
                HomePhone = '+31-97239272' + String.valueOf(i),
                MailingStreet = 'Street 2',
                MailingCity = 'Amsterdam',
                MailingState = 'Noord Holland',
                MailingPostalCode = '2222',
                MailingCountry = 'Nederland',
                OtherStreet = 'Street 2',
                OtherCity = 'Amsterdam',
                OtherState = 'Noord Holland',
                OtherPostalCode = '2222',
                OtherCountry = 'Nederland',
                RecordTypeId = contactRecordTypeId,
                Birthdate = Date.newInstance(1960, 07, 15),
                Email = 'Jansen@nl.com',
                MaritalStatus = 'Married',
                Gender = 'Male'
            );            
            contactRecordsList.add(individualContact);
        }
        
        insert contactRecordsList;
        List<Contact> contactRecordsListToReturn = ([SELECT Id, AccountId FROM Contact]);
        return contactRecordsListToReturn;
    }
    
    public static void createCareObservationsRelatedRecords(Id accountId){
        
        User userId = [SELECT Id, Name FROM USER WHERE Name = 'User User'];
        UnitOfMeasure bloodPressureUnitOfMeasure = new UnitOfMeasure(
            Name = 'mmHg',
            UnitCode = 'mmHg',
            Type = 'Custom',
            OwnerId = userId.Id
        );
        insert bloodPressureUnitOfMeasure;
        
        CodeSet bloodPressureCodeSet= new CodeSet(
            Name = 'Blood Pressure',
            Code = 'bp',
            IsActive = true,
            OwnerId = userId.Id
        );
        insert bloodPressureCodeSet;
        
        CodeSetBundle standardQuestionnaireCodeSetBundle= new CodeSetBundle(
            Name = 'Standard Hospital Questionnaire',
            CodeSet1Id = bloodPressureCodeSet.Id
        );
        
        insert standardQuestionnaireCodeSetBundle;        
        
        CareMetricTarget bloodPressureCareMetricTarget = new CareMetricTarget(
            Name = 'Blood Pressure Care Metric Target',
            Type = 'RANGE',
            PatientId = accountId,
            CodeId = bloodPressureCodeSet.Id,
            UpperLimit = 200,
            LowerLimit = 10,
            UnitOfMeasureId = bloodPressureUnitOfMeasure.Id,
            StartDate =  Date.newInstance(2022, 03, 1),
            OwnerId = userId.Id
        );
        insert bloodPressureCareMetricTarget;
        
        CareObservation bloodPressureCareObservationWeek1 = new CareObservation(
            Name = 'Blood Pressure Care Observation Week 1',
            ObservedSubjectId = accountId,
            CodeId = bloodPressureCodeSet.Id,
            ObservationStatus = 'Final',
            ObservedValueType = 'Range',
            ObservedValueNumerator = 120,
            ObservedValueDenominator = 90,
            ObservedValueUnitId = bloodPressureUnitOfMeasure.Id,
            EffectiveDateTime = Date.newInstance(2022, 04, 1),
            ExpectedValueId = bloodPressureCareMetricTarget.Id,
            IsMonitoredRemotely = true
        );
        insert bloodPressureCareObservationWeek1;
    }
    
    public static void createCaseRecords(Contact contactRecord){
        Id caseMedicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();
        
        Product2 ProductRecord = new Product2(
            Name = 'Telemonitoring App',
            IsActive = true, 
            ProductCode = '0001',
            Family = 'Telemonitoring',
            Syntilio__Supplier__c = 'AppSupplier'
        );
        
        insert ProductRecord;
        
        //Contact contactRecord = [SELECT Id FROM Contact WHERE AccountId =: accountRecord.Id];
        
        Case caseRecord = new Case(
            AccountId = contactRecord.AccountId,
            ContactId = contactRecord.Id,
            Origin = 'Web',
            RecordTypeId  = caseMedicalRecordTypeId,
            Syntilio__EventCode__c = 1111,
            Status = 'New',
            Syntilio__CodeSet__c = 'bp',
            ProductId = ProductRecord.Id
        );
        insert caseRecord;
    }
    
    public static void createCaseRecordsWithInvalidData(){
        Id caseMedicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();
        
        Product2 ProductRecord = new Product2(
            Name = 'Telemonitoring App',
            IsActive = true, 
            ProductCode = '0001',
            Family = 'Telemonitoring',
            Syntilio__Supplier__c = 'AppSupplier'
        );
        
        insert ProductRecord;
        
        //Contact contactRecord = [SELECT Id FROM Contact WHERE AccountId =: accountRecord.Id];
        
        Case caseRecord = new Case(
            AccountId = null,
            ContactId = null,
            Origin = 'Web',
            RecordTypeId  = caseMedicalRecordTypeId,
            Syntilio__EventCode__c = 1111,
            Status = 'New',
            Syntilio__CodeSet__c = '&*#&(@#&@',
            ProductId = ProductRecord.Id
        );
        insert caseRecord;
    }
    
    public static void createCaseRecordsWithoutLinkedProductSupplier(Contact contactRecord){
        Id caseMedicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();
        
        Product2 ProductRecord = new Product2(
            Name = 'Telemonitoring App',
            IsActive = true, 
            ProductCode = '0001',
            Family = 'Telemonitoring'
        );
        
        insert ProductRecord;
        
        Case caseRecord = new Case(
            AccountId = contactRecord.AccountId,
            Origin = 'Web',
            RecordTypeId  = caseMedicalRecordTypeId,
            Syntilio__EventCode__c = 1111,
            Status = 'New',
            Syntilio__CodeSet__c = 'bp',
            ProductId = ProductRecord.Id
        );
        insert caseRecord;
        
    }
    
    public static void createCaseRecordsWithoutAccountRecord(){
        Id caseMedicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();
        Case caseRecord = new Case(
            Origin = 'Web',
            RecordTypeId  = caseMedicalRecordTypeId,
            Syntilio__EventCode__c = 1111,
            Status = 'New'
        );
        insert caseRecord;
    }
    
    public static Syntilio__EventConfiguration__c mockCloseEventConfigurationCustomMetadata(){
        Syntilio__EventConfiguration__c mockCloseEventConfigurationCustomMetadata = new Syntilio__EventConfiguration__c(
            Syntilio__CaseAction__c = 'Close',
            Syntilio__Category__c = 'Medical',
            Syntilio__CloseEventCodes__c = '1111',
            Syntilio__Code__c = 1112,
            Syntilio__Description__c = 'Test Event Code Close',
            Syntilio__ParentCodeId__c = null,
            Syntilio__Priority__c = 'High',
            Syntilio__State__c = 'Critical',
            Name = 'Test Event Code Close',
            Syntilio__WaitingMinutes__c = null);
        return mockCloseEventConfigurationCustomMetadata;
    }
    
    public static Syntilio__EventConfiguration__c mockCloseEventConfigurationCustomMetadata_WrongFormatOfCloseEventCodes(){
        Syntilio__EventConfiguration__c mockCloseEventConfigurationCustomMetadata = new Syntilio__EventConfiguration__c(
            Syntilio__CaseAction__c = 'Close',
            Syntilio__Category__c = 'Medical',
            Syntilio__CloseEventCodes__c = ',',
            Syntilio__Code__c = 1112,
            Syntilio__Description__c = 'Test Event Code Close',
            Syntilio__ParentCodeId__c = null,
            Syntilio__Priority__c = 'High',
            Syntilio__State__c = 'Critical',
            Name = 'Test Event Code Close',
            Syntilio__WaitingMinutes__c = null);
        return mockCloseEventConfigurationCustomMetadata;
    }
    
    public static Syntilio__EventConfiguration__c mockCreateEventConfigurationCustomMetadata_With_ObservationsPeriod(){
        Syntilio__EventConfiguration__c mockCreateEventConfigurationCustomMetadata = new Syntilio__EventConfiguration__c(
            Syntilio__CaseAction__c = 'Upsert',
            Syntilio__Category__c = 'Medical',
            Syntilio__CloseEventCodes__c = '1001',
            Syntilio__Code__c = null,
            Syntilio__Description__c = 'Test Event Code Close',
            Syntilio__ParentCodeId__c = null,
            Syntilio__Priority__c = 'High',
            Syntilio__State__c = 'Critical',
            Name = 'Test Event Code Create',
            Syntilio__WaitingMinutes__c = null
            );
        return mockCreateEventConfigurationCustomMetadata;
    }
    
    
    public static Syntilio__EventConfiguration__c mockCreateEventConfigurationCustomMetadata_Without_ObservationsPeriod(){
        Syntilio__EventConfiguration__c mockCreateEventConfigurationCustomMetadata = new Syntilio__EventConfiguration__c(
            Syntilio__CaseAction__c = 'Upsert',
            Syntilio__Category__c = 'Medical',
            Syntilio__CloseEventCodes__c = '1001',
            Syntilio__Code__c = null,
            Syntilio__Description__c = 'Test Event Code Close',
            Syntilio__ParentCodeId__c = null,
            Syntilio__Priority__c = 'High',
            Syntilio__State__c = 'Critical',
            Name = 'Test Event Code Create',
            Syntilio__WaitingMinutes__c = null);
        return mockCreateEventConfigurationCustomMetadata;
    }
    
    public static Syntilio__ErrorCodeConfiguration__mdt mockErrorCodeConfigurationCustomMetadata(){
        Syntilio__ErrorCodeConfiguration__mdt mockErrorCodeConfigurationCustomMetadata = new Syntilio__ErrorCodeConfiguration__mdt(
            MasterLabel = 'Flow Error 0001',
            DeveloperName = 'FLE0001',
            Syntilio__Description_de_DE__c = '',
            Syntilio__Description_en_GB__c = 'We could not find this event configuration in your org, please contact your system administrator with the event code to check the custom metadata.',
            Syntilio__Description_fr_FR__c = '',
            Syntilio__Description_nl_NL__c = '');
        return mockErrorCodeConfigurationCustomMetadata;
    }
    
    public static Long waitXNumberOfSeconds(Long numberOfMillisecondsToWait){
        Long startTime = DateTime.now().getTime();
        Long endTime = DateTime.now().getTime();
        while (endTime - startTime < numberOfMillisecondsToWait) {
            endTime = DateTime.now().getTime();
        }
        return endTime;
    }    
    
}