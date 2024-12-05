@isTest
private class ServiceAppointmentTriggerTest {
    
    @testSetup static void setup() {
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe');
        insert testContact;
        
        Case testCase = new Case(Subject = 'Test Case 1', ContactId = testContact.Id);
        insert testCase;
        
        ServiceAppointment sa = new ServiceAppointment(
        	EarliestStartTime = Datetime.newInstance(2042, 1, 4, 12, 0, 0),
            DueDate = Datetime.newInstance(2042, 1, 4, 13, 0, 0),
            SchedStartTime = Datetime.newInstance(2042, 1, 4, 12, 0, 0),
            SchedEndTime = Datetime.newInstance(2042, 1, 4, 13, 0, 0),
            ParentRecordId = testCase.Id,
            ContactId = testContact.Id
        );
        insert sa;
    }
    
	@isTest 
    static void TestInsertServiceAppointment() {
        ServiceAppointment testServiceAppointment = [SELECT Id FROM ServiceAppointment LIMIT 1];
        
        Test.startTest();
        
        String expectedCronJobName = 'ScheduledServiceAppointmentHandler_' + testServiceAppointment.Id + '%';
        List<CronTrigger> cronTriggers = [SELECT Id,State FROM CronTrigger WHERE CronJobDetail.Name LIKE :expectedCronJobName];
        Integer activeCronJobs = 0;
        for (CronTrigger cronJob : cronTriggers) {
            if(cronJob.State == 'WAITING') {
                activeCronJobs++;
            }
        }
        System.assertEquals(1, activeCronJobs, 'Should have one active scheduled cron job');
        Test.stopTest();
    }
    
    @isTest 
    static void TestDeleteServiceAppointment() {
        //CHECK IF A TRIGGER WAS REMOVED
        ServiceAppointment testServiceAppointment = [SELECT Id FROM ServiceAppointment LIMIT 1];
        
        Test.startTest();
        delete testServiceAppointment;
        Test.stopTest();
        
        String expectedCronJobName = 'ScheduledServiceAppointmentHandler_' + testServiceAppointment.Id + '%';
        List<CronTrigger> cronTriggers = [SELECT Id,State FROM CronTrigger WHERE CronJobDetail.Name LIKE :expectedCronJobName];
        System.assertEquals(0, cronTriggers.size(), 'Should have no active scheduled cron jobs');
    }
}