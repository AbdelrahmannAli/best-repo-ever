
Account philadelphiaCare = [SELECT Id FROM Account WHERE Name = 'Envida'];
Account twbCare = [SELECT Id FROM Account WHERE Syntilio__ApiName__c = 'Twb'];

/*
Syntilio__ExternalSystem__c externalSystemFierit = new Syntilio__ExternalSystem__c();
externalSystemFierit.Name = 'Fierit' ;
externalSystemFierit.Syntilio__ApiName__c = 'Fierit';
insert externalSystemFierit;
*/
Syntilio__ExternalSystem__c externalSystemOns = new Syntilio__ExternalSystem__c();
externalSystemOns.Name = 'Ons' ;
externalSystemOns.Syntilio__ApiName__c = 'Ons';
insert externalSystemOns;

/*
Syntilio__AccountExternalSystemAssociation__c accountExternalSystemAssociationPhiladelphiaFierit = new Syntilio__AccountExternalSystemAssociation__c();
accountExternalSystemAssociationPhiladelphiaFierit.Syntilio__AccountId__c = philadelphiaCare.Id;
accountExternalSystemAssociationPhiladelphiaFierit.Syntilio__ExternalSystemId__c = externalSystemFierit.Id;
insert accountExternalSystemAssociationPhiladelphiaFierit;
*/

Syntilio__AccountExternalSystemAssociation__c accountExternalSystemAssociationTWVOns = new Syntilio__AccountExternalSystemAssociation__c();
accountExternalSystemAssociationTWVOns.Syntilio__AccountId__c = twbCare.Id;
accountExternalSystemAssociationTWVOns.Syntilio__ExternalSystemId__c = externalSystemOns.Id;
insert accountExternalSystemAssociationTWVOns;

/*
Schema.Location locationPhiladelphiaFierit = new Schema.Location();
locationPhiladelphiaFierit.Name = 'Philadelphia - Fierit';
locationPhiladelphiaFierit.Syntilio__AccountId__c = philadelphiaCare.Id;
locationPhiladelphiaFierit.Syntilio__LocationId__c = '77777777';
locationPhiladelphiaFierit.Syntilio__ExternalSystemId__c = externalSystemFierit.Id;
insert locationPhiladelphiaFierit;
*/

Schema.Location locationTWBOns = new Schema.Location();
locationTWBOns.Name = 'TWB - Ons';
locationTWBOns.Syntilio__AccountId__c = twbCare.Id;
locationTWBOns.Syntilio__LocationId__c = '5';
locationTWBOns.Syntilio__ExternalSystemId__c = externalSystemOns.Id;
insert locationTWBOns;


Contact patientContactKarelGroenendijk = [SELECT Id FROM Contact WHERE LastName = 'Groenendijk'];
Contact patientContactPieter = [SELECT Id FROM Contact WHERE LastName ='Dirk'];
Contact patientContactJohan = [SELECT Id FROM Contact WHERE LastName ='Hendrik'];
Contact patientContactBartels = [SELECT Id FROM Contact WHERE LastName ='Bartels'];






Syntilio__DataHubAppConfiguration__mdt  dataHubAppConfiguration = Syntilio__DataHubAppConfiguration__mdt.getInstance('DataHubAppConfiguration');
List<Syntilio__ExternalId__c> externalIdsList = new List<Syntilio__ExternalId__c>();
if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'staging'){
    Syntilio__ExternalId__c karelExternalId = new Syntilio__ExternalId__c(
        Name = 'clientId',
        Syntilio__Account__c = twbCare.Id,
        Syntilio__ContactId__c = patientContactKarelGroenendijk.Id,
        Syntilio__ExternalSystemId__c = externalSystemOns.Id,
        Syntilio__Id__c = '6689'
    );
    externalIdsList.add(karelExternalId);

    Syntilio__ExternalId__c bartelsExternalClientId = new Syntilio__ExternalId__c(
        Name = 'clientId',
        Syntilio__Account__c = twbCare.Id,
        Syntilio__ContactId__c = patientContactBartels.Id,
        Syntilio__ExternalSystemId__c = externalSystemOns.Id,
        Syntilio__Id__c = '8884'
    );
    externalIdsList.add(bartelsExternalClientId);
}
else if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'test'){
    Syntilio__ExternalId__c karelExternalClientId = new Syntilio__ExternalId__c(
        Name = 'clientId',
        Syntilio__Account__c = twbCare.Id,
        Syntilio__ContactId__c = patientContactKarelGroenendijk.Id,
        Syntilio__ExternalSystemId__c = externalSystemOns.Id,
        Syntilio__Id__c = '6689'
    );
    externalIdsList.add(karelExternalClientId);
    Syntilio__ExternalId__c karelExternalIdentificationId = new Syntilio__ExternalId__c(
        Name = 'identificationNo',
        Syntilio__Account__c = twbCare.Id,
        Syntilio__ContactId__c = patientContactKarelGroenendijk.Id,
        Syntilio__ExternalSystemId__c = externalSystemOns.Id,
        Syntilio__Id__c = '12632'
    );
    externalIdsList.add(karelExternalIdentificationId);

    Syntilio__ExternalId__c bartelsExternalClientId = new Syntilio__ExternalId__c(
        Name = 'clientId',
        Syntilio__Account__c = twbCare.Id,
        Syntilio__ContactId__c = patientContactBartels.Id,
        Syntilio__ExternalSystemId__c = externalSystemOns.Id,
        Syntilio__Id__c = '8884'
    );
    externalIdsList.add(bartelsExternalClientId);
    Syntilio__ExternalId__c bartelsExternalIdentificationId = new Syntilio__ExternalId__c(
        Name = 'identificationNo',
        Syntilio__Account__c = twbCare.Id,
        Syntilio__ContactId__c = patientContactBartels.Id,
        Syntilio__ExternalSystemId__c = externalSystemOns.Id,
        Syntilio__Id__c = '14802'
    );
    externalIdsList.add(bartelsExternalIdentificationId);
}

insert externalIdsList;





