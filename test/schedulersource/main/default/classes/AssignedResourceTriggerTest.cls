@isTest
private class AssignedResourceTriggerTest {
	@isTest 
    static void TestUpdateOwnerServiceAppointment() {
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
        
        Blob b = Crypto.GenerateAESKey(128);
     	String h = EncodingUtil.ConvertTohex(b);
      	String uid = h.SubString(0,8);
        User newOwner = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = uid + '@example.com',
            Username = uid + '@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert newOwner;
        
        ServiceResource sr = new ServiceResource(
            Name = 'Test Service Resource',
            OwnerId = newOwner.Id,
            RelatedRecordId = newOwner.Id,
            IsActive = true
        );
        insert sr;
        
		Test.startTest();
		AssignedResource testAssignedResource = new AssignedResource(
            ServiceAppointmentId = sa.Id,
            ServiceResourceId = sr.Id
        );
        insert testAssignedResource;
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertEquals(newOwner.Id, updatedCase.OwnerId, 'Should update Case OwnerId to reflect a change in Service Resource Assigned');
    }
}