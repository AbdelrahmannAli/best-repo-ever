Id clientAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
Id clientContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
Id businessContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

Id industriesBusinessRecordTypeId;
Id individualContactRecordTypeId;
Id individualAccountRecordTypeId;

List<PackageLicense> packageLicenseRecordList = new List<PackageLicense> ([SELECT Id, AllowedLicenses,CreatedDate,ExpirationDate,IsProvisioned,LastModifiedDate,NamespacePrefix,Status,SystemModstamp,UsedLicenses FROM PackageLicense WHERE NamespacePrefix = 'HealthCloudGA' LIMIT 1]);

if (!packageLicenseRecordList.isEmpty()){
    industriesBusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
    individualContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();
    individualAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();
}

Account patientAccountKarel;
Account patientAccountPieter;
Account patientAccountJohan;

// Create care organization 
Account middinCare = new Account();
middinCare.Name = 'Middin'; // Set the name of the hospital
middinCare.Type = 'Care'; // Set the type of the account
middinCare.Industry = 'Healthcare'; // Set the industry of the account
middinCare.BillingStreet = 'Burgemeester Elsenlaan 170 '; // Set the billing address street
middinCare.BillingCity = 'Rijswijk'; // Set the billing address city
middinCare.BillingState = 'Rijswijk'; // Set the billing address state
middinCare.BillingCountry = 'NL'; // Set the billing address country
middinCare.BillingPostalCode = '2288 BH'; // Set the billing address postal code
middinCare.Website = 'https://middin.nl/contact';
middinCare.Phone = '+0703222246';
middinCare.RecordTypeId = businessAccountRecordTypeId;

insert(middinCare);

//Account middinCare = [SELECT Id FROM Account WHERE Name = 'Envida'];

Account cordaanCare = new Account();
cordaanCare.Name = 'Cordaan'; // Set the name of the hospital
cordaanCare.Type = 'Care Provider'; // Set the type of the account
cordaanCare.Industry = 'Healthcare'; // Set the industry of the account
cordaanCare.BillingStreet = 'De Ruijterkade 7'; // Set the billing address street
cordaanCare.BillingCity = 'Amsterdam'; // Set the billing address city
cordaanCare.BillingState = 'Noord-Holland'; // Set the billing address state
cordaanCare.BillingPostalCode = '1013 AA'; // Set the billing address postal code
cordaanCare.BillingCountry = 'NL';
cordaanCare.Phone = '(020)4356300';
cordaanCare.Website = 'https://www.cordaan.nl/';
cordaanCare.RecordTypeId = businessAccountRecordTypeId;
 
insert(cordaanCare);
//Account cordaanCare = [SELECT Id FROM Account WHERE Name = 'Amarant'];

Account twbCare = new Account();
twbCare.Name = 'Thuiszorg West-Brabant'; // Set the name of the hospital
twbCare.Type = 'Care Provider'; // Set the type of the account
twbCare.Industry = 'Healthcare'; // Set the industry of the account
twbCare.BillingStreet = 'Belder 2-4'; // Set the billing address street
twbCare.BillingCity = 'Roosendaal'; // Set the billing address street
twbCare.BillingState = 'Roosendaal'; // Set the billing address street
twbCare.BillingPostalCode = '4704 RK'; // Set the billing address street
twbCare.BillingCountry = 'NL'; // Set the billing address country
twbCare.Website = 'https://www.twb.nl/';
twbCare.Phone = '0885602000';
twbCare.RecordTypeId = businessAccountRecordTypeId;
twbCare.Syntilio__ApiName__c = 'Twb';

insert(twbCare);
//Account twbCare = [SELECT Id FROM Account WHERE Name = 'Catharina Ziekenhuis'];

// Create care organization 
Account envidaCare = new Account();
envidaCare.Name = 'Envida'; // Set the name of the hospital
envidaCare.Type = 'Care Provider'; // Set the type of the account
envidaCare.Industry = 'Healthcare'; // Set the industry of the account
envidaCare.BillingStreet = 'Abtstraat 2a'; // Set the billing address street
envidaCare.BillingCity = 'Maastricht'; // Set the billing address city
envidaCare.BillingState = 'Noord-Holland'; // Set the billing address state
envidaCare.BillingCountry = 'NL'; // Set the billing address country
envidaCare.BillingPostalCode = '6211 LS'; // Set the billing address postal code
envidaCare.Website = 'https://www.envida.nl/';
envidaCare.Phone = '+0900-2233440';
envidaCare.RecordTypeId = businessAccountRecordTypeId;
envidaCare.Syntilio__ApiName__c = 'Envida';

insert(envidaCare);

//Account envidaCare = [SELECT Id FROM Account WHERE Name = 'Envida'];

