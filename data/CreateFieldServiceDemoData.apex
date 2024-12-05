// Creating a new Account =>

List<Account> hospitalAccounts = new List<Account>();

Account umcUtrecht = new Account(
  Name = 'UMC Utrecht',
  Site = 'Utrecht',
  BillingStreet = 'Hoofddijk 23',
  BillingCity = 'Utrecht',
  BillingCountry = 'Netherlands',
  BillingPostalCode = '3584',
  BillingState = 'CW',
  Phone = '088 75 666 66',
  //HospitalBeds__c = 1042,
  Website = 'https://www.umcutrecht.nl/nl/'
);

hospitalAccounts.add(umcUtrecht);

Account academischMedischCentrum = new Account(
  Name = 'Academisch Medisch Centrum',
  Site = 'Amsterdam',
  BillingStreet = 'Meibergdreef 9',
  BillingCity = 'Amsterdam',
  BillingCountry = 'Netherlands',
  BillingPostalCode = '1105',
  BillingState = 'AZ',
  Phone = '+31 20 566 9111',
  //HospitalBeds__c = 1002,
  Website = 'https://www.amc.nl/web/home.htm'
);

hospitalAccounts.add(academischMedischCentrum);

Account radboudUniversitairMedischCentrum = new Account(
  Name = 'Radboud Universitair Medisch Centrum',
  Site = 'Nijmegen',
  BillingStreet = 'Geert Grooteplein Zuid 10',
  BillingCity = 'Nijmegen',
  BillingCountry = 'Netherlands',
  BillingPostalCode = '6525',
  BillingState = 'GA',
  Phone = '+31 24 361 1111',
  //HospitalBeds__c = 1065,
  Website = 'https://www.radboudumc.nl/en/research'
);

hospitalAccounts.add(radboudUniversitairMedischCentrum);

Account leidsUniversitairMedischCentrum = new Account(
  Name = 'Leids Universitair Medisch Centrum',
  Site = 'Leiden',
  BillingStreet = 'Albinusdreef 2',
  BillingCity = 'Leiden',
  BillingCountry = 'Netherlands',
  BillingPostalCode = '2333',
  BillingState = 'ZA',
  Phone = '+31 71 526 9111',
  //HospitalBeds__c = 882,
  Website = 'https://www.lumc.nl/'
);

hospitalAccounts.add(leidsUniversitairMedischCentrum);

Account erasmusMedischCentrum = new Account(
  Name = 'Erasmus Medisch Centrum',
  Site = 'Rotterdam',
  BillingStreet = ' Doctor Molewaterplein 40',
  BillingCity = 'Rotterdam',
  BillingCountry = 'Netherlands',
  BillingPostalCode = '3015',
  BillingState = 'GD ',
  Phone = '+31 10 704 0704',
  //HospitalBeds__c = 1233,
  Website = 'https://www.erasmusmc.nl/nl-nl/'
);

hospitalAccounts.add(erasmusMedischCentrum);

insert hospitalAccounts;

// insert operating hours for the above hospital

Timezone europeAmsterdamTimeZone = Timezone.getTimeZone('Europe/Amsterdam');

OperatingHours netherlandsOperatingHours = new OperatingHours(
  Name = 'Netherlands operating hours',
  Description = 'Working hours for Netherlands',
  TimeZone = europeAmsterdamTimeZone.getID()
);

insert netherlandsOperatingHours;

// Create time slots
List<TimeSlot> timeSlotsListTillMidday = new List<TimeSlot>();

Time startTime12am = Time.newInstance(0, 0, 0, 0);
Time endTime12pm = Time.newInstance(12, 0, 0, 0);

