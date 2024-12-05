trigger ProtocolActionRelationValidationHandler on Syntilio__ProtocolActionRelation__c (before insert, before update, before delete) {
    
  if(Trigger.isDelete) {
      for (Syntilio__ProtocolActionRelation__c protocolRelation : Trigger.old) {
          String condition = 'Syntilio__Protocol__c = ' + '\'' + protocolRelation.Syntilio__Protocol__c + '\'';
          Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
              'Syntilio__ProtocolActionRelation__c',
              null,
              protocolRelation.Id,
              condition
          );
          if (!reordered) {
              protocolRelation.addError(
                  'Could not automatically reorder other records.'
              );
          }        
      }
      return;
  }
  
  for (Syntilio__ProtocolActionRelation__c protocolRelation : Trigger.new) {
    if (Syntilio.CareHubUtilities.recordsBeingUpdated.contains(protocolRelation.Id)) {
        continue;
    }
      if(Trigger.isUpdate) {
          Syntilio__ProtocolActionRelation__c oldRecord = Trigger.oldMap.get(protocolRelation.Id);
          if (protocolRelation.Syntilio__Order__c == oldRecord.Syntilio__Order__c) {
              continue;
          }  
      }
      
      String condition = 'Syntilio__Protocol__c = ' + '\'' + protocolRelation.Syntilio__Protocol__c + '\'';
      
      Decimal nextOrder = Syntilio.CareHubUtilities.getNextOrder(
          'Syntilio__ProtocolActionRelation__c',
          Trigger.isUpdate,
          condition
      );
      if (
          protocolRelation.Syntilio__Order__c == null ||
          protocolRelation.Syntilio__Order__c > nextOrder
      ) {
          protocolRelation.Syntilio__Order__c = nextOrder;
          continue;
      }
      
      Boolean reordered = Syntilio.CareHubUtilities.reorderRecords(
          'Syntilio__ProtocolActionRelation__c',
          protocolRelation.Syntilio__Order__c,
          Trigger.isUpdate ? protocolRelation.Id : null,
          condition
      );
      if (!reordered) {
          protocolRelation.addError(
              'Could not automatically reorder other records.'
          );
      }        
  }
  
}