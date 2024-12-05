Id careCircleRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareCircle').getRecordTypeId();
Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

Id envidaCareId;
Id amarantCareId;
Id abronaCareId;
Id reinaerdeId;
Id catharinaZiekenhuisId;
Id industriesBusinessRecordTypeId;
Id twbCareId;

List<PackageLicense> packageLicenseRecordList = new List<PackageLicense> ([SELECT Id, AllowedLicenses,CreatedDate,ExpirationDate,IsProvisioned,LastModifiedDate,NamespacePrefix,Status,SystemModstamp,UsedLicenses FROM PackageLicense WHERE NamespacePrefix = 'HealthCloudGA' LIMIT 1]);
if (!packageLicenseRecordList.isEmpty()){
    industriesBusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
}

Account envidaCare = [SELECT Id FROM Account WHERE Name = 'Envida'];
envidaCareId = envidaCare.Id;

Account amarantCare = [SELECT Id FROM Account WHERE Name = 'Amarant'];
amarantCareId = amarantCare.Id;

Account catharinaZiekenhuis = [SELECT Id FROM Account WHERE Name = 'Catharina Ziekenhuis'];
catharinaZiekenhuisId = catharinaZiekenhuis.Id;

Account reinaerde = [SELECT Id FROM Account WHERE Name = 'Reinaerde'];
reinaerdeId = reinaerde.Id;

Account abronaCare = [SELECT Id FROM Account WHERE Name = 'Abrona'];
abronaCareId = abronaCare.Id;

Account twbCare = [SELECT Id FROM Account WHERE Name = 'Thuiszorg West-Brabant'];
twbCareId = twbCare.Id;

Date contractStartDate = System.today();

Contact patientContactJansen = [SELECT Id FROM Contact WHERE LastName = 'Groenendijk'];


//Philaa first : 1216 Hilversum
Contact tBakhuysCareTeam = new Contact();
tBakhuysCareTeam.Title = 'Care Team';
tBakhuysCareTeam.FirstName = '\'t Bakhuys';
tBakhuysCareTeam.LastName = 'Philadelphia Care';
tBakhuysCareTeam.Email = 'bakhuys@philadelphia.nl';
tBakhuysCareTeam.RecordTypeId = careCircleRecordTypeId; // set the record type ID
tBakhuysCareTeam.AccountId = envidaCareId; // set the account ID
tBakhuysCareTeam.Phone = '(123) 232-2321'; // set the home phone number
tBakhuysCareTeam.HomePhone = '(123) 232-2321'; // set the home phone number
tBakhuysCareTeam.MobilePhone = '(123) 232-2321'; // set the mobile phone number
insert tBakhuysCareTeam;

//Philaa second : 2012 Haarlem
Contact tPaleisCareTeam = new Contact();
tPaleisCareTeam.Title = 'Care Team';
tPaleisCareTeam.FirstName = '\'t Paleis';
tPaleisCareTeam.LastName = 'Philadelphia Care';
tPaleisCareTeam.Email = 'hetpaleishaarlem@philadelphia.nl';
tPaleisCareTeam.RecordTypeId = careCircleRecordTypeId; // set the record type ID
tPaleisCareTeam.AccountId = envidaCareId; // set the account ID
tPaleisCareTeam.Phone = '(123) 462-5672'; // set the home phone number
tPaleisCareTeam.HomePhone = '(123) 462-5672'; // set the home phone number
tPaleisCareTeam.MobilePhone = '(123) 462-5672'; // set the mobile phone number
insert tPaleisCareTeam;

//Service Team Amarant : 5411 Zeeland
Contact amarantCareTeam = new Contact();
amarantCareTeam.Title = 'Care Team';
amarantCareTeam.FirstName = 'Service Team Amarant';
amarantCareTeam.LastName = 'Care';
amarantCareTeam.Email = 'amarantCareTeam@nl.com';
amarantCareTeam.RecordTypeId = careCircleRecordTypeId; // set the record type ID
amarantCareTeam.AccountId = amarantCareId; // set the account ID
amarantCareTeam.Phone = '(123) 456-9722'; // set the home phone number
amarantCareTeam.HomePhone = '(123) 178-9722'; // set the home phone number
amarantCareTeam.MobilePhone = '(123) 178-9722'; // set the mobile phone number
insert amarantCareTeam;


