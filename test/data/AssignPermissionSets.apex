List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
List<PermissionSet> permissionSetlist =  new List<PermissionSet>([SELECT ID FROM PermissionSet WHERE Name = 'SyntilioDataHubAdmin' OR Name = 'SyntilioCareHubAdmin' OR Name = 'SyntilioBusinessAccountRecordType' OR Name = 'SyntilioCareCircleContactRecordType' OR Name = 'SyntilioClientContactRecordType' OR Name = 'SyntilioDefaultCaseRecordType' OR Name = 'SyntilioEventTaskRecordType' OR Name = 'SyntilioBusinessContactRecordType' OR Name = 'SyntilioPartnerContactRecordType' OR Name = 'SyntilioSharedDeviceContactRecordType' ]);

for (User userUser : [SELECT ID, Name, Profile.Name, IsActive FROM User WHERE Name LIKE '%User%' AND Profile.Name = 'System Administrator' AND IsActive = true]){
        PermissionSetAssignment permissionSetAssignment1 = new PermissionSetAssignment (PermissionSetId = permissionSetlist[0].Id, AssigneeId = userUser.Id);
    	PermissionSetAssignment permissionSetAssignment2 = new PermissionSetAssignment (PermissionSetId = permissionSetlist[1].Id, AssigneeId = userUser.Id);
        PermissionSetAssignment permissionSetAssignment3 = new PermissionSetAssignment (PermissionSetId = permissionSetlist[2].Id, AssigneeId = userUser.Id);
        PermissionSetAssignment permissionSetAssignment4 = new PermissionSetAssignment (PermissionSetId = permissionSetlist[3].Id, AssigneeId = userUser.Id);
        PermissionSetAssignment permissionSetAssignment5 = new PermissionSetAssignment (PermissionSetId = permissionSetlist[4].Id, AssigneeId = userUser.Id);
        PermissionSetAssignment permissionSetAssignment6 = new PermissionSetAssignment (PermissionSetId = permissionSetlist[5].Id, AssigneeId = userUser.Id);
        PermissionSetAssignment permissionSetAssignment7 = new PermissionSetAssignment (PermissionSetId = permissionSetlist[6].Id, AssigneeId = userUser.Id);
        permissionSetAssignmentList.add(permissionSetAssignment1);
        permissionSetAssignmentList.add(permissionSetAssignment2);
        permissionSetAssignmentList.add(permissionSetAssignment3);
        permissionSetAssignmentList.add(permissionSetAssignment4);
        permissionSetAssignmentList.add(permissionSetAssignment5);
        permissionSetAssignmentList.add(permissionSetAssignment6);
        permissionSetAssignmentList.add(permissionSetAssignment7);
}
try{
    upsert permissionSetAssignmentList;
}catch(exception e){
    system.debug('exception caught' + e);
}