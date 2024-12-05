/*
Syntilio__Questionnaire__c standardTriageQuestionnaire = [SELECT Id FROM Syntilio__Questionnaire__c WHERE Name = 'Standard Triage Questionnaire'];
Syntilio__Questionnaire__c videoTriageQuestionnaire = [SELECT Id FROM Syntilio__Questionnaire__c WHERE Name = 'Video Triage Questionnaire'];
Syntilio__Questionnaire__c patientKarelGroenendijkDiabetesQuestionnaire = [SELECT Id FROM Syntilio__Questionnaire__c WHERE Name = 'Patient Karel Groenendijk Diabetes Questionnaire'];
*/

Syntilio__EventConfiguration__c videoCallReceivedEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1010.0 LIMIT 1];
Syntilio__EventConfiguration__c highBloodPressureEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1001.0 LIMIT 1];
Syntilio__EventConfiguration__c atrialFibrillationEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1006.0 LIMIT 1];
Syntilio__EventConfiguration__c lowOxygenSaturationEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1004.0 LIMIT 1];
Syntilio__EventConfiguration__c medicatieVergetenEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 2.0 LIMIT 1];

Contact patientContactKarelGroenendijk = [SELECT Id FROM Contact WHERE LastName = 'Groenendijk'];
Contact patientContactLukDylan = [SELECT Id FROM Contact WHERE LastName = 'Dylan'];
Contact patientContactFlorisBas = [SELECT Id FROM Contact WHERE LastName = 'Bas'];
Contact patientContactEmmaAlexander = [SELECT Id FROM Contact WHERE LastName = 'Alexander'];
Contact patientContactNoraBram = [SELECT Id FROM Contact WHERE LastName = 'Bram'];

Syntilio__Protocol__c videoProtocolRecord = new Syntilio__Protocol__c();
videoProtocolRecord.Name = 'Video Protocol';
insert videoProtocolRecord;

/*
Syntilio__ProtocolAction__c videoTriageQuestionnaireProtocolActionRecord = new Syntilio__ProtocolAction__c();
videoTriageQuestionnaireProtocolActionRecord.Name = 'Video Triage Questionnaire';
videoTriageQuestionnaireProtocolActionRecord.Syntilio__TypeApiName__c = 'Syntilio__Show_Questionnaire_Questions_and_Create_Protocol_Results';
videoTriageQuestionnaireProtocolActionRecord.Syntilio__Questionnaire__c = videoTriageQuestionnaire.Id;
insert videoTriageQuestionnaireProtocolActionRecord;

Syntilio__ProtocolAction__c callpatientProtocolActionRecord = new Syntilio__ProtocolAction__c();
callpatientProtocolActionRecord.Name = 'Call Patient';
callpatientProtocolActionRecord.Syntilio__TypeApiName__c = 'Syntilio__Call_Patient';
insert callpatientProtocolActionRecord;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord1 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord1.Syntilio__Protocol__c = videoProtocolRecord.Id;
protocolActionRelationRecord1.Syntilio__ProtocolAction__c = callpatientProtocolActionRecord.Id;
protocolActionRelationRecord1.Syntilio__Order__c = 1;
insert protocolActionRelationRecord1;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord2 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord2.Syntilio__Protocol__c = videoProtocolRecord.Id;
protocolActionRelationRecord2.Syntilio__ProtocolAction__c = videoTriageQuestionnaireProtocolActionRecord.Id;
protocolActionRelationRecord2.Syntilio__Order__c = 2;
insert protocolActionRelationRecord2;
*/
Syntilio__ProtocolActivator__c videoTriageProtocolActivatorRecord = new Syntilio__ProtocolActivator__c();
videoTriageProtocolActivatorRecord.Syntilio__Active__c = true;
videoTriageProtocolActivatorRecord.Syntilio__ContactId__c = null;
videoTriageProtocolActivatorRecord.Syntilio__Event__c = videoCallReceivedEventConfiguration.Id;
videoTriageProtocolActivatorRecord.Syntilio__Protocol__c = videoProtocolRecord.Id;
insert videoTriageProtocolActivatorRecord;

