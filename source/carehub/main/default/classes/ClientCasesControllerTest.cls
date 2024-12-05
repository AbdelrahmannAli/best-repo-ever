@isTest
private class ClientCasesControllerTest {
    
    private static Account getAccount() {
		return [SELECT Id FROM Account LIMIT 1];        
    }
    
    private static void createDataHubSynchronisationTestData(){
        Account accountRecord = Syntilio.CareHubTestDataFactory.createAccount(null);
        Syntilio__ExternalSystem__c externalSystemRecord = Syntilio.DataHubTestDataFactory.createExternalSystem(null);
        insert new List<SObject>{accountRecord, externalSystemRecord};

        Syntilio__AccountExternalSystemAssociation__c accountExternalSystemAssociationRecord = Syntilio.DataHubTestDataFactory.createAccountExternalSystemAssociation(
            new Map<String, Object>{
                'Syntilio__AccountId__c' => accountRecord.Id,
                'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
            }
        );

        insert accountExternalSystemAssociationRecord;
    }


    @isTest
    static void getClientCasesTest() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert testContact;

        Case testCase1 = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'Subject' => 'Test Case 1', 'ContactId' => testContact.Id}
        );
        Case testCase2 = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'Subject' => 'Test Case 2', 'ContactId' => testContact.Id}
        );
        insert new List<Case>{testCase1, testCase2};

        Test.startTest();
        ResponseMessage msg = Syntilio.ResponseMessage.deserialize(ClientCasesController.getClientCases(testContact.Id));
        Test.stopTest();

        List<Object> resultObj = (List<Object>) msg.data;
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        for (Object obj : resultObj) {
            result.add((Map<String, Object>) obj);
        }

        System.assertEquals(2, result.size());
        System.assertEquals(testCase1.Owner.Alias, result[0].get('createdBy'));
        System.assertEquals(null, result[0].get('eventCode'));
        System.assertEquals(testCase2.Owner.Alias, result[1].get('createdBy'));
        System.assertEquals(null, result[1].get('eventCode'));
    }

    @isTest
    static void getCaseContactCareCircleMembersTest(){
        Id careCircleMemberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareCircle').getRecordTypeId();
        Contact testContact1 = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{'FirstName' => 'Test', 'LastName' => 'Contact', 'Email' => 'test.contact@example.com'}
        );
        
        Account accountRecord = Syntilio.CareHubTestDataFactory.createAccount(null);
        insert accountRecord;
        
        Contact testContact2 = Syntilio.CareHubTestDataFactory.createContact(
            new Map<String, Object>{
                'FirstName' => 'Pieter', 
                'LastName' => 'Dirk',
                'Email' => 'pieter.dirk@example.com',
                'AccountId' => accountRecord.Id,
                'RecordTypeId' => careCircleMemberRecordTypeId
            }
        );
        insert new List<Contact>{testContact1, testContact2};

        Syntilio__ContactContactRelationship__c testRelationship = Syntilio.CareHubTestDataFactory.createContactContactRelationship(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => testContact1.Id,
            	'Syntilio__RelatedContactId__c' => testContact2.Id
            }
        );
        insert testRelationship;
        
        Test.startTest();
        List<Syntilio__ContactContactRelationship__c> careCircleMembers = ClientCasesController.getCaseContactCareCircleMembers(testContact1.Id);
        Test.stopTest();

        System.assertEquals(1, careCircleMembers.size());
    }

    @isTest
    static void getCasesEventCodeTest() {
        Syntilio__EventConfiguration__c eventConfig = Syntilio.CareHubTestDataFactory.createEventConfiguration(
            new Map<String, Object>{'Syntilio__Code__c' => 123}
        );
        insert eventConfig;

        List<Case> testCases = new List<Case>{
            Syntilio.CareHubTestDataFactory.createCase(
                new Map<String, Object>{'Subject' => 'Test Case 1', 'Syntilio__Event__c' => eventConfig.Id}
            ),
            Syntilio.CareHubTestDataFactory.createCase(
                new Map<String, Object>{'Subject' => 'Test Case 2', 'Syntilio__Event__c' => eventConfig.Id}
            )
        };
        insert testCases;

        Test.startTest();
        Map<String, Decimal> result = Syntilio.ClientCasesController.getCasesEventCode(testCases);
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assertEquals(123, result.get(testCases[0].Id));
        System.assertEquals(123, result.get(testCases[1].Id));
    }

    @isTest
    static void getCasesDurationTest() {
        List<Case> testCases = new List<Case>{
            Syntilio.CareHubTestDataFactory.createCase(
                new Map<String, Object>{'Subject' => 'Test Case 1'}
            ),
            Syntilio.CareHubTestDataFactory.createCase(
                new Map<String, Object>{'Subject' => 'Test Case 2'}
            )
        };
        insert testCases;

        List<Syntilio__CallLog__c> testTranscripts = new List<Syntilio__CallLog__c>{
            Syntilio.CareHubTestDataFactory.createCallLog(
                new Map<String, Object>{'Syntilio__Duration__c' => '00:01:30', 'Syntilio__CaseId__c' => testCases[0].Id}
            ),
            Syntilio.CareHubTestDataFactory.createCallLog(
                new Map<String, Object>{'Syntilio__Duration__c' => '00:02:00', 'Syntilio__CaseId__c' => testCases[0].Id}
            ),
            Syntilio.CareHubTestDataFactory.createCallLog(
                new Map<String, Object>{'Syntilio__Duration__c' => '00:01:00', 'Syntilio__CaseId__c' => testCases[1].Id}
            )
        };
        insert testTranscripts;

        List<Id> testCaseIds = new List<Id>{testCases[0].Id, testCases[1].Id};

        Test.startTest();
        Map<String, String> result = Syntilio.ClientCasesController.getCasesDuration(testCaseIds);
        Test.stopTest();

        System.assertEquals(2, result.size());
        System.assertEquals('00:01:30, 00:02:00', result.get(testCases[0].Id));
        System.assertEquals('00:01:00', result.get(testCases[1].Id));
    }
    
    @isTest
    static void getCaseContactIdTest() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert testContact;
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'Subject' => 'Test Case 1', 'ContactId' => testContact.Id}
        );
        insert testCase;

        Test.startTest();
        String result = Syntilio.ClientCasesController.getCaseContactId(testCase.Id);
        Test.stopTest();
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);

        System.assertEquals(testContact.Id, resultMap.get('ContactId'));
    }
    
    @isTest
    static void getCaseContactExternalSystemTest() {
        createDataHubSynchronisationTestData();
        Account testAccount = getAccount();
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'Subject' => 'Test Case 1', 'AccountId' => testAccount.Id}
        );
        insert testCase;

        Test.startTest();
        String result = Syntilio.ClientCasesController.getCaseContactExternalSystem(testCase.Id);
        Test.stopTest();
        
        System.assertEquals('ES', result);
    }
    
    @isTest
    static void getCaseStatusTest() {
       	Case testCase = Syntilio.CareHubTestDataFactory.createCase(null);
        insert testCase;

        Test.startTest();
        Map<String,String> status = Syntilio.ClientCasesController.getCaseStatus(testCase.Id);
        Test.stopTest();
        
        System.assertEquals(testCase.Status, status.get('status'));
    }
    
    @isTest
    static void updateCaseContactIdTest() {
       	Case testCase = Syntilio.CareHubTestDataFactory.createCase(null);
        insert testCase;
       	Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert testContact;

        Test.startTest();
        Syntilio.ClientCasesController.updateCaseContactId(testCase.Id, testContact.Id);
        Test.stopTest();
        
        Case testCaseAfter = [SELECT ContactId FROM Case LIMIT 1];
        System.assertEquals(testContact.Id, testCaseAfter.ContactId);
    }

    @isTest
    static void getExternalSystems() {
        createDataHubSynchronisationTestData();
        Test.startTest();
        List<Syntilio__ExternalSystem__c> result = Syntilio.ClientCasesController.getExternalSystems();
        Test.stopTest();
        System.assertEquals(1, result.size());
    }

    @isTest
    static void getRedirectURL() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert testContact;

        Case testCase1 = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'Subject' => 'Test Case 1', 'ContactId' => testContact.Id}
        );
        insert testCase1;

        Test.startTest();
        String result = Syntilio.ClientCasesController.getRedirectURL(testCase1.Id, 'ONS' , 'https://development-development.ons-dossier.nl/clients/client_id/medical/overview');
        Test.stopTest();
        
        System.assertEquals(null, result);
    }
    
    @isTest
    static void getContactEventsTest_ContactId() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);

        Syntilio__EventConfiguration__c eventConfiguration = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert new List<SObject>{testContact, eventConfiguration};
        
        Syntilio__SyntilioEvent__c syntilioEvent = Syntilio.CareHubTestDataFactory.createSyntilioEvent(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => testContact.Id, 
                'Syntilio__EventCode__c' => eventConfiguration.Syntilio__Code__c
			}
        );
        insert syntilioEvent;

        Test.startTest();
        List<Syntilio__SyntilioEvent__c> syntilioEvents = Syntilio.ClientCasesController.getContactEvents(testContact.Id);
        Test.stopTest();
        
        System.assertEquals(1, syntilioEvents.size());
    }
    
    @isTest
    static void getContactEventsTest_CaseId() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);

        Syntilio__EventConfiguration__c eventConfiguration = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert new List<SObject>{testContact, eventConfiguration};
            
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'Subject' => 'Test Case 1', 'ContactId' => testContact.Id}
        );
        
        Syntilio__SyntilioEvent__c syntilioEvent = Syntilio.CareHubTestDataFactory.createSyntilioEvent(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => testContact.Id, 
                'Syntilio__EventCode__c' => eventConfiguration.Syntilio__Code__c
			}
        );
        insert new List<SObject>{testCase, syntilioEvent};

        Test.startTest();
        List<Syntilio__SyntilioEvent__c> syntilioEvents = Syntilio.ClientCasesController.getContactEvents(testCase.Id);
        Test.stopTest();
        
        System.assertEquals(1, syntilioEvents.size());
    }
    
    @isTest
    static void getContactEventsTest_Exception() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);

        Syntilio__EventConfiguration__c eventConfiguration = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert new List<SObject>{testContact, eventConfiguration};
            
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{'Subject' => 'Test Case 1', 'ContactId' => testContact.Id}
        );
        
        Syntilio__SyntilioEvent__c syntilioEvent = Syntilio.CareHubTestDataFactory.createSyntilioEvent(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => testContact.Id, 
                'Syntilio__EventCode__c' => eventConfiguration.Syntilio__Code__c
			}
        );
        insert new List<SObject>{testCase, syntilioEvent};
            
        Id testCaseId = testCase.Id;
        delete testCase;

        Test.startTest();
        List<Syntilio__SyntilioEvent__c> syntilioEvents = Syntilio.ClientCasesController.getContactEvents(testCaseId);
        Test.stopTest();
        
        System.assertEquals(0, syntilioEvents.size());
    }
    
    @isTest
    static void getCaseEventCodeTest() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);

        Syntilio__EventConfiguration__c eventConfiguration = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert new List<SObject>{testContact, eventConfiguration};
            
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case 1', 
                'ContactId' => testContact.Id, 
				'Syntilio__Event__c' => eventConfiguration.Id
			}
        );
        
        Syntilio__SyntilioEvent__c syntilioEvent = Syntilio.CareHubTestDataFactory.createSyntilioEvent(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => testContact.Id, 
                'Syntilio__EventCode__c' => eventConfiguration.Syntilio__Code__c
			}
        );
        insert new List<SObject>{testCase, syntilioEvent};

        Test.startTest();
        String eventCode = Syntilio.ClientCasesController.getCaseEventCode(testCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, eventCode);
    }
    
    @isTest
    static void getCaseEventCodeTest_Exception() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);

        Syntilio__EventConfiguration__c eventConfiguration = Syntilio.CareHubTestDataFactory.createEventConfiguration(null);
        insert new List<SObject>{testContact, eventConfiguration};
            
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case 1', 
                'ContactId' => testContact.Id, 
				'Syntilio__Event__c' => eventConfiguration.Id
			}
        );
        
        Syntilio__SyntilioEvent__c syntilioEvent = Syntilio.CareHubTestDataFactory.createSyntilioEvent(
            new Map<String, Object>{
                'Syntilio__ContactId__c' => testContact.Id, 
                'Syntilio__EventCode__c' => eventConfiguration.Syntilio__Code__c
			}
        );
        insert new List<SObject>{testCase, syntilioEvent};
            
        Id testCaseId = testCase.Id;
        delete testCase;

        Test.startTest();
        String eventCode = Syntilio.ClientCasesController.getCaseEventCode(testCaseId);
        Test.stopTest();
        
        System.assertEquals(null, eventCode);
    }

    @isTest
    static void createCaseTest(){
        Test.startTest();
        Id id = Syntilio.ClientCasesController.createCase();
        Test.stopTest();

        System.assertNotEquals(null, id);
    }

    @isTest
    static void setCaseOwnerTest(){
        User testUser = Syntilio.CareHubTestDataFactory.createUser(null);
        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case 1', 
                'Status' => 'New',
                'Priority' => 'Normal'
			}
        );
        insert testCase;

        Test.startTest();
        Id ownerId = ClientCasesController.setCaseOwner(testCase.Id, testUser.Id);
        Test.stopTest();

        System.assertEquals(testUser.Id, ownerId);
    }

    @isTest
    static void getAllContactsTest(){
        Contact testContact1 = Syntilio.CareHubTestDataFactory.createContact(null);
        Contact testContact2 = Syntilio.CareHubTestDataFactory.createContact(null);

        insert new List<Contact>{testContact1, testContact2};

        Test.startTest();
        String result = ClientCasesController.getAllContacts();
        Test.stopTest();
        
        List<Contact> deserializedContacts = (List<Contact>) JSON.deserialize(result, List<Contact>.class);

        System.assertEquals(2, deserializedContacts.size());
    }
    
    @isTest
    static void getAllEventsTest() {
        List<Syntilio__EventConfiguration__c> eventConfigs = new List<Syntilio__EventConfiguration__c>{
            Syntilio.CareHubTestDataFactory.createEventConfiguration(
                new Map<String, Object>{'Syntilio__Code__c' => 123}
            ),
            Syntilio.CareHubTestDataFactory.createEventConfiguration(
                new Map<String, Object>{'Syntilio__Code__c' => 456}
            )
        };
        insert eventConfigs;

        Test.startTest();
        List<Syntilio__EventConfiguration__c> result = ClientCasesController.getAllEvents();
        Test.stopTest();

        System.assertEquals(2, result.size());
    }

    @isTest
    static void setCaseEventTest() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert testContact;

        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case For Event',
                'ContactId' => testContact.Id
            }
        );
        insert testCase;

        Syntilio__EventConfiguration__c eventConfig = Syntilio.CareHubTestDataFactory.createEventConfiguration(
            new Map<String, Object>{'Syntilio__Code__c' => 789}
        );
        insert eventConfig;

        Test.startTest();
        Id updatedCaseId = ClientCasesController.setCaseEvent(testCase.Id, eventConfig.Id);
        Case updatedCase = [SELECT Syntilio__Event__c FROM Case WHERE Id = :updatedCaseId LIMIT 1];
        Test.stopTest();

        System.assertNotEquals(null, updatedCase.Syntilio__Event__c);
        System.assertEquals(eventConfig.Id, updatedCase.Syntilio__Event__c);
    }

    @isTest
    static void setCaseStatusTest() {
        Contact testContact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert testContact;

        Case testCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
                'Subject' => 'Test Case For Event',
                'ContactId' => testContact.Id,
                'Status'=>'Escalated'
            }
        );
        insert testCase;

        Test.startTest();
        String updatedCaseId = ClientCasesController.setCaseStatus(testCase.Id, 'Closed');
        Case updatedCase = [SELECT Status FROM Case WHERE Id =:testCase.Id LIMIT 1];
        Test.stopTest();

        System.assertEquals('Closed', updatedCase.Status);
    }

    @isTest
    static void getClientsTest() {
        RecordType clientRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Client' AND SObjectType = 'Contact' LIMIT 1];
        Syntilio__ExternalSystem__c externalSystemRecord = Syntilio.DataHubTestDataFactory.createExternalSystem(null);
        insert externalSystemRecord;

        List<Contact> testContacts = new List<Contact>{
            Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
                'FirstName' => 'Alice',
                'LastName' => 'Johnson',
                'RecordTypeId' => clientRecordType.Id
            }),
            Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
                'FirstName' => 'Bob',
                'LastName' => 'Smith',
                'RecordTypeId' => clientRecordType.Id
            })
        };
        insert testContacts;

        List<Syntilio__ExternalId__c> externalIds = new List<Syntilio__ExternalId__c>{
            Syntilio.DataHubTestDataFactory.createExternalId(new Map<String, Object>{
                'Name' => 'identificationNo',
                'Syntilio__Id__c' => '12345',
                'Syntilio__ContactId__c' => testContacts[0].Id,
                'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
            }),
            Syntilio.DataHubTestDataFactory.createExternalId(new Map<String, Object>{
                'Name' => 'identificationNo',
                'Syntilio__Id__c' => '67890',
                'Syntilio__ContactId__c' => testContacts[1].Id,
                'Syntilio__ExternalSystemId__c' => externalSystemRecord.Id
            })
        };
        insert externalIds;

        Test.startTest();
        Map<String, Object> result = ClientCasesController.getClients();
        Test.stopTest();

        List<Contact> deserializedContacts = (List<Contact>) JSON.deserialize(result.get('contacts').toString(), List<Contact>.class);
        List<Syntilio__ExternalId__c> deserializedExternalIds = (List<Syntilio__ExternalId__c>) JSON.deserialize(result.get('externalIds').toString(), List<Syntilio__ExternalId__c>.class);
        
        System.assertEquals(2, deserializedContacts.size());
        System.assertEquals(2, deserializedExternalIds.size());
    }

    @isTest
    static void getClientAppointmentsTest() {
        
        Contact testClient = Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Client'
        });
        insert testClient;

        Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout(
            'GET', 'appointments', '?client_id=' + testClient.Id + '&valid_from=' + Date.today()+ '&valid_to=' + Date.today().addDays(8),
            '{"appointments": [{"id": "1", "date": "2024-05-01"}, {"id": "2", "date": "2024-05-03"}]}'
        ));
        
        Test.startTest();
        Object appointments = ClientCasesController.getClientAppoinments(testClient.Id);
        Test.stopTest();

        System.assertNotEquals(null, appointments);
    }

    @isTest
    static void getCaseSuggestedTest() {
        Contact testClient = Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Client'
        });
        insert testClient;

        List<Contact> relatedContacts = new List<Contact>{
            Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
                'FirstName' => 'Alice',
                'LastName' => 'Johnson'
            }),
            Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
                'FirstName' => 'Bob',
                'LastName' => 'Smith'
            })
        };
        insert relatedContacts;

        List<Syntilio__ContactContactRelationship__c> relationships = new List<Syntilio__ContactContactRelationship__c>{
            Syntilio.CareHubTestDataFactory.createContactContactRelationship(new Map<String, Object>{
                'Syntilio__ContactId__c' => testClient.Id,
                'Syntilio__RelatedContactId__c' => relatedContacts[0].Id,
                'Syntilio__Relationship__c' => 'Friend'
            }),
            Syntilio.CareHubTestDataFactory.createContactContactRelationship(new Map<String, Object>{
                'Syntilio__ContactId__c' => testClient.Id,
                'Syntilio__RelatedContactId__c' => relatedContacts[1].Id,
                'Syntilio__Relationship__c' => 'Family'
            })
        };
        insert relationships;

        Test.startTest();
        String suggestedRelationshipsJson = ClientCasesController.getCaseSuggested(testClient.Id);
        Test.stopTest();

        List<Map<String, String>> deserializedRelationships = (List<Map<String, String>>) JSON.deserialize(suggestedRelationshipsJson, List<Map<String, String>>.class);
        System.assertEquals(2, deserializedRelationships.size());
        System.assertEquals('Friend', deserializedRelationships[0].get('relationship'));
        System.assertEquals('Family', deserializedRelationships[1].get('relationship'));
    }

    @isTest
    static void getCaseSuggestedTest_NoRelationships() {
        Contact testClient = Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Client'
        });
        insert testClient;

        Test.startTest();
        String result = ClientCasesController.getCaseSuggested(testClient.Id);
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @isTest
    static void getAllGroupsTest() {
        List<Syntilio__Group__c> groups = new List<Syntilio__Group__c>{
            new Syntilio__Group__c(Name = 'Care Circle', Syntilio__ObjectType__c = 'Care Circle'),
            new Syntilio__Group__c(Name = 'Other Group', Syntilio__ObjectType__c = 'Other Group')
        };
        insert groups;

        Test.startTest();
        String result = ClientCasesController.getAllGroups();
        Test.stopTest();

        List<Syntilio__Group__c> deserializedGroups = (List<Syntilio__Group__c>) JSON.deserialize(result, List<Syntilio__Group__c>.class);

        System.assertEquals(1, deserializedGroups.size());
    }

    @isTest
    static void updateCaseCallerTest() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;

        Contact testClient = Syntilio.CareHubTestDataFactory.createContact(new Map<String, Object>{
            'FirstName' => 'Test',
            'LastName' => 'Client'
        });
        insert testClient;

        String newCallerId = testClient.Id;

        Test.startTest();
        ClientCasesController.updateCaseCaller(testCase.Id, newCallerId);
        Test.stopTest();

        Case updatedCase = [SELECT Syntilio__Caller__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals(newCallerId, updatedCase.Syntilio__Caller__c);
    }

    @isTest
    static void updateCaseCallerGroupTest() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;

        Syntilio__Group__c testGroup = new Syntilio__Group__c(
            Name = 'Test Group',
            Syntilio__ObjectType__c = 'SomeObjectType'
        );
        insert testGroup;

        String callerGroupId = testGroup.Id;

        Test.startTest();
        CareHubUtilities.updateCaseCallerGroup(testCase.Id, callerGroupId);
        Test.stopTest();

        Case updatedCase = [SELECT Syntilio__CallerGroup__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals(callerGroupId, updatedCase.Syntilio__CallerGroup__c, 'The caller group ID should be updated correctly.');
    }
}