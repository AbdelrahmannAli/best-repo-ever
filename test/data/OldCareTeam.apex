Id careTeamRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CareTeam').getRecordTypeId();
Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

Id careNederlandId;
Id stMaryHospitalId;
Id universitairMedischCentrumGroningenId;
Id reinardeId;
Id catharinaZiekenhuisId;
Id industriesBusinessRecordTypeId;

List<PackageLicense> packageLicenseRecordList = new List<PackageLicense> ([SELECT Id, AllowedLicenses,CreatedDate,ExpirationDate,IsProvisioned,LastModifiedDate,NamespacePrefix,Status,SystemModstamp,UsedLicenses FROM PackageLicense WHERE NamespacePrefix = 'HealthCloudGA' LIMIT 1]);
if (!packageLicenseRecordList.isEmpty()){
    industriesBusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
}

// Create care organization 
Account careNederland = new Account();
careNederland.Name = 'Care Nederland'; // Set the name of the hospital
careNederland.Type = 'Hospital'; // Set the type of the account
careNederland.Industry = 'Healthcare'; // Set the industry of the account
careNederland.BillingStreet = '123 Main St'; // Set the billing address street
careNederland.BillingCountry = 'NL'; // Set the billing address country
careNederland.Website = 'https://www.carenederland.org/carexpertise';
careNederland.Phone = '+31-703105055';
careNederland.RecordTypeId = businessRecordTypeId;

insert(careNederland);
careNederlandId = careNederland.Id;


Account stMaryHospital = new Account();
stMaryHospital.Name = 'St. Mary\'s Hospital'; // Set the name of the hospital
stMaryHospital.Type = 'Hospital'; // Set the type of the account
stMaryHospital.Industry = 'Healthcare'; // Set the industry of the account
stMaryHospital.BillingStreet = '123 Main St'; // Set the billing address street
stMaryHospital.BillingCity = 'Anytown'; // Set the billing address city
stMaryHospital.BillingState = 'CA'; // Set the billing address state
stMaryHospital.BillingPostalCode = '12345'; // Set the billing address postal code
stMaryHospital.BillingCountry = 'USA';
stMaryHospital.Phone = '+31-32323242';
stMaryHospital.RecordTypeId = businessRecordTypeId;
 
insert(stMaryHospital);
stMaryHospitalId = stMaryHospital.Id;


Account catharinaZiekenhuis = new Account();
catharinaZiekenhuis.Name = 'Catharina Ziekenhuis'; // Set the name of the hospital
catharinaZiekenhuis.Type = 'Hospital'; // Set the type of the account
catharinaZiekenhuis.Industry = 'Healthcare'; // Set the industry of the account
catharinaZiekenhuis.BillingStreet = '123 Main St'; // Set the billing address street
catharinaZiekenhuis.BillingCountry = 'NL'; // Set the billing address country
catharinaZiekenhuis.Website = 'https://www.catharinaziekenhuis.nl/';
catharinaZiekenhuis.Phone = '31-40232399111';
catharinaZiekenhuis.RecordTypeId = businessRecordTypeId;


insert(catharinaZiekenhuis);
catharinaZiekenhuisId = catharinaZiekenhuis.Id;



Account reinarde = new Account();
reinarde.Name = 'Reinarde'; // Set the name of the hospital
reinarde.Type = 'Hospital'; // Set the type of the account
reinarde.Industry = 'Healthcare'; // Set the industry of the account
reinarde.BillingCountry = 'NL'; // Set the billing address country
reinarde.Website = 'https://www.reinaerde.nl/';
reinarde.Phone = '31-402399111';
reinarde.RecordTypeId = industriesBusinessRecordTypeId != null ? industriesBusinessRecordTypeId : businessRecordTypeId;

insert(reinarde);
reinardeId = reinarde.Id;

