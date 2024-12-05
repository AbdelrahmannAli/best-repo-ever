@namespaceAccessible @isTest
public with sharing class DataHubTestDataFactory {
    // This class will contain methods that are used to created instances of all SObjects
    // in the DataHub package.

    private static Boolean isCreateTestRecordsRunning = false;
    
    private static void addAdditionalFields(SObject reference, Map<String, Object> additionalFields){
        if(additionalFields == null){
            return;
        }
        for(String key : additionalFields.keySet()){
            reference.put(key, additionalFields.get(key));
        }
    }
    @NamespaceAccessible
    public static Account createAccount (Map<String, Object> additionalFields) {
            Account newAccount = new Account(
                Name = 'Test',
                Syntilio__ApiName__c = 'Test',
                Phone = '+123456789',
                BillingStreet = 'Street 2',
                BillingCity = 'Amsterdam',
                BillingState = 'Noord Holland',
                BillingPostalCode = '2222',
                BillingCountry = 'Nederland',
                ShippingStreet = 'Street 2',
                ShippingCity = 'Amsterdam',
                ShippingState = 'Noord Holland',
                ShippingPostalCode = '2222',
                ShippingCountry = 'Nederland'
            );
            
        addAdditionalFields(newAccount, additionalFields);
        return newAccount;
    }
    
    @NamespaceAccessible
    public static Syntilio__AccountExternalSystemAssociation__c createAccountExternalSystemAssociation(Map<String, Object> additionalFields){
        Syntilio__AccountExternalSystemAssociation__c newAccountExternalSystemAssociation = new Syntilio__AccountExternalSystemAssociation__c(
            Name = 'Test Account External System Association'
        );
        addAdditionalFields(newAccountExternalSystemAssociation, additionalFields);
        return newAccountExternalSystemAssociation;
    }
    @NamespaceAccessible
    public static Syntilio__AuditTrail__c createAuditTrail(Map<String, Object> additionalFields) {
        Syntilio__AuditTrail__c newAuditTrail = new Syntilio__AuditTrail__c(
            Syntilio__Source__c = 'Test Source',
            Syntilio__Destination__c = 'Test Destination',
            Syntilio__Status__c = 'Test Status',
            Syntilio__Endpoint__c = 'Test Endpoint',
            Syntilio__ActionName__c = 'Test ActionMethod',
            Syntilio__RequestBody__c = 'Test RequestBody',
            Syntilio__QueryParams__c = 'Test QueryParams',
            Syntilio__ResponseBody__c = 'Test ResponseBody',
            Syntilio__Timestamp__c = Datetime.now()
        );
        addAdditionalFields(newAuditTrail, additionalFields);
        return newAuditTrail;
    }

    @NamespaceAccessible
    public static Contact createContact (Map<String, Object> additionalFields) {
        Contact newContact = new Contact(
                Salutation = 'Mr.',
                Title = 'Patient',
                FirstName = 'Jan',
                LastName = 'Willem',
                Phone = '+31-342424242',
                HomePhone = '+31-342424242',
                MailingStreet = 'Street',
                MailingCity = 'Amsterdam',
                MailingState = 'Noord Holland',
                MailingPostalCode = '893',
                MailingCountry = 'Nederland',
                Birthdate = Date.newInstance(1988, 07, 15),
                Email = 'jan@nl.com'
            );
            addAdditionalFields(newContact, additionalFields);
            return newContact;
    }

    
    @NamespaceAccessible
    public static Syntilio__DataHubSyncInfo__c createDataHubSyncInfo(Map<String, Object> additionalFields){
        Syntilio__DataHubSyncInfo__c newDataHubSyncInfo = new Syntilio__DataHubSyncInfo__c(
            Syntilio__Enabled__c = true,
            Syntilio__Frequency__c = 22,
            Syntilio__InsertNewRecords__c = true,
            Syntilio__LastSyncDate__c = Datetime.now(),
            Syntilio__SyncMode__c = 'AlwaysOverride',
            Syntilio__ExternalSystems__c = 'ES',
            Syntilio__Type__c = 'PullAndPush'
        );
        addAdditionalFields(newDataHubSyncInfo, additionalFields);
        return newDataHubSyncInfo;
    }
    @NamespaceAccessible
    public static Syntilio__ExternalId__c createExternalId(Map<String, Object> additionalFields){
        Syntilio__ExternalId__c newExternalId = new Syntilio__ExternalId__c(Name = 'External Id');
        addAdditionalFields(newExternalId, additionalFields);
        return newExternalId;
    }
    @NamespaceAccessible
    public static Syntilio__ExternalSystem__c createExternalSystem(Map<String, Object> additionalFields){
        Syntilio__ExternalSystem__c newExternalSystem = new Syntilio__ExternalSystem__c(
            Name = 'External System',
            Syntilio__ApiName__c = 'ES'
        );
        addAdditionalFields(newExternalSystem, additionalFields);
        return newExternalSystem;
    }
    @NamespaceAccessible
    public static Case createCase(Map<String, Object> additionalFields){
        Case newCase = new Case(
            Origin = 'Web',
            Status = 'New'
        );
        addAdditionalFields(newCase, additionalFields);
        return newCase;
    }
  







    

    // @namespaceAccessible
    // public static SObject createTestRecord(String objectTypeName, Map<String, Object> params) {
    //     SObjectType objectType = Schema.getGlobalDescribe().get(objectTypeName);
    //     SObject record = objectType.newSObject();

    //     params = convertToLowerCase(params);

    //     Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
    //     for (String fieldName : fieldMap.keySet()) {
    //         if(
    //             !fieldMap.get(fieldName).getDescribe().isCreateable()
    //         ) continue;
                
            
    //         if (params != null && params.containsKey(fieldName)) {
    //             record.put(fieldName, params.get(fieldName));
    //             continue;
    //         } 

    //         if(fieldMap.get(fieldName).getDescribe().isNillable()) continue;
    //         Object fieldValue = getDefaultValueForField(fieldMap.get(fieldName));
    //         if(fieldValue == null) continue;
    //         record.put(fieldName, fieldValue);
    //     }

    //     if (!isCreateTestRecordsRunning) {
    //         insert record;
    //     }
    //     return record;
    // }
    // @namespaceAccessible
    // public static List<SObject> createTestRecords(String objectTypeName, List<Map<String, Object>> paramsList, Integer numberOfRecords) {
    //     List<SObject> recordsToInsert = new List<SObject>();
        
    //     isCreateTestRecordsRunning = true;

    //     for (Integer i = 0; i < numberOfRecords; i++) {
    //         Boolean useNullParam = paramsList == null || paramsList.size() <= i;
    //         recordsToInsert.add(createTestRecord(objectTypeName, useNullParam ? null : paramsList[i]));
    //     }
        
    //     // for (Map<String, Object> params : paramsList) {
    //     //     recordsToInsert.add(createTestRecord(objectTypeName, params));
    //     // }

    //     isCreateTestRecordsRunning = false;
        
    //     insert recordsToInsert;

    //     return recordsToInsert;
    // }
   
    // @namespaceAccessible
    // public static Object getDefaultValueForField(Schema.SObjectField field) {
    //     Schema.DisplayType fieldType = field.getDescribe().getType();
        
    //     switch on fieldType {
    //         when DATE, DATETIME {
    //             return getRandomFutureDate((Integer)Math.round(Math.random() * 10));
    //         }
    //         when PERCENT, CURRENCY, DOUBLE, INTEGER {
    //             return Math.round(Math.random() * 100);
    //         }
    //         when BOOLEAN {
    //             return Math.random() > 0.5;
    //         }
    //         when STRING {
    //             Integer maxLength = field.getDescribe().getLength();
    //         	return generateRandomString(Math.min(maxLength, 10));
    //         }
    //         when ID {
    //             return UserInfo.getUserId().substring(0, 15) + generateRandomString(5);
    //         }
    //         when REFERENCE {
    //             return null;
    //         }
    //         when else {
    //             return null;
    //         }
    //     }
    // }
    
    // @namespaceAccessible
    // public static Map<String, Object> convertToLowerCase(Map<String, Object> inputMap) {
    //     if (inputMap == null) return null;
    //     Map<String, Object> outputMap = new Map<String, Object>();
    //     for (String key : inputMap.keySet()) {
    //         outputMap.put(key.toLowerCase(), inputMap.get(key));
    //     }
    //     return outputMap;
    // }
    // @namespaceAccessible
    // public static Date getRandomFutureDate(Integer maxRandomDays) {
    //     Date currentDate = System.today();
    //     Integer randomDays = Math.mod(Math.abs(Crypto.getRandomInteger()), maxRandomDays) + 1;
    //     return currentDate.addDays(randomDays);
    // }
    // @namespaceAccessible
    // public static String generateRandomString(Integer length) {
    //     String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    //     String randomString = '';
        
    //     for (Integer i = 0; i < length; i++) {
    //         Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), characters.length());
    //         randomString += characters.substring(randomIndex, randomIndex + 1);
    //     }
        
    //     return randomString;
    // }


    
    // @NamespaceAccessible
    // public static void createDataHubSynchronisationTestData(){
    //     Account twbAccount = (Account) createTestRecord('Account', new Map<String, Object>{
    //         'Name' => 'Twb',
    //         'Syntilio__ApiName__c' => 'Twb'
    //     });
    //     Contact johanContact = (Contact) createTestRecord('Contact', new Map<String, Object>{
    //         'Salutation' => 'Mr.',
    //         'Title' => 'Patient',
    //         'FirstName' => 'Johan',
    //         'LastName' => 'Hendrik',
    //         'Phone' => '+31-323276732',
    //         'HomePhone' => '+31-323276733',
    //         'MailingStreet' => 'Street',
    //         'MailingCity' => 'Amsterdam',
    //         'MailingState' => 'Noord Holland',
    //         'MailingPostalCode' => '893',
    //         'MailingCountry' => 'Nederland',
    //         'Birthdate' => Date.newInstance(1960, 07, 15),
    //         'Email' => 'Johan@nl.com',
    //         'AccountId' => twbAccount.Id
    //     });

    //     Syntilio__ExternalSystem__c onsSystem = (Syntilio__ExternalSystem__c) createTestRecord('Syntilio__ExternalSystem__c', new Map<String, Object>{
    //         'Name' => 'Ons',
    //         'Syntilio__ApiName__c' => 'Ons'
    //     });

    //     Syntilio__AccountExternalSystemAssociation__c twbAccountAssociation = (Syntilio__AccountExternalSystemAssociation__c) createTestRecord('Syntilio__AccountExternalSystemAssociation__c', new Map<String, Object>{
    //         'Name' => 'Twb_Ons',
    //         'Syntilio__AccountId__c' => twbAccount.Id,
    //         'Syntilio__ExternalSystemId__c' => onsSystem.Id
    //     });

    //     Syntilio__ExternalId__c johanExternalId = (Syntilio__ExternalId__c) createTestRecord('Syntilio__ExternalId__c', new Map<String, Object>{
    //         'Syntilio__Account__c' => twbAccount.Id,
    //         'Syntilio__ExternalSystemId__c' => onsSystem.Id,
    //         'Syntilio__ContactId__c' => johanContact.Id,
    //         'Syntilio__Id__c' => '1234',
    //         'Name' => 'clientId',
    //         'Syntilio__RelatedSalesforceInternalId__c' => null
    //     });
    // }
    
    // @NamespaceAccessible
    // public static void createFileTriggerTestData(){

    //     Account twbAccount = (Account) createTestRecord('Account', new Map<String, Object>{
    //         'Name' => 'Twb',
    //         'Syntilio__ApiName__c' => 'Twb'
    //     });

    //     Contact johanContact = (Contact) createTestRecord('Contact', new Map<String, Object>{
    //         'Salutation' => 'Mr.',
    //         'Title' => 'Patient',
    //         'FirstName' => 'Johan',
    //         'LastName' => 'Hendrik',
    //         'Phone' => '+31-323276732',
    //         'HomePhone' => '+31-323276733',
    //         'MailingStreet' => 'Street',
    //         'MailingCity' => 'Amsterdam',
    //         'MailingState' => 'Noord Holland',
    //         'MailingPostalCode' => '893',
    //         'MailingCountry' => 'Nederland',
    //         'Birthdate' => Date.newInstance(1960, 07, 15),
    //         'Email' => 'Johan@nl.com',
    //         'AccountId' => twbAccount.Id
    //     });

    //     Syntilio__ExternalSystem__c onsSystem = (Syntilio__ExternalSystem__c) createTestRecord('Syntilio__ExternalSystem__c', new Map<String, Object>{
    //         'Name' => 'Ons',
    //         'Syntilio__ApiName__c' => 'Ons'
    //     });

    //     Syntilio__AccountExternalSystemAssociation__c twbAccountAssociation = (Syntilio__AccountExternalSystemAssociation__c) createTestRecord('Syntilio__AccountExternalSystemAssociation__c', new Map<String, Object>{
    //         'Name' => 'Twb_Ons',
    //         'Syntilio__AccountId__c' => twbAccount.Id,
    //         'Syntilio__ExternalSystemId__c' => onsSystem.Id
    //     });

    //     Syntilio__ExternalId__c johanExternalId = (Syntilio__ExternalId__c) createTestRecord('Syntilio__ExternalId__c', new Map<String, Object>{
    //         'Syntilio__Account__c' => twbAccount.Id,
    //         'Syntilio__ExternalSystemId__c' => onsSystem.Id,
    //         'Syntilio__ContactId__c' => johanContact.Id,
    //         'Syntilio__Id__c' => '1234',
    //         'Name' => 'clientId',
    //         'Syntilio__RelatedSalesforceInternalId__c' => null
    //     });

    //     Case newCase = (Case) createTestRecord('Case', new Map<String, Object>{
    //         'AccountId' => twbAccount.Id,
    //         'ContactId' => johanContact.Id,
    //         'Origin' => 'Web',
    //         'Status' => 'New'
    //     });
    // }
    
    // @NamespaceAccessible
    // public static List<Account> createAccountRecords (Integer numberOfAccountsToBeCreated) {
    //     List<Account> accountRecordsList = new List<Account>();
    //     for (Integer i = 0; i < numberOfAccountsToBeCreated; i++) {
    //         Account patientAccountJohan = new Account(
    //             Name = 'Johan Hendrik'+ String.valueOf(i),
    //             Phone = '+31-323276732'+ String.valueOf(i),
    //             BillingStreet = 'Street 1',
    //             BillingCity = 'Amsterdam',
    //             BillingState = 'Noord Holland',
    //             BillingPostalCode = '8932',
    //             BillingCountry = 'Nederland',
    //             ShippingStreet = 'Street 2',
    //             ShippingCity = 'Amsterdam',
    //             ShippingState = 'Noord Holland',
    //             ShippingPostalCode = '8932',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    //             ShippingCountry = 'Nederland',
    //             Industry = 'Healthcare',
    //             Type = 'Patient'
    //         );
    //         accountRecordsList.add(patientAccountJohan);
    //     }
    //     insert accountRecordsList;
    //     return accountRecordsList;
    // }
    
    // @NamespaceAccessible
    // public static List<Contact> createContactRecordsWithAccountRelation (Integer numberOfContactsToBeCreated, List<Account> accountList) {
    //     List<Contact> contactRecordsList = new List<Contact>();
    //     for (Integer i = 0; i < numberOfContactsToBeCreated; i++) {
    //         Contact patientContactJohan = new Contact(
    //             Salutation = 'Mr.',
    //             Title = 'Patient',
    //             FirstName = 'Johan',
    //             LastName = 'Hendrik' + String.valueOf(i),
    //             Phone = '+31-323276732' + String.valueOf(i),
    //             HomePhone = '+31-323276733' + String.valueOf(i),
    //             MailingStreet = 'Street' + String.valueOf(i+1),
    //             MailingCity = 'Amsterdam',
    //             MailingState = 'Noord Holland',
    //             MailingPostalCode = '893'+ String.valueOf(i),
    //             MailingCountry = 'Nederland',
    //             Birthdate = Date.newInstance(1960, 07, 15),
    //             Email = 'Johan@nl.com',
    //             AccountId = accountList[i].Id
    //         );
    //         contactRecordsList.add(patientContactJohan);
    //     }
    //     insert contactRecordsList;
    //     return contactRecordsList;
    // }
    
    // @NamespaceAccessible
    // public static List<Contact> createContactRecordsWithoutAccountRelation (Integer numberOfContactsToBeCreated) {
    //     List<Contact> contactRecordsList = new List<Contact>();
    //     for (Integer i = 0; i < numberOfContactsToBeCreated; i++) {
    //         Contact patientContactJohan = new Contact(
    //             Salutation = 'Mr.',
    //             Title = 'Patient',
    //             FirstName = 'Jan',
    //             LastName = 'Willem' + String.valueOf(i),
    //             Phone = '+31-342424242' + String.valueOf(i),
    //             HomePhone = '+31-342424242' + String.valueOf(i),
    //             MailingStreet = 'Street'+ String.valueOf(i+1),
    //             MailingCity = 'Amsterdam',
    //             MailingState = 'Noord Holland',
    //             MailingPostalCode = '893' + String.valueOf(i),
    //             MailingCountry = 'Nederland',
    //             Birthdate = Date.newInstance(1988, 07, 15),
    //             Email = 'jan@nl.com'
    //         );
    //         contactRecordsList.add(patientContactJohan);
    //     }
    //     insert contactRecordsList;
    //     return contactRecordsList;
    // }    
    
    // @NamespaceAccessible
    // public static List<Contact> createContactRecordsWithoutInsertion (Integer numberOfContactsToBeCreated) {
    //     List<Contact> contactRecordsList = new List<Contact>();
    //     for (Integer i = 0; i < numberOfContactsToBeCreated; i++) {
    //         Contact patientContactJohan = new Contact(
    //             Salutation = 'Mr.',
    //             Title = 'Patient',
    //             FirstName = 'Jan',
    //             LastName = 'Willem' + String.valueOf(i),
    //             Phone = '+31-342424242' + String.valueOf(i),
    //             HomePhone = '+31-342424242' + String.valueOf(i),
    //             MailingStreet = 'Street'+ String.valueOf(i+1),
    //             MailingCity = 'Amsterdam',
    //             MailingState = 'Noord Holland',
    //             MailingPostalCode = '893' + String.valueOf(i),
    //             MailingCountry = 'Nederland',
    //             Birthdate = Date.newInstance(1988, 07, 15),
    //             Email = 'jan@nl.com'
    //         );
    //         contactRecordsList.add(patientContactJohan);
    //     }
    //     return contactRecordsList;
    // }  
    
    // @NamespaceAccessible
    // public static List<Syntilio__ExternalId__c> createRelatedExternalIds(List<SObject> sObjectList, String externalSystemId) {
    //     List<Syntilio__ExternalId__c> externalIds = new List<Syntilio__ExternalId__c>();
    
    //     if(sObjectList.size() == 0) return externalIds;
    
    //     for (SObject oneSObject : sObjectList) {
    //       	externalIds.add(
    //             new Syntilio__ExternalId__c(
    //                 Name = 'Test ExternalId ' + oneSObject.Id, 
    //                 Syntilio__RelatedSalesforceInternalId__c = oneSObject.Id,
    //                 Syntilio__Id__c = String.valueOf(oneSObject.Id),
    //                 Syntilio__ExternalSystemId__c = externalSystemId
    //             )
	// 		);
    //     }
        
    //     insert externalIds;
    //     return externalIds;
    // }
    
    // @NamespaceAccessible
    // public static DataHubModel.Destination createDestinationRecords (String technology, String destinationName) {
    //     DataHubModel.Destination destinationRecord = new DataHubModel.Destination();
    //     destinationRecord.technology = technology;
    //     destinationRecord.destinationName = destinationName;
    //     return destinationRecord;
    // }
    
    // @NamespaceAccessible
    // public static DataHubModel createDataHubModel (List<DataHubModel.Destination> destinationRecords, List<Object> objectsBodyList) {         
    //     DataHubModel dataHubModel = new DataHubModel();
    //     dataHubModel.destinations = destinationRecords;
    //     dataHubModel.objectsBody = objectsBodyList;
    //     return dataHubModel;
    // }
    
    // @NamespaceAccessible
    // public static void createDataHubSyncInfoThatShouldUpdate(String objectName) {  

    //     Syntilio.DataHubTestDataFactory.createTestRecords('Syntilio__DataHubSyncInfo__c', new List<Map<String, Object>>{
    //         new Map<String, Object>{
    //             'Name' => 'Email',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 0,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => Datetime.now(),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'LastName',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 0,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => Datetime.now(),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'Pull'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'Phone',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 0,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => Datetime.now(),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'CreateTaskOnConflict',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'Birthdate',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 0,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => Datetime.now(),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         } 
    //     }, 4);

    // }
    
    // @NamespaceAccessible
    // public static void createDataHubSyncInfoRecordsWithinFrequencyTimeFrame (String objectName) {  
    //     Syntilio.DataHubTestDataFactory.createTestRecords('Syntilio__DataHubSyncInfo__c', new List<Map<String, Object>>{
    //         new Map<String, Object>{
    //             'Name' => 'FirstName',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 24,
    //             'Syntilio__IsUniqueIdentifier__c' => true,
    //             'Syntilio__LastSyncDate__c' => null,
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'Email',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 23,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => null,
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'Push'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'LastName',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 22,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => null,
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'Pull'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'Phone',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 21,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => null,
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'CreateTaskOnConflict',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'Birthdate ',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 24,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => DateTime.now().addHours(-5),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         }
    //     }, 4);
    // }
    
    // @NamespaceAccessible
    // public static void createDataHubSyncInfoRecordsNotWithinFrequencyTimeFrame (String objectName) {  
 
    //     Syntilio.DataHubTestDataFactory.createTestRecords('Syntilio__DataHubSyncInfo__c', new List<Map<String, Object>>{
    //         new Map<String, Object>{
    //             'Name' => 'FirstName',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 24,
    //             'Syntilio__IsUniqueIdentifier__c' => true,
    //             'Syntilio__LastSyncDate__c' => DateTime.now().addHours(-5),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'Push'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'Email',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 24,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => DateTime.now().addHours(-5),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         },
    //         new Map<String, Object>{
    //             'Name' => 'Birthdate ',
    //             'Syntilio__Enabled__c' => true,
    //             'Syntilio__Frequency__c' => 24,
    //             'Syntilio__IsUniqueIdentifier__c' => false,
    //             'Syntilio__LastSyncDate__c' => DateTime.now().addHours(-5),
    //             'Syntilio__ObjectName__c' => objectName,
    //             'Syntilio__SyncMode__c' => 'AlwaysOverride',
    //             'Syntilio__ExternalSystems__c' => 'Ons',
    //             'Syntilio__Type__c' => 'PullAndPush'
    //         }
    //     }, 3);
    // }  

    // @namespaceAccessible
    // public static List<Syntilio__DataHubSyncInfo__c> createDatahubSyncInfoRecords(String objectApiName, String externalSystems) {
    //     Syntilio.DataHubTestDataFactory.createDataHubSynchronisationTestData();
    //     Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
    //     List<Schema.SObjectField> fields = objectDescribe.fields.getMap().values();
    //     List<Syntilio__DataHubSyncInfo__c> records = new  List<Syntilio__DataHubSyncInfo__c>();
    //     for (Schema.SObjectField sObjectField : fields) {
    //         Syntilio__DataHubSyncInfo__c record = new Syntilio__DataHubSyncInfo__c(
    //             Syntilio__ExternalSystems__c = externalSystems,
    //             Syntilio__Frequency__c = 0,
    //             Name = sObjectField.getDescribe().getName(),
    //             Syntilio__ObjectName__c = objectApiName
    //         );
    //         records.add(record);
    //     }

    //     insert records;
    //     return records;
    // }

    // @namespaceAccessible
    // public static List<Case> createCaseRecords(
    //     List<Contact> contactRecord,
    //   Integer numberOfRecords
    // ) {
      
    // List<Contact> contactList = (List<Contact>) contactRecord;

    // List<Case> caseRecordsList = new List<Case>();
    // for (Integer i = 0; i < numberOfRecords; i++) {
    //     Case caseRecord = new Case();

    //     if (contactList != null) {
    //         caseRecord.AccountId = contactList[i >= contactList.size() ? 0 : i].AccountId;
    //         caseRecord.ContactId = contactList[i >= contactList.size() ? 0 : i].Id;
    //     }

    //     caseRecord.Origin = 'Web';
    //     caseRecord.Status = 'New';
    //     caseRecordsList.add(caseRecord);
    // }
    // insert caseRecordsList;
    // return caseRecordsList;
      
    // }
  
    
    // @NamespaceAccessible
    // public static HTTPResponse dataHubSyncSuccessfulResponse() {
    //     HttpResponse response = new HttpResponse();
    //     response.setHeader('Content-Type', 'application/json');
    //     response.setBody('[ { "Syntilio__Id__c": "6", "IdentificationNo__c": "3232323110551", "FirstName": "Test", "lastName": "Test", "LastModifiedDate": "2023-02-01T16:51:38.000+01:00", "Phone": "+31722627282", "Birthdate": "1999-02-01" }, { "Syntilio__Id__c": "3232323110552", "IdentificationNo__c": "3232323110552", "FirstName": "Test", "lastName": "ChangeingLastName", "LastModifiedDate": "2023-02-01T16:55:22.000+01:00", "Phone": "+323827328", "Birthdate": "1999-02-01"} ]');
    //     response.setStatusCode(200);
    //     return response;
    // }
    
    // @NamespaceAccessible
    // public static HTTPResponse dataHubSyncUnSuccessfulResponse() {
    //     HttpResponse response = new HttpResponse();
    //     response.setHeader('Content-Type', 'application/json');
    //     response.setBody('[ { "Success": false, "Message": "Reason Phrase: Bad Request, Error: Response status code does not indicate success: 400 (Bad Request).", "ResponseData": null, "Data": null, "ProviderName": "Salesforce:GrowtivityDev", "StatusCode": 400, "ExcludedMappings": {} } ]');
    //     response.setStatusCode(400);
    //     return response;
    // }
    
    // @NamespaceAccessible
    // public static HTTPResponse dataHubSyncSuccessfulEmptyResponse() {
    //     HttpResponse response = new HttpResponse();
    //     response.setHeader('Content-Type', 'application/json');
    //     response.setBody('[]');
    //     response.setStatusCode(200);
    //     return response;
    // }
    // @NamespaceAccessible
    // public static HTTPResponse dataHubSyncV2SuccessfulResponse() {
    //     HttpResponse response = new HttpResponse();
    //     response.setHeader('Content-Type', 'application/json');
    //     response.setBody('{"Twb_Ons": [ { "Email": "Johan@newemail.com", "ExternalIds": [{"Name": "clientId", "Syntilio__Id__c": "1234"}, {"Name": "identificationNo", "Syntilio__Id__c": "123"}] } ]}');
    //     response.setStatusCode(200);
    //     return response;
    // }
    
    // @NamespaceAccessible
    // public static HTTPResponse dataHubSyncV2UnSuccessfulResponse() {
    //     HttpResponse response = new HttpResponse();
    //     response.setHeader('Content-Type', 'application/json');
    //     response.setBody('{"Twb_Ons": [ { "Success": false, "Message": "Reason Phrase: Bad Request, Error: Response status code does not indicate success: 400 (Bad Request).", "ResponseData": null, "Data": null, "ProviderName": "Salesforce:GrowtivityDev", "StatusCode": 400, "ExcludedMappings": {} } ]}');
    //     response.setStatusCode(400);
    //     return response;
    // }
    
    // @NamespaceAccessible
    // public static HTTPResponse dataHubSyncV2SuccessfulEmptyResponse() {
    //     HttpResponse response = new HttpResponse();
    //     response.setHeader('Content-Type', 'application/json');
    //     response.setBody('{"Twb_Ons": []}');
    //     response.setStatusCode(200);
    //     return response;
    // }
}