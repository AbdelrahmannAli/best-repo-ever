@IsTest
public class GetCaseContactTest {
    @TestSetup
    static void setup() {
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Phone = '1234567890',
            HomePhone = '0987654321',
            Birthdate = Date.newInstance(1990, 1, 1),
            Email = 'johndoe@example.com',
            MailingStreet = '123 Main St',
            MailingCity = 'Springfield',
            MailingState = 'IL',
            MailingPostalCode = '62701',
            MailingCountry = 'USA'
        );
        insert testContact;
 
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            ContactId = testContact.Id
        );
        insert testCase;
 
        Case testCaseNoContact = new Case(
            Subject = 'Case Without Contact',
            Status = 'New'
        );
        insert testCaseNoContact;
 
        Syntilio__ExternalSystem__c externalSystemRecord = new Syntilio__ExternalSystem__c(
            Name = 'External System',
            Syntilio__ApiName__c = 'ES'
        );
        insert externalSystemRecord;
 
        Syntilio__ExternalId__c externalId = new Syntilio__ExternalId__c(
            Name = 'identificationNo',
            Syntilio__Id__c = '1',
            Syntilio__ContactId__c = testContact.Id,
            Syntilio__ExternalSystemId__c = externalSystemRecord.Id
        );
        insert externalId;
    }
 
    @IsTest
    static void testGetContactDataSuccess() {
        Case testCase = [SELECT Id FROM Case WHERE ContactId != null LIMIT 1];
 
        Contact result = GetCaseContact.getContactData(testCase.Id);
 
        System.assertNotEquals(null, result, 'The contact should not be null.');
        System.assertEquals('John Doe', result.Name, 'The contact name should match.');
        System.assertEquals('1', result.Syntilio__UserId__c, 'The contact Id should match.');
    }
 
    @IsTest
    static void testGetContactDataNoContact() {
        Case testCaseNoContact = [SELECT Id FROM Case WHERE ContactId = null LIMIT 1];
        Contact result = GetCaseContact.getContactData(testCaseNoContact.Id);
 
        System.assertEquals(null, result, 'Expected null when no contact is linked to the case.');
    }
 
    @IsTest
    static void testGetContactDataInvalidCaseId() {
        Contact result = GetCaseContact.getContactData('InvalidCaseId');
 
        System.assertEquals(null, result, 'Expected null when an invalid case ID is provided.');
    }
 
    @IsTest
    static void testGetContactDataNoExternalId() {
        Case testCase = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];
 
        delete [SELECT Id FROM Syntilio__ExternalId__c WHERE Syntilio__ContactId__c = :testCase.ContactId];
 
        Contact result = GetCaseContact.getContactData(testCase.Id);
 
        System.assertNotEquals(null, result, 'The contact should not be null.');
        System.assertEquals(null, result.Syntilio__UserId__c, 'The Syntilio User ID should be null when no external ID exists.');
    }
}