Account universitairMedischCentrumGroningen = new Account();
universitairMedischCentrumGroningen.Name = 'Universitair Medisch Centrum Groningen'; // Set the name of the hospital
universitairMedischCentrumGroningen.Type = 'Hospital'; // Set the type of the account
universitairMedischCentrumGroningen.Industry = 'Healthcare'; // Set the industry of the account
universitairMedischCentrumGroningen.BillingCountry = 'NL'; // Set the billing address country
universitairMedischCentrumGroningen.Phone = '31-23242432';
universitairMedischCentrumGroningen.RecordTypeId = industriesBusinessRecordTypeId != null ? industriesBusinessRecordTypeId : businessRecordTypeId;


insert(universitairMedischCentrumGroningen);
universitairMedischCentrumGroningenId = universitairMedischCentrumGroningen.Id;

Date contractStartDate = System.today();

Contact patientContactJansen = [SELECT Id FROM Contact WHERE LastName = 'Thomas'];

Contact reinarderCareTeam = new Contact();
reinarderCareTeam.Title = 'Care Team';
reinarderCareTeam.FirstName = 'John Doe';
reinarderCareTeam.LastName = 'Care Team';
reinarderCareTeam.Email = 'reinarderCareTeam@nl.com';
reinarderCareTeam.RecordTypeId = careTeamRecordTypeId; // set the record type ID
reinarderCareTeam.AccountId = reinardeId; // set the account ID
reinarderCareTeam.Phone = '(123) 456-7890'; // set the home phone number
reinarderCareTeam.HomePhone = '(123) 456-7890'; // set the home phone number
reinarderCareTeam.MobilePhone = '(123) 456-7890'; // set the mobile phone number
insert reinarderCareTeam;

Contact careNederlandCareTeam = new Contact();
careNederlandCareTeam.Title = 'Care Team';
careNederlandCareTeam.FirstName = 'Care Nederland';
careNederlandCareTeam.LastName = ' Care Team';
careNederlandCareTeam.Email = 'careNederlandCareTeam@nl.com';
careNederlandCareTeam.RecordTypeId = careTeamRecordTypeId; // set the record type ID
careNederlandCareTeam.AccountId = careNederlandId; // set the account ID
careNederlandCareTeam.Phone = '(123) 232-2321'; // set the home phone number
careNederlandCareTeam.HomePhone = '(123) 232-2321'; // set the home phone number
careNederlandCareTeam.MobilePhone = '(123) 232-2321'; // set the mobile phone number
insert careNederlandCareTeam;

Contact stMaryHospitalCareTeam = new Contact();
stMaryHospitalCareTeam.Title = 'Care Team';
stMaryHospitalCareTeam.FirstName = 'ST Mary';
stMaryHospitalCareTeam.LastName = 'Care Team';
stMaryHospitalCareTeam.Email = 'stMaryHospitalCareTeam@nl.com';
stMaryHospitalCareTeam.RecordTypeId = careTeamRecordTypeId; // set the record type ID
stMaryHospitalCareTeam.AccountId = stMaryHospitalId; // set the account ID
stMaryHospitalCareTeam.Phone = '(123) 456-9722'; // set the home phone number
stMaryHospitalCareTeam.HomePhone = '(123) 178-9722'; // set the home phone number
stMaryHospitalCareTeam.MobilePhone = '(123) 178-9722'; // set the mobile phone number
insert stMaryHospitalCareTeam;

Contact universitairMedischCentrumGroningenCareTeam = new Contact();
universitairMedischCentrumGroningenCareTeam.Title = 'Care Team';
universitairMedischCentrumGroningenCareTeam.FirstName = 'Universitair Medisch Centrum Groningen';
universitairMedischCentrumGroningenCareTeam.LastName = 'Care Team';
universitairMedischCentrumGroningenCareTeam.Email = 'universitairMedischCentrumGroningenCareTeam@nl.com';
universitairMedischCentrumGroningenCareTeam.RecordTypeId = careTeamRecordTypeId; // set the record type ID
universitairMedischCentrumGroningenCareTeam.AccountId = universitairMedischCentrumGroningenId; // set the account ID
universitairMedischCentrumGroningenCareTeam.Phone = '(123) 462-5672'; // set the home phone number
universitairMedischCentrumGroningenCareTeam.HomePhone = '(123) 462-5672'; // set the home phone number
universitairMedischCentrumGroningenCareTeam.MobilePhone = '(123) 462-5672'; // set the mobile phone number
insert universitairMedischCentrumGroningenCareTeam;


