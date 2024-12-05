Id clientContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();

Contact contactKevin = new Contact(
    Salutation = 'Dr.',
    Title = 'Pulmonologist',
    Department = 'Pulmonology',
    FirstName = 'Kevin',
    LastName = 'Willem',
    Phone = '+31-323276732',
    HomePhone = '+31-23672632',
    Birthdate = Date.newInstance(1972, 07, 15),
    MailingStreet = 'Street 5',
    MailingCity = 'Amsterdam',
    MailingState = 'Noord Holland',
    MailingPostalCode = '8932',
    MailingCountry = 'Nederland',
    Email = 'kevin@nl.com',
    AssistantName = 'Alice',
    AssistantPhone =  '+31-329362326'
);
insert contactKevin;

Contact patientContactKarelGroenendijk = [SELECT Id FROM Contact WHERE LastName = 'Groenendijk'];

Contact patientContactPieter = [SELECT Id FROM Contact WHERE LastName ='Dirk'];

Contact patientContactJohan = [SELECT Id FROM Contact WHERE LastName ='Hendrik'];

Account envidaCare = [SELECT Id FROM Account WHERE Name = 'Envida'];
Account middinCare = [SELECT Id FROM Account WHERE Name = 'Middin'];
Account cordaanCare = [SELECT Id FROM Account WHERE Name = 'Cordaan'];
Account twbCare = [SELECT Id FROM Account WHERE Syntilio__ApiName__c = 'Twb'];

Product2 telemonitoringAppProduct = new Product2(
    Name = 'Telemonitoring App',
    IsActive = true, 
    ProductCode = '0001',
    Family = 'Telemonitoring',
    Syntilio__Supplier__c = 'AppSupplier'
);
insert telemonitoringAppProduct;

Product2 mobileAppProduct = new Product2(
    Name = 'Syntilio VideoHub',
    IsActive = true, 
    ProductCode = '0002',
    Family = 'VideoHub',
    Syntilio__Supplier__c = 'AppSupplier'
);
insert mobileAppProduct;

Product2 medidoDeviceProduct = new Product2(
    Name = 'Medido',
    IsActive = true, 
    ProductCode = '0003'
);
insert medidoDeviceProduct;

//Asset karelBloodPressureReaderAssetRecord = [SELECT Id FROM Asset WHERE Name = 'Blood Pressure Reader'];

Asset karelAppleWatchAsset = new Asset(
    AccountId = middinCare.Id,
    ContactId = patientContactKarelGroenendijk.Id,
    IsCompetitorProduct = false, 
    Name = 'Apple Watch',
    Syntilio__AssetId__c = '101',
    Product2Id = telemonitoringAppProduct.Id,
    InstallDate = Date.newInstance(2022, 02, 11),
    PurchaseDate = Date.newInstance(2020, 06, 01),
    Status = 'Registered',
    Description = 'Apple Watch 7',
    Quantity = 1
);
insert karelAppleWatchAsset;

Asset karelBloodPressureReaderAsset = new Asset(
    AccountId = middinCare.Id,
    ContactId = patientContactKarelGroenendijk.Id,
    IsCompetitorProduct = false, 
    Name = 'Blood Pressure Reader',
    Syntilio__AssetId__c = '102',
    Product2Id = telemonitoringAppProduct.Id,
    InstallDate = Date.newInstance(2022, 03, 27),
    PurchaseDate = Date.newInstance(2021, 02, 01),
    Status = 'Registered',
    Description = 'Blood Pressure Reader Asset',
    Quantity = 1
);
insert karelBloodPressureReaderAsset;

Asset karelBloodPressureReaderChildAsset = new Asset(
    AccountId = middinCare.Id,
    ContactId = patientContactKarelGroenendijk.Id,
    IsCompetitorProduct = false, 
    Name = 'Blood Pressure Reader Child',
    Syntilio__AssetId__c = '103',
    Product2Id = telemonitoringAppProduct.Id,
    InstallDate = Date.newInstance(2022, 03, 27),
    PurchaseDate = Date.newInstance(2021, 02, 01),
    Status = 'Registered',
    Description = 'Blood Pressure Reader SubAsset',
    Quantity = 1,
    ParentId = karelBloodPressureReaderAsset.Id
);
insert karelBloodPressureReaderChildAsset;


