@isTest
private class ScheduledServiceAppointmentHandlerTest {

    //@isTest
    static void testScheduledServiceAppointmentHandler() {
        User u = [SELECT ID FROM User WHERE Name = 'User User' LIMIT 1];
        System.runAs(u) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User newOwner = new User(
                FirstName = 'Test',
                LastName = 'User',
                Alias = 'tuser',
                Email = uid + '@example.com',
                Username = uid + '@example.com',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
            );
            insert newOwner;
            
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
			
            Test.startTest();
            ScheduledServiceAppointmentHandler testHandler = new ScheduledServiceAppointmentHandler(sa.Id);
            testHandler.execute(null);
            Test.stopTest();
            
            //AgentWork agentWorkRecord = [SELECT Id FROM AgentWork LIMIT 1];
        }
	}
}