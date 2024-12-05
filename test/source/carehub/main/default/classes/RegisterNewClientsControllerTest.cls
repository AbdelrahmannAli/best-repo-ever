@isTest
public with sharing class RegisterNewClientsControllerTest {
    
    private static Contact getContact() {
        return [SELECT Id FROM Contact LIMIT 1];
    }
    
    private static Account getAccount() {
        return [SELECT Id FROM Account LIMIT 1];
    }
    
    private static Syntilio__ExternalSystem__c getExternalSystem() {
        return [SELECT Syntilio__ApiName__c FROM Syntilio__ExternalSystem__c LIMIT 1];
    }
    
	private static void registerNewClientsControllerSetupData() {
        Account account = Syntilio.CareHubTestDataFactory.createAccount(
            new Map<String, Object>{
            	'Name' => 'Test',
                'Syntilio__ApiName__c' => 'Twb'
            }
        );
        
        Syntilio__ExternalSystem__c externalSystem = Syntilio.DataHubTestDataFactory.createExternalSystem(
            new Map<String, Object>{
            	'Name' => 'Ons',
                'Syntilio__ApiName__c' => 'Ons'
         	}
        );
        insert new List<SObject>{account, externalSystem};
            
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
            	'AccountId' => account.Id,
                'LastName' => 'Test Contact'
            }
        );
        insert testContact;
    }
    
    private static void insertExternalIdForRegisterClient(Id contactId, Id externalSystemId) {
        insert Syntilio.DataHubTestDataFactory.createExternalId(
            new Map<String, Object>{
            	'Name' => 'clientId',
                'Syntilio__Id__c' => '3',
                'Syntilio__ContactId__c' => contactId,
                'Syntilio__ExternalSystemId__c' => externalSystemId
            }
        );
    }
    
    private static void linkAccountToExternalSystemAndLocation(Id accountId, Id externalSystemId) {
        Syntilio__AccountExternalSystemAssociation__c association = Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation(
            new Map<String, Object>{
            	'Syntilio__AccountId__c' => accountId,
                'Syntilio__ExternalSystemId__c' => externalSystemId
            }
        );
        
        Schema.Location location = Syntilio.CareHubTestDataFactory.createLocation(
            new Map<String, Object>{
            	'Syntilio__AccountId__c' => accountId,
                'Syntilio__ExternalSystemId__c' => externalSystemId
            }
        );
        insert new List<SObject>{association, location};
    }

    private static String mapResponse = '{"Twb_Ons": [{"contact":{"FirstName":"Luke (vn)","LastName":"Semburg","Birthdate":"2020-11-07","GenderIdentity":"Male"},"externalIds":[{"Syntilio__Id__c":3,"Name":"clientId"}],"locations":[{"Name":"TEST team 1 30","Syntilio__LocationId__c":"77777777"},{"Name":"TEST team 2","Syntilio__LocationId__c":"77777778"},{"Name":"NIZ","Syntilio__LocationId__c":"90909090"},{"Name":"ODC Trampoline team 1","Syntilio__LocationId__c":"14140301"},{"Name":"Zuivelstraat Veenendaal team 1","Syntilio__LocationId__c":"13105801"},{"Name":"Land van Belofte","Syntilio__LocationId__c":"13121101"},{"Name":"Eikenlaan","Syntilio__LocationId__c":"13142001"},{"Name":"Huize uit de kunst team 1","Syntilio__LocationId__c":"13152301"},{"Name":"Kleine Hakke","Syntilio__LocationId__c":"13170401"},{"Name":"Achtergracht","Syntilio__LocationId__c":"13173701"},{"Name":"Digicontact Begeleiders","Syntilio__LocationId__c":"41200101"}]}]}';
    private static String listResponse = '[{"contact":{"FirstName":"Luke (vn)","LastName":"Semburg","Birthdate":"2020-11-07","GenderIdentity":"Male"},"externalIds":[{"Syntilio__Id__c":3,"Name":"clientId"}],"locations":[{"Name":"TEST team 1 30","Syntilio__LocationId__c":"77777777"},{"Name":"TEST team 2","Syntilio__LocationId__c":"77777778"},{"Name":"NIZ","Syntilio__LocationId__c":"90909090"},{"Name":"ODC Trampoline team 1","Syntilio__LocationId__c":"14140301"},{"Name":"Zuivelstraat Veenendaal team 1","Syntilio__LocationId__c":"13105801"},{"Name":"Land van Belofte","Syntilio__LocationId__c":"13121101"},{"Name":"Eikenlaan","Syntilio__LocationId__c":"13142001"},{"Name":"Huize uit de kunst team 1","Syntilio__LocationId__c":"13152301"},{"Name":"Kleine Hakke","Syntilio__LocationId__c":"13170401"},{"Name":"Achtergracht","Syntilio__LocationId__c":"13173701"},{"Name":"Digicontact Begeleiders","Syntilio__LocationId__c":"41200101"}]}]';

    @testSetup
    static void setup() {
        registerNewClientsControllerSetupData();
    }

    @isTest
    static void checkClientTestExistence_Exists() {
        Account account = getAccount();
        Contact contact = getContact();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();
        insertExternalIdForRegisterClient(contact.Id, externalSystem.Id);
        
        Test.startTest();
        Boolean result = Syntilio.RegisterNewClientsController.checkClientExistence('3', account.Id, externalSystem.Syntilio__ApiName__c);
        Test.stopTest();
        
        System.assertEquals(true, result);
    }

    @isTest
    static void checkClientExistenceTest_DoesNotExist() {
        Account account = getAccount();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();
        
        Test.startTest();
        Boolean result = RegisterNewClientsController.checkClientExistence('1', account.Id, externalSystem.Syntilio__ApiName__c);
        Test.stopTest();
        
        System.assertEquals(false, result);
    }

    @isTest
    static void fetchClientTest_EmptyResponse() {
        Account account = getAccount();
        Test.setMock(HttpCalloutMock.class, new Syntilio.MockRegisterNewClientResponse('GET', 200, '[]'));
        
        Test.startTest();
        ResponseMessage result = Syntilio.RegisterNewClientsController.fetchClient('3', account.Id, 'Fierit');
        Test.stopTest();
        
        System.assertEquals(false, result.isSuccess);
        System.assertEquals('Error while fetching client', result.message);
	}

    @isTest
    static void fetchClientTest_Failure() {
        Account account = getAccount();
        Test.setMock(HttpCalloutMock.class, new Syntilio.MockRegisterNewClientResponse('GET', 400, '[]'));

        Test.startTest();
        ResponseMessage result = Syntilio.RegisterNewClientsController.fetchClient('3', account.Id, 'Fierit');
        Test.stopTest();
        
        System.assertEquals(false, result.isSuccess);
        System.assertEquals('Error while fetching client', result.message);
    }

    @isTest
    static void fetchClientTest_NotFoundOnECD() {
        Account account = getAccount();
        Test.setMock(HttpCalloutMock.class, new Syntilio.MockRegisterNewClientResponse('GET', 200, '{"Twb_Ons": []}'));
        
        Test.startTest();
        ResponseMessage result = Syntilio.RegisterNewClientsController.fetchClient('3', account.Id, 'Ons');
        Test.stopTest();
        
        List<Syntilio.FetchClientModel> resultList = (List<Syntilio.FetchClientModel>) result.data;
        System.assertEquals(false, result.isSuccess);
        System.assertEquals('No client found with the given id', result.message);
    }
    
    @isTest
    static void fetchClientTest_Found() {
        Account account = getAccount();
        Test.setMock(HttpCalloutMock.class, new Syntilio.MockRegisterNewClientResponse('GET', 200, '{"Twb_Ons": [{"Name": "Test"}]}'));
        
        Test.startTest();
        ResponseMessage result = Syntilio.RegisterNewClientsController.fetchClient('3', account.Id, 'Ons');
        Test.stopTest();
        
        List<Syntilio.FetchClientModel> resultList = (List<Syntilio.FetchClientModel>) result.data;
        System.assertEquals(true, result.isSuccess);
        System.assertEquals('Client fetched successfully', result.message);
    }

    @isTest
    static void getClientInfoTest_ClientNotExistsInSF() {
        Test.setMock(HttpCalloutMock.class, new MockRegisterNewClientResponse('GET', 200, mapResponse));
        Account account = getAccount();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();
        List<Object> responseBodyList = (List<Object>) JSON.deserializeUntyped(listResponse);
        List<FetchClientModel> fetchClientModelList = (List<FetchClientModel>) JSON.deserialize(JSON.serialize(responseBodyList), List<FetchClientModel>.class);
            
        Test.startTest();
        String result = Syntilio.RegisterNewClientsController.getClientInfo('3', account.Id, externalSystem.Syntilio__ApiName__c);
        Test.stopTest();
        
        ResponseMessage responseMessage = (ResponseMessage) Syntilio.ResponseMessage.deserialize(result);
        String responseMessageStringParsed = (String) responseMessage.data;
        Syntilio.FetchClientModel fetchClientModel = (Syntilio.FetchClientModel) JSON.deserialize(responseMessageStringParsed, Syntilio.FetchClientModel.class);

        System.assertEquals(fetchClientModelList[0].contact.FirstName, fetchClientModel.contact.FirstName);
        System.assertEquals(fetchClientModelList[0].contact.LastName, fetchClientModel.contact.LastName);
        System.assertEquals(fetchClientModelList[0].contact.Birthdate, fetchClientModel.contact.Birthdate);
        System.assertEquals(fetchClientModelList[0].contact.GenderIdentity, fetchClientModel.contact.GenderIdentity);
    }

    @isTest
    static void getClientInfoTest_ClientEmptyResponse() {
        Test.setMock(HttpCalloutMock.class, new MockRegisterNewClientResponse('GET', 200, '{"Twb_Ons":[]}'));
        
        Account account = getAccount();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();

        Test.startTest();
        String result = Syntilio.RegisterNewClientsController.getClientInfo('3', account.Id, externalSystem.Syntilio__ApiName__c);
        Test.stopTest();
        
        ResponseMessage responseMessage = (ResponseMessage) Syntilio.ResponseMessage.deserialize(result);
        ResponseMessage exceptedResponse = new ResponseMessage(
            null,
            'No client found with the given id',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
        
        System.assertEquals(exceptedResponse.data, responseMessage.data);
        System.assertEquals(exceptedResponse.message, responseMessage.message);
        System.assertEquals(exceptedResponse.type, responseMessage.type);

    }

    @isTest
    static void getClientInfoTest_ClientFailure() {
        Test.setMock(HttpCalloutMock.class, new MockRegisterNewClientResponse('GET', 400, 'Bad Request'));

        Account account = getAccount();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();
        
        Test.startTest();
        String result = RegisterNewClientsController.getClientInfo('3', account.Id, externalSystem.Syntilio__ApiName__c);
        Test.stopTest();
        
        ResponseMessage responseMessage = (ResponseMessage) Syntilio.ResponseMessage.deserialize(result);
        System.assertEquals('Error while fetching client', responseMessage.message);        
    }

    @isTest
    static void getClientInfoTest_ClientExistsInSF() {
        Test.setMock(HttpCalloutMock.class, new MockRegisterNewClientResponse('GET', 200, mapResponse));
        Account account = getAccount();
        Contact contact = getContact();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();
        insertExternalIdForRegisterClient(contact.Id, externalSystem.Id);
        
        Test.startTest();
        String result = RegisterNewClientsController.getClientInfo('3', account.Id, externalSystem.Syntilio__ApiName__c);
        Test.stopTest();
        
        ResponseMessage responseMessage = (ResponseMessage) Syntilio.ResponseMessage.deserialize(result);
        ResponseMessage exceptionMessage = new ResponseMessage(
            '',
            'Client already exists',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
        System.assertEquals(exceptionMessage.data, responseMessage.data);
        System.assertEquals(exceptionMessage.message, responseMessage.message);
        System.assertEquals(exceptionMessage.type, responseMessage.type);
    }

    @isTest
    static void createContactTest_Success() {
        Account testAccount = getAccount();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();
        linkAccountToExternalSystemAndLocation(testAccount.Id, externalSystem.Id);
        List<Object> responseBodyList = (List<Object>) JSON.deserializeUntyped(listResponse);
        String firstElement = JSON.serialize(responseBodyList[0]);
        Test.startTest();
        String result = Syntilio.RegisterNewClientsController.createContact(firstElement, externalSystem.Syntilio__ApiName__c, testAccount.Id);
        Test.stopTest();
        
        ResponseMessage responseMessage = (ResponseMessage) Syntilio.ResponseMessage.deserialize(result);
        ResponseMessage exceptionMessage = new ResponseMessage(
            '',
            'Client created successfully',
            Syntilio.ResponseMessage.MessageType.SUCCESS
        );
        System.assertEquals(exceptionMessage.data, responseMessage.data);
        System.assertEquals(exceptionMessage.message, responseMessage.message);
        System.assertEquals(exceptionMessage.type, responseMessage.type);
    }

    @isTest
    static void createContactTest_Failure() {
        Account testAccount = getAccount();
        Syntilio__ExternalSystem__c externalSystem = getExternalSystem();
        List<Object> responseBodyList = (List<Object>) JSON.deserializeUntyped(listResponse);
        String firstElement = JSON.serialize(responseBodyList[0]);
        Test.startTest();
        String result = Syntilio.RegisterNewClientsController.createContact(firstElement, externalSystem.Syntilio__ApiName__c, testAccount.Id);
        Test.stopTest();
        
        ResponseMessage responseMessage = (ResponseMessage) Syntilio.ResponseMessage.deserialize(result);
        ResponseMessage exceptionMessage = new ResponseMessage(
            '',
            'Error while creating client',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
        // System.assertEquals(exceptionMessage.data, responseMessage.data);
        // System.assertEquals(exceptionMessage.message, responseMessage.message);
        // System.assertEquals(exceptionMessage.type, responseMessage.type);
    }

    @isTest
    static void createContactTest_WithEmptyParams() {
        Test.startTest();
        String result = Syntilio.RegisterNewClientsController.createContact(null, null, null);
        Test.stopTest();
        
        ResponseMessage responseMessage = (ResponseMessage) Syntilio.ResponseMessage.deserialize(result);
        ResponseMessage exceptionMessage = new ResponseMessage(
            '',
            'Client is required',
            Syntilio.ResponseMessage.MessageType.ERROR
        );
        System.assertEquals(exceptionMessage.data, responseMessage.data);
        System.assertEquals(exceptionMessage.message, responseMessage.message);
        System.assertEquals(exceptionMessage.type, responseMessage.type);
    }
}