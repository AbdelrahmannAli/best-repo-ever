@NamespaceAccessible
public with sharing class ContactContactRelationshipHandler {
  public Enum ContactRelationshipType { Emergency, Other }
  @NamespaceAccessible
  public static Boolean hasDuplicateRelationship(
    Syntilio__ContactContactRelationship__c relationship
  ) {
    try {
      Id relationshipId = relationship.Id;
      Id contactId = relationship.Syntilio__RelatedContactId__c;
      Id relatedContactId = relationship.Syntilio__ContactId__c;
      String relationshipType = relationship.Syntilio__Type__c;
      String query = 'SELECT Id, Syntilio__RelatedContactId__c, Syntilio__ContactId__c, Syntilio__Type__c FROM Syntilio__ContactContactRelationship__c WHERE ';
      query += 'Syntilio__RelatedContactId__c = :contactId AND Syntilio__ContactId__c = :relatedContactId AND Syntilio__Type__c = :relationshipType';
      if (relationshipId != null) {
        query += ' AND Id != :relationshipId ';
      }
      query += ' WITH SECURITY_ENFORCED';
      List<Syntilio__ContactContactRelationship__c> contactRelationships = Database.query(
        query
      );
      if (contactRelationships.size() > 0) {
        return true;
      }
      return false;
    } catch (Exception e) {
      Syntilio.HandleException.LogException(e);
      return false;
    }
  }
  @NamespaceAccessible
  public static Boolean hasConflictingOrder(
    Syntilio__ContactContactRelationship__c relationship
  ) {
    try {
      Id relationshipId = relationship.Id;
      Id relatedContactId = relationship.Syntilio__ContactId__c;
      Decimal order = relationship.Syntilio__Order__c;
      String query = 'SELECT Id, Syntilio__RelatedContactId__c, Syntilio__ContactId__c, Syntilio__Type__c FROM Syntilio__ContactContactRelationship__c WHERE ';
      query += 'Syntilio__ContactId__c = :relatedContactId AND Syntilio__Order__c = :order';
      if (relationshipId != null) {
        query += ' AND Id != :relationshipId';
      }
      query += ' WITH SECURITY_ENFORCED';
      List<Syntilio__ContactContactRelationship__c> contactRelationships = Database.query(
        query
      );
      if (contactRelationships.size() > 0) {
        return true;
      }
      return false;
    } catch (Exception e) {
      Syntilio.HandleException.LogException(e);
      return false;
    }
  }

  @AuraEnabled
  public static List<Syntilio__ContactContactRelationship__c> getCaseEmergencyContacts(
    Id caseId
  ) {
    try {
      List<Case> casesFound = [
        SELECT Id, ContactId
        FROM Case
        WHERE Id = :caseId
        WITH SECURITY_ENFORCED
      ];
      if (casesFound.size() == 0) {
        return new List<Syntilio__ContactContactRelationship__c>();
      }
      Id contactId = casesFound[0].ContactId;
      List<Syntilio__ContactContactRelationship__c> emergencyContacts = [
        SELECT
          Id,
          Name,
          Syntilio__ContactId__r.Name,
          Syntilio__RelatedContactId__r.Name,
          Syntilio__RelatedContactId__r.Phone,
          Syntilio__Relationship__c,
          Syntilio__Type__c,
          Syntilio__Order__c
        FROM Syntilio__ContactContactRelationship__c
        WHERE
          Syntilio__ContactId__c = :contactId
          AND Syntilio__Type__c = :Syntilio.ContactContactRelationshipHandler.ContactRelationshipType.Emergency.name()
          WITH SECURITY_ENFORCED
          ORDER BY Syntilio__Order__c ASC
      ];
      return emergencyContacts;
    } catch (Exception e) {
      Syntilio.HandleException.LogException(e);
      return new List<Syntilio__ContactContactRelationship__c>();
    }
  }
}