TimeSlot sundayTimeSlot = new TimeSlot(
  DayOfWeek = 'Sunday',
  StartTime = startTime12am,
  EndTime = endTime12pm,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidday.add(sundayTimeSlot);

TimeSlot mondayTimeSlot = new TimeSlot(
  DayOfWeek = 'Monday',
  StartTime = startTime12am,
  EndTime = endTime12pm,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidday.add(mondayTimeSlot);

TimeSlot tuesdayTimeSlot = new TimeSlot(
  DayOfWeek = 'Tuesday',
  StartTime = startTime12am,
  EndTime = endTime12pm,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidday.add(tuesdayTimeSlot);

TimeSlot wednesdayTimeSlot = new TimeSlot(
  DayOfWeek = 'Wednesday',
  StartTime = startTime12am,
  EndTime = endTime12pm,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidday.add(wednesdayTimeSlot);

TimeSlot thursdayTimeSlot = new TimeSlot(
  DayOfWeek = 'Thursday',
  StartTime = startTime12am,
  EndTime = endTime12pm,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidday.add(thursdayTimeSlot);

TimeSlot fridayTimeSlot = new TimeSlot(
  DayOfWeek = 'Friday',
  StartTime = startTime12am,
  EndTime = endTime12pm,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidday.add(fridayTimeSlot);

TimeSlot saturdayTimeSlot = new TimeSlot(
  DayOfWeek = 'Saturday',
  StartTime = startTime12am,
  EndTime = endTime12pm,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidday.add(saturdayTimeSlot);

insert timeSlotsListTillMidday;


List<TimeSlot> timeSlotsListTillMidnight = new List<TimeSlot>();


Time startTime12pm = Time.newInstance(12, 0, 0, 0);
Time endTime12am = Time.newInstance(00, 0, 0, 0);

TimeSlot sundayTimeSlotTillMidnight = new TimeSlot(
  DayOfWeek = 'Sunday',
  StartTime = startTime12pm,
  EndTime = endTime12am,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidnight.add(sundayTimeSlotTillMidnight);

TimeSlot mondayTimeSlotTillMidnight = new TimeSlot(
  DayOfWeek = 'Monday',
  StartTime = startTime12pm,
  EndTime = endTime12am,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidnight.add(mondayTimeSlotTillMidnight);

TimeSlot tuesdayTimeSlotTillMidnight = new TimeSlot(
  DayOfWeek = 'Tuesday',
  StartTime = startTime12pm,
  EndTime = endTime12am,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidnight.add(tuesdayTimeSlotTillMidnight);

TimeSlot wednesdayTimeSlotTillMidnight = new TimeSlot(
  DayOfWeek = 'Wednesday',
  StartTime = startTime12pm,
  EndTime = endTime12am,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidnight.add(wednesdayTimeSlotTillMidnight);

TimeSlot thursdayTimeSlotTillMidnight = new TimeSlot(
  DayOfWeek = 'Thursday',
  StartTime = startTime12pm,
  EndTime = endTime12am,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidnight.add(thursdayTimeSlotTillMidnight);

TimeSlot fridayTimeSlotTillMidnight = new TimeSlot(
  DayOfWeek = 'Friday',
  StartTime = startTime12pm,
  EndTime = endTime12am,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidnight.add(fridayTimeSlotTillMidnight);

TimeSlot saturdayTimeSlotTillMidnight = new TimeSlot(
  DayOfWeek = 'Saturday',
  StartTime = startTime12pm,
  EndTime = endTime12am,
  OperatingHoursId = netherlandsOperatingHours.Id
);

timeSlotsListTillMidnight.add(saturdayTimeSlotTillMidnight);

insert timeSlotsListTillMidnight;

//Create a new teritory based on the above hospital
List<ServiceTerritory> serviceTerritoriesList = new List<ServiceTerritory>();

ServiceTerritory rotterdamServiceTerritory = new ServiceTerritory(
  Name = 'Rotterdam',
  IsActive = true,
  OperatingHoursId = netherlandsOperatingHours.Id
);

serviceTerritoriesList.add(rotterdamServiceTerritory);

ServiceTerritory amsterdamServiceTerritory = new ServiceTerritory(
  Name = 'Amsterdam',
  IsActive = true,
  OperatingHoursId = netherlandsOperatingHours.Id
);

serviceTerritoriesList.add(amsterdamServiceTerritory);

ServiceTerritory leidenServiceTerritory = new ServiceTerritory(
  Name = 'Leiden',
  IsActive = true,
  OperatingHoursId = netherlandsOperatingHours.Id
);

serviceTerritoriesList.add(leidenServiceTerritory);

ServiceTerritory nijmegenServiceTerritory = new ServiceTerritory(
  Name = 'Nijmegen',
  IsActive = true,
  OperatingHoursId = netherlandsOperatingHours.Id
);

serviceTerritoriesList.add(nijmegenServiceTerritory);

ServiceTerritory utrechtServiceTerritory = new ServiceTerritory(
  Name = 'Utrecht',
  IsActive = true,
  OperatingHoursId = netherlandsOperatingHours.Id
);

serviceTerritoriesList.add(utrechtServiceTerritory);

insert serviceTerritoriesList;

// insert work types

List<WorkType> workTypesList = new List<WorkType>();

WorkType generalPracticeWorkType = new WorkType(
  Name = 'General Practice',
  EstimatedDuration = 60,
  DurationType = 'minutes',
  ShouldAutoCreateSvcAppt = true
);

workTypesList.add(generalPracticeWorkType);

WorkType informationAndAdviceWorkType = new WorkType(
  Name = 'Information and advice',
  EstimatedDuration = 30,
  DurationType = 'minutes',
  ShouldAutoCreateSvcAppt = true
);

workTypesList.add(informationAndAdviceWorkType);

WorkType medicalAndHealthCheckups = new WorkType(
  Name = 'Medical and health check-ups',
  EstimatedDuration = 120,
  DurationType = 'minutes',
  ShouldAutoCreateSvcAppt = true
);

workTypesList.add(medicalAndHealthCheckups);

WorkType healthAndNutritionAdvice = new WorkType(
  Name = 'Health and nutrition advice',
  EstimatedDuration = 30,
  DurationType = 'minutes',
  ShouldAutoCreateSvcAppt = true
);

workTypesList.add(healthAndNutritionAdvice);

WorkType managementOfAcuteAndChronicConditions = new WorkType(
  Name = 'Management of acute and chronic conditions',
  EstimatedDuration = 60,
  DurationType = 'minutes',
  ShouldAutoCreateSvcAppt = true
);

workTypesList.add(managementOfAcuteAndChronicConditions);

insert workTypesList;

// insert work orders

List<WorkOrder> workOrdersList = new List<WorkOrder>();

//Work order status default is new
WorkOrder criticalWorkOrder = new workOrder(
  Priority = 'Critical',
  AccountId = umcUtrecht.id,
  WorkTypeId = managementOfAcuteAndChronicConditions.id,
  ServiceTerritoryId = serviceTerritoriesList[0].Id
);

workOrdersList.add(criticalWorkOrder);

WorkOrder highPriorityWorkOrder = new workOrder(
  Priority = 'High',
  AccountId = radboudUniversitairMedischCentrum.id,
  WorkTypeId = managementOfAcuteAndChronicConditions.id,
  ServiceTerritoryId = serviceTerritoriesList[1].Id
);

workOrdersList.add(highPriorityWorkOrder);

WorkOrder MediumPriorityWorkOrder = new workOrder(
  Priority = 'Medium',
  AccountId = academischMedischCentrum.id,
  WorkTypeId = medicalAndHealthCheckups.id,
  ServiceTerritoryId = serviceTerritoriesList[2].Id
);

workOrdersList.add(MediumPriorityWorkOrder);

WorkOrder LowPriorityWorkOrder = new workOrder(
  Priority = 'Low',
  AccountId = leidsUniversitairMedischCentrum.id,
  WorkTypeId = medicalAndHealthCheckups.id,
  ServiceTerritoryId = serviceTerritoriesList[3].Id
);

workOrdersList.add(LowPriorityWorkOrder);

WorkOrder anotherWorkOrder = new workOrder(
  AccountId = leidsUniversitairMedischCentrum.id,
  WorkTypeId = healthAndNutritionAdvice.Id,
  ServiceTerritoryId = serviceTerritoriesList[3].Id
);

workOrdersList.add(anotherWorkOrder);

insert workOrdersList;

// Create 20 service appointments for the rotterdam hospital
List<ServiceAppointment> serviceAppointmentsList = new List<ServiceAppointment>();

Datetime eariliestDateTime = Datetime.newInstance(2023, 1, 1); //by default sets time @ 8 am
Datetime dueDateTime = Datetime.newInstance(2023, 1, 2);

for (Integer i = 0; i < 20; i++) {
  serviceAppointmentsList.add(
    new ServiceAppointment(
      ParentRecordId = erasmusMedischCentrum.id,
      EarliestStartTime = eariliestDateTime,
      DueDate = dueDateTime,
      ServiceTerritoryId = rotterdamServiceTerritory.Id
    )
  );
  serviceAppointmentsList.add(
    new ServiceAppointment(
      ParentRecordId = umcUtrecht.id,
      EarliestStartTime = eariliestDateTime,
      DueDate = dueDateTime,
      ServiceTerritoryId = serviceTerritoriesList[(Integer) Math.random() * 4].Id
    )
  );

  serviceAppointmentsList.add(
    new ServiceAppointment(
      ParentRecordId = radboudUniversitairMedischCentrum.id,
      EarliestStartTime = eariliestDateTime,
      DueDate = dueDateTime,
      ServiceTerritoryId = serviceTerritoriesList[(Integer) Math.random() * 4].Id
    )
  );

  serviceAppointmentsList.add(
    new ServiceAppointment(
      ParentRecordId = academischMedischCentrum.id,
      EarliestStartTime = eariliestDateTime,
      DueDate = dueDateTime,
      ServiceTerritoryId = serviceTerritoriesList[(Integer) Math.random() * 4].Id
    )
  );

  serviceAppointmentsList.add(
    new ServiceAppointment(
      ParentRecordId = leidsUniversitairMedischCentrum.id,
      EarliestStartTime = eariliestDateTime,
      DueDate = dueDateTime,
      ServiceTerritoryId = serviceTerritoriesList[(Integer) Math.random() * 4].Id
    )
  );
}

insert serviceAppointmentsList;