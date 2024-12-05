Id contactBusinessRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
Id individualAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesIndividual').getRecordTypeId();

Contact contactWillem = [SELECT Id FROM Contact WHERE LastName = 'Willem'];

HealthcareProvider healthcareProviderHospital = new HealthcareProvider(
    Name = 'Hospital',
    PractitionerId = contactWillem.Id,
    ProviderType = 'Hospital',
    ProviderClass = 'Medical Group',
    Status = 'Active',
    InitialStartDate = Date.newInstance(2010, 01, 01),
    EhrSystem = 'Epic'
);
insert healthcareProviderHospital;

Account individualAccountJansen = [SELECT Id FROM Account WHERE Name = 'Jansen Hendrik'];

Contact individualContactJansen = [SELECT Id FROM Contact WHERE LastName = 'Hendrik'];

Syntilio__MedicalCondition__c medicalConditionCOPD = new Syntilio__MedicalCondition__c(
    Name = 'COPD'
);
insert medicalConditionCOPD;

HealthCondition healthCondition = new HealthCondition(
    PatientId = individualAccountJansen.Id,
    Syntilio__MedicalCondition__c = medicalConditionCOPD.Id,
    RecordCreationDateTime = system.now(),
    Severity = 'Moderate',
    ConditionStatus = 'Active',
    DiagnosticStatus = 'Confirmed',
    RecordCreatorId = healthcareProviderHospital.Id
);
insert healthCondition;

Product2 jansenTelemonitoringAppProduct = [SELECT Id FROM Product2 WHERE Name = 'Telemonitoring App'];

Asset jansenBloodPressureReaderAsset = [SELECT Id FROM Asset WHERE Name = 'Blood Pressure Reader'];

Asset jansenAppleWatchAsset = [SELECT Id FROM Asset WHERE Name = 'Apple Watch'];

User userId = [SELECT Id, Name FROM USER WHERE Name = 'User User'];

UnitOfMeasure weightUnitOfMeasure = new UnitOfMeasure(
    Name = 'KG',
    UnitCode = 'kg',
    Type = 'Custom',
    OwnerId = userId.Id
);
insert weightUnitOfMeasure;

UnitOfMeasure heartRateUnitOfMeasure = new UnitOfMeasure(
    Name = 'BPM',
    UnitCode = 'bpm',
    Type = 'Custom',
    OwnerId = userId.Id
);

insert heartRateUnitOfMeasure;

UnitOfMeasure bloodPressureUnitOfMeasure = new UnitOfMeasure(
    Name = 'mmHg',
    UnitCode = 'mmhg',
    Type = 'Custom',
    OwnerId = userId.Id
);
insert bloodPressureUnitOfMeasure;

UnitOfMeasure percentUnitOfMeasure = new UnitOfMeasure(
    Name = '%',
    UnitCode = 'percent',
    Type = 'Custom',
    OwnerId = userId.Id
);
insert percentUnitOfMeasure;

UnitOfMeasure glucoseUnitOfMeasure1 = new UnitOfMeasure(
    Name = 'Glucose',
    UnitCode = 'mg/dL',
    Type = 'Custom',
    OwnerId = userId.Id
);
insert glucoseUnitOfMeasure1;

UnitOfMeasure glucoseUnitOfMeasure2 = new UnitOfMeasure(
    Name = 'Glucose',
    UnitCode = 'mmol/L',
    Type = 'Custom',
    OwnerId = userId.Id
);
insert glucoseUnitOfMeasure2;

UnitOfMeasure electrocardiogramUnitOfMeasure = new UnitOfMeasure(
    Name = 'V',
    UnitCode = 'volt',
    Type = 'Custom',
    OwnerId = userId.Id
);
insert electrocardiogramUnitOfMeasure;

//UnitOfMeasure bloodPressureUnitOfMeasure = [SELECT Id FROM UnitOfMeasure WHERE Name = 'mmHg'];