/*

Syntilio__Protocol__c diabetesTriageProtocolRecord = new Syntilio__Protocol__c();
diabetesTriageProtocolRecord.Name = 'Diabetes Protocol';
diabetesTriageProtocolRecord.Syntilio__Description__c = 'Evaluates sugar levels';
diabetesTriageProtocolRecord.Syntilio__EstimatedTime__c = 2;
insert diabetesTriageProtocolRecord;

Syntilio__ProtocolAction__c PatientProtocolActionRecord = new Syntilio__ProtocolAction__c();
PatientProtocolActionRecord.Name = 'Diabetes Questionnaire';
PatientProtocolActionRecord.Syntilio__TypeApiName__c = 'Syntilio__Show_Questionnaire_Questions_and_Create_Protocol_Results';
PatientProtocolActionRecord.Syntilio__Questionnaire__c = patientKarelGroenendijkDiabetesQuestionnaire.Id;
insert PatientProtocolActionRecord;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord3 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord3.Syntilio__Protocol__c = diabetesTriageProtocolRecord.Id;
protocolActionRelationRecord3.Syntilio__ProtocolAction__c = PatientProtocolActionRecord.Id;
protocolActionRelationRecord3.Syntilio__Order__c = 1;
insert protocolActionRelationRecord3;

Syntilio__ProtocolActivator__c patientDiabetesTriageProtocolActivatorRecord = new Syntilio__ProtocolActivator__c();
patientDiabetesTriageProtocolActivatorRecord.Syntilio__Active__c = true;
patientDiabetesTriageProtocolActivatorRecord.Syntilio__ContactId__c = patientContactKarelGroenendijk.Id;
patientDiabetesTriageProtocolActivatorRecord.Syntilio__Event__c = null;
patientDiabetesTriageProtocolActivatorRecord.Syntilio__Protocol__c = diabetesTriageProtocolRecord.Id;
insert patientDiabetesTriageProtocolActivatorRecord;

*/
Syntilio__Protocol__c standardProtocolRecord = new Syntilio__Protocol__c();
standardProtocolRecord.Name = 'Triage Protocol';
standardProtocolRecord.Syntilio__Description__c = 'Universal standard triage protocol';
standardProtocolRecord.Syntilio__EstimatedTime__c = 4;
insert standardProtocolRecord;
/*
Syntilio__ProtocolAction__c standardTriageQuestionnaireProtocolActionRecord = new Syntilio__ProtocolAction__c();
standardTriageQuestionnaireProtocolActionRecord.Name = 'Standard Triage Questionnaire';
standardTriageQuestionnaireProtocolActionRecord.Syntilio__TypeApiName__c = 'Syntilio__Show_Questionnaire_Questions_and_Create_Protocol_Results';
standardTriageQuestionnaireProtocolActionRecord.Syntilio__Questionnaire__c = standardTriageQuestionnaire.Id;
insert standardTriageQuestionnaireProtocolActionRecord;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord5 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord5.Syntilio__Protocol__c = standardProtocolRecord.Id;
protocolActionRelationRecord5.Syntilio__ProtocolAction__c = callpatientProtocolActionRecord.Id;
protocolActionRelationRecord5.Syntilio__Order__c = 1;
insert protocolActionRelationRecord5;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord6 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord6.Syntilio__Protocol__c = standardProtocolRecord.Id;
protocolActionRelationRecord6.Syntilio__ProtocolAction__c = standardTriageQuestionnaireProtocolActionRecord.Id;
protocolActionRelationRecord6.Syntilio__Order__c = 2;
insert protocolActionRelationRecord6;
*/
Syntilio__ProtocolActivator__c protocolActivatorRecord3 = new Syntilio__ProtocolActivator__c();
protocolActivatorRecord3.Syntilio__Active__c = true;
protocolActivatorRecord3.Syntilio__ContactId__c = patientContactKarelGroenendijk.Id;
protocolActivatorRecord3.Syntilio__Event__c = null;
protocolActivatorRecord3.Syntilio__Protocol__c = standardProtocolRecord.Id;
insert protocolActivatorRecord3;


