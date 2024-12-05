List<Syntilio__EventConfiguration__c> eventConfigurationList = new List<Syntilio__EventConfiguration__c>();

Syntilio__EventConfiguration__c highBloodPressureEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'High Blood Pressure',
  Syntilio__Description__c = 'Test event code create',
  Syntilio__Code__c = 1001.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = 'bp',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(highBloodPressureEventConfiguration);

Syntilio__EventConfiguration__c lowBloodPressureEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Low Blood Pressure',
  Syntilio__Description__c = 'Test event code create',
  Syntilio__Code__c = 1002.0,
  Syntilio__ParentCodeId__c =   null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = 'bp',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(lowBloodPressureEventConfiguration);

Syntilio__EventConfiguration__c normalBloodPressureEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Normal Blood Pressure',
  Syntilio__Description__c = 'Test event code create',
  Syntilio__Code__c = 1003.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Close',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = '1001;1002',
  Syntilio__CodeSet__c = 'bp',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(normalBloodPressureEventConfiguration);

Syntilio__EventConfiguration__c lowOxygenSaturationEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Low Oxygen Saturation',
  Syntilio__Description__c = 'Test event code create',
  Syntilio__Code__c = 1004.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = 'spo2',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(lowOxygenSaturationEventConfiguration);

Syntilio__EventConfiguration__c normalOxygenSaturationEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Normal Oxygen Saturation',
  Syntilio__Description__c = 'Test event code close',
  Syntilio__Code__c = 1005.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Close',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = '1004',
  Syntilio__CodeSet__c = 'spo2',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(normalOxygenSaturationEventConfiguration);

Syntilio__EventConfiguration__c atrialFibrillationEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Atrial Fibrillation',
  Syntilio__Description__c = 'Test code event only',
  Syntilio__Code__c = 1006.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Event',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = 'ecg',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(atrialFibrillationEventConfiguration);

Syntilio__EventConfiguration__c sinusRhythmEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Sinus Rhythm',
  Syntilio__Description__c = 'Test code event only',
  Syntilio__Code__c = 1007.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Event',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = 'ecg',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(sinusRhythmEventConfiguration);

Syntilio__EventConfiguration__c arrhythmiaEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Arrhythmia',
  Syntilio__Description__c = 'Test event code create',
  Syntilio__Code__c = 1008.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = 'hr',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(arrhythmiaEventConfiguration);

Syntilio__EventConfiguration__c normalHeartRateEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Normal Heart Rate',
  Syntilio__Description__c = 'Test event code close',
  Syntilio__Code__c = 1009.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Close',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = '1008',
  Syntilio__CodeSet__c = 'hr',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(normalHeartRateEventConfiguration);

Syntilio__EventConfiguration__c videoCallReceivedEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Video Call Received',
  Syntilio__Description__c = 'Video call received from patient create event',
  Syntilio__Code__c = 1010.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = true,
  Syntilio__Sync__c = true
);
eventConfigurationList.add(videoCallReceivedEventConfiguration);


Syntilio__EventConfiguration__c bloodPressureDeviceNotReachableEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Blood Pressure Device Not Reachable',
  Syntilio__Description__c = 'Test event code create',
  Syntilio__Code__c = 2001.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = 'bp',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(bloodPressureDeviceNotReachableEventConfiguration);

Syntilio__EventConfiguration__c bloodPressureDeviceReachableEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Blood Pressure Device Reachable',
  Syntilio__Description__c = 'Test event code close',
  Syntilio__Code__c = 2002.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Close',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = '2001',
  Syntilio__CodeSet__c = 'bp',
  Syntilio__Sync__c = true
);
eventConfigurationList.add(bloodPressureDeviceReachableEventConfiguration);
insert eventConfigurationList;

Syntilio__EventConfiguration__c intakeEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Intake',
  Syntilio__Description__c = 'Client onboarding intake',
  Syntilio__Code__c = 1012.0,
  Syntilio__ParentCodeId__c = videoCallReceivedEventConfiguration.Id,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = true,
  Syntilio__Sync__c = true
);
insert intakeEventConfiguration;