//Contact stMaryCareTeamRecord = [SELECT Id FROM Contact WHERE FirstName = 'ST Mary' AND LastName = 'Care Team'];
//Contact careNederlandCareTeamRecord = [SELECT Id FROM Contact WHERE FirstName = 'Care Nederland' AND LastName = 'Care Team'];

//Account stMaryAccountRecord = [SELECT Id FROM Account WHERE Name = 'St. Mary\'s Hospital'];
//Account careNederlandAccountRecord = [SELECT Id FROM Account WHERE Name = 'Care Nederland'];
 
Syntilio__CareOperatingHours__c stMaryOperatingHoursMorning = new Syntilio__CareOperatingHours__c();
stMaryOperatingHoursMorning.Name = 'ST Mary Morning Syntilio__CareOperatingHours__c';
stMaryOperatingHoursMorning.Syntilio__CareTeam__c = stMaryHospitalCareTeam.Id;
stMaryOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
stMaryOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
stMaryOperatingHoursMorning.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';

insert stMaryOperatingHoursMorning;

Syntilio__CareOperatingHours__c stMaryOperatingHoursNight = new Syntilio__CareOperatingHours__c();
stMaryOperatingHoursNight.Name = 'ST Mary Night Syntilio__CareOperatingHours__c';
stMaryOperatingHoursNight.Syntilio__CareTeam__c = stMaryHospitalCareTeam.Id;
stMaryOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
stMaryOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
stMaryOperatingHoursNight.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';

insert stMaryOperatingHoursNight;

Syntilio__CareOperatingHours__c careNederlandOperatingHoursMorning = new Syntilio__CareOperatingHours__c();
careNederlandOperatingHoursMorning.Name = 'Care Nederland Morning Syntilio__CareOperatingHours__c';
careNederlandOperatingHoursMorning.Syntilio__CareTeam__c = careNederlandCareTeam.Id;
careNederlandOperatingHoursMorning.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
careNederlandOperatingHoursMorning.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
careNederlandOperatingHoursMorning.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';

insert careNederlandOperatingHoursMorning;

Syntilio__CareOperatingHours__c careNederlandOperatingHoursNight = new Syntilio__CareOperatingHours__c();
careNederlandOperatingHoursNight.Name = 'Care Nederland Night Syntilio__CareOperatingHours__c';
careNederlandOperatingHoursNight.Syntilio__CareTeam__c = careNederlandCareTeam.Id;
careNederlandOperatingHoursNight.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
careNederlandOperatingHoursNight.Syntilio__EndDate__c = Date.newInstance(2024, 06, 30);
careNederlandOperatingHoursNight.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';

insert careNederlandOperatingHoursNight;


Syntilio__CareTimeSlot__c stMaryTimeSlotMondayMorning = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotMondayMorning.Syntilio__DayOfWeek__c = 'Monday';
stMaryTimeSlotMondayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
stMaryTimeSlotMondayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotMondayMorning.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursMorning.Id;
//timeSlotMondayMorning.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotMondayMorning;


Syntilio__CareTimeSlot__c stMaryTimeSlotMondayNight = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotMondayNight.Syntilio__DayOfWeek__c = 'Monday';
stMaryTimeSlotMondayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotMondayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
stMaryTimeSlotMondayNight.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursNight.Id;
//timeSlotMondayNight.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotMondayNight;


