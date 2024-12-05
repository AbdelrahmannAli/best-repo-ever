trigger ContactContactRelationshipTrigger on Syntilio__ContactContactRelationship__c(
  before insert,
  before update,
  before delete
) {
  if (Trigger.isDelete) {
    for (
      Syntilio__ContactContactRelationship__c contactRelationship : Trigger.old
    ) {
      String condition =
      'Syntilio__RelationshipType__c = \''+ 
      contactRelationship.Syntilio__RelationshipType__c +
      '\' AND Syntilio__Type__c = \'' +
      contactRelationship.Syntilio__Type__c +
      '\' ' ;

      if (contactRelationship.Syntilio__ContactId__c != null) {
        condition += 'AND Syntilio__ContactId__c = \'' + contactRelationship.Syntilio__ContactId__c + '\'';
    }

      Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
        'Syntilio__ContactContactRelationship__c',
        null,
        contactRelationship.Id,
        condition
      );
      if (!reordered) {
        contactRelationship.addError(
          'Could not automatically reorder other records.'
        );
      }
    }
    return;
  }
  Map <String,Decimal> triggerNextOrder = new Map <String,Decimal> ();
  for (
    Syntilio__ContactContactRelationship__c contactRelationship : Trigger.new
    ) {
    try {
      Boolean isInsert = Trigger.isInsert;
      if (Syntilio.CareHubUtilities.recordsBeingUpdated.contains(contactRelationship.Id)) {
        continue;
      }
      if(Trigger.isUpdate) {
        Syntilio__ContactContactRelationship__c oldRecord = Trigger.oldMap.get(contactRelationship.Id);
        if(contactRelationship.Syntilio__ContactId__c != oldRecord.Syntilio__ContactId__c
          || contactRelationship.Syntilio__Type__c != oldRecord.Syntilio__Type__c){
            String updateCondition = 'Syntilio__ContactId__c = \'' +
            oldRecord.Syntilio__ContactId__c + 
            '\' AND Syntilio__RelationshipType__c = \''+ 
            oldRecord.Syntilio__RelationshipType__c +
            '\' AND Syntilio__Type__c = \'' +
            oldRecord.Syntilio__Type__c +
            '\' ' ;
            Boolean updateReordered = Syntilio.CareHubUtilities.reorderRecords(
              'Syntilio__ContactContactRelationship__c',
              null,
              contactRelationship.Id,
              updateCondition
            );
            if (!updateReordered) {
              contactRelationship.addError(
                'Could not automatically reorder other records.'
              );
            }
            isInsert = true;
        }else if (contactRelationship.Syntilio__Order__c == oldRecord.Syntilio__Order__c) {
            continue;
        }
      }

      String condition =
        'Syntilio__ContactId__c = \'' +
        contactRelationship.Syntilio__ContactId__c + 
        '\' AND Syntilio__RelationshipType__c = \''+ 
        contactRelationship.Syntilio__RelationshipType__c +
        '\' AND Syntilio__Type__c = \'' +
        contactRelationship.Syntilio__Type__c +
        '\' ' ;
      Boolean checkConflictingRelationships = Syntilio.ContactContactRelationshipHandler.hasDuplicateRelationship(
        contactRelationship
      );
      if (checkConflictingRelationships) {
        contactRelationship.addError('Contact relationship already exists');
        continue;
      }
      String nextOrderCondition = contactRelationship.Syntilio__ContactId__c + '/' + contactRelationship.Syntilio__RelationshipType__c + '/' + contactRelationship.Syntilio__Type__c;
      Decimal nextOrder = !triggerNextOrder.containsKey(nextOrderCondition) ? Syntilio.CareHubUtilities.getNextOrder(
        'Syntilio__ContactContactRelationship__c',
        contactRelationship.Id != null,
        condition
      ) : triggerNextOrder.get(nextOrderCondition);
      if (
        contactRelationship.Syntilio__Order__c == null ||
        contactRelationship.Syntilio__Order__c > nextOrder 
      ) {
        contactRelationship.Syntilio__Order__c = nextOrder;
        triggerNextOrder.put(nextOrderCondition , nextOrder +1);
      }
      Boolean checkConflictingOrder = Syntilio.ContactContactRelationshipHandler.hasConflictingOrder(
        contactRelationship
      );
      if (checkConflictingOrder) {
        Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
          'Syntilio__ContactContactRelationship__c',
          Trigger.isDelete ? null : contactRelationship.Syntilio__Order__c,
          isInsert? null : contactRelationship.Id,
          condition
        );
        if (!reordered) {
          contactRelationship.addError(
            'Could not automatically reorder other records.'
          );
        }
      }
    } catch (Exception e) {
      Syntilio.HandleException.LogException(e);
      if (contactRelationship != null) {
        contactRelationship.addError('Something went wrong');
      }
    }
  }
}