//AbronaCare : 3447 Haarlem
Contact abronaCareTeam = new Contact();
abronaCareTeam.Title = 'Care Team';
abronaCareTeam.FirstName = 'Woerden-Gouda';
abronaCareTeam.LastName = 'Abrona Care';
abronaCareTeam.Email = 'registrationsWoerden@abrona.nl';
abronaCareTeam.RecordTypeId = careCircleRecordTypeId; // set the record type ID
abronaCareTeam.AccountId = abronaCareId; // set the account ID
abronaCareTeam.Phone = '(123) 456-9722'; // set the home phone number
abronaCareTeam.HomePhone = '(123) 178-9722'; // set the home phone number
abronaCareTeam.MobilePhone = '(123) 178-9722'; // set the mobile phone number
insert abronaCareTeam;

//Philaa first
Contact reinarderCareTeam = new Contact();
reinarderCareTeam.Title = 'Care Team';
reinarderCareTeam.FirstName = 'John Doe';
reinarderCareTeam.LastName = 'Care Team';
reinarderCareTeam.Email = 'reinarderCareTeam@nl.com';
reinarderCareTeam.RecordTypeId = careCircleRecordTypeId; // set the record type ID
reinarderCareTeam.AccountId = reinaerdeId; // set the account ID
reinarderCareTeam.Phone = '(123) 456-7890'; // set the home phone number
reinarderCareTeam.HomePhone = '(123) 456-7890'; // set the home phone number
reinarderCareTeam.MobilePhone = '(123) 456-7890'; // set the mobile phone number
insert reinarderCareTeam;

//Unknown Caller
Contact unknownCaller = new Contact();
unknownCaller.FirstName = 'Unknown';
unknownCaller.LastName = 'Caller';
unknownCaller.AccountId = twbCare.Id; // set the account ID
unknownCaller.RecordTypeId = careCircleRecordTypeId; // set the record type ID
insert unknownCaller;

// List<OperatingHours> morningOperatingHoursList = new List<OperatingHours> ();
// List<OperatingHours> nightOperatingHoursList = new List<OperatingHours> ();

// OperatingHours tBakhuysOperatingHoursMorning = new OperatingHours();
// tBakhuysOperatingHoursMorning.Name = '\'t Bakhuys Care Team Operating Hours';
// tBakhuysOperatingHoursMorning.Syntilio__CareTeam__c = tBakhuysCareTeam.Id;
// tBakhuysOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// tBakhuysOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
// tBakhuysOperatingHoursMorning.TimeZone = 'Europe/Amsterdam';

// morningOperatingHoursList.add(tBakhuysOperatingHoursMorning);
// insert tBakhuysOperatingHoursMorning;


// OperatingHours tBakhuysOperatingHoursNight = new OperatingHours();
// tBakhuysOperatingHoursNight.Name = '\'t Bakhuys Night Operating Hours';
// tBakhuysOperatingHoursNight.Syntilio__CareTeam__c = tBakhuysCareTeam.Id;
// tBakhuysOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// tBakhuysOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
// tBakhuysOperatingHoursNight.TimeZone = 'Europe/Amsterdam';
// nightOperatingHoursList.add(tBakhuysOperatingHoursNight);

// insert tBakhuysOperatingHoursNight;

// OperatingHours tPaleisOperatingHoursMorning = new OperatingHours();
// tPaleisOperatingHoursMorning.Name = '\'t Paleis Morning Operating Hours';
// tPaleisOperatingHoursMorning.Syntilio__CareTeam__c = tPaleisCareTeam.Id;
// tPaleisOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// tPaleisOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
// tPaleisOperatingHoursMorning.TimeZone = 'Europe/Amsterdam';
// morningOperatingHoursList.add(tPaleisOperatingHoursMorning);

// insert tPaleisOperatingHoursMorning;

// OperatingHours tPaleisOperatingHoursNight = new OperatingHours();
// tPaleisOperatingHoursNight.Name = '\'t Paleis Night Operating Hours';
// tPaleisOperatingHoursNight.Syntilio__CareTeam__c = tPaleisCareTeam.Id;
// tPaleisOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// tPaleisOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
// tPaleisOperatingHoursNight.TimeZone = 'Europe/Amsterdam';
// nightOperatingHoursList.add(tPaleisOperatingHoursNight);

// insert tPaleisOperatingHoursNight;


// OperatingHours amarantOperatingHoursMorning = new OperatingHours();
// amarantOperatingHoursMorning.Name = 'Amarant Morning Operating Hours';
// amarantOperatingHoursMorning.Syntilio__CareTeam__c = amarantCareTeam.Id;
// amarantOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// amarantOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
// amarantOperatingHoursMorning.TimeZone = 'Europe/Amsterdam';
// morningOperatingHoursList.add(amarantOperatingHoursMorning);