Asset karelAndriodMobileAsset = new Asset(
    AccountId = middinCare.Id,
    ContactId = patientContactKarelGroenendijk.Id,
    IsCompetitorProduct = false, 
    Name = 'Andriod Mobile',
    Syntilio__AssetId__c = '104',
    Product2Id = mobileAppProduct.Id,
    InstallDate = Date.newInstance(2022, 03, 27),
    PurchaseDate = Date.newInstance(2021, 02, 01),
    Status = 'Registered',
    Description = 'Andriod Mobile',
    Quantity = 1,
    ParentId = null
);
insert karelAndriodMobileAsset;

Asset pieterAndriodMobileAsset = new Asset(
    AccountId = middinCare.Id,
    ContactId = patientContactPieter.Id,
    IsCompetitorProduct = false, 
    Name = 'Andriod Mobile',
    Syntilio__AssetId__c = '105',
    Product2Id = mobileAppProduct.Id,
    InstallDate = Date.newInstance(2022, 03, 27),
    PurchaseDate = Date.newInstance(2021, 02, 01),
    Status = 'Registered',
    Description = 'Andriod Mobile',
    Quantity = 1,
    ParentId = null
);
insert pieterAndriodMobileAsset;

Asset johanAndriodMobileAsset = new Asset(
    AccountId = cordaanCare.Id,
    ContactId = patientContactJohan.Id,
    IsCompetitorProduct = false, 
    Name = 'Andriod Mobile',
    Syntilio__AssetId__c = '106',
    Product2Id = mobileAppProduct.Id,
    InstallDate = Date.newInstance(2022, 03, 27),
    PurchaseDate = Date.newInstance(2021, 02, 01),
    Status = 'Registered',
    Description = 'Andriod Mobile',
    Quantity = 1,
    ParentId = null
);
insert johanAndriodMobileAsset;

Asset karelMedidoAsset = new Asset(
    AccountId = twbCare.Id,
    ContactId = patientContactKarelGroenendijk.Id,
    IsCompetitorProduct = false, 
    Name = 'Medication Device',
    Syntilio__AssetId__c = '107',
    Product2Id = medidoDeviceProduct.Id,
    InstallDate = Date.newInstance(2022, 03, 27),
    PurchaseDate = Date.newInstance(2021, 02, 01),
    Status = 'Registered',
    Description = 'Medido Medication Device',
    Quantity = 1
);
insert karelMedidoAsset;

Id medicalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SyntilioDefault').getRecordTypeId();

Syntilio__EventConfiguration__c highBloodPressureEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1001.0 LIMIT 1];

Case johnMedicalHighBloodPressureCaseRecord = new Case(
    Subject = 'High Blood Pressure',
    AccountId = envidaCare.Id,
    ContactId = patientContactKarelGroenendijk.Id,
    Syntilio__Event__c = highBloodPressureEventConfiguration.Id,
    AssetId = karelBloodPressureReaderAsset.Id,
    RecordTypeId = medicalCaseRecordTypeId,
    Origin = 'Web',
    Status = 'New',
    Priority = 'High',
    ProductId = telemonitoringAppProduct.Id,
    Syntilio__CodeSet__c = 'bp'
    
);
insert johnMedicalHighBloodPressureCaseRecord;

Syntilio__EventConfiguration__c bloodPressureDeviceNotReachableEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 2001.0 LIMIT 1];

Case johnTechnicalBloodPressureDeviceNotReachableCaseRecord = new Case(
    Subject = 'Blood Pressure Device Not Reachable',
    AccountId = envidaCare.Id,
    ContactId = patientContactKarelGroenendijk.Id,
    Syntilio__Event__c = bloodPressureDeviceNotReachableEventConfiguration.Id,
    AssetId = karelBloodPressureReaderAsset.Id,
    RecordTypeId = medicalCaseRecordTypeId,
    Origin = 'Web',
    Status = 'New',
    Priority = 'High',
    ProductId = telemonitoringAppProduct.Id,
    Syntilio__CodeSet__c = 'bp'
);
insert johnTechnicalBloodPressureDeviceNotReachableCaseRecord;

Syntilio__EventConfiguration__c atrialFibrillationEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1006.0 LIMIT 1];