CodeSet oxygenSaturationCodeSet = new CodeSet(
    Name = 'Oxygen Saturation',
    Code = 'spo2',
    IsActive = true,
    OwnerId = userId.Id
);
insert oxygenSaturationCodeSet;

CodeSet electrocardiogramCodeSet = new CodeSet(
    Name = 'Electrocardiogram',
    Code = 'ecg',
    IsActive = true,
    OwnerId = userId.Id
);
insert electrocardiogramCodeSet;

CodeSet bloodPressureCodeSet= new CodeSet(
    Name = 'Blood Pressure',
    Code = 'bp',
    IsActive = true,
    OwnerId = userId.Id
);
insert bloodPressureCodeSet;

CodeSet weightCodeSet= new CodeSet(
    Name = 'Weight',
    Code = 'wgt',
    IsActive = true,
    OwnerId = userId.Id
);
insert weightCodeSet;

CodeSet heartRateCodeSet= new CodeSet(
    Name = 'Heart Rate',
    Code = 'hr',
    IsActive = true,
    OwnerId = userId.Id
);
insert heartRateCodeSet;

CodeSet GlucoseCodeSet= new CodeSet(
    Name = 'Glucose',
    Code = 'glu',
    IsActive = true,
    OwnerId = userId.Id
);
insert GlucoseCodeSet;

CodeSet standardQuestionnaireCodeSet= new CodeSet(
    Name = 'Standard Hospital Questionnaire',
    Code = '0004',
    IsActive = true,
    OwnerId = userId.Id
);
insert standardQuestionnaireCodeSet;


CodeSetBundle standardQuestionnaireCodeSetBundle= new CodeSetBundle(
    Name = 'Standard Hospital Questionnaire',
    CodeSet1Id = standardQuestionnaireCodeSet.Id
);
insert standardQuestionnaireCodeSetBundle;

//CodeSet bloodPressureCodeSet = [SELECT Id FROM CodeSet WHERE Name = 'Blood Pressure'];

CareMetricTarget weightCareMetricTarget = new CareMetricTarget(
    Name = 'Weight Care Metric Target',
    Type = 'RANGE',
    PatientId = individualAccountJansen.Id,
    CodeId = weightCodeSet.Id,
    UpperLimit = 500,
    LowerLimit = 1,
    UnitOfMeasureId = weightUnitOfMeasure.Id,
    StartDate =  Date.newInstance(2022, 03, 1),
    OwnerId = userId.Id
);
insert weightCareMetricTarget;

CareMetricTarget heartRateCareMetricTarget = new CareMetricTarget(
    Name = 'Heart Rate Care Metric Target',
    Type = 'RANGE',
    PatientId = individualAccountJansen.Id,
    CodeId = heartRateCodeSet.Id,
    UpperLimit = 350,
    LowerLimit = 50,
    UnitOfMeasureId = heartRateUnitOfMeasure.Id,
    StartDate =  Date.newInstance(2022, 03, 1),
    OwnerId = userId.Id
);
insert heartRateCareMetricTarget;

CareMetricTarget bloodPressureCareMetricTarget = new CareMetricTarget(
    Name = 'Blood Pressure Care Metric Target',
    Type = 'RANGE',
    PatientId = individualAccountJansen.Id,
    CodeId = bloodPressureCodeSet.Id,
    UpperLimit = 200,
    LowerLimit = 10,
    UnitOfMeasureId = bloodPressureUnitOfMeasure.Id,
    StartDate =  Date.newInstance(2022, 03, 1),
    OwnerId = userId.Id
);
insert bloodPressureCareMetricTarget;

//CareMetricTarget bloodPressureCareMetricTarget = [SELECT Id FROM CareMetricTarget WHERE Name= 'Blood Pressure Care Metric Target'];