Syntilio__CareTimeSlot__c stMaryTimeSlotTuesdayMorning = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotTuesdayMorning.Syntilio__DayOfWeek__c = 'Tuesday';
stMaryTimeSlotTuesdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
stMaryTimeSlotTuesdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotTuesdayMorning.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursMorning.Id;
//timeSlotTuesdayMorning.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotTuesdayMorning;


Syntilio__CareTimeSlot__c stMaryTimeSlotTuesdayNight = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotTuesdayNight.Syntilio__DayOfWeek__c = 'Tuesday';
stMaryTimeSlotTuesdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotTuesdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
stMaryTimeSlotTuesdayNight.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursNight.Id;
//timeSlotTuesdayNight.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotTuesdayNight;

Syntilio__CareTimeSlot__c stMaryTimeSlotWednesdayMorning = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotWednesdayMorning.Syntilio__DayOfWeek__c = 'Wednesday';
stMaryTimeSlotWednesdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
stMaryTimeSlotWednesdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotWednesdayMorning.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursMorning.Id;
//timeSlotWednesdayMorning.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotWednesdayMorning;


Syntilio__CareTimeSlot__c stMaryTimeSlotWednesdayNight = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotWednesdayNight.Syntilio__DayOfWeek__c = 'Wednesday';
stMaryTimeSlotWednesdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotWednesdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
stMaryTimeSlotWednesdayNight.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursNight.Id;
//timeSlotWednesdayNight.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotWednesdayNight;

Syntilio__CareTimeSlot__c stMaryTimeSlotThursdayMorning = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotThursdayMorning.Syntilio__DayOfWeek__c = 'Thursday';
stMaryTimeSlotThursdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
stMaryTimeSlotThursdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotThursdayMorning.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursMorning.Id;
//timeSlotThursdayMorning.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotThursdayMorning;


Syntilio__CareTimeSlot__c stMaryTimeSlotThursdayNight = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotThursdayNight.Syntilio__DayOfWeek__c = 'Thursday';
stMaryTimeSlotThursdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotThursdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
stMaryTimeSlotThursdayNight.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursNight.Id;
//timeSlotThursdayNight.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotThursdayNight;


Syntilio__CareTimeSlot__c stMaryTimeSlotFridayMorning = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotFridayMorning.Syntilio__DayOfWeek__c = 'Friday';
stMaryTimeSlotFridayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
stMaryTimeSlotFridayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotFridayMorning.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursMorning.Id;
//timeSlotFridayMorning.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotFridayMorning;


Syntilio__CareTimeSlot__c stMaryTimeSlotFridayNight = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotFridayNight.Syntilio__DayOfWeek__c = 'Friday';
stMaryTimeSlotFridayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotFridayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
stMaryTimeSlotFridayNight.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursNight.Id;
//timeSlotFridayNight.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotFridayNight;


Syntilio__CareTimeSlot__c stMaryTimeSlotSaturdayMorning = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotSaturdayMorning.Syntilio__DayOfWeek__c = 'Saturday';
stMaryTimeSlotSaturdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
stMaryTimeSlotSaturdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotSaturdayMorning.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursMorning.Id;
//timeSlotSaturdayMorning.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotSaturdayMorning;


Syntilio__CareTimeSlot__c stMaryTimeSlotSaturdayNight = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotSaturdayNight.Syntilio__DayOfWeek__c = 'Saturday';
stMaryTimeSlotSaturdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotSaturdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
stMaryTimeSlotSaturdayNight.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursNight.Id;
//timeSlotSaturdayNight.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotSaturdayNight;

Syntilio__CareTimeSlot__c stMaryTimeSlotSundayMorning = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotSundayMorning.Syntilio__DayOfWeek__c = 'Sunday';
stMaryTimeSlotSundayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
stMaryTimeSlotSundayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotSundayMorning.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursMorning.Id;
//timeSlotSundayMorning.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotSundayMorning;


