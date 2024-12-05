@isTest
public with sharing class HandleExceptionTest {

    @isTest
    public static void logException_Test() {
        try{
            Test.startTest();

            Contact contactRecord = new Contact();
            insert contactRecord;
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    } 
    
    @isTest
    public static void logExceptionAsString_Test() {
        try{
            Test.startTest();

            Syntilio.HandleException.logExceptionAsString('Exception type caught: System.NullPointerException', 'Attempt to de-reference a null object', 'null', 1, Syntilio.HandleException.ExceptionSource.Apex.name());
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    } 

    @isTest
    public static void logExceptionAsStringNew_Test() {
        try{
            Test.startTest();

            Syntilio.HandleException.logExceptionAsString(
                'Exception type caught: System.NullPointerException', 
                'Attempt to de-reference a null object', 
                'null', 
                1, 
                'testMethod',
                'testClassname',
                'Syntilio',
                Syntilio.HandleException.ExceptionSource.Apex.name());
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    } 

    @isTest
    public static void logExceptionLWC_Test() {
        try{
            Test.startTest();

            Syntilio.HandleException.logExceptionLWC(
                'Exception type caught: System.NullPointerException',
                'Attempt to de-reference a null object',
                'null',
                1,
                'testMethod',
                'testClass',
                'Syntilio',
                'LWC'
              );
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    } 
}