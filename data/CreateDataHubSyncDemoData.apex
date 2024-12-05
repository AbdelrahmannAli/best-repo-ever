Datetime now = Datetime.now();
List<Syntilio__DataHubSyncInfo__c> dataHubSyncInfoRecordsList = new List<Syntilio__DataHubSyncInfo__c>();
Syntilio__DataHubSyncInfo__c dataHubSyncInfo1 = new Syntilio__DataHubSyncInfo__c(
    Name = 'FirstName',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 22,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo1);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo3 = new Syntilio__DataHubSyncInfo__c(
    Name = 'LastName',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 22,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo3);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo4 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Phone',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 22,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo4);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo5 = new Syntilio__DataHubSyncInfo__c(
    Name = 'MailingStreet',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo5);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo6 = new Syntilio__DataHubSyncInfo__c(
    Name = 'MailingPostalCode',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo6);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo7 = new Syntilio__DataHubSyncInfo__c(
    Name = 'MailingState',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo7);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo8 = new Syntilio__DataHubSyncInfo__c(
    Name = 'MailingCity',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo8);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo9 = new Syntilio__DataHubSyncInfo__c(
    Name = 'MailingCountry',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo9);


Syntilio__DataHubSyncInfo__c dataHubSyncInfo10 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__Comments__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__MedicalReport__c',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo10);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo11 = new Syntilio__DataHubSyncInfo__c(
    Name = 'CreatedBy.Name',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = false,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__MedicalReport__c',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'Push'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo11);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo12 = new Syntilio__DataHubSyncInfo__c(
    Name = 'CreatedDate',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = false,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__MedicalReport__c',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'Push'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo12);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo13 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__ExternalUpdatedAt__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__MedicalReport__c',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo13);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo14 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__Author__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__MedicalReport__c',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo14);
Syntilio__DataHubSyncInfo__c dataHubSyncInfo15 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__ContactId__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 0,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__ContactContactRelationship__c',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo15);
Syntilio__DataHubSyncInfo__c dataHubSyncInfo16 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__RelatedContactId__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 0,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__ContactContactRelationship__c',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo16);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo17 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Name',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 0,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__ContactContactRelationship__c',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo17);


Syntilio__DataHubSyncInfo__c dataHubSyncInfo25 = new Syntilio__DataHubSyncInfo__c(
    Name = 'MobilePhone',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 0,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo25);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo26 = new Syntilio__DataHubSyncInfo__c(
    Name = 'RecordTypeId',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 0,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Contact',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo26);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo27 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Description',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 22,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Event',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo27);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo28 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Subject',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 22,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Event',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo28);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo29 = new Syntilio__DataHubSyncInfo__c(
    Name = 'StartDateTime',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 22,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Event',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo29);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo30 = new Syntilio__DataHubSyncInfo__c(
    Name = 'EndDateTime',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 22,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Event',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo30);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo31 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__RelationshipType__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 0,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__ContactContactRelationship__c',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo31);

Syntilio__DataHubSyncInfo__c dataHubSyncInfo32 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__Relationship__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 0,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__ContactContactRelationship__c',
    Syntilio__SyncMode__c = 'AlwaysOverride',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo32);
Syntilio__DataHubSyncInfo__c dataHubSyncInfo33 = new Syntilio__DataHubSyncInfo__c(
    Name = 'Syntilio__AuthorRole__c',
    Syntilio__Enabled__c = true,
    Syntilio__Frequency__c = 21,
    Syntilio__InsertNewRecords__c = true,
    Syntilio__IsUniqueIdentifier__c = false,
    Syntilio__LastSyncDate__c = now,
    Syntilio__ObjectName__c = 'Syntilio__MedicalReport__c',
    Syntilio__SyncMode__c = 'CreateTaskOnConflict',
    Syntilio__ExternalSystems__c = 'Ons',
    Syntilio__Type__c = 'PullAndPush'
);
dataHubSyncInfoRecordsList.add(dataHubSyncInfo33);

insert dataHubSyncInfoRecordsList;