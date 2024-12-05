/*************************************************************************   
@description A reusable class to upsert in the database and return the database dml action response details.*/
@namespaceAccessible
public with sharing class UpsertToDatabase {
        
    /*************************************************************************   
    @description A method that performs insert DML action and takes List of SObject and Boolean allOrNone
    If allOrNone is set to false and a record fails, the remainder of the DML operation can still succeed.
    You must iterate through the returned results to identify which records succeeded or failed.
    If allOrNone is set to true and the method isn’t successful, an exception is thrown.*/
    @NamespaceAccessible
    public static List<Database.SaveResult> insertAction (List<sObject> sObjectRecordsList, Boolean allOrNone){
        List<Database.SaveResult> databaseSaveResultList = new List<Database.SaveResult> ();
            String sObjectType;
            if(sObjectRecordsList != null && !sObjectRecordsList.isEmpty()){
        		sObjectType = String.valueOf(sObjectRecordsList[0].getSObjectType());
                if(Syntilio.DataHubUtilities.isObjectCreateable(sObjectType, null))
                    databaseSaveResultList = Database.insert(sObjectRecordsList, allOrNone);
            }
        return databaseSaveResultList;
    }
    
    /*************************************************************************   
    @description A method that performs update DML action and takes List of SObject and Boolean allOrNone*/
    @NamespaceAccessible
    public static List<Database.SaveResult> updateAction (List<sObject> sObjectRecordsList, Boolean allOrNone){
        List<Database.SaveResult> databaseSaveResultList = new List<Database.SaveResult> ();
            String sObjectType;
            if(sObjectRecordsList != null && !sObjectRecordsList.isEmpty()){
        		sObjectType = String.valueOf(sObjectRecordsList[0].getSObjectType());
                if(Syntilio.DataHubUtilities.isObjectUpdateable(sObjectType, null))
            		databaseSaveResultList = Database.update(sObjectRecordsList, allOrNone);
            }
        return databaseSaveResultList;
    }
    
    /*************************************************************************   
    @description A method that performs upsert DML action and takes List of SObject SObjectField fieldSpecificationName, and Boolean allOrNone*/
    @NamespaceAccessible
    public static List<Database.UpsertResult> upsertAction (List<sObject> sObjectRecordsList, Schema.SObjectField fieldSpecificationName, Boolean allOrNone){
        List<Database.UpsertResult> databaseUpsertResultList = new List <Database.UpsertResult> () ;
            String sObjectType;
            if(sObjectRecordsList != null && !sObjectRecordsList.isEmpty()){
        		sObjectType = String.valueOf(sObjectRecordsList[0].getSObjectType());
                if(Syntilio.DataHubUtilities.isObjectCreateable(sObjectType, null) || Syntilio.DataHubUtilities.isObjectUpdateable(sObjectType, null))
                    databaseUpsertResultList = Database.upsert(sObjectRecordsList, fieldSpecificationName, allOrNone);
            }
        return databaseUpsertResultList;
    }

    /*************************************************************************   
    @description A method that performs upsert DML action and takes List of SObject SObjectField and Boolean allOrNone*/
    @NamespaceAccessible
    public static List<Database.UpsertResult> upsertAction (List<sObject> sObjectRecordsList, Boolean allOrNone){
        List<Database.UpsertResult> databaseUpsertResultList = new List <Database.UpsertResult> ();
            String sObjectType;
            if(sObjectRecordsList != null && !sObjectRecordsList.isEmpty()){
        		sObjectType = String.valueOf(sObjectRecordsList[0].getSObjectType());
                if(Syntilio.DataHubUtilities.isObjectCreateable(sObjectType, null) || Syntilio.DataHubUtilities.isObjectUpdateable(sObjectType, null))
                    databaseUpsertResultList = Database.upsert(sObjectRecordsList, allOrNone);
            }
        return databaseUpsertResultList;
    }

    // /*************************************************************************   
    // @description A method that performs delete DML action and takes List of SObject SObjectField fieldSpecificationName, and Boolean allOrNone*/
    @NamespaceAccessible
    public static List<Database.DeleteResult> deleteAction (List<sObject> sObjectRecordsList, Boolean allOrNone){
        List<Database.DeleteResult> databaseSaveResultList = new List <Database.DeleteResult> (); 
            String sObjectType;
            if(sObjectRecordsList != null && !sObjectRecordsList.isEmpty()){
        		sObjectType = String.valueOf(sObjectRecordsList[0].getSObjectType());
                if(Syntilio.DataHubUtilities.isObjectDeletable(sObjectType, null))
            		databaseSaveResultList = Database.delete(sObjectRecordsList, allOrNone);
            }
        return databaseSaveResultList;
    }

    /*************************************************************************   
    @description A method that return the DML status and failure details */
    @NamespaceAccessible
    public static Map<Boolean, List<Object>> getDmlActionStatus(List<Database.SaveResult> databaseSaveResultList, List<Database.UpsertResult> databaseUpsertResultList){
        Map<Boolean, List<Object>> databaseResultMap = new Map<Boolean, List<Object>>();
        List<Object> databaseFailureActionErrorDetails = new List<Object>();

        if(databaseSaveResultList != null){
            for (Database.SaveResult databaseResultRecord : databaseSaveResultList) {
                if (!databaseResultRecord.isSuccess()){
                    databaseFailureActionErrorDetails.add(databaseResultRecord.getErrors());
                }
            }
        }else{
            for (Database.UpsertResult databaseUpsertRecord : databaseUpsertResultList) {
                if (!databaseUpsertRecord.isSuccess()){
                    databaseFailureActionErrorDetails.add(databaseUpsertRecord.getErrors());
                }
            }
        }

        
        if(databaseFailureActionErrorDetails != null && !databaseFailureActionErrorDetails.isEmpty())
            databaseResultMap.put(false, databaseFailureActionErrorDetails);
        else
            databaseResultMap.put(true, null);
        return databaseResultMap;
    }
    
}