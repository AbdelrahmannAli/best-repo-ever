Contact patientContactKarelGroenendijk = [SELECT Id FROM Contact WHERE LastName = 'Groenendijk' AND FirstName = 'Karel'];

Syntilio__EventConfiguration__c videoCallEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1010.0 LIMIT 1];

Id syntilioDefaultCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();


Case karelVideoCallCaseRecord = new Case(
    Subject = 'Video Call',
    ContactId = patientContactKarelGroenendijk.Id,
    Syntilio__Event__c = videoCallEventConfiguration.Id,
    RecordTypeId = syntilioDefaultCaseRecordTypeId,
    Origin = 'Web',
    Status = 'New',
    Priority = 'High'
);
insert karelVideoCallCaseRecord;

List<Syntilio__CallLog__c> callLogList = new List<Syntilio__CallLog__c>();

Syntilio__CallLog__c callLogRecordMonday = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:02:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 19, 09, 00, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 19, 09, 02, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordMonday);

Syntilio__CallLog__c callLogRecordTuesday1 = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:02:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 20, 09, 00, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 20, 09, 02, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordTuesday1);

Syntilio__CallLog__c callLogRecordTuesday2 = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:02:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 20, 11, 13, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 20, 11, 15, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordTuesday2);

Syntilio__CallLog__c callLogRecordWednesday1 = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:02:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 21, 14, 00, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 21, 14, 02, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordWednesday1);

Syntilio__CallLog__c callLogRecordWednesday2 = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:02:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 21, 13, 48, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 21, 13, 50, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordWednesday2);

Syntilio__CallLog__c callLogRecordWednesday3 = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:01:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 21, 16, 30, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 21, 16, 31, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordWednesday3);

Syntilio__CallLog__c callLogRecordThursday1 = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:03:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 22, 06, 34, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 22, 06, 37, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordThursday1);

Syntilio__CallLog__c callLogRecordThursday2 = new Syntilio__CallLog__c(
    Syntilio__CaseId__c = karelVideoCallCaseRecord.Id,
    Syntilio__Duration__c = '00:04:00',
    Syntilio__StartTime__c = DateTime.newInstance(2024, 02, 22, 08, 16, 00),
    Syntilio__EndTime__c = DateTime.newInstance(2024, 02, 22, 08, 20, 00),
    Syntilio__TranscriptionBody__c = null,
    Syntilio__Type__c = 'Video'
);
callLogList.Add(callLogRecordThursday2);

