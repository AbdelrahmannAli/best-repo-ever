@isTest
public with sharing class UpsertToDatabaseTest {

    
    private static List<Contact> createContactRecordsWithoutInsertion (Integer numberOfContactsToBeCreated) {
        List<Contact> contactRecordsList = new List<Contact>();
        for (Integer i = 0; i < numberOfContactsToBeCreated; i++) {
            Contact patientContactJohan = new Contact(
                Salutation = 'Mr.',
                Title = 'Patient',
                FirstName = 'Jan',
                LastName = 'Willem' + String.valueOf(i),
                Phone = '+31-342424242' + String.valueOf(i),
                HomePhone = '+31-342424242' + String.valueOf(i),
                MailingStreet = 'Street'+ String.valueOf(i+1),
                MailingCity = 'Amsterdam',
                MailingState = 'Noord Holland',
                MailingPostalCode = '893' + String.valueOf(i),
                MailingCountry = 'Nederland',
                Birthdate = Date.newInstance(1988, 07, 15),
                Email = 'jan@nl.com'
            );
            contactRecordsList.add(patientContactJohan);
        }
        return contactRecordsList;
    }  
    

    @isTest
    public static void insertAction_Should_InsertContact_Test() {
		List<Database.SaveResult> databaseResultList;
        try{
            List<Contact> contactRecordsList = createContactRecordsWithoutInsertion(1);
            
            Test.startTest();
	        databaseResultList = Syntilio.UpsertToDatabase.insertAction(contactRecordsList, false);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
       	List<Contact> contactListAfterCreation = [SELECT Id FROM Contact];
        system.assertEquals(1, contactListAfterCreation.size());
        system.assertEquals(true, databaseResultList[0].isSuccess());
    }
    
    @isTest
    public static void insertAction_Should_LogException_Test() {
        try{
            List<Contact> contactRecordsList = null;

            Test.startTest();
	        Syntilio.UpsertToDatabase.insertAction(contactRecordsList, false);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }

        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertEquals(0, exceptionList.size());
    }
    
    @isTest
    public static void insertAction_Should_ReturnErrorMessage_Test() {
		List<Database.SaveResult> databaseResultList;
        Map<Boolean, List<Object>> dmlActionStatus;
        try{
            Contact individualContact = new Contact(
	            FirstName = 'Jansen'
            );            
            List<Contact> contactRecordsList = new List<Contact>();
            contactRecordsList.add(individualContact);

            Test.startTest();
	        databaseResultList = Syntilio.UpsertToDatabase.insertAction(contactRecordsList, false);
            dmlActionStatus = Syntilio.UpsertToDatabase.getDmlActionStatus(databaseResultList, null);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(false, databaseResultList[0].isSuccess());
        system.assertEquals(true, dmlActionStatus.containsKey(false));
    }
    
    @isTest
    public static void updateAction_Should_UpdateContact_Test() {
		List<Database.SaveResult> databaseResultList;
        try{
            
            // List<Contact> contactRecordsList = Syntilio.DataHubTestDataFactory.createContactRecordsWithoutAccountRelation(1);
            Contact contactToInsert = Syntilio.DataHubTestDataFactory.createContact(null);
            
            List<Contact> contactRecordsList = new List<Contact>();
            contactRecordsList.add(contactToInsert);
            insert contactRecordsList;

            Test.startTest();
        	contactRecordsList[0].FirstName = 'Karel';
	        databaseResultList = Syntilio.UpsertToDatabase.updateAction(contactRecordsList, false);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
       	List<Contact> contactAfterUpdate = [SELECT Id, FirstName, LastName FROM Contact LIMIT 1];
        system.assertEquals(true, databaseResultList[0].isSuccess());
        system.assertEquals('Karel', contactAfterUpdate[0].FirstName);
    }
    
    @isTest
    public static void updateAction_Should_LogException_Test() {
        try{
            List<Contact> contactRecordsList = null;

            Test.startTest();
	        Syntilio.UpsertToDatabase.updateAction(contactRecordsList, false);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }

        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertEquals(0, exceptionList.size());
    }
    @isTest
    public static void updateAction_Should_ReturnErrorMessage_Test() {
		List<Database.SaveResult> databaseResultList;
        try{
            Contact individualContact = new Contact(
	            FirstName = 'Jansen'
            );            
            List<Contact> contactRecordsList = new List<Contact>();
            contactRecordsList.add(individualContact);
            Test.startTest();
	        databaseResultList = Syntilio.UpsertToDatabase.updateAction(contactRecordsList, false);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }

        system.assertEquals(false, databaseResultList[0].isSuccess());
    }
 
    @isTest
    public static void upsertAction_Should_UpsertContact_Test() {
		List<Database.UpsertResult> databaseResultList;
        Map<Boolean, List<Object>> dmlActionStatus;
        try{
            List<Contact> contactRecordsList = createContactRecordsWithoutInsertion(1);
            sObjectField[] fieldList = new sObjectField[] {Contact.Email};

            Test.startTest();
	        databaseResultList = Syntilio.UpsertToDatabase.upsertAction(contactRecordsList, fieldList[0] ,false);
            dmlActionStatus = Syntilio.UpsertToDatabase.getDmlActionStatus(null, databaseResultList);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
       	List<Contact> contactListAfterCreation = [SELECT Id FROM Contact];
        system.assertEquals(1, contactListAfterCreation.size());
        system.assertEquals(true, databaseResultList[0].isSuccess());
        system.assertEquals(true, dmlActionStatus.containsKey(true));
    }
    
    @isTest
    public static void upsertAction_Should_LogException_Test() {
        try{
            List<Contact> contactRecordsList = null;

            Test.startTest();
	        Syntilio.UpsertToDatabase.upsertAction(contactRecordsList, null, false);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }

        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertEquals(0, exceptionList.size());
    }
    @isTest
    public static void upsertAction_Should_ReturnErrorMessage_Test() {
		List<Database.UpsertResult> databaseResultList;
        Map<Boolean, List<Object>> dmlActionStatus;
        try{
            
            
            Contact individualContact = new Contact(
	            FirstName = 'Jansen'
            );            
            List<Contact> contactRecordsList = new List<Contact>();
            contactRecordsList.add(individualContact);
       	    sObjectField[] fieldList = new sObjectField[] {Contact.Email};

            Test.startTest();
	        databaseResultList = Syntilio.UpsertToDatabase.upsertAction(contactRecordsList, fieldList[0] ,false);
            dmlActionStatus = Syntilio.UpsertToDatabase.getDmlActionStatus(null, databaseResultList);
            Test.stopTest();

        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        system.assertEquals(false, databaseResultList[0].isSuccess());
        system.assertEquals(true, dmlActionStatus.containsKey(false));
    }
}