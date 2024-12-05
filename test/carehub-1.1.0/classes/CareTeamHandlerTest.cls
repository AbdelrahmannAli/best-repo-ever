@isTest
public with sharing class CareTeamHandlerTest {
    
    private static Case getCase(){
        return [SELECT Id, ContactId, CreatedDate, Syntilio__CareTeam__c FROM Case LIMIT 1];
    }
    
    private static Contact getCareTeam(){
        return [SELECT Id FROM Contact WHERE LastName = 'Team' LIMIT 1];
    }
    
    private static Contact getPhiladelphiaCareTeam(){
        return [SELECT Id FROM Contact WHERE LastName = 'Philadelphia Care' LIMIT 1];
    }
    
    private static void createCareTeamData() {
        List<Account> accountList = new List<Account>();
        Id careTeamRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareTeam').getRecordTypeId();
        for(Integer i = 0; i < 2; i++){
            accountList.add(
                Syntilio.CareHubTestDataFactory.createAccount(
                    new Map<String, Object>{
                        'Name' => 'John Nasser' + i    
                    }
                )
            ); 
        }
        insert accountList;

        Contact careTeam = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'FirstName' => 'Care',
                'LastName' => 'Team',
                'RecordTypeId' => careTeamRecordTypeId,
                'AccountId' => accountList[0].Id
            }
        );
        
        Contact tBakhuysCareTeam = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
            	'FirstName' => '\'t Bakhuys',
                'LastName' => 'Philadelphia Care',
                'Email' => 'bakhuys@philadelphia.nl',
                'RecordTypeId' => careTeamRecordTypeId,
                'AccountId' => accountList[1].Id
            }
        );
        
        Contact contactRecord = (Contact) Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
            	'AccountId' => accountList[0].Id,
               	'MailingPostalCode' => '12345'
			}
        );
        
        insert new List<SObject>{careTeam, tBakhuysCareTeam, contactRecord};
        
        Id caseMedicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('SyntilioDefault')
            .getRecordTypeId();
        
        Case caseRecord = (Case) Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
            	'ContactId' => contactRecord.Id
            }
        );

        Syntilio__CareOrganizationContractRelation__c testContract1 = 
            Syntilio.CareHubTestDataFactory.createCareOrganizationContractRelation(
                new Map<String, Object>{
                    'Syntilio__MainAccount__c' => accountList[0].Id,
                    'Syntilio__CounterPartyAccount__c' => accountList[1].Id
                }
        );
        Syntilio__CareOrganizationContractRelation__c testContract2 = 
            Syntilio.CareHubTestDataFactory.createCareOrganizationContractRelation(
                new Map<String, Object>{
            		'Syntilio__MainAccount__c' => accountList[1].Id,
            		'Syntilio__CounterPartyAccount__c' => accountList[0].Id,
            		'Syntilio__EndDate__c' => null
                }
        );

        Syntilio__ServiceZipCode__c serviceZipCode1 = Syntilio.CareHubTestDataFactory.createServiceZipCode(
            new Map<String, Object>{
                'Name' => '12345',
                'Syntilio__ContactId__c' => careTeam.Id,
                'Syntilio__ZipCode__c' => '12345'
            }
        );
        
        Syntilio__ServiceZipCode__c serviceZipCode2 = Syntilio.CareHubTestDataFactory.createServiceZipCode(
            new Map<String, Object>{
                'Name' => '67890',
                'Syntilio__ContactId__c' => careTeam.Id,
                'Syntilio__ZipCode__c' => '67890'
            }
        );
        
        Syntilio__ServiceZipCode__c serviceZipCode3 = Syntilio.CareHubTestDataFactory.createServiceZipCode(
             new Map<String, Object>{
                 'Name' => 'Client zip code',
                 'Syntilio__ContactId__c' => careTeam.Id,
                 'Syntilio__ZipCode__c' => '2316321'
             }
        );
        
        Syntilio__CareOperatingHours__c careTeamOperatingHours = Syntilio.CareHubTestDataFactory.createCareOperatingHours(
            new Map<String, Object>{
                'Name' => '\'t careTeamOperatingHours',
                'Syntilio__CareTeam__c' => careTeam.Id
         	}
        );
        insert careTeamOperatingHours;

        List<String> weekDaysList = new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
        List<Syntilio__CareTimeSlot__c> morningTimeSlotList = new List<Syntilio__CareTimeSlot__c>();
        for (String weekDay : weekDaysList) {
            Syntilio__CareTimeSlot__c timeSlotMorning = Syntilio.CareHubTestDataFactory.createCareTimeSlot(
                new Map<String, Object>{
                    'Syntilio__DayOfWeek__c' => weekDay,
                    'Syntilio__CareOperatingHoursId__c' => careTeamOperatingHours.Id
                }
            );
            morningTimeSlotList.add(timeSlotMorning);
        }
        
        List<SObject> toInsert = new List<SObject>();
        toInsert.addAll(morningTimeSlotList);
        toInsert.addAll(new List<SObject>{caseRecord, testContract1, testContract2, serviceZipCode1, serviceZipCode2, serviceZipCode3});
        insert toInsert;
    }

    @testSetup
    public static void setupTestData() {
        createCareTeamData();
    }

    @isTest
    static void updateCaseCareTeamIdTest() {        
        Case testCase = getCase();
        Contact careTeam = getCareTeam(); 

        Test.startTest();
        Syntilio.CareTeamHandler.updateCaseCareTeamId(testCase.Id, careTeam.Id);
        Test.stopTest();

        List<Case> updatedCases = [SELECT Id, Syntilio__CareTeam__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(careTeam.Id, updatedCases[0].Syntilio__CareTeam__c);
    }

    @isTest
    static void isCareTeamWorkingThisZipCodeTest_True() {        
        Case testCase = getCase();
        Contact careTeam = getCareTeam();

        Test.startTest();
        Boolean result = Syntilio.CareTeamHandler.isCareTeamWorkingThisZipCode(careTeam.Id, testCase, '12345');
        Test.stopTest();

        System.assertEquals(true, result);
    }
    
    @isTest
    static void isCareTeamWorkingThisZipCodeTest_NullZipCode() {        
        Case testCase = getCase();
        Contact careTeam = getCareTeam();

        Test.startTest();
        Boolean result = Syntilio.CareTeamHandler.isCareTeamWorkingThisZipCode(careTeam.Id, testCase, null);
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void isCareTeamWorkingThisZipCodeTest_False() {  
        Case testCase = getCase();
        Contact careTeam = getCareTeam();

        Test.startTest();
        Boolean result = Syntilio.CareTeamHandler.isCareTeamWorkingThisZipCode(careTeam.Id, testCase, '5');
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @isTest
    static void isCareTeamAvailableTest_True() {
        Id careTeamRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareTeam').getRecordTypeId();
        
        Case testCase = getCase();
        Contact careTeam = getCareTeam();

        Test.startTest();
        Boolean result = Syntilio.CareTeamHandler.isCareTeamAvailable(careTeam.Id, testCase);
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void isCareTeamAvailableTest_False() {
        Id careTeamRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareTeam').getRecordTypeId();
        
        Case testCase = getCase();
        Contact careTeam = getPhiladelphiaCareTeam();

        Test.startTest();
        Boolean result = Syntilio.CareTeamHandler.isCareTeamAvailable(careTeam.Id, testCase);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    @isTest
    static void isCareTeamWorkingThisZipCodeTest_NoZipCodes() {
        Contact careTeam = getPhiladelphiaCareTeam();
        Case testCase = getCase();
        Syntilio__ServiceZipCode__c[] serviceZipCodeList = [
            SELECT Name, Syntilio__ZipCode__c
            FROM Syntilio__ServiceZipCode__c
            WHERE Syntilio__ContactId__c = :careTeam.Id
        ];
        delete serviceZipCodeList;

        Test.startTest();
        Boolean result = Syntilio.CareTeamHandler.isCareTeamWorkingThisZipCode(careTeam.Id, testCase, '5');
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void isCareTeamWorkingThisZipCodeTest_NoMailingPostalCode() {
        Contact careTeam = getPhiladelphiaCareTeam();
        Case testCase = getCase();

        Test.startTest();
        Boolean result = Syntilio.CareTeamHandler.isCareTeamWorkingThisZipCode(careTeam.Id, testCase, null);
        Test.stopTest();

        System.assertEquals(true, result);
    }

    @isTest
    static void getAllCareOrgsInContractTest() {
        Account testAccount1 = [SELECT Id FROM Account WHERE Name = 'John Nasser0'];
        Account testAccount2 = [SELECT Id FROM Account WHERE Name = 'John Nasser1'];
        
        Test.startTest();
        List<Id> result = Syntilio.CareTeamHandler.getAllCareOrgsInContract(testAccount1.Id);
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assertEquals(testAccount1.Id, result[0]);
        System.assertEquals(testAccount2.Id, result[1]);
    }

    @isTest
    static void getPatientDataTest() {
        Contact testContact = [SELECT Id, AccountId, MailingPostalCode FROM Contact LIMIT 1];

        Test.startTest();
        Contact result = Syntilio.CareTeamHandler.getPatientData(testContact.Id);
        Test.stopTest();

        System.assertEquals(testContact.Id, result.Id);
        System.assertEquals(testContact.AccountId, result.AccountId);
        System.assertEquals(testContact.MailingPostalCode, result.MailingPostalCode);
    }

    @isTest
    static void getCareTeamsTest_CaseWithContact() {
        Case testCase = getCase();
        
		Test.startTest();
        String result = Syntilio.CareTeamHandler.getCareTeams(testCase.Id);
        Test.stopTest();

        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String, Object> data = (Map<String, Object>) resultData.get('data');
        List<Object> careteamObject = (List<Object>) data.get('allCareTeams');
        System.assertEquals(true, resultData.get('isSuccess'));
        System.assertEquals(true, careteamObject.size() >= 1); 
    }

    @isTest
    static void getCareTeamsTest_CaseWithoutContact() {
        Case testCase = getCase();
        testCase.ContactId = null;
        update testCase;
        
        Test.startTest();
        String result = Syntilio.CareTeamHandler.getCareTeams(testCase.Id);
        Test.stopTest();

        Map<String, Object> resultData = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals(false, resultData.get('isSuccess'));
        System.assertEquals('Requested Case may have not been assigned to a patient', resultData.get('message'));
    }
}