Syntilio__EventConfiguration__c exitInterviewEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Exit Interview',
  Syntilio__Description__c = 'Exit Interview',
  Syntilio__Code__c = 1020.0,
  Syntilio__ParentCodeId__c = videoCallReceivedEventConfiguration.Id,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Event',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = true,
  Syntilio__Sync__c = true
);
insert exitInterviewEventConfiguration;
/*
Syntilio__EventConfiguration__c alarmTimeoutEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Medido Alarm Timeout',
  Syntilio__Description__c = 'The client has not taken their medicine after a medication alarm.',
  Syntilio__Code__c = 1021.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true
);
insert alarmTimeoutEventConfiguration;

Syntilio__EventConfiguration__c medidoDispenseErrorEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Medido Dispense error',
  Syntilio__Description__c = 'Dispenser reports dispensing problem',
  Syntilio__Code__c = 1022.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true
);
insert medidoDispenseErrorEventConfiguration;

Syntilio__EventConfiguration__c medidoPowerDownEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Medido Power Down',
  Syntilio__Description__c = 'No mains power',
  Syntilio__Code__c = 1023.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true
);
insert medidoPowerDownEventConfiguration;

Syntilio__EventConfiguration__c medidoRollLoadingFailedEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Medido Roll Loading Failed',
  Syntilio__Description__c = 'Role loading failed',
  Syntilio__Code__c = 1024.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true
);
insert medidoRollLoadingFailedEventConfiguration;

Syntilio__EventConfiguration__c medidoDispenserJammedEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Medido Dispenser Jammed',
  Syntilio__Description__c = 'Dispenser reported wastloper',
  Syntilio__Code__c = 1025.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = 'Critical',
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = false,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true
);
insert medidoDispenserJammedEventConfiguration;
*/

Syntilio__EventConfiguration__c dispenserMeldEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Dispenser meld een uitgifteprobleem - Medido',
  Syntilio__Description__c = 'De medicatierol loopt vast tijdens een uitgifte en moet opnieuw worden geladen',
  Syntilio__Code__c = 1.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert dispenserMeldEventConfiguration;

Syntilio__EventConfiguration__c medicatieVergetenEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Medicatie vergeten - Medido',
  Syntilio__Description__c = 'De cliënt heeft zijn medicijnen niet uitgenomen (niet bevestigd met de OK knop)',
  Syntilio__Code__c = 2.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert medicatieVergetenEventConfiguration;

Syntilio__EventConfiguration__c geenNetstroomEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Geen netstroom - Medido',
  Syntilio__Description__c = 'De dispenser heeft geen toevoer van stroom',
  Syntilio__Code__c = 6.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = 120,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert geenNetstroomEventConfiguration;

Syntilio__EventConfiguration__c netstroomHersteldEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Netstroom hersteld - Medido',
  Syntilio__Description__c = 'De dispenser heeft weer netstroom, na een "geen netsroom" melding',
  Syntilio__Code__c = 16.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Close',
  Syntilio__Priority__c = 'Low',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = String.valueOf('6'),
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert netstroomHersteldEventConfiguration;

Syntilio__EventConfiguration__c rolNietGeladenEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Rol niet geladen voor eerste innamemomenten - Medido',
  Syntilio__Description__c = 'De dispenser heeft geen medicijnrol bij uitgiftemoment',
  Syntilio__Code__c = 19.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert rolNietGeladenEventConfiguration;

