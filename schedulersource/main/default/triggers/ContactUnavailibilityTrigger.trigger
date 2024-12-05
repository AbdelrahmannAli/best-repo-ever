trigger ContactUnavailibilityTrigger on Syntilio__Unavailability__c (after insert, after update, after delete) {
    List<ServiceAppointment> serviceAppointmentsToBeUpdated = new List<ServiceAppointment>();
    List<AssignedResource> assignedResourcesToBeInserted = new List<AssignedResource>();
    List<Syntilio__Unavailability__c> recordsToProcess = new List<Syntilio__Unavailability__c>();
    if(Trigger.isInsert || Trigger.isUpdate) {
        recordsToProcess.addAll(Trigger.new);
    } else {
        recordsToProcess.addAll(Trigger.old);
    }
    for(Syntilio__Unavailability__c unavailability : recordsToProcess) {
        if(Trigger.isInsert || Trigger.isDelete) {
            List<ServiceAppointment> serviceAppointments = [SELECT FIELDS(Standard)
                                                            FROM ServiceAppointment 
                                                            WHERE SchedStartTime >= :unavailability.Syntilio__StartsAt__c 
                                                            AND SchedEndTime <= :unavailability.Syntilio__EndsAt__c 
                                                            AND ContactId = :unavailability.Syntilio__ContactId__c];
            for(ServiceAppointment sa : serviceAppointments) {
                if(Trigger.isInsert) {
                    sa.Status = 'Canceled';
                    //Here this means that the unavailability of the contact was deleted, therefore the contact is now available again, so we need to schedule the cancelled apointments
                } else if(sa.Status != 'Scheduled'){
                    sa.Status = 'Scheduled';
                    AssignedResource resource = ServiceAppointmentHandler.assignResource(sa);
                    if(resource != null) {
                        assignedResourcesToBeInserted.add(resource);
                    }
                }
            }
            serviceAppointmentsToBeUpdated.addAll(serviceAppointments);
        } else if(Trigger.isUpdate) {
            DateTime oldStartDatetime = Trigger.oldMap.get(unavailability.Id).Syntilio__StartsAt__c;
            Datetime newStartDatetime = Trigger.newMap.get(unavailability.Id).Syntilio__StartsAt__c;
            Datetime oldEndDatetime = Trigger.oldMap.get(unavailability.Id).Syntilio__EndsAt__c;
            Datetime newEndDatetime = Trigger.newMap.get(unavailability.Id).Syntilio__EndsAt__c;
            if(newStartDatetime < oldStartDatetime || newEndDatetime > oldEndDatetime) {
                //Delete additional Service Appointments since window of unavailability increased
                List<ServiceAppointment> serviceAppointments = [SELECT FIELDS(Standard)
                                                                FROM ServiceAppointment
                                                                WHERE ((SchedStartTime >= :newStartDatetime
                                                                AND SchedStartTime <= :oldStartDatetime)
                                                                OR (SchedEndTime >= :oldEndDatetime 
                                                                AND SchedEndTime <= :newEndDatetime))
                                                                AND Status != 'Canceled'
                                                                AND ContactId = :unavailability.Syntilio__ContactId__c];
                for(ServiceAppointment sa : serviceAppointments) {
                    sa.Status = 'Canceled';
                }
                serviceAppointmentsToBeUpdated.addAll(serviceAppointments);
            } else if(newStartDatetime > oldStartDatetime || newEndDatetime < oldEndDatetime) {
                //Assign agents to previously canceled Service Appointments since window of unavailability decreased
                List<ServiceAppointment> serviceAppointments = [SELECT FIELDS(Standard)
                                                                FROM ServiceAppointment 
                                                                WHERE ((SchedStartTime <= :newStartDatetime
                                                                AND SchedStartTime >= :oldStartDatetime)
                                                                OR (SchedEndTime <= :oldEndDatetime 
                                                                AND SchedEndTime >= :newEndDatetime))
                                                                AND Status = 'Canceled'
                                                                AND ContactId = :unavailability.Syntilio__ContactId__c];
                for(ServiceAppointment sa : serviceAppointments) {
                    sa.Status = 'Scheduled';
                    AssignedResource resource = ServiceAppointmentHandler.assignResource(sa);
                    if(resource != null) {
                        assignedResourcesToBeInserted.add(resource);
                    }
                }
                serviceAppointmentsToBeUpdated.addAll(serviceAppointments);
            }
        }
    }
    update serviceAppointmentsToBeUpdated;
    insert assignedResourcesToBeInserted;
}