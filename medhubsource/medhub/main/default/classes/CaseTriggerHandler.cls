public with sharing class CaseTriggerHandler {
    
    //public static void isBeforeInsert(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {}
    
    //public static void isBeforeUpdate(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {}
    
    //public static void isBeforeDelete(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {}
    
    //public static void isAfterInsert(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {}
    
    public static void isAfterUpdate(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {
        CaseTriggerHelper.deleteCareObservationRecordsWhenCaseIsClosed(newList);
    }
    //public static void isAfterDelete(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {}
    
    //public static void isAfterUndelete(List<Case> oldList, List<Case> newList, Map<Id, Case> oldMap, Map<Id, Case> newMap) {}
}