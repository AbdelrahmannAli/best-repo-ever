public with sharing class ServiceAppointmentHandler {
    public class Candidate {
        public String startTime;
        public String endTime;
        public String[] resources;
        public String territoryId;
    }
    
    public class ServiceAppointmentMethodInput {
      @InvocableVariable(label='Method to be applied on the input Service Appointment')
      public String methodToBeUsed;
     
      @InvocableVariable(label='Input Service Appointment')
      public ServiceAppointment inputServiceAppointment;
    }
	
    @InvocableMethod(label='Service Appointment Handler Functions' description='All functions related to Service Appointments that can be called from a flow')
    public static List<ServiceAppointment> serviceAppointmentHandlerFunctions(List<ServiceAppointmentMethodInput> serviceAppointmentsToBeProcessed) {
        List<ServiceAppointment> result = new List<ServiceAppointment>();
        for(ServiceAppointmentMethodInput serviceAppointmentToBeProcessed : serviceAppointmentsToBeProcessed){
            switch on serviceAppointmentToBeProcessed.methodToBeUsed {
                //Abort All Scheduled Jobs for a Service Appointment
                when 'abortScheduledJobs'{
                    String cronJobName = 'ScheduledServiceAppointmentHandler_' + serviceAppointmentToBeProcessed.inputServiceAppointment.Id + '%';
                    List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :cronJobName];
                    for (CronTrigger cronTrigger : cronTriggers) {
                        System.abortJob(cronTrigger.Id);
                    }
                }
                
                //Clone the ServiceAppointment and create a new instance for the next recurrence
                when 'cloneServiceAppointment' {
                	result.add(cloneServiceAppointment(serviceAppointmentToBeProcessed.inputServiceAppointment));
                }
                
                //Get last instance of a series of recurrent appointments
                when 'getLastInSeries' {
                	result.add(getLastInSeries(serviceAppointmentToBeProcessed.inputServiceAppointment));
                }
        	}
        }
        return result;
    }
    
    public static boolean isNextOccurenceInsideTimeframe(ServiceAppointment sa) {
        WorkType relatedWorkType = [SELECT TimeframeEnd,TimeFrameEndUnit FROM WorkType WHERE Id = :sa.WorkTypeId];
        Integer timeframeEndInDays = relatedWorkType.TimeframeEnd;
        if(relatedWorkType.TimeFrameEndUnit == 'Hours') {
            timeframeEndInDays = relatedWorkType.TimeframeEnd / 24;
        }
        Integer reoccursAfterInDays = getRecurrenceInDays(sa);
        
        Datetime nextOccurence = sa.SchedStartTime.addDays(reoccursAfterInDays);
        Datetime timeframeEndsAt = Datetime.now().addDays(timeframeEndInDays);
        
        return nextOccurence <= timeframeEndsAt;
    }
    
    public static boolean isNextOccurenceJustOutsideTimeframe(ServiceAppointment sa) {
        WorkType relatedWorkType = [SELECT TimeframeEnd,TimeFrameEndUnit FROM WorkType WHERE Id = :sa.WorkTypeId];
        Integer timeframeEndInDays = relatedWorkType.TimeframeEnd;
        if(relatedWorkType.TimeFrameEndUnit == 'Hours') {
            timeframeEndInDays = relatedWorkType.TimeframeEnd / 24;
        }
        Integer reoccursAfterInDays = getRecurrenceInDays(sa);
        
        Datetime nextOccurence = sa.SchedStartTime.addDays(reoccursAfterInDays);
        Datetime timeframeEndsAt = Datetime.now().addDays(timeframeEndInDays);
        Double differenceInMilliseconds = (Double) (nextOccurence.getTime() - timeframeEndsAt.getTime());
        Double differenceInDays = differenceInMilliseconds/(1000 * 60 * 60 * 24);
        return differenceInDays > 0 && (differenceInDays/reoccursAfterInDays < 1);
    }
    
    public static ServiceAppointment cloneServiceAppointment(ServiceAppointment appointmentToBeCloned) {
        Integer reoccursAfterInDays = getRecurrenceInDays(appointmentToBeCloned);
        
        Case clonedCase = [SELECT 
                           AccountId,AssetId,Comments,ContactId,Description,
                            Origin,OwnerId,ParentId,Priority,ProductId,Reason,RecordTypeId,
                            Subject,Syntilio__Event__c,Syntilio__ParentAsset__c 
                           FROM Case WHERE Id = :appointmentToBeCloned.ParentRecordId LIMIT 1].clone();
        clonedCase.Status = 'New';
        clonedCase.Id = null;
        insert clonedCase;
        
        ServiceAppointment clonedAppointment = new ServiceAppointment(
            EarliestStartTime = Datetime.now(),
            DueDate = Datetime.now().addDays(7),
            Status = 'Scheduled',
            ParentRecordId = clonedCase.Id,
            InsertedByAgent__c = false,
            UpdatedByAgent__c = false,
            UpdateAllOccurrences__c = true,
            RecurrencePeriod__c = appointmentToBeCloned.RecurrencePeriod__c,
            Recurrence_Period_Type__c = appointmentToBeCloned.Recurrence_Period_Type__c,
            ArrivalWindowStartTime = appointmentToBeCloned.ArrivalWindowStartTime.addDays(reoccursAfterInDays),
            SchedStartTime = appointmentToBeCloned.SchedStartTime.addDays(reoccursAfterInDays),
			ArrivalWindowEndTime = appointmentToBeCloned.ArrivalWindowEndTime.addDays(reoccursAfterInDays),
            SchedEndTime = appointmentToBeCloned.SchedEndTime.addDays(reoccursAfterInDays),
            AdditionalInformation = appointmentToBeCloned.AdditionalInformation,
            AppointmentCategoryId = appointmentToBeCloned.AppointmentCategoryId,
            AppointmentType = appointmentToBeCloned.AppointmentType,
            City = appointmentToBeCloned.City,
            Country = appointmentToBeCloned.Country,
            ContactId = appointmentToBeCloned.ContactId,
            Description = appointmentToBeCloned.Description,
            Duration = appointmentToBeCloned.Duration,
            DurationType = appointmentToBeCloned.DurationType,
            Email = appointmentToBeCloned.Email,
            EngagementChannelTypeId = appointmentToBeCloned.EngagementChannelTypeId,
            GeocodeAccuracy = appointmentToBeCloned.GeocodeAccuracy,
            IsAnonymousBooking = appointmentToBeCloned.IsAnonymousBooking,
            IsOffsiteAppointment = appointmentToBeCloned.IsOffsiteAppointment,
            OwnerId = appointmentToBeCloned.OwnerId,
            Phone = appointmentToBeCloned.Phone,
            PostalCode = appointmentToBeCloned.PostalCode,
            ServiceTerritoryId = appointmentToBeCloned.ServiceTerritoryId,
            State = appointmentToBeCloned.State,
            Street = appointmentToBeCloned.Street,
            Subject = appointmentToBeCloned.Subject,
            WorkTypeId = appointmentToBeCloned.WorkTypeId
        );
        
        return clonedAppointment;
    }
    
    public static ServiceAppointment getLastInSeries(ServiceAppointment sa) {
        ServiceAppointment lastInSeries = sa;
        try{
            while(lastInSeries.NextOccurenceId__c != null) {
                lastInSeries = [SELECT Id,NextOccurenceId__c,RecurrencePeriod__c,FIELDS(Standard),
                                Recurrence_Period_Type__c, InsertedByAgent__c, UpdatedByAgent__c, UpdateAllOccurrences__c
                                FROM ServiceAppointment WHERE Id = :lastInSeries.NextOccurenceId__c LIMIT 1];
            }
        } catch(Exception ex) {
        }
        return lastInSeries;
    }
    
    public static Integer getRecurrenceInDays(ServiceAppointment appointment) {
        Integer reoccursAfterInDays = (Integer) appointment.RecurrencePeriod__c;
        if(appointment.Recurrence_Period_Type__c == 'Weeks') {
            reoccursAfterInDays = reoccursAfterInDays * 7;
        } else if(appointment.Recurrence_Period_Type__c == 'Months') {
            reoccursAfterInDays = reoccursAfterInDays * 30;
        }
        return reoccursAfterInDays;
    }
    
    public static AssignedResource assignResource(ServiceAppointment appointment){
        try{
            List<AssignedResource> resources = [SELECT Id,ServiceResourceId,EventId from AssignedResource WHERE ServiceAppointmentId = :appointment.Id];
            
            if(resources != null && resources.size() != 0) {
                delete resources;
            }
            
            lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
                .setId(appointment.WorkTypeId)
                .build();
            //Build input for GetAppointmentCandidates
            lxscheduler.GetAppointmentCandidatesInput input = new lxscheduler.GetAppointmentCandidatesInputBuilder()
                .setWorkType(workType)
                .setAccountId(appointment.AccountId)
                .setTerritoryIds(new List<String>{appointment.ServiceTerritoryId})
                .setStartTime(appointment.SchedStartTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
                .setEndTime(appointment.SchedEndTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
                .build();
            String candidatesStr = lxscheduler.SchedulerResources.getAppointmentCandidates(input);
            
            List<Candidate> candidates = (List<Candidate>)JSON.deserialize(candidatesStr, List<Candidate>.class);
            if(candidates.size() == 0) {
                createTaskAndEvent(appointment);
                return null;
            }
            
            AssignedResource resourceAssigned = new AssignedResource(
                ServiceAppointmentId = appointment.Id,
                ServiceResourceId = candidates.get(0).resources.get(0),
                isRequiredResource = true
            );
            return resourceAssigned;
        } catch(Exception ex) {
            createTaskAndEvent(appointment);
            return null;
        }
    }
    
    private static void createTaskAndEvent(ServiceAppointment appointment) {
		try {
            List<Calendar> calendars = [SELECT Id from Calendar WHERE Name = 'Unassigned Appointments' Limit 1];
            if(calendars.size() > 0) {
                Event newEvent = new Event(
                    Subject = 'Unassigned Meeting',
                    StartDateTime = appointment.SchedStartTime,
                    EndDateTime = appointment.SchedEndTime,
                    IsAllDayEvent = false,
                    OwnerId = calendars.get(0).Id
                );
                insert newEvent;
            }
            Task taskRecord = new Task(
                WhatId = appointment.Id,
                Subject = 'Appointment Not Assigned',
                Description = 'Could not find a free resource for that appointment in the current slot',
                Priority = 'High',
                ActivityDate = Date.ValueOf(appointment.SchedStartTime.addDays(-1))
            );
            insert taskRecord;
        } catch(Exception ex) {
        }
    }

    public static String convertDatetimeToCronExpression(Datetime inputDatetime) {
        String cronExpression = '';
  
        // Extract the components of the datetime
        Integer year = inputDatetime.year();
        Integer month = inputDatetime.month();
        Integer day = inputDatetime.day();
        Integer hour = inputDatetime.hour();
        Integer minute = inputDatetime.minute();
  
        // Convert to cron expression format
        cronExpression = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
  
        return cronExpression;
    }
    
}