// insert amarantOperatingHoursMorning;

// OperatingHours amarantOperatingHoursNight = new OperatingHours();
// amarantOperatingHoursNight.Name = 'Amarant Night Operating Hours';
// amarantOperatingHoursNight.Syntilio__CareTeam__c = amarantCareTeam.Id;
// amarantOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// amarantOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
// amarantOperatingHoursNight.TimeZone = 'Europe/Amsterdam';
// nightOperatingHoursList.add(amarantOperatingHoursNight);

// insert amarantOperatingHoursNight;

// OperatingHours woerdenGoudaAbronaOperatingHoursMorning = new OperatingHours();
// woerdenGoudaAbronaOperatingHoursMorning.Name = 'Woerden-Gouda Abrona Morning Operating Hours';
// woerdenGoudaAbronaOperatingHoursMorning.Syntilio__CareTeam__c = abronaCareTeam.Id;
// woerdenGoudaAbronaOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// woerdenGoudaAbronaOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
// woerdenGoudaAbronaOperatingHoursMorning.TimeZone = 'Europe/Amsterdam';
// morningOperatingHoursList.add(woerdenGoudaAbronaOperatingHoursMorning);

// insert woerdenGoudaAbronaOperatingHoursMorning;

// OperatingHours woerdenGoudaAbronaOperatingHoursNight = new OperatingHours();
// woerdenGoudaAbronaOperatingHoursNight.Name = 'Woerden-Gouda Abrona Night Operating Hours';
// woerdenGoudaAbronaOperatingHoursNight.Syntilio__CareTeam__c = abronaCareTeam.Id;
// woerdenGoudaAbronaOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
// woerdenGoudaAbronaOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
// woerdenGoudaAbronaOperatingHoursNight.TimeZone = 'Europe/Amsterdam';
// nightOperatingHoursList.add(woerdenGoudaAbronaOperatingHoursNight);

// insert woerdenGoudaAbronaOperatingHoursNight;
 
List<Syntilio__CareOperatingHours__c> careMorningOperatingHoursList = new List<Syntilio__CareOperatingHours__c> ();
List<Syntilio__CareOperatingHours__c> careNightOperatingHoursList = new List<Syntilio__CareOperatingHours__c> ();

Syntilio__CareOperatingHours__c CaretBakhuysOperatingHoursMorning = new Syntilio__CareOperatingHours__c();
CaretBakhuysOperatingHoursMorning.Name = '\'t Bakhuys Care Team Syntilio__CareOperatingHours__c';
CaretBakhuysOperatingHoursMorning.Syntilio__CareCircleId__c = tBakhuysCareTeam.Id;
CaretBakhuysOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
CaretBakhuysOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
CaretBakhuysOperatingHoursMorning.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';

careMorningOperatingHoursList.add(CaretBakhuysOperatingHoursMorning);
insert CaretBakhuysOperatingHoursMorning;


Syntilio__CareOperatingHours__c CaretBakhuysOperatingHoursNight = new Syntilio__CareOperatingHours__c();
CaretBakhuysOperatingHoursNight.Name = '\'t Bakhuys Night Syntilio__CareOperatingHours__c';
CaretBakhuysOperatingHoursNight.Syntilio__CareCircleId__c = tBakhuysCareTeam.Id;
CaretBakhuysOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
CaretBakhuysOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
CaretBakhuysOperatingHoursNight.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';
careNightOperatingHoursList.add(CaretBakhuysOperatingHoursNight);

insert CaretBakhuysOperatingHoursNight;

Syntilio__CareOperatingHours__c caretPaleisOperatingHoursMorning = new Syntilio__CareOperatingHours__c();
caretPaleisOperatingHoursMorning.Name = '\'t Paleis Morning Syntilio__CareOperatingHours__c';
caretPaleisOperatingHoursMorning.Syntilio__CareCircleId__c = tPaleisCareTeam.Id;
caretPaleisOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
caretPaleisOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
caretPaleisOperatingHoursMorning.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';
careMorningOperatingHoursList.add(caretPaleisOperatingHoursMorning);

insert caretPaleisOperatingHoursMorning;

Syntilio__CareOperatingHours__c caretPaleisOperatingHoursNight = new Syntilio__CareOperatingHours__c();
caretPaleisOperatingHoursNight.Name = '\'t Paleis Night Syntilio__CareOperatingHours__c';
caretPaleisOperatingHoursNight.Syntilio__CareCircleId__c = tPaleisCareTeam.Id;
caretPaleisOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
caretPaleisOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
caretPaleisOperatingHoursNight.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';
careNightOperatingHoursList.add(caretPaleisOperatingHoursNight);

