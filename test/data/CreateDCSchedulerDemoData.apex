List<Syntilio__CareOperatingHours__c> operatingHoursList = new List<Syntilio__CareOperatingHours__c> ();

Syntilio__CareOperatingHours__c digiContactOperatingHours = new Syntilio__CareOperatingHours__c();
digiContactOperatingHours.Name = 'DigiContact Morning Syntilio__CareOperatingHours__c';
digiContactOperatingHours.Syntilio__StartDate__c = Date.newInstance(2023, 06, 01);
digiContactOperatingHours.Syntilio__EndDate__c = Date.newInstance(2026, 06, 30);
digiContactOperatingHours.Syntilio__TimeZone__c = 'GMT+01:00	Central European Standard Time (Europe/Amsterdam)';

operatingHoursList.add(digiContactOperatingHours);
insert digiContactOperatingHours;


List<String> weekDaysList = new List<String> {'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
List<Syntilio__CareTimeSlot__c> morningTimeSlotList = new List<Syntilio__CareTimeSlot__c>();
List<Syntilio__CareTimeSlot__c> nightTimeSlotList = new List<Syntilio__CareTimeSlot__c>();

Integer dayWeeekMorningCounter = 0;
For (Syntilio__CareOperatingHours__c morningOperatingHoursRecord : operatingHoursList){
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
For (Syntilio__CareOperatingHours__c nightOperatingHoursRecord : operatingHoursList){
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

ServiceTerritory digiContactHQ = new ServiceTerritory();
digiContactHQ.Name = 'DigiContact HQ';
digiContactHQ.OperatingHoursId = digiContactOperatingHours.Id;
digiContactHQ.IsActive = true;
digiContactHQ.City = 'Amsterdam';
insert digiContactHQ;

List<User> userIdList = [SELECT Id, Name FROM USER WHERE Name = 'User User'];

ServiceResource serviceResourceAgent1 = new ServiceResource();
serviceResourceAgent1.Name = 'Agent 1';
serviceResourceAgent1.ResourceType = 'Agent';
serviceResourceAgent1.IsActive = true;
serviceResourceAgent1.IsPrimary = true;
serviceResourceAgent1.RelatedRecordId = !userIdList.isEmpty() ? userIdList[0].Id : null;

insert serviceResourceAgent1;

WorkTypeGroup intakeWorkTypeGroup = new WorkTypeGroup();
intakeWorkTypeGroup.Name = 'Video Call Appointments';
intakeWorkTypeGroup.GroupType = 'Default';
intakeWorkTypeGroup.IsActive = true;
insert intakeWorkTypeGroup;
/*
WorkTypeGroup careAppointmentWorkTypeGroup = new WorkTypeGroup();
careAppointmentWorkTypeGroup.Name = 'Care Appointment';
careAppointmentWorkTypeGroup.GroupType = 'Default';
careAppointmentWorkTypeGroup.IsActive = true;
insert careAppointmentWorkTypeGroup;

WorkTypeGroup exitInterviewAppointmentWorkTypeGroup = new WorkTypeGroup();
exitInterviewAppointmentWorkTypeGroup.Name = 'Exit Interview Appointment';
exitInterviewAppointmentWorkTypeGroup.GroupType = 'Default';
exitInterviewAppointmentWorkTypeGroup.IsActive = true;
insert exitInterviewAppointmentWorkTypeGroup;
*/

WorkType intakeWorkType = new WorkType();
intakeWorkType.Name = 'Intake Appointment';
intakeWorkType.EstimatedDuration = 1;
intakeWorkType.DurationType = 'Hours';
intakeWorkType.TimeframeStart = 0;
intakeWorkType.TimeFrameStartUnit = 'Day(s)';
intakeWorkType.TimeframeEnd = 10;
intakeWorkType.TimeFrameEndUnit = 'Day(s)';
insert intakeWorkType;

WorkType careWorkType = new WorkType();
careWorkType.Name = 'Care Appointment';
careWorkType.EstimatedDuration = 1;
careWorkType.DurationType = 'Hours';
careWorkType.TimeframeStart = 0;
careWorkType.TimeFrameStartUnit = 'Day(s)';
careWorkType.TimeframeEnd = 10;
careWorkType.TimeFrameEndUnit = 'Day(s)';
insert careWorkType;

WorkType exitInterviewWorkType = new WorkType();
exitInterviewWorkType.Name = 'Exit Interview Appointment';
exitInterviewWorkType.EstimatedDuration = 30;
exitInterviewWorkType.DurationType = 'Minutes';
exitInterviewWorkType.TimeframeStart = 0;
exitInterviewWorkType.TimeFrameStartUnit = 'Day(s)';
exitInterviewWorkType.TimeframeEnd = 10;
exitInterviewWorkType.TimeFrameEndUnit = 'Day(s)';
insert exitInterviewWorkType;
