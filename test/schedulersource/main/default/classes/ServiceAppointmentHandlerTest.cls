@isTest
public with sharing class ServiceAppointmentHandlerTest {
	@isTest
    static void testAbortScheduledJobs() {
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        
        Case testCase = new Case(Subject = 'Test Case 1', ContactId = testContact.Id);
        insert testCase;
        
        ServiceAppointment testServiceAppointment = new ServiceAppointment(
        	EarliestStartTime = Datetime.newInstance(2042, 1, 4, 12, 0, 0),
            DueDate = Datetime.newInstance(2042, 1, 4, 13, 0, 0),
            SchedStartTime = Datetime.newInstance(2042, 1, 4, 12, 0, 0),
            SchedEndTime = Datetime.newInstance(2042, 1, 4, 13, 0, 0),
            ParentRecordId = testCase.Id,
            ContactId = testContact.Id
        );
        insert testServiceAppointment;
        
        ServiceAppointmentHandler.ServiceAppointmentMethodInput testServiceAppointmentMethodInput = new ServiceAppointmentHandler.ServiceAppointmentMethodInput();
        testServiceAppointmentMethodInput.inputServiceAppointment = testServiceAppointment;
        testServiceAppointmentMethodInput.methodToBeUsed = 'abortScheduledJobs';
        List<ServiceAppointmentHandler.ServiceAppointmentMethodInput> testServiceAppointmentMethodInputs = new List<ServiceAppointmentHandler.ServiceAppointmentMethodInput>();
		testServiceAppointmentMethodInputs.add(testServiceAppointmentMethodInput);

        Test.startTest();
        ServiceAppointmentHandler.serviceAppointmentHandlerFunctions(testServiceAppointmentMethodInputs);
        Test.stopTest();
        
        String expectedCronJobName = 'ScheduledServiceAppointmentHandler_' + testServiceAppointment.Id + '%';
        List<CronTrigger> cronTriggers = [SELECT Id,State FROM CronTrigger WHERE CronJobDetail.Name LIKE :expectedCronJobName];
        System.assertEquals(0, cronTriggers.size(), 'Should have no active scheduled cron jobs');
    }
    
    @isTest
    static void testIsNextOccurenceInsideTimeframeSuccess(){
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        
        Case testCase = new Case(Subject = 'Test Case 1', ContactId = testContact.Id);
        insert testCase;
        
        WorkType testWorkType = new WorkType(
        	Name='Test Work Type',
            TimeframeEnd=10,
            TimeFrameEndUnit='Days',
            EstimatedDuration = 1,
            DurationType = 'Hours'
        );
        insert testWorkType;
        
        ServiceAppointment testServiceAppointment = new ServiceAppointment(
        	EarliestStartTime = Datetime.now(),
            DueDate = Datetime.now().addDays(7),
            SchedStartTime = Datetime.now().addDays(3),
            SchedEndTime = Datetime.now().addDays(3).addHours(1),
            ArrivalWindowStartTime = Datetime.now().addDays(3),
            ArrivalWindowEndTime = Datetime.now().addDays(3).addHours(1),
            ParentRecordId = testCase.Id,
            ContactId = testContact.Id,
            WorkTypeId = testWorkType.Id,
            RecurrencePeriod__c = 5,
            Recurrence_Period_Type__c = 'Days'
        );
        insert testServiceAppointment;
        
        Test.startTest();
        Boolean result = ServiceAppointmentHandler.isNextOccurenceInsideTimeframe(testServiceAppointment);
        Test.stopTest();
        
        System.assertEquals(true, result, 'Should have returned that the next recurrence is in the timeframe specified');
    }
    
    @isTest
    static void testIsNextOccurenceInsideTimeframeFailure(){
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        
        Case testCase = new Case(Subject = 'Test Case 1', ContactId = testContact.Id);
        insert testCase;
        
        WorkType testWorkType = new WorkType(
        	Name='Test Work Type',
            TimeframeEnd=10,
            TimeFrameEndUnit='Days',
            EstimatedDuration = 1,
            DurationType = 'Hours'
        );
        insert testWorkType;
        
        ServiceAppointment testServiceAppointment = new ServiceAppointment(
        	EarliestStartTime = Datetime.now(),
            DueDate = Datetime.now().addDays(7),
            SchedStartTime = Datetime.now().addDays(1),
            SchedEndTime = Datetime.now().addDays(1).addHours(1),
            ArrivalWindowStartTime = Datetime.now().addDays(1),
            ArrivalWindowEndTime = Datetime.now().addDays(1).addHours(1),
            ParentRecordId = testCase.Id,
            ContactId = testContact.Id,
            WorkTypeId = testWorkType.Id,
            RecurrencePeriod__c = 15,
            Recurrence_Period_Type__c = 'Days'
        );
        insert testServiceAppointment;
        
        Test.startTest();
        Boolean result = ServiceAppointmentHandler.isNextOccurenceInsideTimeframe(testServiceAppointment);
        Test.stopTest();
        
        System.assertEquals(false, result, 'Should not have returned that the next recurrence is in the timeframe specified');
    }
    
    @isTest
    static void testCloneServiceAppointment(){
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        
        Case testCase = new Case(Subject = 'Test Case 1', ContactId = testContact.Id);
        insert testCase;
        
        WorkType testWorkType = new WorkType(
        	Name='Test Work Type',
            TimeframeEnd=10,
            TimeFrameEndUnit='Days',
            EstimatedDuration = 1,
            DurationType = 'Hours'
        );
        insert testWorkType;
        
        ServiceAppointment testServiceAppointment = new ServiceAppointment(
        	EarliestStartTime = Datetime.newInstance(2042, 1, 4, 12, 0, 0),
            DueDate = Datetime.newInstance(2042, 1, 4, 13, 0, 0),
            SchedStartTime = Datetime.newInstance(2042, 1, 4, 12, 0, 0),
            SchedEndTime = Datetime.newInstance(2042, 1, 4, 13, 0, 0),
            ArrivalWindowStartTime = Datetime.newInstance(2042, 1, 4, 12, 0, 0),
            ArrivalWindowEndTime = Datetime.newInstance(2042, 1, 4, 13, 0, 0),
            ParentRecordId = testCase.Id,
            ContactId = testContact.Id,
            WorkTypeId = testWorkType.Id,
            RecurrencePeriod__c = 5,
            Recurrence_Period_Type__c = 'Days'
        );
        insert testServiceAppointment;
        
        Test.startTest();
        ServiceAppointment clonedServiceAppointment = ServiceAppointmentHandler.cloneServiceAppointment(testServiceAppointment);
        Test.stopTest();
        
        System.assertEquals(null, clonedServiceAppointment.ActualDuration, 'Should have ActualDuration and other related fields nullified');
        System.assertEquals(null, clonedServiceAppointment.Comments, 'Should have Comments and other related fields nullified');
        System.assertEquals(testServiceAppointment.ArrivalWindowStartTime.addDays(5), clonedServiceAppointment.ArrivalWindowStartTime, 'Should have Comments and other related fields nullified');
        System.assertEquals(testServiceAppointment.SchedEndTime.addDays(5), clonedServiceAppointment.SchedEndTime, 'Should have Comments and other related fields nullified');
    }

    @isTest
    static void testConvertDatetimeToCronExpression() {
        Datetime d = Datetime.newInstance(2024, 1, 4, 12, 0, 0);
        String returnedCron = ServiceAppointmentHandler.convertDatetimeToCronExpression(d);
        String expectedCron = '0 0 12 4 1 ? 2024';
        System.assertEquals(returnedCron, expectedCron, 'CRON returned not as expected');
    }
}