insert caretPaleisOperatingHoursNight;  

Syntilio__CareOperatingHours__c careamarantOperatingHoursMorning = new Syntilio__CareOperatingHours__c();
careamarantOperatingHoursMorning.Name = 'Amarant Morning Syntilio__CareOperatingHours__c';
careamarantOperatingHoursMorning.Syntilio__CareCircleId__c = amarantCareTeam.Id;
careamarantOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
careamarantOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
careamarantOperatingHoursMorning.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';
careMorningOperatingHoursList.add(careamarantOperatingHoursMorning);

insert careamarantOperatingHoursMorning;

Syntilio__CareOperatingHours__c careamarantOperatingHoursNight = new Syntilio__CareOperatingHours__c();
careamarantOperatingHoursNight.Name = 'Amarant Night Syntilio__CareOperatingHours__c';
careamarantOperatingHoursNight.Syntilio__CareCircleId__c = amarantCareTeam.Id;
careamarantOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
careamarantOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
careamarantOperatingHoursNight.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';
careNightOperatingHoursList.add(careamarantOperatingHoursNight);

insert careamarantOperatingHoursNight;

Syntilio__CareOperatingHours__c carewoerdenGoudaAbronaOperatingHoursMorning = new Syntilio__CareOperatingHours__c();
carewoerdenGoudaAbronaOperatingHoursMorning.Name = 'Woerden-Gouda Abrona Morning Syntilio__CareOperatingHours__c';
carewoerdenGoudaAbronaOperatingHoursMorning.Syntilio__CareCircleId__c = abronaCareTeam.Id;
carewoerdenGoudaAbronaOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
carewoerdenGoudaAbronaOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
carewoerdenGoudaAbronaOperatingHoursMorning.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';
careMorningOperatingHoursList.add(carewoerdenGoudaAbronaOperatingHoursMorning);

insert carewoerdenGoudaAbronaOperatingHoursMorning;

Syntilio__CareOperatingHours__c carewoerdenGoudaAbronaOperatingHoursNight = new Syntilio__CareOperatingHours__c();
carewoerdenGoudaAbronaOperatingHoursNight.Name = 'Woerden-Gouda Abrona Night Syntilio__CareOperatingHours__c';
carewoerdenGoudaAbronaOperatingHoursNight.Syntilio__CareCircleId__c = abronaCareTeam.Id;
carewoerdenGoudaAbronaOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
carewoerdenGoudaAbronaOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
carewoerdenGoudaAbronaOperatingHoursNight.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';
careNightOperatingHoursList.add(carewoerdenGoudaAbronaOperatingHoursNight);

insert carewoerdenGoudaAbronaOperatingHoursNight;

//////