Account amarantCare = new Account();
amarantCare.Name = 'Amarant'; // Set the name of the hospital
amarantCare.Type = 'Care Provider'; // Set the type of the account
amarantCare.Industry = 'Healthcare'; // Set the industry of the account
amarantCare.BillingStreet = 'Bredaseweg 570'; // Set the billing address street
amarantCare.BillingCity = 'Tilburg'; // Set the billing address city
amarantCare.BillingState = 'Noord-Holland'; // Set the billing address state
amarantCare.BillingPostalCode = '5037 LH'; // Set the billing address postal code
amarantCare.BillingCountry = 'NL';
amarantCare.Phone = '+310886115333';
amarantCare.Website = 'https://www.amarant.nl/';
amarantCare.RecordTypeId = businessAccountRecordTypeId;
 
insert(amarantCare);
//Account amarantCare = [SELECT Id FROM Account WHERE Name = 'Amarant'];

Account catharinaZiekenhuis = new Account();
catharinaZiekenhuis.Name = 'Catharina Ziekenhuis'; // Set the name of the hospital
catharinaZiekenhuis.Type = 'Care Provider'; // Set the type of the account
catharinaZiekenhuis.Industry = 'Healthcare'; // Set the industry of the account
catharinaZiekenhuis.BillingStreet = 'Michelangelolaan 2'; // Set the billing address street
catharinaZiekenhuis.BillingCity = 'Eindhoven'; // Set the billing address street
catharinaZiekenhuis.BillingState = 'Noord-Holland'; // Set the billing address street
catharinaZiekenhuis.BillingPostalCode = '5623 EJ'; // Set the billing address street
catharinaZiekenhuis.BillingCountry = 'NL'; // Set the billing address country
catharinaZiekenhuis.Website = 'https://www.catharinaziekenhuis.nl/';
catharinaZiekenhuis.Phone = '310402399111';
catharinaZiekenhuis.RecordTypeId = businessAccountRecordTypeId;

insert(catharinaZiekenhuis);
//Account catharinaZiekenhuis = [SELECT Id FROM Account WHERE Name = 'Catharina Ziekenhuis'];


Account reinaerde = new Account();
reinaerde.Name = 'Reinaerde'; // Set the name of the hospital
reinaerde.Type = 'Care Provider'; // Set the type of the account
reinaerde.Industry = 'Healthcare'; // Set the industry of the account
reinaerde.BillingStreet = 'Kon. Wilhelminalaan 3'; // Set the billing address street
reinaerde.BillingCity = 'Utrecht'; // Set the billing address street
reinaerde.BillingState = 'Noord-Holland'; // Set the billing address street
reinaerde.BillingPostalCode = '3527 LA'; // Set the billing address street
reinaerde.BillingCountry = 'NL'; // Set the billing address countryreinarde.Website = 'https://www.reinaerde.nl/';
reinaerde.Phone = '310302299922';
reinaerde.Website = 'http://www.reinaerde.nl/';
reinaerde.RecordTypeId = businessAccountRecordTypeId;

insert(reinaerde);
//Account reinaerde = [SELECT Id FROM Account WHERE Name = 'Reinaerde'];

Account abronaCare = new Account();
abronaCare.Name = 'Abrona'; // Set the name of the hospital
abronaCare.Type = 'Care Provider'; // Set the type of the account
abronaCare.Industry = 'Healthcare'; // Set the industry of the account
abronaCare.BillingStreet = 'Sterrenberglaan 6'; // Set the billing address street
abronaCare.BillingCity = 'Huis Ter Heide'; // Set the billing address street
abronaCare.BillingState = 'Noord-Holland'; // Set the billing address street
abronaCare.BillingPostalCode = '3712 XA'; // Set the billing address street
abronaCare.BillingCountry = 'NL'; // Set the billing address country
abronaCare.Phone = '+310882019911';
abronaCare.Website = 'https://www.abrona.nl/nl';
abronaCare.RecordTypeId = businessAccountRecordTypeId;

insert(abronaCare);
//Account abronaCare = [SELECT Id FROM Account WHERE Name = 'Abrona'];

Contact patientContactKarel = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Karel',
    LastName = 'Groenendijk',
    AccountId = twbCare.Id,
    Phone = '+31638886128',
    HomePhone = '+31638886128',
    //Gender = 'Male',
    Birthdate = Date.newInstance(1960, 07, 15),
    //MaritalStatus = 'Married',
    Email = 'karel@nl.com',
    MailingStreet = 'Street 1',
    MailingCity = 'Hilversum',
    MailingState = 'Noord Holland',
    MailingPostalCode = '1216',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 1',
    OtherCity = 'Hilversum',
    OtherState = 'Noord Holland',
    OtherPostalCode = '1216',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    OtherCountry = 'Nederland',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactKarel;


Contact patientContactPieter = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Pieter',
    LastName = 'Dirk',
    AccountId = envidaCare.Id,
    Phone = '+447859730937',
    HomePhone = '+447859730937',
    MailingStreet = 'Street 2',
    MailingCity = 'Haarlem',
    MailingState = 'Noord Holland',
    MailingPostalCode = '2012',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 2',
    OtherCity = 'Haarlem',
    OtherState = 'Noord Holland',
    OtherPostalCode = '2012',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    OtherCountry = 'Nederland',
    Birthdate = Date.newInstance(1970, 04, 29),
    Email = 'pieter@nl.com',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactPieter;


