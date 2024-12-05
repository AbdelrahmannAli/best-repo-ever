/*************************************************************************
@description A class that handles exception logging*/
global with sharing class HandleException extends Exception {
    /*************************************************************************
@description A method that logs an exception with full details.*/
    @namespaceaccessible
    public enum ExceptionSource { Apex, LWC, Aura, Flow }
    
    global  static void logException(Exception e) {
        logException(e, '');
    }

    /*************************************************************************   
@description A method that logs an exception with full details with related record Id
-> relatedToId : Case/object for which this error in logged.*/
    global  static void logException(Exception e, String relatedToId) {
        try {
            String stackTrace = e.getStackTraceString().substringBefore('\n');
            String nameSpace = stackTrace.substringAfter('Class.').substringBefore('.');
            String className = stackTrace.substringAfter(nameSpace + '.')
                .substringBefore('.');
            String methodName = stackTrace.substringBefore(':')
                .substringAfter(nameSpace + '.' + className)
                .substringAfter('.');
            
            //Governer Limit of executingQuery
            String QueryLimit =
                '1. SOQL Queries used / SOQL Queries allowed: ' +
                Limits.getQueries() +
                '/' +
                Limits.getLimitQueries();
            String DMLimit =
                '2. Number of records queried so far /  Number allowed: ' +
                Limits.getDmlRows() +
                '/' +
                Limits.getLimitDmlRows();
            String DMLStat =
                '3. Number of DML statements used so far / Number allowed: ' +
                Limits.getDmlStatements() +
                '/' +
                Limits.getLimitDmlStatements();
            String CPUT =
                '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' +
                Limits.getCpuTime() +
                '/' +
                Limits.getLimitCpuTime();
            
            //Log information in object
            Syntilio__Exception__c exceptionRecord = new Syntilio__Exception__c();
            exceptionRecord.Name = 'Exception ' + String.valueOf(system.now());
            exceptionRecord.Syntilio__ExceptionSource__c = ExceptionSource.Apex.name();
            exceptionRecord.Syntilio__RelatedRecordId__c = relatedToId;
            exceptionRecord.Syntilio__GovtLimitInExecutingCode__c = String.format(
                '{0}\n{1}\n{2}\n{3}',
                new List<string>{ QueryLimit, DMLimit, DMLStat, CPUT }
            );
            exceptionRecord.Syntilio__ExceptionMessage__c = e.getMessage();
            exceptionRecord.Syntilio__ExceptionType__c = e.getTypeName();
            exceptionRecord.Syntilio__LineNumber__c = e.getLineNumber();
            exceptionRecord.Syntilio__StackTrace__c = e.getStackTraceString();
            exceptionRecord.Syntilio__MethodName__c = methodName;
            exceptionRecord.Syntilio__Namespace__c = nameSpace;
            exceptionRecord.Syntilio__ClassName__c = className;
            
            List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>();
            exceptionList.add(exceptionRecord);
            Syntilio.UpsertToDatabase.insertAction(exceptionList, false);
        } finally {
        }
    }
    
    /*************************************************************************
@description A method that logs an exception as String format*/
    @Deprecated
    global static void logExceptionAsString(String typeName, String message, String cause, Integer lineNumber, String stackTrace) {
        List<Syntilio__Exception__c> logExceptionRecordList = new List<Syntilio__Exception__c>();
        Syntilio__Exception__c logExceptionRecord = new Syntilio__Exception__c(
            Name = 'Exception ' + String.valueOf(system.now()),
            Syntilio__ExceptionDetails__c = 'Exception type caught: ' +
            typeName +
            ',\n' +
            'Message: ' +
            message +
            ',\n' +
            'Cause: ' +
            cause +
            ',\n' +
            'Line number: ' +
            string.valueOf(lineNumber) +
            ',\n' +
            'Stack trace: ' +
            stackTrace,
            Syntilio__ExceptionSource__c = ExceptionSource.Apex.name()
        );
        logExceptionRecordList.add(logExceptionRecord);
        Syntilio.UpsertToDatabase.insertAction(logExceptionRecordList, false);
    }
    
    /*************************************************************************
@description A method that logs an exception as String format*/
    @AuraEnabled
    global  static void logExceptionAsString(String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, string source) {
        List<Syntilio__Exception__c> logExceptionRecordList = new List<Syntilio__Exception__c>();
        Syntilio__Exception__c exceptionRecord = new Syntilio__Exception__c();
        exceptionRecord.Name = 'Exception ' + String.valueOf(system.now());
        exceptionRecord.Syntilio__ExceptionType__c = exceptionType;
        exceptionRecord.Syntilio__ExceptionMessage__c = exceptionMessage;
        exceptionRecord.Syntilio__StackTrace__c = stackTrace;
        exceptionRecord.Syntilio__LineNumber__c = lineNumber;
        exceptionRecord.Syntilio__MethodName__c = methodName;
        exceptionRecord.Syntilio__ClassName__c = className;
        exceptionRecord.Syntilio__Namespace__c = nameSpace;
        exceptionRecord.Syntilio__ExceptionSource__c = source;
        
        logExceptionRecordList.add(exceptionRecord);
        Syntilio.UpsertToDatabase.insertAction(logExceptionRecordList, false);
    }
    
    /*************************************************************************
@description A method that logs an exception as String format in Lightning Web Components*/
    @AuraEnabled
    global  static String logExceptionLWC(String exceptionType, String exceptionMessage, String stackTrace, Integer lineNumber, String methodName, String className, String nameSpace, string source) {
        List<Syntilio__Exception__c> logExceptionRecordList = new List<Syntilio__Exception__c>();
        Syntilio__Exception__c exceptionRecord = new Syntilio__Exception__c();
        exceptionRecord.Name = 'Exception ' + String.valueOf(system.now());
        exceptionRecord.Syntilio__ExceptionType__c = exceptionType;
        exceptionRecord.Syntilio__ExceptionMessage__c = exceptionMessage;
        exceptionRecord.Syntilio__StackTrace__c = stackTrace;
        exceptionRecord.Syntilio__LineNumber__c = lineNumber;
        exceptionRecord.Syntilio__MethodName__c = methodName;
        exceptionRecord.Syntilio__ClassName__c = className;
        exceptionRecord.Syntilio__Namespace__c = nameSpace;
        exceptionRecord.Syntilio__ExceptionSource__c = source;
        
        logExceptionRecordList.add(exceptionRecord);
        List<Database.SaveResult> dbResult = Syntilio.UpsertToDatabase.insertAction(logExceptionRecordList, false);
        return JSON.serialize(dbResult);
    }
}