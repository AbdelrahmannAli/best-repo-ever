@isTest
public with sharing class PostalCodeInfoHandlerTest {
    
    private static Contact getContact() {
        return [SELECT MailingCountry, Syntilio__PostalCodeInfo__c FROM Contact LIMIT 1];
    }
    
    private static Syntilio__PostalCodeInfo__c getPostalCodeInfo() {
        return [SELECT Id FROM Syntilio__PostalCodeInfo__c LIMIT 1];
    }
	
    @testSetup
    public static void setup() {
        Syntilio__PostalCodeInfo__c newPostalCodeInfo = Syntilio.CareHubTestDataFactory.createPostalCodeInfo(null);
        insert newPostalCodeInfo;
    }
    
    @isTest
    public static void getPostalCodeInfoTest() {
        List<String> postalCodes = new List<String>{'3066'};
        
        Test.startTest();
        Map<String, Syntilio__PostalCodeInfo__c> postalCodesMap = Syntilio.PostalCodeInfoHandler.getPostalCodeInfo(postalCodes);
        Test.stopTest();
        
        System.assert(postalCodesMap.keySet().size() > 0);
        System.assertNotEquals(null, postalCodesMap.get('NL 3066'));
    }
    
    @isTest
    public static void syncPostalCodesTest() {
        Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout(
            'GET', 'postalcodeinfo', '?country=NL&codes=3067', 
            '{"ZipCodeStack": [{"code": "3067", "countryCode": "NL", "city": "Amsterdam", "state": "Zuid-Holland"}]}'));
        
        Map<String, Set<String>> countryCodeToPostalCodes = new Map<String, Set<String>>{'NL' => new Set<String>{'3067'}};
        Map<String, Syntilio__PostalCodeInfo__c> postalCodesMap = new Map<String, Syntilio__PostalCodeInfo__c>();
            
        Test.startTest();
        Syntilio.PostalCodeInfoHandler.syncPostalCodes(countryCodeToPostalCodes, postalCodesMap);
        Test.stopTest();
		
        List<Syntilio__PostalCodeInfo__c> postalCodesAfter = [SELECT Name FROM Syntilio__PostalCodeInfo__c];
        System.assertEquals(2, postalCodesAfter.size());
        System.assertEquals('3066', postalCodesAfter[0].Name);
        System.assertEquals('3067', postalCodesAfter[1].Name);
    }
    
    @isTest
    public static void handlePostalCodesTest_PostalCodeInfoAlreadyExists() {
        Syntilio__PostalCodeInfo__c postalCodeInfo = getPostalCodeInfo();
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3066', 'MailingCountry' => 'Netherlands'}
        );
        insert contact;
        
        String contactIdsSerialized = JSON.serialize(new List<String>{contact.Id}); 
        String countryLabelToCodeSerialized = '{"Netherlands": "NL"}';
        
        Test.startTest();
        Syntilio.PostalCodeInfoHandler.handlePostalCodes(contactIdsSerialized, countryLabelToCodeSerialized);
        Test.stopTest();
        
        Contact contactAfter = getContact();
        System.assertEquals(postalCodeInfo.Id, contactAfter.Syntilio__PostalCodeInfo__c);
    }
    
    @isTest
    public static void handlePostalCodesTest_PostalCodeInfoDoesNotExist() {
        Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout(
            'GET', 'postalcodeinfo', '?country=NL&codes=3067', 
            '{"ZipCodeStack": [{"code": "3067", "countryCode": "NL", "city": "Amsterdam", "state": "Zuid-Holland"}]}'));
        
        Syntilio__PostalCodeInfo__c postalCodeInfo = getPostalCodeInfo();
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3067', 'MailingCountry' => 'Netherlands'}
        );
        insert contact;
        
        String contactIdsSerialized = JSON.serialize(new List<String>{contact.Id}); 
        String countryLabelToCodeSerialized = '{"Netherlands": "NL"}';
        
        Test.startTest();
        Syntilio.PostalCodeInfoHandler.handlePostalCodes(contactIdsSerialized, countryLabelToCodeSerialized);
        Test.stopTest();
        
        Contact contactAfter = getContact();
        List<Syntilio__PostalCodeInfo__c> postalCodesAfter = [SELECT Name FROM Syntilio__PostalCodeInfo__c];
        System.assertEquals(2, postalCodesAfter.size());
        System.assertEquals('3066', postalCodesAfter[0].Name);
        System.assertEquals('3067', postalCodesAfter[1].Name);
        System.assertEquals(postalCodesAfter[1].Id, contactAfter.Syntilio__PostalCodeInfo__c);
    }
    
    @isTest
    public static void handleContactInsertTest_CountryOrPostalCodeNull() {
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3067', 'MailingCountry' => null}
        );
        
        Test.startTest();
        Database.SaveResult saveResult = Database.insert(contact, false);
        Test.stopTest();        
        
        System.assertEquals(true, saveResult.isSuccess());
    }
    
    @isTest
    public static void handleContactInsertTest_CountryNotFound() {
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3067', 'MailingCountry' => 'some country'}
        );
        
        Test.startTest();
        Database.SaveResult saveResult = Database.insert(contact, false);
        Test.stopTest();        
        
        Contact contactAfter = getContact();
        System.assertEquals(true, saveResult.isSuccess());
        System.assertEquals(null, contactAfter.Syntilio__PostalCodeInfo__c);
    }
    
    @isTest
    public static void handleContactInsertTest() {
        Syntilio__PostalCodeInfo__c postalCodeInfo = getPostalCodeInfo();
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3066', 'MailingCountry' => 'Nederland'}
        );
        
        Test.startTest();
        Database.SaveResult saveResult = Database.insert(contact, false);
        Test.stopTest();        
        
        Contact contactAfter = getContact();
        System.assertEquals(true, saveResult.isSuccess());
    }
    
    @isTest
    public static void handleContactUpdateTest_NoUpdateInCountryAndPostalCode() {
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3066', 'MailingCountry' => 'Nederland'}
        );
        insert contact;
        
        Test.startTest();
        contact.LastName = 'test';
        Database.SaveResult saveResult = Database.update(contact, false);
        Test.stopTest();        
        
        System.assertEquals(true, saveResult.isSuccess());
    }

    @isTest
    public static void handleContactUpdateTest_CountryOrPostalCodeNull() {
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => null, 'MailingCountry' => 'Nederland'}
        );
        insert contact;
        
        Test.startTest();
        contact.MailingCountry = null;
        Database.SaveResult saveResult = Database.update(contact, false);
        Test.stopTest();        
        
        System.assertEquals(true, saveResult.isSuccess());
    }

    @isTest
    public static void handleContactUpdateTest_CountryNotFound() {
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3066', 'MailingCountry' => null}
        );
        insert contact;
        
        Test.startTest();
        contact.MailingCountry = 'Neterlands';
        Database.SaveResult saveResult = Database.update(contact, false);
        Test.stopTest();        
        
        System.assertEquals(true, saveResult.isSuccess());
    }
    
    @isTest
    public static void handleContactUpdateTest() {
        Syntilio__PostalCodeInfo__c postalCodeInfo = getPostalCodeInfo();
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'MailingPostalCode' => '3066', 'MailingCountry' => null}
        );
        insert contact;
        
        Test.startTest();
        contact.MailingCountry = 'Nederland';
        Database.SaveResult saveResult = Database.update(contact, false);
        Test.stopTest();        
        
        Contact contactAfter = getContact();
        System.assertEquals(true, saveResult.isSuccess());
    }
}