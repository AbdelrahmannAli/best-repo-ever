public with sharing class InstallationHandler {
    
    public static void insertAPIOnlyUser(){
        Profile apiOnlyProfile = getProfile();
        PermissionSet apiOnlyPermissionSet = getPermissionSet();
        String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
        String usernameSuffix = instanceUrl.replace('https://', '').split('\\.')[0] + '.com';
        User systemAdmin = getSystemAdmin();
        List<User> users = [SELECT Id FROM User WHERE ProfileId = :apiOnlyProfile.Id];
        if(users.size() > 0) {
            return;
        }
        User syntilioApiOnly = new User(
            FirstName = 'Syntilio',
            LastName = 'API Only',
            ProfileId = apiOnlyProfile.Id,
            Email = 'it@syntilio.com',
            Username = 'apionly@' + usernameSuffix,
            Alias = 'apionly',
            TimeZoneSidKey = systemAdmin.TimeZoneSidKey, 
            LocaleSidKey = systemAdmin.LocaleSidKey,
            EmailEncodingKey = systemAdmin.EmailEncodingKey,
            LanguageLocaleKey = systemAdmin.LanguageLocaleKey
        );
        insert syntilioApiOnly;
        PermissionSetAssignment assignment = new PermissionSetAssignment(
            PermissionSetId = apiOnlyPermissionSet.Id,
            AssigneeId = syntilioApiOnly.Id
        );
        insert assignment;
    } 
    
    public static Profile getProfile(){
        List<Profile> apiOnlyProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Syntilio API Only'];
        return apiOnlyProfile.size() == 0? null : apiOnlyProfile[0]; 
    }
    
    public static PermissionSet getPermissionSet(){
        List<PermissionSet> apiOnlyPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SyntilioAPIOnly'];
        return apiOnlyPermissionSet.size() == 0? null : apiOnlyPermissionSet[0]; 
    }

    public static User getSystemAdmin(){
        List<User> systemAdmin = [
            SELECT Id, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey
			FROM User
			WHERE Alias = 'UUser'];
        return systemAdmin.size() == 0? null : systemAdmin[0]; 
    }
}