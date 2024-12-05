ServiceAppointment[] serviceAppointment = [SELECT Id FROM ServiceAppointment];

delete serviceAppointment;

WorkOrder[] workOrders = [SELECT Id FROM WorkOrder];

delete workOrders;

WorkType[] workTypes = [SELECT Id FROM WorkType];

delete workTypes;

// ServiceResource[] serviceResources = [SELECT Id FROM ServiceResource];

// delete serviceResources;

// you can't delete service resources you can only deactivate them

ServiceTerritory[] serviceTerritories = [SELECT Id FROM ServiceTerritory];

delete serviceTerritories;

TimeSlot[] timeSlots = [SELECT Id FROM TimeSlot];

delete timeSlots;

Syntilio__CareOperatingHours__c[] Syntilio__CareOperatingHours__c = [SELECT Id FROM Syntilio__CareOperatingHours__c where Name <> 'Pacific Coast 8 am to 4 pm']; // change string to your org's Default operating hours

delete Syntilio__CareOperatingHours__c;

// you can't delete accounts which have oppurtunities status as 'closed won'

Account[] accounts = [SELECT Id FROM Account where Name <> 'Edge Communications' OR Name <> 'Sample Account for Entitlements'];

delete accounts;