Syntilio__Protocol__c medicatieVergetenProtocolRecord = new Syntilio__Protocol__c();
medicatieVergetenProtocolRecord.Name = 'Medicatie Gemist';
//medicatieVergetenProtocolRecord.Syntilio__Description__c = 'De cliënt heeft zijn medicijnen niet uitgenomen vragenlijst';
medicatieVergetenProtocolRecord.Syntilio__EstimatedTime__c = 4;
insert medicatieVergetenProtocolRecord;

Syntilio__ProtocolActivator__c protocolActivatorRecord4 = new Syntilio__ProtocolActivator__c();
protocolActivatorRecord4.Syntilio__Active__c = true;
protocolActivatorRecord4.Syntilio__ContactId__c = null;
protocolActivatorRecord4.Syntilio__Event__c = medicatieVergetenEventConfiguration.Id;
protocolActivatorRecord4.Syntilio__Protocol__c = medicatieVergetenProtocolRecord.Id;
insert protocolActivatorRecord4;

/*
Syntilio__ProtocolActivator__c protocolActivatorRecord4 = new Syntilio__ProtocolActivator__c();
protocolActivatorRecord4.Syntilio__Active__c = true;
protocolActivatorRecord4.Syntilio__ContactId__c = null;
protocolActivatorRecord4.Syntilio__Event__c = atrialFibrillationEventConfiguration.Id;
protocolActivatorRecord4.Syntilio__Protocol__c = standardProtocolRecord.Id;
insert protocolActivatorRecord4;

Syntilio__ProtocolActivator__c protocolActivatorRecord5 = new Syntilio__ProtocolActivator__c();
protocolActivatorRecord5.Syntilio__Active__c = true;
protocolActivatorRecord5.Syntilio__ContactId__c = null;
protocolActivatorRecord5.Syntilio__Event__c = lowOxygenSaturationEventConfiguration.Id;
protocolActivatorRecord5.Syntilio__Protocol__c = standardProtocolRecord.Id;
insert protocolActivatorRecord5;

Syntilio__Group__c autGroup = new Syntilio__Group__c();
autGroup.Name = 'AUT';
autGroup.Syntilio__ObjectType__c = 'Contact';
insert autGroup;

Syntilio__Group__c lbaGroup = new Syntilio__Group__c();
lbaGroup.Name = 'LBA';
lbaGroup.Syntilio__ObjectType__c = 'Contact';
insert lbaGroup;

Syntilio__Group__c lbwGroup = new Syntilio__Group__c();
lbwGroup.Name = 'LBW';
lbwGroup.Syntilio__ObjectType__c = 'Contact';
insert lbwGroup;

Syntilio__Group__c ggzGroup = new Syntilio__Group__c();
ggzGroup.Name = 'GGZ';
ggzGroup.Syntilio__ObjectType__c = 'Contact';
insert ggzGroup;

Syntilio__Group__c nahGroup = new Syntilio__Group__c();
nahGroup.Name = 'NAH';
nahGroup.Syntilio__ObjectType__c = 'Contact';
insert nahGroup;

Syntilio__Group__c oudGroup = new Syntilio__Group__c();
oudGroup.Name = 'OUD';
oudGroup.Syntilio__ObjectType__c = 'Contact';
insert oudGroup;

Syntilio__Group__c jusGroup = new Syntilio__Group__c();
jusGroup.Name = 'JUS';
jusGroup.Syntilio__ObjectType__c = 'Contact';
insert jusGroup;

Syntilio__Group__c jgdGroup = new Syntilio__Group__c();
jgdGroup.Name = 'JGD';
jgdGroup.Syntilio__ObjectType__c = 'Contact';
insert jgdGroup;


Syntilio__GroupMember__c autGroupKarelAssociation = new Syntilio__GroupMember__c();
autGroupKarelAssociation.Syntilio__GroupId__c = autGroup.Id;
autGroupKarelAssociation.Syntilio__ContactId__c = patientContactKarelGroenendijk.Id;
insert autGroupKarelAssociation;

Syntilio__GroupMember__c autGroupDylanAssociation = new Syntilio__GroupMember__c();
autGroupDylanAssociation.Syntilio__GroupId__c = autGroup.Id;
autGroupDylanAssociation.Syntilio__ContactId__c = patientContactLukDylan.Id;
insert autGroupDylanAssociation;

Syntilio__Protocol__c autProtocolRecord = new Syntilio__Protocol__c();
autProtocolRecord.Name = 'AUT Protocol';
autProtocolRecord.Syntilio__Description__c = 'Autism-focused inclusive communication protocol';
autProtocolRecord.Syntilio__EstimatedTime__c = 6;
insert autProtocolRecord;

Syntilio__ProtocolAction__c autTriageQuestionnaireProtocolActionRecord = new Syntilio__ProtocolAction__c();
autTriageQuestionnaireProtocolActionRecord.Name = 'AUT Questionnaire';
autTriageQuestionnaireProtocolActionRecord.Syntilio__TypeApiName__c = 'Syntilio__Show_Questionnaire_Questions_and_Create_Protocol_Results';
autTriageQuestionnaireProtocolActionRecord.Syntilio__Questionnaire__c = standardTriageQuestionnaire.Id;
insert autTriageQuestionnaireProtocolActionRecord;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord7 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord7.Syntilio__Protocol__c = autProtocolRecord.Id;
protocolActionRelationRecord7.Syntilio__ProtocolAction__c = autTriageQuestionnaireProtocolActionRecord.Id;
protocolActionRelationRecord7.Syntilio__Order__c = 1;
insert protocolActionRelationRecord7;

Syntilio__ProtocolActivator__c protocolActivatorRecord6 = new Syntilio__ProtocolActivator__c();
protocolActivatorRecord6.Syntilio__Active__c = true;
protocolActivatorRecord6.Syntilio__ContactId__c = null;
protocolActivatorRecord6.Syntilio__Event__c = null;
protocolActivatorRecord6.Syntilio__Protocol__c = autProtocolRecord.Id;
protocolActivatorRecord6.Syntilio__GroupId__c = autGroup.Id;
insert protocolActivatorRecord6;


Syntilio__Group__c lbaCareHomeSharedDeviceGroup = new Syntilio__Group__c();
lbaCareHomeSharedDeviceGroup.Name = 'Care Home LBA Shared Device Group';
lbaCareHomeSharedDeviceGroup.Syntilio__ObjectType__c = 'Contact';
insert lbaCareHomeSharedDeviceGroup;

Syntilio__GroupMember__c lbaCareHomeSharedDeviceGroupFlorisBasAssociation = new Syntilio__GroupMember__c();
lbaCareHomeSharedDeviceGroupFlorisBasAssociation.Syntilio__GroupId__c = lbaCareHomeSharedDeviceGroup.Id;
lbaCareHomeSharedDeviceGroupFlorisBasAssociation.Syntilio__ContactId__c = patientContactFlorisBas.Id;
insert lbaCareHomeSharedDeviceGroupFlorisBasAssociation;

Syntilio__GroupMember__c lbaCareHomeSharedDeviceGroupEmmaAlexanderAssociation = new Syntilio__GroupMember__c();
lbaCareHomeSharedDeviceGroupEmmaAlexanderAssociation.Syntilio__GroupId__c = lbaCareHomeSharedDeviceGroup.Id;
lbaCareHomeSharedDeviceGroupEmmaAlexanderAssociation.Syntilio__ContactId__c = patientContactEmmaAlexander.Id;
insert lbaCareHomeSharedDeviceGroupEmmaAlexanderAssociation;

Syntilio__GroupMember__c lbaCareHomeSharedDeviceGroupNoraBramAssociation = new Syntilio__GroupMember__c();
lbaCareHomeSharedDeviceGroupNoraBramAssociation.Syntilio__GroupId__c = lbaCareHomeSharedDeviceGroup.Id;
lbaCareHomeSharedDeviceGroupNoraBramAssociation.Syntilio__ContactId__c = patientContactNoraBram.Id;
insert lbaCareHomeSharedDeviceGroupNoraBramAssociation;

Id clientContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
Account philadelphiaCare = [SELECT Id FROM Account WHERE Name = 'Envida'];

Contact andriodSharedTabDevice = new Contact(
    Salutation = 'Mr.',
    Title = 'Shared Contact',
    FirstName = 'LBA',
    LastName = 'Shared Device',
    AccountId = philadelphiaCare.Id,
    Phone = '+34342423243',
    HomePhone = '+34342423243',
    MailingStreet = 'Street 7',
    MailingCity = 'Hilversum',
    MailingState = 'Noord Holland',
    MailingPostalCode = '1223',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
    MailingCountry = 'Nederland',
    OtherStreet = 'Street 7',
    OtherCity = 'Hilversum',
    OtherState = 'Noord Holland',
    OtherPostalCode = '1223',                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    OtherCountry = 'Nederland',
    RecordTypeId = clientContactRecordTypeId
);
insert andriodSharedTabDevice;

Syntilio__GroupMember__c lbaCareHomeSharedDeviceGroupAndriodSharedTabDeviceAssociation = new Syntilio__GroupMember__c();
lbaCareHomeSharedDeviceGroupAndriodSharedTabDeviceAssociation.Syntilio__GroupId__c = lbaCareHomeSharedDeviceGroup.Id;
lbaCareHomeSharedDeviceGroupAndriodSharedTabDeviceAssociation.Syntilio__ContactId__c = andriodSharedTabDevice.Id;
insert lbaCareHomeSharedDeviceGroupAndriodSharedTabDeviceAssociation;

Syntilio__Protocol__c careHomeLbaSharedDeviceProtocolRecord = new Syntilio__Protocol__c();
careHomeLbaSharedDeviceProtocolRecord.Name = 'Care Home LBA Shared Device Protocol';
insert careHomeLbaSharedDeviceProtocolRecord;

Syntilio__ProtocolAction__c careHomeLbaSharedDeviceProtocolActionRecord = new Syntilio__ProtocolAction__c();
careHomeLbaSharedDeviceProtocolActionRecord.Name = 'Shared Device Flow';
careHomeLbaSharedDeviceProtocolActionRecord.Syntilio__TypeApiName__c = 'Syntilio__Shared_Device_Contact_Group';
careHomeLbaSharedDeviceProtocolActionRecord.Syntilio__Questionnaire__c = null;
insert careHomeLbaSharedDeviceProtocolActionRecord;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord8 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord8.Syntilio__Protocol__c = careHomeLbaSharedDeviceProtocolRecord.Id;
protocolActionRelationRecord8.Syntilio__ProtocolAction__c = careHomeLbaSharedDeviceProtocolActionRecord.Id;
protocolActionRelationRecord8.Syntilio__Order__c = 1;
insert protocolActionRelationRecord8;

Syntilio__ProtocolActivator__c protocolActivatorRecord7 = new Syntilio__ProtocolActivator__c();
protocolActivatorRecord7.Syntilio__Active__c = true;
protocolActivatorRecord7.Syntilio__ContactId__c = null;
protocolActivatorRecord7.Syntilio__Event__c = null;
protocolActivatorRecord7.Syntilio__Protocol__c = careHomeLbaSharedDeviceProtocolRecord.Id;
protocolActivatorRecord7.Syntilio__GroupId__c = lbaCareHomeSharedDeviceGroup.Id;
insert protocolActivatorRecord7;


Contact bakhuysCareTeamPhiladelphia = [SELECT Id FROM Contact WHERE LastName = 'Philadelphia Care' AND FirstName = '\'t Bakhuys'];

Syntilio__Group__c ggzCareHomeSharedDeviceGroupWithCareTeam = new Syntilio__Group__c();
ggzCareHomeSharedDeviceGroupWithCareTeam.Name = 'Care Home GGZ Shared Device Group With Care Team';
ggzCareHomeSharedDeviceGroupWithCareTeam.Syntilio__ObjectType__c = 'Contact';
insert ggzCareHomeSharedDeviceGroupWithCareTeam;

Syntilio__GroupMember__c ggzCareHomeSharedDeviceGroupWithCareTeamFlorisBasAssociation = new Syntilio__GroupMember__c();
ggzCareHomeSharedDeviceGroupWithCareTeamFlorisBasAssociation.Syntilio__GroupId__c = ggzCareHomeSharedDeviceGroupWithCareTeam.Id;
ggzCareHomeSharedDeviceGroupWithCareTeamFlorisBasAssociation.Syntilio__ContactId__c = patientContactFlorisBas.Id;
insert ggzCareHomeSharedDeviceGroupWithCareTeamFlorisBasAssociation;

Syntilio__GroupMember__c ggzCareHomeSharedDeviceGroupWithCareTeamEmmaAlexanderAssociation = new Syntilio__GroupMember__c();
ggzCareHomeSharedDeviceGroupWithCareTeamEmmaAlexanderAssociation.Syntilio__GroupId__c = ggzCareHomeSharedDeviceGroupWithCareTeam.Id;
ggzCareHomeSharedDeviceGroupWithCareTeamEmmaAlexanderAssociation.Syntilio__ContactId__c = patientContactEmmaAlexander.Id;
insert ggzCareHomeSharedDeviceGroupWithCareTeamEmmaAlexanderAssociation;

Syntilio__GroupMember__c ggzCareHomeSharedDeviceGroupWithCareTeamNoraBramAssociation = new Syntilio__GroupMember__c();
ggzCareHomeSharedDeviceGroupWithCareTeamNoraBramAssociation.Syntilio__GroupId__c = ggzCareHomeSharedDeviceGroupWithCareTeam.Id;
ggzCareHomeSharedDeviceGroupWithCareTeamNoraBramAssociation.Syntilio__ContactId__c = patientContactNoraBram.Id;
insert ggzCareHomeSharedDeviceGroupWithCareTeamNoraBramAssociation;

Syntilio__GroupMember__c ggzCareHomeSharedDeviceGroupWithCareTeambakhuysAssociation = new Syntilio__GroupMember__c();
ggzCareHomeSharedDeviceGroupWithCareTeambakhuysAssociation.Syntilio__GroupId__c = ggzCareHomeSharedDeviceGroupWithCareTeam.Id;
ggzCareHomeSharedDeviceGroupWithCareTeambakhuysAssociation.Syntilio__ContactId__c = bakhuysCareTeamPhiladelphia.Id;
insert ggzCareHomeSharedDeviceGroupWithCareTeambakhuysAssociation;

Syntilio__Protocol__c careHomeGgzSharedDeviceWithCareTeamProtocolRecord = new Syntilio__Protocol__c();
careHomeGgzSharedDeviceWithCareTeamProtocolRecord.Name = 'Care Home GGZ Shared Device With Care Team Protocol';
insert careHomeGgzSharedDeviceWithCareTeamProtocolRecord;

Syntilio__ProtocolAction__c careHomeGgzSharedDeviceWithCareTeamProtocolActionRecord = new Syntilio__ProtocolAction__c();
careHomeGgzSharedDeviceWithCareTeamProtocolActionRecord.Name = 'Shared Device Flow';
careHomeGgzSharedDeviceWithCareTeamProtocolActionRecord.Syntilio__TypeApiName__c = 'Syntilio__Shared_Device_Contact_Group';
careHomeGgzSharedDeviceWithCareTeamProtocolActionRecord.Syntilio__Questionnaire__c = null;
insert careHomeGgzSharedDeviceWithCareTeamProtocolActionRecord;

Syntilio__ProtocolActionRelation__c protocolActionRelationRecord9 = new Syntilio__ProtocolActionRelation__c();
protocolActionRelationRecord9.Syntilio__Protocol__c = careHomeGgzSharedDeviceWithCareTeamProtocolRecord.Id;
protocolActionRelationRecord9.Syntilio__ProtocolAction__c = careHomeGgzSharedDeviceWithCareTeamProtocolActionRecord.Id;
protocolActionRelationRecord9.Syntilio__Order__c = 1;
insert protocolActionRelationRecord9;

Syntilio__ProtocolActivator__c protocolActivatorRecord8 = new Syntilio__ProtocolActivator__c();
protocolActivatorRecord8.Syntilio__Active__c = true;
protocolActivatorRecord8.Syntilio__ContactId__c = null;
protocolActivatorRecord8.Syntilio__Event__c = null;
protocolActivatorRecord8.Syntilio__Protocol__c = careHomeGgzSharedDeviceWithCareTeamProtocolRecord.Id;
protocolActivatorRecord8.Syntilio__GroupId__c = ggzCareHomeSharedDeviceGroupWithCareTeam.Id;
insert protocolActivatorRecord8;

*/