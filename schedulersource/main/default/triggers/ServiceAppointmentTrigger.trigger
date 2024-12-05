trigger ServiceAppointmentTrigger on ServiceAppointment (after insert, before update, before delete) {
    if(!Trigger.isInsert) {
        List<Id> appointmentsToDelete = new List<Id>();
        for (ServiceAppointment sa : Trigger.old) {
            //Delete scheduled job in case of deletion or being canceled or changing start time
            if(Trigger.isDelete || (Trigger.isUpdate && (Trigger.newMap.get(sa.Id).Status == 'Canceled' || (sa.SchedStartTime != Trigger.newMap.get(sa.Id).SchedStartTime)))){
                String cronJobName = 'ScheduledServiceAppointmentHandler_' + sa.Id + '%';
                List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :cronJobName];
                if (!cronTriggers.isEmpty()) {
                    for (CronTrigger cronTrigger : cronTriggers) {
                        System.abortJob(cronTrigger.Id);
                    }
                }
            }
            //Delete series of service appointments in case of recurring
            if(Trigger.isDelete && sa.NextOccurenceId__c != null) {
                appointmentsToDelete.add(sa.NextOccurenceId__c);
            }
        }
        if(Trigger.isDelete) {
        	Database.delete(appointmentsToDelete);
        }
    }
    
    if(!Trigger.isDelete) {
        List<ServiceAppointment> appointmentsPointerToBeUpdated = new List<ServiceAppointment>();
        List<ServiceAppointment> appointmentsToBeInserted = new List<ServiceAppointment>();
        List<ServiceAppointment> appointmentsToBeUpdated = new List<ServiceAppointment>();
        List<AssignedResource> assignedResourcesToBeInserted = new List<AssignedResource>();
        for (ServiceAppointment sa : Trigger.new) {
            //Schedule a new scheduled flow in case of insert or cancel or update time
            if(Trigger.isInsert || (Trigger.isUpdate && sa.Status != 'Canceled' && (Trigger.oldMap.get(sa.Id).SchedStartTime != sa.SchedStartTime))) {
                ScheduledServiceAppointmentHandler handler = new ScheduledServiceAppointmentHandler(sa.Id);
                if(sa.SchedStartTime < Datetime.now()) {
                    handler.execute(null);
                    sa.SchedStartTime = Trigger.oldMap.get(sa.Id).SchedStartTime;
                } else {
                    Datetime cronSchedStartTime = sa.SchedStartTime;
                    String cronSchedStartTimeStr = ServiceAppointmentHandler.convertDatetimeToCronExpression(cronSchedStartTime);
            		System.schedule('ScheduledServiceAppointmentHandler_' + sa.Id + Datetime.now(), cronSchedStartTimeStr, handler);
                }
            }
            if(sa.RecurrencePeriod__c != null && sa.RecurrencePeriod__c != 0) {
                if(Trigger.isInsert) {
                    //Create and schedule recurrences in the same timeframe or first occurence outside it
                    if(ServiceAppointmentHandler.isNextOccurenceInsideTimeframe(sa) || ServiceAppointmentHandler.isNextOccurenceJustOutsideTimeframe(sa)) {
                        ServiceAppointment clonedAppointment = ServiceAppointmentHandler.cloneServiceAppointment(sa);
                        appointmentsToBeInserted.add(clonedAppointment);
                        //Add this service appoitment to a list that will update the next occurence, the problem is that we don't yet know the next occurence ID, look at comment named "search for this" 
                        appointmentsPointerToBeUpdated.add(new ServiceAppointment(Id = sa.Id, NextOccurenceId__c = null));
                        //Handle either creating new AssignedResource or if not available then create Task
                        if(!sa.InsertedByAgent__c){
                            AssignedResource serviceResource = ServiceAppointmentHandler.assignResource(sa);
                            if(serviceResource != null) {
                                assignedResourcesToBeInserted.add(serviceResource);
                            }
                        }
                    }
                } else {
                    //Check if time is changed, if not, no need to do any change
                    if(Trigger.oldMap.get(sa.Id).SchedStartTime != Trigger.newMap.get(sa.Id).SchedStartTime) {
                        if(!sa.UpdateAllOccurrences__c){
                            //Handle Update in case of single recurrence
                            //Schedule future appointment outside timeframe
                            ServiceAppointment lastInSeries = ServiceAppointmentHandler.getLastInSeries(sa);
                            ServiceAppointment clonedAppointment = ServiceAppointmentHandler.cloneServiceAppointment(lastInSeries);
                            appointmentsToBeInserted.add(clonedAppointment);
                            appointmentsPointerToBeUpdated.add(lastInSeries);
                            //Set recurrence to null for this appointment to avoid scheduling the exceptional appointment
                            sa.Recurrence_Period_Type__c = null;
                            sa.RecurrencePeriod__c = null;
                        } else {
                            //Handle Update in case of all recurrences
                            //Detect if the update is done by agent or by code, changes by agent do not need scheduling (first in series)
                            if(!sa.UpdatedByAgent__c) {
                                //Handle updating AssignedResource, or if not available then create Task
                                AssignedResource serviceResource = ServiceAppointmentHandler.assignResource(sa);
                                if(serviceResource != null) {
                                    assignedResourcesToBeInserted.add(serviceResource);
                                }
                            }
                            //Change next occurence's time
                            if(sa.NextOccurenceId__c != null) {
                                ServiceAppointment nextOccurence = [SELECT Id,ArrivalWindowStartTime,SchedStartTime,ArrivalWindowEndTime,SchedEndTime,RecurrencePeriod__c,Recurrence_Period_Type__c FROM ServiceAppointment WHERE Id = :sa.NextOccurenceId__c LIMIT 1];
                                Integer reoccursAfterInDays = ServiceAppointmentHandler.getRecurrenceInDays(sa);
                                nextOccurence.ArrivalWindowStartTime = sa.ArrivalWindowStartTime.addDays(reoccursAfterInDays);
                                nextOccurence.SchedStartTime = sa.SchedStartTime.addDays(reoccursAfterInDays);
                                nextOccurence.ArrivalWindowEndTime = sa.ArrivalWindowEndTime.addDays(reoccursAfterInDays);
                                nextOccurence.SchedEndTime = sa.SchedEndTime.addDays(reoccursAfterInDays);
                                appointmentsToBeUpdated.add(nextOccurence);
                            }
                        }
                    }
                    //Reset fields to default values to support future edits of recurrences
                    sa.UpdateAllOccurrences__c = true;
                    sa.UpdatedByAgent__c = false;
                }
            }
        }
        insert appointmentsToBeInserted;
        update appointmentsToBeUpdated;
        insert assignedResourcesToBeInserted;
        //List of Appointments with lastInSeries changed in trigger but the object was not updated therefore not in the Trigger.new or .old
        List<ServiceAppointment> lastInSeriesPointerChangedNotInTrigger = new List<ServiceAppointment>();
        Set<Id> triggerNewIds = (new Map<Id,ServiceAppointment>(Trigger.new)).keySet();
        //This is done to update the pointer to the next occurence that was just inserted
        for(Integer i = 0; i < appointmentsPointerToBeUpdated.size(); i++) {
            //search for this
            appointmentsPointerToBeUpdated.get(i).NextOccurenceId__c = appointmentsToBeInserted.get(i).Id;
            if(!triggerNewIds.contains(appointmentsPointerToBeUpdated.get(i).Id)) {
                lastInSeriesPointerChangedNotInTrigger.add(appointmentsPointerToBeUpdated.get(i));
            }
        }
        if(Trigger.isInsert) {
            //This is done as the trigger is an After Insert trigger not before
            update appointmentsPointerToBeUpdated;
        } else {
            //Update last in series appointments with the next occurence field changed. These appointments were not changed previously and therefore not in the trigger
            update lastInSeriesPointerChangedNotInTrigger;
        }
        
    }
}