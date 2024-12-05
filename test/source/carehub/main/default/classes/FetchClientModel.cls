@JsonAccess(serializable='always' deserializable='always') @NamespaceAccessible
public with sharing class FetchClientModel {
    @NamespaceAccessible public Contact contact {get; set;}
    @NamespaceAccessible public List<Syntilio__ExternalId__c> externalIds {get; set;}
    @NamespaceAccessible public List<Schema.Location> locations {get; set;}
}