Syntilio__CareTimeSlot__c stMaryTimeSlotSundayNight = new Syntilio__CareTimeSlot__c();
stMaryTimeSlotSundayNight.Syntilio__DayOfWeek__c = 'Sunday';
stMaryTimeSlotSundayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
stMaryTimeSlotSundayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
stMaryTimeSlotSundayNight.Syntilio__CareOperatingHoursId__c = stMaryOperatingHoursNight.Id;
//timeSlotSundayNight.Type = Date.newInstance(2023, 04, 30);
insert stMaryTimeSlotSundayNight;


Syntilio__CareTimeSlot__c careNederlandTimeSlotMondayMorning = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotMondayMorning.Syntilio__DayOfWeek__c = 'Monday';
careNederlandTimeSlotMondayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
careNederlandTimeSlotMondayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotMondayMorning.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursMorning.Id;
//timeSlotMondayMorning.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotMondayMorning;


Syntilio__CareTimeSlot__c careNederlandTimeSlotMondayNight = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotMondayNight.Syntilio__DayOfWeek__c = 'Monday';
careNederlandTimeSlotMondayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotMondayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
careNederlandTimeSlotMondayNight.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursNight.Id;
//timeSlotMondayNight.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotMondayNight;


Syntilio__CareTimeSlot__c careNederlandTimeSlotTuesdayMorning = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotTuesdayMorning.Syntilio__DayOfWeek__c = 'Tuesday';
careNederlandTimeSlotTuesdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
careNederlandTimeSlotTuesdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotTuesdayMorning.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursMorning.Id;
//timeSlotTuesdayMorning.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotTuesdayMorning;


Syntilio__CareTimeSlot__c careNederlandTimeSlotTuesdayNight = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotTuesdayNight.Syntilio__DayOfWeek__c = 'Tuesday';
careNederlandTimeSlotTuesdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotTuesdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
careNederlandTimeSlotTuesdayNight.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursNight.Id;
//timeSlotTuesdayNight.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotTuesdayNight;

Syntilio__CareTimeSlot__c careNederlandTimeSlotWednesdayMorning = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotWednesdayMorning.Syntilio__DayOfWeek__c = 'Wednesday';
careNederlandTimeSlotWednesdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
careNederlandTimeSlotWednesdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotWednesdayMorning.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursMorning.Id;
//timeSlotWednesdayMorning.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotWednesdayMorning;


Syntilio__CareTimeSlot__c careNederlandTimeSlotWednesdayNight = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotWednesdayNight.Syntilio__DayOfWeek__c = 'Wednesday';
careNederlandTimeSlotWednesdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotWednesdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
careNederlandTimeSlotWednesdayNight.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursNight.Id;
//timeSlotWednesdayNight.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotWednesdayNight;

Syntilio__CareTimeSlot__c careNederlandTimeSlotThursdayMorning = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotThursdayMorning.Syntilio__DayOfWeek__c = 'Thursday';
careNederlandTimeSlotThursdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
careNederlandTimeSlotThursdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotThursdayMorning.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursMorning.Id;
//timeSlotThursdayMorning.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotThursdayMorning;


Syntilio__CareTimeSlot__c careNederlandTimeSlotThursdayNight = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotThursdayNight.Syntilio__DayOfWeek__c = 'Thursday';
careNederlandTimeSlotThursdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotThursdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
careNederlandTimeSlotThursdayNight.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursNight.Id;
//timeSlotThursdayNight.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotThursdayNight;


Syntilio__CareTimeSlot__c careNederlandTimeSlotFridayMorning = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotFridayMorning.Syntilio__DayOfWeek__c = 'Friday';
careNederlandTimeSlotFridayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
careNederlandTimeSlotFridayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotFridayMorning.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursMorning.Id;
//timeSlotFridayMorning.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotFridayMorning;


Syntilio__CareTimeSlot__c careNederlandTimeSlotFridayNight = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotFridayNight.Syntilio__DayOfWeek__c = 'Friday';
careNederlandTimeSlotFridayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotFridayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
careNederlandTimeSlotFridayNight.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursNight.Id;
//timeSlotFridayNight.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotFridayNight;


