@isTest
public class CaseOwnerControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a unique test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        String uniqueUsername = 'testuser' + DateTime.now().getTime() + '@testorg.com';
        User testUser = new User(Alias = 'testusr', Email='testuser@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
                                 UserName=uniqueUsername);
        insert testUser;

        // Create a test case assigned to the test user
        Case testCase = new Case(Subject = 'Test Case', OwnerId = testUser.Id);
        insert testCase;
    }

    @isTest
    static void testControllerInitializationAndOwnershipChange() {
        // Retrieve the test case created in @testSetup
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];
        
        // Initialize the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseOwnerController controller = new CaseOwnerController(stdController);

        // Check that the controller's caseId matches the test case ID
        System.assertEquals(testCase.Id, controller.caseId, 'Controller caseId should match the test case ID');
        
        // Verify that the initial case owner does not match the current user
        System.assertNotEquals(UserInfo.getUserId(), testCase.OwnerId, 'Initial owner should not be the current user');
        
        // Test the ownership change method
        Test.startTest();
        CaseOwnerController.changeOwner(testCase.Id);
        Test.stopTest();

        // Verify the ownership change
        Case updatedCase = [SELECT OwnerId FROM Case WHERE Id = :testCase.Id];
        
        // Check that the case owner has been updated to the current user
        System.assertEquals(UserInfo.getUserId(), updatedCase.OwnerId, 'Case owner should be updated to the current user');
        System.assertNotEquals(testCase.OwnerId, updatedCase.OwnerId, 'Case owner should be different from the original owner');
    }
}
