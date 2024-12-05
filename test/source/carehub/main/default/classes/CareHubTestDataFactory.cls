@NamespaceAccessible
@isTest
public with sharing class CareHubTestDataFactory {
    // This class will contain methods that are used to created instances of all SObjects
    // in the CareHub package.
    
    private static void addAdditionalFields(SObject reference, Map<String, Object> additionalFields){
        if(additionalFields == null){
            return;
        }
        for(String key : additionalFields.keySet()){
            reference.put(key, additionalFields.get(key));
        }
    }

    @NamespaceAccessible
    public static Account createAccount(Map<String, Object> additionalFields){
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
    public static Asset createAsset(Map<String, Object> additionalFields){
        Asset newAsset = new Asset(
            Name = 'Test Asset Name',
            IsCompetitorProduct = false,
            Syntilio__AssetId__c = '123',
            InstallDate = Date.newInstance(2022, 03, 27),
            PurchaseDate = Date.newInstance(2021, 02, 01),
            Status = 'Registered',
            Description = 'Test Asset Description',
            Quantity = 1
        );
        addAdditionalFields(newAsset, additionalFields);
        return newAsset;
    }

    @NamespaceAccessible
    public static Syntilio__CallLog__c createCallLog(Map<String, Object> additionalFields){
        Syntilio__CallLog__c newCallLog = new Syntilio__CallLog__c(
            Syntilio__Duration__c = '00:02:00',
            Syntilio__StartTime__c = Datetime.now(),
            Syntilio__EndTime__c = Datetime.now().addMinutes(2),
            Syntilio__Type__c = 'Video'
        );
        addAdditionalFields(newCallLog, additionalFields);
        return newCallLog;
    }
    
    @NamespaceAccessible
    public static Syntilio__CareOperatingHours__c createCareOperatingHours(Map<String, Object> additionalFields){
        Syntilio__CareOperatingHours__c newCareOperatingHours = new Syntilio__CareOperatingHours__c(
            Name = 'careTeamOperatingHours',
        	Syntilio__StartDate__c = Date.today().addYears(-1),
        	Syntilio__EndDate__c = Date.today().addYears(1),
        	Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)'
        );
        addAdditionalFields(newCareOperatingHours, additionalFields);
        return newCareOperatingHours;
    }
    
    @NamespaceAccessible
    public static Syntilio__CareOrganizationContractRelation__c createCareOrganizationContractRelation(Map<String, Object> additionalFields){
        Syntilio__CareOrganizationContractRelation__c newCareOrganizationContractRelation = new Syntilio__CareOrganizationContractRelation__c(
            Syntilio__StartDate__c = Date.today().addDays(-1),
            Syntilio__EndDate__c = Date.today().addDays(1)
        );
        addAdditionalFields(newCareOrganizationContractRelation, additionalFields);
        return newCareOrganizationContractRelation;
    }
    
    @NamespaceAccessible
    public static Syntilio__CareTimeSlot__c createCareTimeSlot(Map<String, Object> additionalFields){
        Syntilio__CareTimeSlot__c newCareTimeSlot = new Syntilio__CareTimeSlot__c(
            Syntilio__DayOfWeek__c = 'Monday',
            Syntilio__StartTime__c = Time.newInstance(0, 0, 0, 0),
            Syntilio__EndTime__c = Time.newInstance(23, 45, 0, 0)
        );
        addAdditionalFields(newCareTimeSlot, additionalFields);
        return newCareTimeSlot;
    }

    @NamespaceAccessible
    public static Case createCase(Map<String, Object> additionalFields){
        Case newCase = new Case(
            Origin = 'Web',
            Status = 'New',
            Syntilio__CodeSet__c = 'Standard Code Set mmHg'
        );
        addAdditionalFields(newCase, additionalFields);
        return newCase;
    }
    
    @NamespaceAccessible
    public static Contact createContact(Map<String, Object> additionalFields){
        Contact newContact = new Contact(
            Salutation = 'Mr.',
            FirstName = 'First',
            LastName = 'Last',
            Phone = '+123456789',
            Email = 'first.last@test.com',
            HomePhone = '+123456789',
            MailingStreet = 'Street 2',
            MailingCity = 'Amsterdam',
            MailingState = 'Noord Holland',
            MailingPostalCode = '2222',
            MailingCountry = 'Nederland',
            OtherStreet = 'Street 2',
            OtherCity = 'Amsterdam',
            OtherState = 'Noord Holland',
            OtherPostalCode = '2222',
            OtherCountry = 'Nederland'
        );
        addAdditionalFields(newContact, additionalFields);
        return newContact;
    }
    
    @NamespaceAccessible
    public static Syntilio__ContactAlert__c createContactAlert(Map<String, Object> additionalFields){
        Syntilio__ContactAlert__c newContactAlert = new Syntilio__ContactAlert__c(
            Name = 'Test Contact Alert',
            Syntilio__Active__c = true,
            Syntilio__Description__c = 'Test Description',
            Syntilio__StartDate__c = Date.today()
        );
        addAdditionalFields(newContactAlert, additionalFields);
        return newContactAlert;
    }
    
    @NamespaceAccessible
    public static Syntilio__ContactContactRelationship__c createContactContactRelationship(Map<String, Object> additionalFields){
        Syntilio__ContactContactRelationship__c newContactContactRelationship = new Syntilio__ContactContactRelationship__c(
            Name = 'Test Relationship',
            Syntilio__Relationship__c = 'Father',
            Syntilio__RelationshipType__c = 'Informal',
            Syntilio__Type__c = 'Emergency'
        );
        addAdditionalFields(newContactContactRelationship, additionalFields);
        return newContactContactRelationship;
    }

    @NamespaceAccessible
    public static Syntilio__ContactNote__c createContactNote(Map<String, Object> additionalFields){
        Syntilio__ContactNote__c newContactNote = new Syntilio__ContactNote__c(
            Name = 'Test Contact Note',
            Syntilio__Content__c = 'Test Comment',
            Syntilio__ExternalUpdatedAt__c = Datetime.now()
        );
        addAdditionalFields(newContactNote, additionalFields);
        return newContactNote;
    }
    
    @NamespaceAccessible
    public static Syntilio__ContactToLocation__c createContactToLocation(Map<String, Object> additionalFields){
        Syntilio__ContactToLocation__c newContactToLocation = new Syntilio__ContactToLocation__c(
        	Name = 'Test Location'
        );
        addAdditionalFields(newContactToLocation, additionalFields);
        return newContactToLocation;
    }


    @NamespaceAccessible
    public static Contract createContract(Map<String, Object> additionalFields){
        Contract newContract = new Contract(
            Name = 'Test Contract',
    		StartDate = Date.today().addDays(-1),
            ContractTerm = 300
        );
        addAdditionalFields(newContract, additionalFields);
        return newContract;
    }
    
    @NamespaceAccessible
    public static Syntilio__EventConfiguration__c createEventConfiguration(Map<String, Object> additionalFields){
        Syntilio__EventConfiguration__c newEventConfiguration = new Syntilio__EventConfiguration__c(
            Name = 'Test Event',
            Syntilio__Description__c = 'Test event code create',
            Syntilio__Code__c = 1111.0,
            Syntilio__ParentCodeId__c = null,
            Syntilio__Category__c = 'Medical',
            Syntilio__CaseAction__c = 'Upsert',
            Syntilio__Priority__c = 'High',
            Syntilio__State__c = 'Critical',
            Syntilio__WaitingMinutes__c = null,
            Syntilio__CloseEventCodes__c = null,
            Syntilio__CodeSet__c = 'bp'
        );
        addAdditionalFields(newEventConfiguration, additionalFields);
        return newEventConfiguration;
    }
    
    @NamespaceAccessible
    public static Syntilio__Group__c createGroup(Map<String, Object> additionalFields){
        Syntilio__Group__c newGroup = new Syntilio__Group__c(
            Name = 'Test Group',
            Syntilio__ObjectType__c = 'Contact'
        );
        addAdditionalFields(newGroup, additionalFields);
        return newGroup;
    }
    
    @NamespaceAccessible
    public static Syntilio__GroupMember__c createGroupMember(Map<String, Object> additionalFields){
        Syntilio__GroupMember__c newGroupMember = new Syntilio__GroupMember__c();
        addAdditionalFields(newGroupMember, additionalFields);
        return newGroupMember;
    }
    
    @NamespaceAccessible
    public static Schema.Location createLocation(Map<String, Object> additionalFields){
        Schema.Location newLocation = new Schema.Location(
            Name = 'Test Location',
            Syntilio__LocationId__c = '12345'
        );
        addAdditionalFields(newLocation, additionalFields);
        return newLocation;
    }
    
    @NamespaceAccessible
    public static Syntilio__MedicalNote__c createMedicalNote(Map<String, Object> additionalFields){
        Syntilio__MedicalNote__c newMedicalNote = new Syntilio__MedicalNote__c(
            Name = 'Test Medical Note',
            Syntilio__Comments__c = 'Test Comment',
            Syntilio__Author__c = 'Test Employee',
            Syntilio__ExternalUpdatedAt__c = Datetime.now()
        );
        addAdditionalFields(newMedicalNote, additionalFields);
        return newMedicalNote;
    }
    
    @NamespaceAccessible
    public static Syntilio__MedicalPolicy__c createMedicalPolicy(Map<String, Object> additionalFields){
        Syntilio__MedicalPolicy__c newMedicalPolicy = new Syntilio__MedicalPolicy__c(
            Name = 'Test Medical Policy',
            Syntilio__MostRecent__c = false,
            Syntilio__Narrative__c = 'Test Narrative',
            Syntilio__ResuscitationDecision__c = 'Resuscitate',
            Syntilio__Status__c = 'Test Status'
        );
        addAdditionalFields(newMedicalPolicy, additionalFields);
        return newMedicalPolicy;
    }
    /*
    @NamespaceAccessible
    public static OperatingHours createOperatingHours(Map<String, Object> additionalFields){
        OperatingHours newOperatingHours = new OperatingHours(
            Name = 'careTeamOperatingHours',
        	Syntilio__StartDate__c = Date.today().addYears(-1),
        	Syntilio__EndDate__c = Date.today().addYears(1),
        	TimeZone = 'Europe/Amsterdam'
        );
        addAdditionalFields(newOperatingHours, additionalFields);
        return newOperatingHours;
    }
    */
    @NamespaceAccessible
    public static Order createOrder(Map<String, Object> additionalFields){
        Order newOrder = new Order(
            Name = 'Test Order',
            Syntilio__ActivationReminder__c = 0,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        addAdditionalFields(newOrder, additionalFields);
        return newOrder;
    }
    
    @NamespaceAccessible
    public static OrderItem createOrderItem(Map<String, Object> additionalFields){
        OrderItem newOrderItem = new OrderItem(
            ListPrice = 100,
            UnitPrice = 100,
            Quantity = 1,
            ServiceDate = Date.today()
        );
        addAdditionalFields(newOrderItem, additionalFields);
        return newOrderItem;
    }
    
    @NamespaceAccessible
    public static Syntilio__PostalCodeInfo__c createPostalCodeInfo(Map<String, Object> additionalFields) {
        Syntilio__PostalCodeInfo__c newPostalCodeInfo = new Syntilio__PostalCodeInfo__c(
            Name = '3066',
            Syntilio__CountryCode__c = 'NL',
            Syntilio__State__c = 'Zuid-Holland',
            Syntilio__City__c = 'Rotterdam'
        );
        addAdditionalFields(newPostalCodeInfo, additionalFields);
        return newPostalCodeInfo;
    }
    
    @NamespaceAccessible
    public static Pricebook2 createPriceBook2(Map<String, Object> additionalFields) {
        Pricebook2 newPriceBook2 = new Pricebook2(
            Name = 'Test Pricebook'
        );
        addAdditionalFields(newPriceBook2, additionalFields);
        return newPriceBook2;
    }
    
    @NamespaceAccessible
    public static PricebookEntry createPriceBookEntry(Map<String, Object> additionalFields) {
        PricebookEntry newPriceBookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            IsActive = true,
            UnitPrice = 500
        );
        addAdditionalFields(newPriceBookEntry, additionalFields);
        return newPriceBookEntry;
    }
    
    @NamespaceAccessible
    public static Product2 createProduct2(Map<String, Object> additionalFields){
        Product2 newProduct2 = new Product2(
            Name = 'Test Product',
            IsActive = true,
            ProductCode = '0001',
            Family = 'Telemonitoring',
            Syntilio__Supplier__c = 'AppSupplier',
            Syntilio__Minutes__c = 1,
            Syntilio__AddOns__c = null,
            Syntilio__IsSubscription__c = true
        );
        addAdditionalFields(newProduct2, additionalFields);
        return newProduct2;
    }
    
    @NamespaceAccessible
    public static Syntilio__Protocol__c createProtocol(Map<String, Object> additionalFields){
        Syntilio__Protocol__c newProtocol = new Syntilio__Protocol__c(
    		Name = 'Test Protocol',
            Syntilio__JSON__c = '{}',
            Syntilio__Description__c = 'Test Description',
			Syntilio__EstimatedTime__c = 3 
        );
        addAdditionalFields(newProtocol, additionalFields);
        return newProtocol;
    }
    /*
    @NamespaceAccessible
    public static Syntilio__ProtocolAction__c createProtocolAction(Map<String, Object> additionalFields){
        Syntilio__ProtocolAction__c newProtocolAction = new Syntilio__ProtocolAction__c(
            Name = 'Test Protocol Action',
            Syntilio__TypeApiName__c = 'Test Protocol Action Api Name'
        );
        addAdditionalFields(newProtocolAction, additionalFields);
        return newProtocolAction;
    }

    @NamespaceAccessible
    public static Syntilio__ProtocolActionRelation__c createProtocolActionRelation(Map<String, Object> additionalFields){
        Syntilio__ProtocolActionRelation__c newProtocolActionRelation = new Syntilio__ProtocolActionRelation__c();
        addAdditionalFields(newProtocolActionRelation, additionalFields);
        return newProtocolActionRelation;
    }
    */
    @NamespaceAccessible
    public static Syntilio__ProtocolActivator__c createProtocolActivator(Map<String, Object> additionalFields){
        Syntilio__ProtocolActivator__c newProtocolActivator = new Syntilio__ProtocolActivator__c(
            Syntilio__Active__c = true,
            Syntilio__Global__c = false
        );
        addAdditionalFields(newProtocolActivator, additionalFields);
        return newProtocolActivator;
    }
    
    @NamespaceAccessible
    public static Syntilio__ProtocolPage__c createProtocolPage(Map<String, Object> additionalFields){
        Syntilio__ProtocolPage__c newProtocolPage = new Syntilio__ProtocolPage__c(
    		Name = 'Test Protocol Page',
            Syntilio__Title__c = 'Test Protocol Page',
            Syntilio__JSON__c = '{}'
        );
        addAdditionalFields(newProtocolPage, additionalFields);
        return newProtocolPage;
    }
    
    @NamespaceAccessible
    public static Syntilio__ProtocolPageQuestion__c createProtocolPageQuestion(Map<String, Object> additionalFields){
        Syntilio__ProtocolPageQuestion__c newProtocolPageQuestion = new Syntilio__ProtocolPageQuestion__c(
    		Name = 'Test Protocol Page Question',
            Syntilio__Required__c = true,
            Syntilio__JSON__c = '{}'
        );
        addAdditionalFields(newProtocolPageQuestion, additionalFields);
        return newProtocolPageQuestion;
    }
    
    @NamespaceAccessible
    public static Syntilio__ProtocolPageQuestionResult__c createProtocolPageQuestionResult(Map<String, Object> additionalFields){
        Syntilio__ProtocolPageQuestionResult__c newProtocolPageQuestionResult = new Syntilio__ProtocolPageQuestionResult__c(
    		Name = 'Test Protocol Page Question Result',
            Syntilio__Answer__c = 'test answer'
        );
        addAdditionalFields(newProtocolPageQuestionResult, additionalFields);
        return newProtocolPageQuestionResult;
    }
    
    @NamespaceAccessible
    public static Syntilio__ProtocolResult__c createProtocolResult(Map<String, Object> additionalFields){
        Syntilio__ProtocolResult__c newProtocolResult = new Syntilio__ProtocolResult__c();
        addAdditionalFields(newProtocolResult, additionalFields);
        return newProtocolResult;
    }
    
    @NamespaceAccessible
    public static Syntilio__Question__c createQuestion(Map<String, Object> additionalFields){
        Syntilio__Question__c newQuestion = new Syntilio__Question__c(
            Name = 'TestQuestion',
            Syntilio__Title__c = 'Test Question',
            Syntilio__JSON__c = '{}',
            Syntilio__QuestionType__c = 'text'
        );
        addAdditionalFields(newQuestion, additionalFields);
        return newQuestion;
    }
    /*
    @NamespaceAccessible
    public static Syntilio__Questionnaire__c createQuestionnaire(Map<String, Object> additionalFields){
        Syntilio__Questionnaire__c newQuestionnaire = new Syntilio__Questionnaire__c(
            Name = 'Test Questionnaire',
            Syntilio__Active__c = true
        );
        addAdditionalFields(newQuestionnaire, additionalFields);
        return newQuestionnaire;
    }

    @NamespaceAccessible
    public static Syntilio__QuestionnaireQuestion__c createQuestionnaireQuestion(Map<String, Object> additionalFields){
        Syntilio__QuestionnaireQuestion__c newQuestionnaireQuestion = new Syntilio__QuestionnaireQuestion__c();
        addAdditionalFields(newQuestionnaireQuestion, additionalFields);
        return newQuestionnaireQuestion;
    }
    */
    @NamespaceAccessible
    public static Syntilio__MedicalReport__c createReport(Map<String, Object> additionalFields){
        Syntilio__MedicalReport__c newReport = new Syntilio__MedicalReport__c(
            Name = 'TestQuestion',
            Syntilio__Comments__c = 'Test Comments',
            Syntilio__Author__c = 'Test Employee',
            Syntilio__AuthorRole__c = 'Test Employee Role',
            Syntilio__ExternalUpdatedAt__c = Datetime.now()
        );
        addAdditionalFields(newReport, additionalFields);
        return newReport;
    }
    
    @NamespaceAccessible
    public static Syntilio__ServiceZipCode__c createServiceZipCode(Map<String, Object> additionalFields){
        Syntilio__ServiceZipCode__c newServiceZipCode = new Syntilio__ServiceZipCode__c(
            Name = 'Test Service Zip Code',
            Syntilio__ZipCode__c = '11234'
        );
        addAdditionalFields(newServiceZipCode, additionalFields);
        return newServiceZipCode;
    }
    
    @NamespaceAccessible
    public static Syntilio__SyntilioEvent__c createSyntilioEvent(Map<String, Object> additionalFields){
        Syntilio__SyntilioEvent__c newSyntilioEvent = new Syntilio__SyntilioEvent__c(
            Name = 'Test Syntilio Event',
            Syntilio__Category__c = 'Medical',
            Syntilio__EventCode__c = 12312,
            Syntilio__Priority__c = 'High',
            Syntilio__TimeStamp__c = Datetime.now()
        );
        addAdditionalFields(newSyntilioEvent, additionalFields);
        return newSyntilioEvent;
    }
    
    @NamespaceAccessible
    public static Syntilio__SyntilioPlatformEvent__e createSyntilioPlatformEvent(Map<String, Object> additionalFields){
        Syntilio__SyntilioPlatformEvent__e newSyntilioPlatformEvent = new Syntilio__SyntilioPlatformEvent__e(
            Syntilio__AssetId__c = '',
            Syntilio__SubAssetId__c = '', 
            Syntilio__AssetDescription__c ='', 
            Syntilio__SupplierEventCode__c = null, 
            Syntilio__SubAssetIndex__c = null, 
            Syntilio__Product__c = '', 
            Syntilio__EventId__c = '0001',
            Syntilio__TimeStamp__c = Datetime.now()
        );
        addAdditionalFields(newSyntilioPlatformEvent, additionalFields);
        return newSyntilioPlatformEvent;
    }

    @NamespaceAccessible
    public static User createUser(Map<String, Object> additionalFields){
        User newUser = new User(
            Username = 'testuser_' + DateTime.now().getTime() + '@example.com',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            LastName = 'TestUser',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        addAdditionalFields(newUser, additionalFields);
        return newUser;
    }
}