Syntilio__CareTimeSlot__c careNederlandTimeSlotSaturdayMorning = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotSaturdayMorning.Syntilio__DayOfWeek__c = 'Saturday';
careNederlandTimeSlotSaturdayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
careNederlandTimeSlotSaturdayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotSaturdayMorning.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursMorning.Id;
//timeSlotSaturdayMorning.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotSaturdayMorning;


Syntilio__CareTimeSlot__c careNederlandTimeSlotSaturdayNight = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotSaturdayNight.Syntilio__DayOfWeek__c = 'Saturday';
careNederlandTimeSlotSaturdayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotSaturdayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
careNederlandTimeSlotSaturdayNight.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursNight.Id;
//timeSlotSaturdayNight.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotSaturdayNight;

Syntilio__CareTimeSlot__c careNederlandTimeSlotSundayMorning = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotSundayMorning.Syntilio__DayOfWeek__c = 'Sunday';
careNederlandTimeSlotSundayMorning.Syntilio__StartTime__c	 = Time.newInstance(00, 00, 00, 00);
careNederlandTimeSlotSundayMorning.Syntilio__EndTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotSundayMorning.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursMorning.Id;
//timeSlotSundayMorning.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotSundayMorning;


Syntilio__CareTimeSlot__c careNederlandTimeSlotSundayNight = new Syntilio__CareTimeSlot__c();
careNederlandTimeSlotSundayNight.Syntilio__DayOfWeek__c = 'Sunday';
careNederlandTimeSlotSundayNight.Syntilio__StartTime__c	 = Time.newInstance(12, 00, 00, 00);
careNederlandTimeSlotSundayNight.Syntilio__EndTime__c	 = Time.newInstance(23, 45, 00, 00);
careNederlandTimeSlotSundayNight.Syntilio__CareOperatingHoursId__c = careNederlandOperatingHoursNight.Id;
//timeSlotSundayNight.Type = Date.newInstance(2023, 04, 30);
insert careNederlandTimeSlotSundayNight;

ServiceTerritory stMaryMorningServiceTerritory1017 = new ServiceTerritory();
stMaryMorningServiceTerritory1017.Name = 'ST Mary Morning Shift Service Territory';
stMaryMorningServiceTerritory1017.OperatingHoursId = stMaryOperatingHoursMorning.Id;
stMaryMorningServiceTerritory1017.IsActive = true;
stMaryMorningServiceTerritory1017.PostalCode = '1017';
insert stMaryMorningServiceTerritory1017;

ServiceTerritory stMaryNightServiceTerritory1018 = new ServiceTerritory();
stMaryNightServiceTerritory1018.Name = 'ST Mary Night Shift Service Territory';
stMaryNightServiceTerritory1018.OperatingHoursId = stMaryOperatingHoursNight.Id;
stMaryNightServiceTerritory1018.IsActive = true;
stMaryNightServiceTerritory1018.PostalCode = '1018';
insert stMaryNightServiceTerritory1018;


ServiceTerritory careNederlandMorningServiceTerritory1017 = new ServiceTerritory();
careNederlandMorningServiceTerritory1017.Name = 'Care Nederland Morning Shift Service Territory';
careNederlandMorningServiceTerritory1017.OperatingHoursId = careNederlandOperatingHoursMorning.Id;
careNederlandMorningServiceTerritory1017.IsActive = true;
careNederlandMorningServiceTerritory1017.PostalCode = '1017';
insert careNederlandMorningServiceTerritory1017;

ServiceTerritory careNederlandNightServiceTerritory1018 = new ServiceTerritory();
careNederlandNightServiceTerritory1018.Name = 'Care Nederland Night Shift Service Territory';
careNederlandNightServiceTerritory1018.OperatingHoursId = careNederlandOperatingHoursNight.Id;
careNederlandNightServiceTerritory1018.IsActive = true;
careNederlandNightServiceTerritory1018.PostalCode = '1018';
insert careNederlandNightServiceTerritory1018;