CareObservation weightCareObservationWeek1 = new CareObservation(
    Name = 'Weight Care Observation Week 1',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = weightCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = weightUnitOfMeasure.Id,
    NumericValue = 80,
    EffectiveDateTime = Date.newInstance(2022, 04, 1),
    ExpectedValueId = weightCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = weightUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert weightCareObservationWeek1;

CareObservation weightCareObservationWeek2= new CareObservation(
    Name = 'Weight Care Observation Week 3',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = weightCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = weightUnitOfMeasure.Id,
    NumericValue = 78,
    EffectiveDateTime = Date.newInstance(2022, 04, 8),
    ExpectedValueId = weightCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = weightUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert weightCareObservationWeek2;

CareObservation weightCareObservationWeek3= new CareObservation(
    Name = 'Weight Care Observation Week 3',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = weightCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = weightUnitOfMeasure.Id,
    NumericValue = 75,
    EffectiveDateTime = Date.newInstance(2022, 04, 15),
    ExpectedValueId = weightCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = weightUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert weightCareObservationWeek3;

CareObservation heartRateCareObservationWeek1 = new CareObservation(
    Name = 'Heart Rate Care Observation Week 1',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = heartRateCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = heartRateUnitOfMeasure.Id,
    NumericValue = 80,
    EffectiveDateTime = Date.newInstance(2022, 04, 1),
    ExpectedValueId = heartRateCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = heartRateUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert heartRateCareObservationWeek1;

CareObservation heartRateCareObservationWeek2 = new CareObservation(
    Name = 'Heart Rate Care Observation Week 2',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = heartRateCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = heartRateUnitOfMeasure.Id,
    NumericValue = 100,
    EffectiveDateTime = Date.newInstance(2022, 04, 8),
    ExpectedValueId = heartRateCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = heartRateUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert heartRateCareObservationWeek2;


CareObservation heartRateCareObservationWeek3 = new CareObservation(
    Name = 'Heart Rate Care Observation Week 3',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = heartRateCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = heartRateUnitOfMeasure.Id,
    NumericValue = 90,
    EffectiveDateTime = Date.newInstance(2022, 04, 15),
    ExpectedValueId = heartRateCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = heartRateUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert heartRateCareObservationWeek3;

CareObservation bloodPressureCareObservationWeek1 = new CareObservation(
    Name = 'Blood Pressure Care Observation Week 1',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = bloodPressureCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Range',
    ObservedValueNumerator = 120,
    ObservedValueDenominator = 90,
    ObservedValueUnitId = bloodPressureUnitOfMeasure.Id,
    EffectiveDateTime = Date.newInstance(2022, 04, 1),
    ExpectedValueId = bloodPressureCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    DeviceId = jansenBloodPressureReaderAsset.Id
);
insert bloodPressureCareObservationWeek1;

CareObservation bloodPressureCareObservationWeek2 = new CareObservation(
    Name = 'Blood Pressure Care Observation Week 2',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = bloodPressureCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Range',
    ObservedValueNumerator = 100,
    ObservedValueDenominator = 70,
    ObservedValueUnitId = bloodPressureUnitOfMeasure.Id,
    EffectiveDateTime = Date.newInstance(2022, 04, 5),
    ExpectedValueId = bloodPressureCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    DeviceId = jansenBloodPressureReaderAsset.Id
);
insert bloodPressureCareObservationWeek2;

CareObservation bloodPressureCareObservationWeek3 = new CareObservation(
    Name = 'Blood Pressure Observation Week 3',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = bloodPressureCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Range',
    ObservedValueNumerator = 110,
    ObservedValueDenominator = 80,
    ObservedValueUnitId = bloodPressureUnitOfMeasure.Id,
    EffectiveDateTime = Date.newInstance(2022, 04, 15),
    ExpectedValueId = bloodPressureCareMetricTarget.Id,
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    DeviceId = jansenBloodPressureReaderAsset.Id
);
insert bloodPressureCareObservationWeek3;

CareObservation oxygenSaturationCareObservationWeek1 = new CareObservation(
    Name = 'Oxygen Saturation Observation Week 1',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = oxygenSaturationCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = percentUnitOfMeasure.Id,
    NumericValue = 98,
    EffectiveDateTime = Date.newInstance(2022, 04, 01),
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = percentUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert oxygenSaturationCareObservationWeek1;

CareObservation oxygenSaturationCareObservationWeek2 = new CareObservation(
    Name = 'Oxygen Saturation Observation Week 2',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = oxygenSaturationCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = percentUnitOfMeasure.Id,
    NumericValue = 100,
    EffectiveDateTime = Date.newInstance(2022, 04, 05),
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = percentUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert oxygenSaturationCareObservationWeek2;

CareObservation oxygenSaturationCareObservationWeek3 = new CareObservation(
    Name = 'Oxygen SaturationObservation  Week 3',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = oxygenSaturationCodeSet.Id,
    ObservationStatus = 'Final',
    ObservedValueType = 'Quantity',
    UnitOfMeasureId = percentUnitOfMeasure.Id,
    NumericValue = 94,
    EffectiveDateTime = Date.newInstance(2022, 04, 15),
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    ObservedValueUnitId = percentUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert oxygenSaturationCareObservationWeek3;

CareObservation electrocardiogramCareObservationWeek1 = new CareObservation(
    Name = 'Electrocardiogram Observation Week 1',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = electrocardiogramCodeSet.Id,
    ObservationStatus = 'Final',
    //ObservedValueType = 'Quantity',
    UnitOfMeasureId = electrocardiogramUnitOfMeasure.Id,
    //NumericValue = 90,
    ObservedValueText = '-7.281497192382812e-05V -8.043693542480469e-05V -8.866883087158202e-05V -9.733087158203124e-05V -0.00010625637817382812V -0.00011522732543945312V -0.00012401557922363281V -0.00013249023437499999V',
    EffectiveDateTime = Date.newInstance(2022, 04, 01),
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    // ObservedValueUnitId = electrocardiogramUnitOfMeasure.Id,
    BaselineUnitId = electrocardiogramUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id

);
insert electrocardiogramCareObservationWeek1;

CareObservation electrocardiogramCareObservationWeek2 = new CareObservation(
    Name = 'Electrocardiogram Observation  Week 2',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = electrocardiogramCodeSet.Id,
    ObservationStatus = 'Final',
    //ObservedValueType = 'Quantity',
    UnitOfMeasureId = electrocardiogramUnitOfMeasure.Id,
    ObservedValueText = '0.0008227933349609375V 0.0007742551269531249V 0.0007036845092773437V 0.00061619775390625V 0.0005181317138671875V 0.0004159224853515625V 0.0003151133422851562V 0.0002203743133544922V ',
    EffectiveDateTime = Date.newInstance(2022, 04, 05),
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    // ObservedValueUnitId = electrocardiogramUnitOfMeasure.Id,
    BaselineUnitId = electrocardiogramUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert electrocardiogramCareObservationWeek2;

CareObservation electrocardiogramCareObservationWeek3 = new CareObservation(
    Name = 'Electrocardiogram Observation Week 3',
    ObservedSubjectId = individualAccountJansen.Id,
    CodeId = electrocardiogramCodeSet.Id,
    ObservationStatus = 'Final',
    // ObservedValueType = 'Quantity',
    UnitOfMeasureId = electrocardiogramUnitOfMeasure.Id,
    ObservedValueText = '-8.984722900390625e-05V -8.671613311767578e-05V -8.481881713867187e-05V -8.386631774902344e-05V -8.353556823730468e-05V -8.395469665527343e-05V -8.527782440185546e-05V -8.718569183349609e-05V',
    EffectiveDateTime = Date.newInstance(2022, 04, 15),
    IsMonitoredRemotely = true,
    ObserverId = healthcareProviderHospital.Id,
    Category = 'Vital-Signs',
    // ObservedValueUnitId = electrocardiogramUnitOfMeasure.Id,
    BaselineUnitId = electrocardiogramUnitOfMeasure.Id,
    DeviceId = jansenAppleWatchAsset.Id
);
insert electrocardiogramCareObservationWeek3;

//CareObservation weightCareObservationWeek1Record = [SELECT Id FROM CareObservation WHERE Name= 'Weight Care Observation Week 1'];