Case johnMedicalAtrialFibrillationCaseRecord = new Case(
    Subject = 'Atrial Fibrillation',
    AccountId = cordaanCare.Id,
    ContactId = patientContactPieter.Id,
    Syntilio__Event__c = atrialFibrillationEventConfiguration.Id,
    AssetId = karelAppleWatchAsset.Id,
    RecordTypeId = medicalCaseRecordTypeId,
    Origin = 'Web',
    Status = 'New',
    Priority = 'High',
    ProductId = telemonitoringAppProduct.Id,
    Syntilio__CodeSet__c = 'ecg'
);
insert johnMedicalAtrialFibrillationCaseRecord;

Syntilio__EventConfiguration__c lowOxygenSaturationEventConfiguration = [SELECT Id FROM Syntilio__EventConfiguration__c WHERE Syntilio__Code__c = 1004.0 LIMIT 1];

Case johnMedicalOxygenSaturationCaseRecord = new Case(
    Subject = 'Low Oxygen Saturation',
    AccountId = twbCare.Id,
    ContactId = patientContactJohan.Id,
    Syntilio__Event__c = lowOxygenSaturationEventConfiguration.Id,
    AssetId = karelAppleWatchAsset.Id,
    RecordTypeId = medicalCaseRecordTypeId,
    Origin = 'Web',
    Status = 'New',
    Priority = 'High',
    ProductId = telemonitoringAppProduct.Id,
    Syntilio__CodeSet__c = 'spo2'
);
insert johnMedicalOxygenSaturationCaseRecord;

Syntilio__SyntilioEvent__c johnMedicalSyntilioEventRecord = new Syntilio__SyntilioEvent__c(
    Syntilio__Account__c = middinCare.Id,
    Syntilio__Asset__c = karelBloodPressureReaderAsset.Id,
    Syntilio__AssetIndex__c = 0001,
    Syntilio__Case__c = johnMedicalHighBloodPressureCaseRecord.Id,
    Syntilio__Category__c = 'Medical',
    Syntilio__EventId__c = '000001',
    Syntilio__EventCode__c = 1001,
    Syntilio__Priority__c = 'High',
    Syntilio__Product__c = 'Blood Pressure',
    Syntilio__SupplierEventCode__c = 9991,
    Syntilio__TimeStamp__c = system.now()
);
insert johnMedicalSyntilioEventRecord;

Syntilio__SyntilioEvent__c johnTechnicalSyntilioEventRecord = new Syntilio__SyntilioEvent__c(
    Syntilio__Account__c = middinCare.Id,
    Syntilio__Asset__c = karelBloodPressureReaderAsset.Id,
    Syntilio__AssetIndex__c = 0001,
    Syntilio__Case__c = johnTechnicalBloodPressureDeviceNotReachableCaseRecord.Id,
    Syntilio__Category__c = 'Technical',
    Syntilio__EventId__c = '000002',
    Syntilio__EventCode__c = 2001,
    Syntilio__Priority__c = 'High',
    Syntilio__Product__c = 'Blood Pressure',
    Syntilio__SupplierEventCode__c = 9992,
    Syntilio__TimeStamp__c = system.now()
);
insert johnTechnicalSyntilioEventRecord;

Syntilio__SyntilioEvent__c unKnownEventDataSyntilioEventRecord = new Syntilio__SyntilioEvent__c(
    Syntilio__AssetIndex__c = 0001,
    Syntilio__EventId__c = '000003',
    Syntilio__EventCode__c = 000,
    Syntilio__Priority__c = 'High',
    Syntilio__Product__c = 'Blood Pressure',
    Syntilio__SupplierEventCode__c = 9993,
    Syntilio__TimeStamp__c = system.now()
);
insert unKnownEventDataSyntilioEventRecord;

Syntilio__SyntilioEvent__c unknownPatientMedicalSyntilioEventRecord = new Syntilio__SyntilioEvent__c(
    Syntilio__AssetIndex__c = 0001,
    Syntilio__Category__c = 'Medical',
    Syntilio__EventId__c = '000004',
    Syntilio__EventCode__c = 1001,
    Syntilio__Priority__c = 'High',
    Syntilio__Product__c = 'Blood Pressure',
    Syntilio__SupplierEventCode__c = 9991,
    Syntilio__TimeStamp__c = system.now()
);
insert unknownPatientMedicalSyntilioEventRecord;

