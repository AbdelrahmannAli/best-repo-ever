List<Profile> apiOnlyProfiles = [SELECT Id, Name FROM Profile WHERE Name = 'Syntilio API Only'];
Profile apiOnlyProfile = apiOnlyProfiles.size() == 0? null : apiOnlyProfiles[0]; 
List<PermissionSet> apiOnlyPermissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SyntilioAPIOnly'];
PermissionSet apiOnlyPermissionSet = apiOnlyPermissionSets.size() == 0? null : apiOnlyPermissionSets[0]; 
String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
String usernameSuffix = instanceUrl.replace('https://', '').split('\\.')[0] + '.com';
List<User> systemAdmins = [
        SELECT Id, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey
        FROM User
        WHERE Alias = 'UUser'];
User systemAdmin = systemAdmins.size() == 0? null : systemAdmins[0];
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