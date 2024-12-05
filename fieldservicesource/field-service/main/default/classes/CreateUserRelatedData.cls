public with sharing class CreateUserRelatedData {

    // CreateUserDataFuture.createUser();
    public static void createUser() {

        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while (randomString.length() < (1 + Math.random() * 20 )) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(idx, idx+1);
        }

        list<Profile> profileId = [SELECT Id FROM Profile WHERE Name = 'Service Cloud' LIMIT 1];

        String finalUserName  = 'janSimon@Syntilio' + randomString + '.demoUser' + randomString;

        User doctorJan = new User(
                FirstName='Jan',
                LastName='Simon',
                Email='salesforce.isv@Syntilio.com',
                Alias='jSimon',
                Username=finalUserName,
                IsActive=true,
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'GMT',
                ProfileID = profileId.get(0).id,
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
            );

        insert doctorJan;

        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();

        PermissionSet fieldServiceAgentLicense  = [select id from PermissionSet where label = 'Field Service Agent License'];
        PermissionSet fieldServiceAgentPermission  = [select id from PermissionSet where label = 'Field Service Agent Permissions'];

        PermissionSetAssignment permissionSetA = new PermissionSetAssignment
                (PermissionSetId = fieldServiceAgentLicense.id, AssigneeId = doctorJan.Id);
            
            permissionSetList.add(permissionSetA);
            
            PermissionSetAssignment permissionSetB = new PermissionSetAssignment
                (PermissionSetId = fieldServiceAgentPermission.id, AssigneeId = doctorJan.Id);
            
            permissionSetList.add(permissionSetB);
                
            try{
                upsert permissionSetList;
            }catch(exception e){
            }
        
        CreateUserRelatedData.createServiceResourceAndTerrirtoryMember(doctorJan.id);

    }
  
    @future
    public static void createServiceResourceAndTerrirtoryMember(Id id) {
        ServiceResource janSimonResource = new ServiceResource(
            Name = 'Jan Simon',
            RelatedRecordId = id,
            IsActive = true,
            ResourceType = 'T'
        );

        try {
            insert janSimonResource;
        } catch (exception e) {
        }
            

        datetime startDate = DatetIME.newInstance(2022, 8 , 1);
        datetime endDate = DatetIME.newInstance(2024, 12 , 27);

        List<ServiceTerritory> serviceTerritory = [Select id from ServiceTerritory where name='Amsterdam'];

        ServiceTerritoryMember serviceTerritoryMember = new ServiceTerritoryMember();
        serviceTerritoryMember.ServiceResourceId  = janSimonResource.id;
        serviceTerritoryMember.ServiceTerritoryId = serviceTerritory[0].id;
        serviceTerritoryMember.EffectiveStartDate = startDate;
        serviceTerritoryMember.EffectiveEndDate = endDate;
        serviceTerritoryMember.TerritoryType  = 'P';

        upsert serviceTerritoryMember;
    }
}


