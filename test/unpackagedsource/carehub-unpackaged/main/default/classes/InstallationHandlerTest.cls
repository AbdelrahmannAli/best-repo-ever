@isTest
public with sharing class InstallationHandlerTest {
	@isTest
    static void testInstallScript() {

		InstallationHandler.insertAPIOnlyUser();
		List<User> users = [SELECT Id FROM User WHERE Name = 'Syntilio API Only'];
		System.assertEquals(1, users.size());
        List<PermissionSet> apiOnlyPermissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SyntilioAPIOnly'];
		System.assertEquals(1, apiOnlyPermissionSets.size());
        List<PermissionSetAssignment> assignments = [
            SELECT Id FROM PermissionSetAssignment 
            WHERE AssigneeId = :users[0].Id 
            AND PermissionSetId = :apiOnlyPermissionSets[0].Id
        ];
		System.assertEquals(1, assignments.size());        
    }
}