List<String> weekDaysList = new List<String> {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
List<Syntilio__CareTimeSlot__c> morningTimeSlotList = new List<Syntilio__CareTimeSlot__c>();
List<Syntilio__CareTimeSlot__c> nightTimeSlotList = new List<Syntilio__CareTimeSlot__c>();

Integer dayWeeekMorningCounter = 0;
For (Syntilio__CareOperatingHours__c morningOperatingHoursRecord : careMorningOperatingHoursList){
    for (String weekDay : weekDaysList){
        Syntilio__CareTimeSlot__c timeSlotMorning = new Syntilio__CareTimeSlot__c();
        timeSlotMorning.Syntilio__DayOfWeek__c = weekDay;
        timeSlotMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
        timeSlotMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
        timeSlotMorning.Syntilio__CareOperatingHoursId__c = morningOperatingHoursRecord.Id;
        morningTimeSlotList.add(timeSlotMorning);
    }
}
Integer dayWeeekNighCounter = 0;
For (Syntilio__CareOperatingHours__c nightOperatingHoursRecord : careNightOperatingHoursList){
    for (String weekDay : weekDaysList){
        Syntilio__CareTimeSlot__c timeSlotNight = new Syntilio__CareTimeSlot__c();
        timeSlotNight.Syntilio__DayOfWeek__c = weekDay;
        timeSlotNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
        timeSlotNight.Syntilio__EndTime__c	 = Time.newInstance(23, 59, 59, 59);
        timeSlotNight.Syntilio__CareOperatingHoursId__c = nightOperatingHoursRecord.Id;
        nightTimeSlotList.add(timeSlotNight);
    }
}

insert morningTimeSlotList;
insert nightTimeSlotList;
/*
ServiceTerritory tBakhuysMorningServiceTerritory1216 = new ServiceTerritory();
tBakhuysMorningServiceTerritory1216.Name = '\'t Bakhuys Morning Shift Service Territory';
tBakhuysMorningServiceTerritory1216.OperatingHoursId = tBakhuysOperatingHoursMorning.Id;
tBakhuysMorningServiceTerritory1216.IsActive = true;
tBakhuysMorningServiceTerritory1216.PostalCode = '1216';
tBakhuysMorningServiceTerritory1216.City = 'Hilversum';
insert tBakhuysMorningServiceTerritory1216;

ServiceTerritory tBakhuysNightServiceTerritory1216 = new ServiceTerritory();
tBakhuysNightServiceTerritory1216.Name = '\'t Bakhuys Night Shift Service Territory';
tBakhuysNightServiceTerritory1216.OperatingHoursId = tBakhuysOperatingHoursNight.Id;
tBakhuysNightServiceTerritory1216.IsActive = true;
tBakhuysNightServiceTerritory1216.PostalCode = '1216';
tBakhuysNightServiceTerritory1216.City = 'Hilversum';

insert tBakhuysNightServiceTerritory1216;

ServiceTerritory tPaleisMorningServiceTerritory2012 = new ServiceTerritory();
tPaleisMorningServiceTerritory2012.Name = '\'t Paleis Morning Shift Service Territory';
tPaleisMorningServiceTerritory2012.OperatingHoursId = tPaleisOperatingHoursMorning.Id;
tPaleisMorningServiceTerritory2012.IsActive = true;
tPaleisMorningServiceTerritory2012.PostalCode = '2012'; 
tPaleisMorningServiceTerritory2012.City = 'Haarlem';
insert tPaleisMorningServiceTerritory2012;

ServiceTerritory tPaleisNightServiceTerritory2012 = new ServiceTerritory();
tPaleisNightServiceTerritory2012.Name = '\'t Paleis Night Shift Service Territory';
tPaleisNightServiceTerritory2012.OperatingHoursId = tPaleisOperatingHoursNight.Id;
tPaleisNightServiceTerritory2012.IsActive = true;
tPaleisNightServiceTerritory2012.PostalCode = '2012';
tPaleisNightServiceTerritory2012.City = 'Haarlem';

insert tPaleisNightServiceTerritory2012;


///////////
ServiceTerritory ambulantAmsterdamMorningServiceTerritory1069 = new ServiceTerritory();
ambulantAmsterdamMorningServiceTerritory1069.Name = 'Ambulant Amsterdam Morning Shift Service Territory';
ambulantAmsterdamMorningServiceTerritory1069.OperatingHoursId = tPaleisOperatingHoursMorning.Id;
ambulantAmsterdamMorningServiceTerritory1069.IsActive = true;
ambulantAmsterdamMorningServiceTerritory1069.PostalCode = '1069';  
ambulantAmsterdamMorningServiceTerritory1069.City = 'Amsterdam';
insert ambulantAmsterdamMorningServiceTerritory1069;

ServiceTerritory ambulantAmsterdamNightServiceTerritory1069 = new ServiceTerritory();
ambulantAmsterdamNightServiceTerritory1069.Name = 'Ambulant Amsterdam Night Shift Service Territory';
ambulantAmsterdamNightServiceTerritory1069.OperatingHoursId = tPaleisOperatingHoursNight.Id;
ambulantAmsterdamNightServiceTerritory1069.IsActive = true;
ambulantAmsterdamNightServiceTerritory1069.PostalCode = '1069';
ambulantAmsterdamNightServiceTerritory1069.City = 'Amsterdam';

insert ambulantAmsterdamNightServiceTerritory1069;

ServiceTerritory amarantMorningServiceTerritory5411 = new ServiceTerritory();
amarantMorningServiceTerritory5411.Name = 'Amarant Morning Shift Service Territory';
amarantMorningServiceTerritory5411.OperatingHoursId = tPaleisOperatingHoursMorning.Id;
amarantMorningServiceTerritory5411.IsActive = true;
amarantMorningServiceTerritory5411.PostalCode = '5411';  
amarantMorningServiceTerritory5411.City = 'Zeeland';
insert amarantMorningServiceTerritory5411;

ServiceTerritory amarantNightServiceTerritory5411 = new ServiceTerritory();
amarantNightServiceTerritory5411.Name = 'Ambulant Night Shift Service Territory';
amarantNightServiceTerritory5411.OperatingHoursId = tPaleisOperatingHoursNight.Id;
amarantNightServiceTerritory5411.IsActive = true;
amarantNightServiceTerritory5411.PostalCode = '5411';
amarantNightServiceTerritory5411.City = 'Zeeland';

insert amarantNightServiceTerritory5411;


ServiceTerritory abronaMorningServiceTerritory3447 = new ServiceTerritory();
abronaMorningServiceTerritory3447.Name = 'Abrona Morning Shift Service Territory';
abronaMorningServiceTerritory3447.OperatingHoursId = tPaleisOperatingHoursMorning.Id;
abronaMorningServiceTerritory3447.IsActive = true;
abronaMorningServiceTerritory3447.PostalCode = '3447';  
abronaMorningServiceTerritory3447.City = 'Haarlem';
insert abronaMorningServiceTerritory3447;

ServiceTerritory abronaNightServiceTerritory3447 = new ServiceTerritory();
abronaNightServiceTerritory3447.Name = 'Abrona Night Shift Service Territory';
abronaNightServiceTerritory3447.OperatingHoursId = tPaleisOperatingHoursNight.Id;
abronaNightServiceTerritory3447.IsActive = true;
abronaNightServiceTerritory3447.PostalCode = '3447';
abronaNightServiceTerritory3447.City = 'Haarlem';

insert abronaNightServiceTerritory3447;

// Patients Zip Codes Karel:1216, Pieter:2012, Johan:5411
Syntilio__ServiceZipCode__c tBakhuysMorningServiceZipCode1216 = new Syntilio__ServiceZipCode__c();
tBakhuysMorningServiceZipCode1216.Name = '\'t Bakhuys Morning 1216';
tBakhuysMorningServiceZipCode1216.Syntilio__ContactId__c = tBakhuysCareTeam.Id;
//tBakhuysMorningServiceZipCode1216.Syntilio__ZipCodeToServiceTerritory__c = tBakhuysMorningServiceTerritory1216.Id;
insert tBakhuysMorningServiceZipCode1216;

Syntilio__ServiceZipCode__c tBakhuysNightServiceZipCode1216 = new Syntilio__ServiceZipCode__c();
tBakhuysNightServiceZipCode1216.Name = '\'t Bakhuys Night 1216';
tBakhuysNightServiceZipCode1216.Syntilio__ContactId__c = tBakhuysCareTeam.Id;
//tBakhuysNightServiceZipCode1216.Syntilio__ZipCodeToServiceTerritory__c = tBakhuysNighServiceTerritory1216.Id;
insert tBakhuysNightServiceZipCode1216;

Syntilio__ServiceZipCode__c tBakhuysMorningServiceZipCode2012 = new Syntilio__ServiceZipCode__c();
tBakhuysMorningServiceZipCode2012.Name = '\'t Bakhuys Morning 2012';
tBakhuysMorningServiceZipCode2012.Syntilio__ContactId__c = tBakhuysCareTeam.Id;
//tBakhuysMorningServiceZipCode2012.Syntilio__ZipCodeToServiceTerritory__c = tBakhuysMorningServiceTerritory1216.Id;
insert tBakhuysMorningServiceZipCode2012;

Syntilio__ServiceZipCode__c tBakhuysNightServiceZipCode2012 = new Syntilio__ServiceZipCode__c();
tBakhuysNightServiceZipCode2012.Name = '\'t Bakhuys Night 2012';
tBakhuysNightServiceZipCode2012.Syntilio__ContactId__c = tBakhuysCareTeam.Id;
//tBakhuysNightServiceZipCode2012.Syntilio__ZipCodeToServiceTerritory__c = tBakhuysNighServiceTerritory1216.Id;
insert tBakhuysNightServiceZipCode2012;

/*
Syntilio__ServiceZipCode__c tPaleisMorningServiceZipCode = new Syntilio__ServiceZipCode__c();
tPaleisMorningServiceZipCode.Name = '\'t Paleis Morning 2012';
tPaleisMorningServiceZipCode.Syntilio__ContactId__c = tPaleisCareTeam.Id;
//tPaleisMorningServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = tPaleisMorningServiceTerritory2012.Id;
insert tPaleisMorningServiceZipCode;

Syntilio__ServiceZipCode__c tPaleisNightServiceZipCode = new Syntilio__ServiceZipCode__c();
tPaleisNightServiceZipCode.Name = '\'t Paleis Night 2012';
tPaleisNightServiceZipCode.Syntilio__ContactId__c = tPaleisCareTeam.Id;
//tPaleisNightServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = tPaleisNightServiceTerritory2012.Id;
insert tPaleisNightServiceZipCode;
*/

Syntilio__ServiceZipCode__c tPaleisMorningServiceZipCode5411 = new Syntilio__ServiceZipCode__c();
tPaleisMorningServiceZipCode5411.Name = '\'t Paleis Morning 5411';
tPaleisMorningServiceZipCode5411.Syntilio__ContactId__c = tPaleisCareTeam.Id;
tPaleisMorningServiceZipCode5411.Syntilio__ZipCode__c = '5411';
//tPaleisMorningServiceZipCode5411.Syntilio__ZipCodeToServiceTerritory__c = tPaleisMorningServiceTerritory2012.Id;
insert tPaleisMorningServiceZipCode5411;

Syntilio__ServiceZipCode__c tPaleisNightServiceZipCode5411 = new Syntilio__ServiceZipCode__c();
tPaleisNightServiceZipCode5411.Name = '\'t Paleis Night 5411';
tPaleisNightServiceZipCode5411.Syntilio__ContactId__c = tPaleisCareTeam.Id;
tPaleisNightServiceZipCode5411.Syntilio__ZipCode__c = '5411';
//tPaleisNightServiceZipCode5411.Syntilio__ZipCodeToServiceTerritory__c = tPaleisNightServiceTerritory2012.Id;
insert tPaleisNightServiceZipCode5411;

/*
Syntilio__ServiceZipCode__c ambulantAmsterdamMorningServiceZipCode = new Syntilio__ServiceZipCode__c();
ambulantAmsterdamMorningServiceZipCode.Name = 'Ambulant Amsterdam Morning 1069';
ambulantAmsterdamMorningServiceZipCode.Syntilio__ContactId__c = ambulantAmsterdamCareTeam.Id;
//ambulantAmsterdamMorningServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = ambulantAmsterdamMorningServiceTerritory1069.Id;
insert ambulantAmsterdamMorningServiceZipCode;

Syntilio__ServiceZipCode__c ambulantAmsterdamNightServiceZipCode = new Syntilio__ServiceZipCode__c();
ambulantAmsterdamNightServiceZipCode.Name = 'Ambulant Amsterdam Night 1069';
ambulantAmsterdamNightServiceZipCode.Syntilio__ContactId__c = ambulantAmsterdamCareTeam.Id;
//ambulantAmsterdamNightServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = ambulantAmsterdamNightServiceTerritory1069.Id;
insert ambulantAmsterdamNightServiceZipCode;
*/

Syntilio__ServiceZipCode__c amarantMorningServiceZipCode1216 = new Syntilio__ServiceZipCode__c();
amarantMorningServiceZipCode1216.Name = 'Amarant Morning 1216';
amarantMorningServiceZipCode1216.Syntilio__ContactId__c = amarantCareTeam.Id;
amarantMorningServiceZipCode1216.Syntilio__ZipCode__c = '1216';
//amarantMorningServiceZipCode1216.Syntilio__ZipCodeToServiceTerritory__c = amarantMorningServiceTerritory5411.Id;
insert amarantMorningServiceZipCode1216;

Syntilio__ServiceZipCode__c amarantNightServiceZipCode1216 = new Syntilio__ServiceZipCode__c();
amarantNightServiceZipCode1216.Name = 'Amarant Night 1216';
amarantNightServiceZipCode1216.Syntilio__ZipCode__c = '1216';
amarantNightServiceZipCode1216.Syntilio__ContactId__c = amarantCareTeam.Id;
//amarantNightServiceZipCode1216.Syntilio__ZipCodeToServiceTerritory__c = amarantNightServiceTerritory5411.Id;
insert amarantNightServiceZipCode1216;

Syntilio__ServiceZipCode__c amarantMorningServiceZipCode2012 = new Syntilio__ServiceZipCode__c();
amarantMorningServiceZipCode2012.Name = 'Amarant Morning 2012';
amarantMorningServiceZipCode2012.Syntilio__ZipCode__c = '2012';
amarantMorningServiceZipCode2012.Syntilio__ContactId__c = amarantCareTeam.Id;
//amarantMorningServiceZipCode2012.Syntilio__ZipCodeToServiceTerritory__c = amarantMorningServiceTerritory5411.Id;
insert amarantMorningServiceZipCode2012;

Syntilio__ServiceZipCode__c amarantNightServiceZipCode2012 = new Syntilio__ServiceZipCode__c();
amarantNightServiceZipCode2012.Name = 'Amarant Night 2012';
amarantNightServiceZipCode2012.Syntilio__ZipCode__c = '2012';
amarantNightServiceZipCode2012.Syntilio__ContactId__c = amarantCareTeam.Id;
//amarantNightServiceZipCode2012.Syntilio__ZipCodeToServiceTerritory__c = amarantNightServiceTerritory5411.Id;
insert amarantNightServiceZipCode2012;


Syntilio__ServiceZipCode__c abronaMorningServiceZipCode = new Syntilio__ServiceZipCode__c();
abronaMorningServiceZipCode.Name = 'Abrona Morning 1216';
abronaMorningServiceZipCode.Syntilio__ZipCode__c = '1216';
abronaMorningServiceZipCode.Syntilio__ContactId__c = abronaCareTeam.Id;
//abronaMorningServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = amarantMorningServiceTerritory5411.Id;
insert abronaMorningServiceZipCode;

Syntilio__ServiceZipCode__c abronaNightServiceZipCode = new Syntilio__ServiceZipCode__c();
abronaNightServiceZipCode.Name = 'Abrona Night 1216';
abronaNightServiceZipCode.Syntilio__ZipCode__c = '1216';
abronaNightServiceZipCode.Syntilio__ContactId__c = abronaCareTeam.Id;
//abronaNightServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = abronaMorningServiceTerritory3447.Id;
insert abronaNightServiceZipCode;

Syntilio__ServiceZipCode__c abronaMorningServiceZipCode5411 = new Syntilio__ServiceZipCode__c();
abronaMorningServiceZipCode5411.Name = 'Abrona Morning 5411';
abronaMorningServiceZipCode5411.Syntilio__ZipCode__c = '5411';
abronaMorningServiceZipCode5411.Syntilio__ContactId__c = abronaCareTeam.Id;
//abronaMorningServiceZipCode5411.Syntilio__ZipCodeToServiceTerritory__c = amarantMorningServiceTerritory5411.Id;
insert abronaMorningServiceZipCode5411;

Syntilio__ServiceZipCode__c abronaNightServiceZipCode5411 = new Syntilio__ServiceZipCode__c();
abronaNightServiceZipCode5411.Name = 'Abrona Night 5411';
abronaNightServiceZipCode5411.Syntilio__ZipCode__c = '5411';
abronaNightServiceZipCode5411.Syntilio__ContactId__c = abronaCareTeam.Id;
//abronaNightServiceZipCode5411.Syntilio__ZipCodeToServiceTerritory__c = abronaMorningServiceTerritory3447.Id;
insert abronaNightServiceZipCode5411;

Syntilio__CareOrganizationContractRelation__c careOrganizationContractRelationPhiladelphiaAndAmarant = new Syntilio__CareOrganizationContractRelation__c();
careOrganizationContractRelationPhiladelphiaAndAmarant.Name = 'Philadelphia and Amarant Care Contract';
careOrganizationContractRelationPhiladelphiaAndAmarant.Syntilio__MainAccount__c = envidaCare.Id;
careOrganizationContractRelationPhiladelphiaAndAmarant.Syntilio__CounterPartyAccount__c = amarantCare.Id;
careOrganizationContractRelationPhiladelphiaAndAmarant.Syntilio__DirectContract__c = true;
careOrganizationContractRelationPhiladelphiaAndAmarant.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
careOrganizationContractRelationPhiladelphiaAndAmarant.Syntilio__EndDate__c = Date.newInstance(2026, 06, 01);
insert careOrganizationContractRelationPhiladelphiaAndAmarant;

Syntilio__CareOrganizationContractRelation__c careOrganizationContractRelationPhiladelphiaAndAbrona = new Syntilio__CareOrganizationContractRelation__c();
careOrganizationContractRelationPhiladelphiaAndAbrona.Name = 'Philadelphia and Abrona Care Contract';
careOrganizationContractRelationPhiladelphiaAndAbrona.Syntilio__MainAccount__c = envidaCare.Id;
careOrganizationContractRelationPhiladelphiaAndAbrona.Syntilio__CounterPartyAccount__c = abronaCare.Id;
careOrganizationContractRelationPhiladelphiaAndAbrona.Syntilio__DirectContract__c = true;
careOrganizationContractRelationPhiladelphiaAndAbrona.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
careOrganizationContractRelationPhiladelphiaAndAbrona.Syntilio__EndDate__c = Date.newInstance(2026, 06, 01);
insert careOrganizationContractRelationPhiladelphiaAndAbrona;