Syntilio__EventConfiguration__c rolLadenMislukt = new Syntilio__EventConfiguration__c(
  Name = 'Rol laden mislukt - Medido',
  Syntilio__Description__c = 'Het laden van een nieuwe medicijnrol is mislukt',
  Syntilio__Code__c = 20.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = 120,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert rolLadenMislukt;

Syntilio__EventConfiguration__c dispenserIsVastgelopenEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Dispenser is vastgelopen - Medido',
  Syntilio__Description__c = 'De medicijnrol is vastgelopen in de dispenser en moet opnieuw worden geladen',
  Syntilio__Code__c = 25.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = 120,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert dispenserIsVastgelopenEventConfiguration;

Syntilio__EventConfiguration__c laadFoutEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Laad fout - Medido',
  Syntilio__Description__c = 'De medicijnrol is vastgelopen in de dispenser en moet opnieuw worden geladen',
  Syntilio__Code__c = 26.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'High',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert laadFoutEventConfiguration;

Syntilio__EventConfiguration__c medicijnrolGeladenEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Medicijnrol geladen - Medido',
  Syntilio__Description__c = 'De medicijnrol is succesvol geladen',
  Syntilio__Code__c = 37.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Technical',
  Syntilio__CaseAction__c = 'Close',
  Syntilio__Priority__c = 'Low',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = String.valueOf('19;20'),
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = false,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert medicijnrolGeladenEventConfiguration;

Syntilio__EventConfiguration__c clientStartMeldingEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Cliënt start melding - Medido',
  Syntilio__Description__c = 'Een nieuwe cliënt is de Medido gaan gebruiken',
  Syntilio__Code__c = 41.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'Medium',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true,
  Syntilio__SearchForClientComponentVisibility__c = 'Visible'
);
insert clientStartMeldingEventConfiguration;

Syntilio__EventConfiguration__c clientStopMeldingEventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Cliënt stop melding - Medido',
  Syntilio__Description__c = 'Een bestaande cliënt is gestopt met het gebruiken van de Medido',
  Syntilio__Code__c = 42.0,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'Medium',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true,
  Syntilio__SearchForClientComponentVisibility__c = 'Hide'
);
insert clientStopMeldingEventConfiguration;

Syntilio__EventConfiguration__c telefonischeMeldingN5EventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Telefonische Melding - N5',
  Syntilio__Description__c = 'N5 Telefonische Melding',
  Syntilio__Code__c = null,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'Medium',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true,
  Syntilio__SearchForClientComponentVisibility__c = 'Visible'
);
insert telefonischeMeldingN5EventConfiguration;

Syntilio__EventConfiguration__c valincidentN5EventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Valincident - N5',
  Syntilio__Description__c = 'N5 Valincident',
  Syntilio__Code__c = null,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'Medium',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true,
  Syntilio__SearchForClientComponentVisibility__c = 'Visible'
);
insert valincidentN5EventConfiguration;

Syntilio__EventConfiguration__c diabetesN5EventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Diabetes - N5',
  Syntilio__Description__c = 'N5 Diabetes',
  Syntilio__Code__c = null,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'Medium',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true,
  Syntilio__SearchForClientComponentVisibility__c = 'Visible'
);
insert diabetesN5EventConfiguration;

Syntilio__EventConfiguration__c katheterzorgN5EventConfiguration = new Syntilio__EventConfiguration__c(
  Name = 'Katheterzorg - N5',
  Syntilio__Description__c = 'N5 Katheterzorg',
  Syntilio__Code__c = null,
  Syntilio__ParentCodeId__c = null,
  Syntilio__Category__c = 'Medical',
  Syntilio__CaseAction__c = 'Upsert',
  Syntilio__Priority__c = 'Medium',
  Syntilio__State__c = null,
  Syntilio__WaitingMinutes__c = null,
  Syntilio__CloseEventCodes__c = null,
  Syntilio__CodeSet__c = null,
  Syntilio__AlwaysCreateNewCase__c = true,
  Syntilio__ReopenCaseWithinXMinutes__c = null,
  Syntilio__Planable__c = false,
  Syntilio__Sync__c = true,
  Syntilio__SearchForClientComponentVisibility__c = 'Visible'
);
insert katheterzorgN5EventConfiguration;