Syntilio__ServiceZipCode__c stMaryMorningServiceZipCode = new Syntilio__ServiceZipCode__c();
stMaryMorningServiceZipCode.Name = 'ST Mary Morning 1017';
stMaryMorningServiceZipCode.Syntilio__ContactId__c = stMaryHospitalCareTeam.Id;
stMaryMorningServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = stMaryMorningServiceTerritory1017.Id;
insert stMaryMorningServiceZipCode;

Syntilio__ServiceZipCode__c stMaryNightServiceZipCode = new Syntilio__ServiceZipCode__c();
stMaryNightServiceZipCode.Name = 'ST Mary Night 1018';
stMaryNightServiceZipCode.Syntilio__ContactId__c = stMaryHospitalCareTeam.Id;
stMaryNightServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = stMaryNightServiceTerritory1018.Id;
insert stMaryNightServiceZipCode;

Syntilio__ServiceZipCode__c careNederlandMorningServiceZipCode = new Syntilio__ServiceZipCode__c();
careNederlandMorningServiceZipCode.Name = 'Care Nederland Morning 1017';
careNederlandMorningServiceZipCode.Syntilio__ContactId__c = careNederlandCareTeam.Id;
careNederlandMorningServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = careNederlandMorningServiceTerritory1017.Id;
insert careNederlandMorningServiceZipCode;

Syntilio__ServiceZipCode__c careNederlandNightServiceZipCode = new Syntilio__ServiceZipCode__c();
careNederlandNightServiceZipCode.Name = 'Care Nederland Night 1018';
careNederlandNightServiceZipCode.Syntilio__ContactId__c = careNederlandCareTeam.Id;
careNederlandNightServiceZipCode.Syntilio__ZipCodeToServiceTerritory__c = careNederlandNightServiceTerritory1018.Id;
insert careNederlandNightServiceZipCode;


Syntilio__CareOrganizationContractRelation__c careOrganizationContractRelationCareNederlandAndStMary = new Syntilio__CareOrganizationContractRelation__c();
careOrganizationContractRelationCareNederlandAndStMary.Name = 'ST Mary Care Nerderland Contract';
careOrganizationContractRelationCareNederlandAndStMary.Syntilio__MainAccount__c = careNederland.Id;
careOrganizationContractRelationCareNederlandAndStMary.Syntilio__CounterPartyAccount__c = stMaryHospital.Id;
careOrganizationContractRelationCareNederlandAndStMary.Syntilio__DirectContract__c = true;
careOrganizationContractRelationCareNederlandAndStMary.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
careOrganizationContractRelationCareNederlandAndStMary.Syntilio__EndDate__c = Date.newInstance(2024, 06, 01);
insert careOrganizationContractRelationCareNederlandAndStMary;

/*
// create b2b contracts 
CareOrganizationContractRelation__c reinardeStMaryContract = new CareOrganizationContractRelation__c();
reinardeStMaryContract.Name = 'Reinarde StMary';
reinardeStMaryContract.MainAccount__c  = reinardeId;
reinardeStMaryContract.CounterPartyAccount__c = stMaryHospitalId;
reinardeStMaryContract.StartDate__c = contractStartDate;

CareOrganizationContractRelation__c careNederlandStMaryContract = new CareOrganizationContractRelation__c();
careNederlandStMaryContract.Name = 'Care Nederland StMary';
careNederlandStMaryContract.MainAccount__c  = careNederlandId;
careNederlandStMaryContract.CounterPartyAccount__c = stMaryHospitalId;
careNederlandStMaryContract.StartDate__c = contractStartDate;

List<CareOrganizationContractRelation__c> careOrganizationContractsList = new List<CareOrganizationContractRelation__c>();
careOrganizationContractsList.add(reinardeStMaryContract);
careOrganizationContractsList.add(careNederlandStMaryContract);

insert(careOrganizationContractsList);
*/