Syntilio__SyntilioEvent__c johnMedicalInvalidAssetSyntilioEventRecord = new Syntilio__SyntilioEvent__c(
    Syntilio__AssetIndex__c = 0001,
    Syntilio__Category__c = 'Medical',
    Syntilio__EventId__c = '000005',
    Syntilio__EventCode__c = 1001,
    Syntilio__Priority__c = 'High',
    Syntilio__Product__c = 'Blood Pressure',
    Syntilio__SupplierEventCode__c = 9991,
    Syntilio__TimeStamp__c = system.now()
);
insert johnMedicalInvalidAssetSyntilioEventRecord;

Syntilio__SyntilioEvent__c johnMedicalAtrialFibrillationSyntilioEventRecord = new Syntilio__SyntilioEvent__c(
    Syntilio__Account__c = middinCare.Id,
    Syntilio__Asset__c = karelAppleWatchAsset.Id,
    Syntilio__AssetIndex__c = 0001,
    Syntilio__Case__c = johnMedicalAtrialFibrillationCaseRecord.Id,
    Syntilio__Category__c = 'Medical',
    Syntilio__EventId__c = '000006',
    Syntilio__EventCode__c = 1006,
    Syntilio__Priority__c = 'High',
    Syntilio__Product__c = 'Electrocardiogram',
    Syntilio__SupplierEventCode__c = 9994,
    Syntilio__TimeStamp__c = system.now()
);
insert johnMedicalAtrialFibrillationSyntilioEventRecord;

Syntilio__SyntilioEvent__c johnMedicalOxygenSaturationSyntilioRecord = new Syntilio__SyntilioEvent__c(
    Syntilio__Account__c = middinCare.Id,
    Syntilio__Asset__c = karelAppleWatchAsset.Id,
    Syntilio__AssetIndex__c = 0001,
    Syntilio__Case__c = johnMedicalOxygenSaturationCaseRecord.Id,
    Syntilio__Category__c = 'Medical',
    Syntilio__EventId__c = '000007',
    Syntilio__EventCode__c = 1004,
    Syntilio__Priority__c = 'High',
    Syntilio__Product__c = 'Oxygen Saturation',
    Syntilio__SupplierEventCode__c = 9995,
    Syntilio__TimeStamp__c = system.now()
);
insert johnMedicalOxygenSaturationSyntilioRecord;

Task unKnownEventDataSyntilioEventTaskRecord = new Task(
    Subject = 'Unknown event code 000 received',
    Syntilio__SyntilioEvent__c = unKnownEventDataSyntilioEventRecord.Id,
    Priority = 'Medium',
    Status = 'Not Started',
    Syntilio__Reason__c = 'We could not find this event&apos;s configuration in your org, please contact your system administrator with the event code to check the custom metadata.'
);
insert unKnownEventDataSyntilioEventTaskRecord;

Task unKnownPatientDataSyntilioEventTaskRecord = new Task(
    Subject = 'Unknown patient data',
    Syntilio__SyntilioEvent__c = unknownPatientMedicalSyntilioEventRecord.Id,
    Priority = 'High',
    Status = 'In Progress',
    Syntilio__Reason__c = 'We received an event with an empty UserId and AssetId, please contact your service team to validate these values.',
    Description = 'Missing UserId and AssetId in platform event.'
);
//insert unKnownPatientDataSyntilioEventTaskRecord;

Task johnMedicalInvalidAssetTaskRecord = new Task(
    Subject = 'Patient asset not found',
    Syntilio__SyntilioEvent__c = johnMedicalInvalidAssetSyntilioEventRecord.Id,
    Priority = 'High',
    Status = 'Not Started',
    Syntilio__Reason__c = 'We could not find an Asset in your org that matches the serial number in the event, please contact your service team to validate these values.',
    Description = 'Missing patient asset data.'
);
insert johnMedicalInvalidAssetTaskRecord;

Task callPatientTaskRecord = new Task(
    Subject = 'Call patient',
    Syntilio__SyntilioEvent__c = unknownPatientMedicalSyntilioEventRecord.Id,
    Priority = 'High',
    Status = 'In Progress',
    Syntilio__Reason__c = '',
    Description = 'Call patient for follow up.'
);
insert callPatientTaskRecord;