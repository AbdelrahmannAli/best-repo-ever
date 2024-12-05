trigger AssignedResourceTrigger on AssignedResource (after insert, after update) {
	List<Case> casesToUpdate = new List<Case>();
    //Handling changing the case owner
    for(AssignedResource newAssignedResource : Trigger.new) {
        //Gettting parent case 
        ServiceAppointment serviceAppointmentLinkedToSR = [SELECT ParentRecordId FROM ServiceAppointment WHERE Id = :newAssignedResource.ServiceAppointmentId];
        Case parentCase = [SELECT Id,OwnerId FROM Case WHERE Id = :serviceAppointmentLinkedToSR.ParentRecordId LIMIT 1];
        
        //Getting Service Resource
        ServiceResource serviceResourceAssigned = [SELECT RelatedRecordId FROM ServiceResource WHERE Id = :newAssignedResource.ServiceResourceId];
        
        if(parentCase.OwnerId != serviceResourceAssigned.RelatedRecordId) {
            parentCase.OwnerId = serviceResourceAssigned.RelatedRecordId;
            casesToUpdate.add(parentCase);
        }
    }
    update casesToUpdate;
}