Contact patientContactJohan = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Johan',
    LastName = 'Hendrik',
    AccountId = envidaCare.Id,
    Phone = '+447706218252',
    HomePhone = '+447706218252',
    MailingStreet = 'Street 3',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5411',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 3',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5411',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    Birthdate = Date.newInstance(1960, 07, 15),
    Email = 'johan@nl.com',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactJohan;

Contact patientContactRimon = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Rimon',
    LastName = 'Hanna',
    AccountId = envidaCare.Id,
    Phone = '+31626020860',
    HomePhone = '+31626020860',
    MailingStreet = 'Street 3',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5411',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 3',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5411',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactRimon;

Contact patientContactRaoul = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Raoul',
    LastName = 'Zaal',
    AccountId = envidaCare.Id,
    Phone = '+31619959391',
    HomePhone = '+31619959391',
    MailingStreet = 'Street 3',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5411',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 3',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5411',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactRaoul;

Contact patientContactAndrew = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Andrew',
    LastName = 'Hanna',
    AccountId = envidaCare.Id,
    Phone = '+971528679759',
    HomePhone = '+971528679759',
    MailingStreet = 'Street 3',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5411',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 3',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5411',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactAndrew;

Contact patientContactLuk = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Luk',
    LastName = 'Dylan',
    AccountId = cordaanCare.Id,
    Phone = '+3134343434',
    HomePhone = '+3134343434',
    MailingStreet = 'Street 4',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5412',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 3',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5412',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactLuk;

Contact patientContactFloris = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Floris',
    LastName = 'Bas',
    AccountId = cordaanCare.Id,
    Phone = '+319432783232',
    HomePhone = '+319432783232',
    MailingStreet = 'Street 5',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5413',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 5',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5413',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactFloris;


Contact patientContactEmma = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Emma',
    LastName = 'Alexander',
    AccountId = twbCare.Id,
    Phone = '+3193434282',
    HomePhone = '+3193434282',
    MailingStreet = 'Street 6',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5414',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 6',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5414',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactEmma;

Contact patientContactNora = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Nora',
    LastName = 'Bram',
    AccountId = twbCare.Id,
    Phone = '+31834248319',
    HomePhone = '+31834248319',
    MailingStreet = 'Street 7',
    MailingCity = 'Zeeland',
    MailingState = 'Noord Holland',
    MailingPostalCode = '5415',
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 7',
    OtherCity = 'Zeeland',
    OtherState = 'Noord Holland',
    OtherPostalCode = '5415',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactNora;

Contact patientContactBartje = new Contact(
    Salutation = 'Mr.',
    Title = 'Client',
    FirstName = 'Bartje',
    LastName = 'Bartels',
    AccountId = twbCare.Id,
    Phone = '+31646354657',
    HomePhone = '+31646354657',
    Email = 'bartels@mail.com',
    MailingStreet = 'De Hazelaar 7',
    MailingCity = 'Hoogerheide',
    MailingState = 'Noord Holland',
    MailingPostalCode = '4631 AP',
    MailingCountry = 'Nederland',
    OtherStreet = 'De Hazelaar 7',
    OtherCity = 'Hoogerheide',
    OtherState = 'Noord Holland',
    OtherPostalCode = '4631 AP',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    OtherCountry = 'Nederland',
    //OnsId__c = '4564',
    RecordTypeId = clientContactRecordTypeId
);
insert patientContactBartje;
/*

Account accountOns = new Account(
    Name = 'Ons',
    Phone = '+31232732837',
    BillingStreet = 'Street 4',
    BillingCity = 'Utrecht',
    BillingState = 'Noord Holland',
    BillingPostalCode = '9991ON',
    BillingCountry = 'Nederland',
    ShippingStreet = 'Street 3',
    ShippingCity = 'Utrecht',
    ShippingState = 'Noord Holland',
    ShippingPostalCode = '9991ON',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ShippingCountry = 'Nederland',
    Industry = 'Healthcare',
    RecordTypeId = businessAccountRecordTypeId
);
insert accountOns;

Account accountLuscii = new Account(
    Name = 'Luscii',
    Phone = '+3137232782',
    BillingStreet = 'Street 5',
    BillingCity = 'Utrecht',
    BillingState = 'Noord Holland',
    BillingPostalCode = '3227LU',
    BillingCountry = 'Nederland',
    ShippingStreet = 'Street 5',
    ShippingCity = 'Utrecht',
    ShippingState = 'Noord Holland',
    ShippingPostalCode = '3227LU',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    ShippingCountry = 'Nederland',
    Industry = 'Healthcare',
    RecordTypeId = businessAccountRecordTypeId
);
insert accountLuscii;
*/