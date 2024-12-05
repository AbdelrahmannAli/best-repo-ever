@isTest
public with sharing class DataHubCalloutTest {
    
    private static DataHubModel.Destination createDestinationRecords (String technology, String destinationName) {
        DataHubModel.Destination destinationRecord = new DataHubModel.Destination();
        destinationRecord.technology = technology;
        destinationRecord.destinationName = destinationName;
        return destinationRecord;
    }

    @isTest
    public static void onGetObjectTriggerCallout_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String queryParameters = '?Id=1';

            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('GET', objectTypeName, queryParameters));

            response = Syntilio.DataHubCallout.onGet(objectTypeName, queryParameters, dataHubModeldDestinationsSerialized);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void onGetRaiseExceptionTest() {
        Syntilio.DataHubCallout.raiseException = true;
        Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
        List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        destinationRecordList.Add(destinationRecord);
                                            
        String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);

        Test.startTest();
        HttpResponse response = Syntilio.DataHubCallout.onGet('report', '', dataHubModeldDestinationsSerialized);
        Test.stopTest();
        System.assertEquals(null, response);

    }

    @isTest
    public static void onPostRaiseExceptionTest() {
        Syntilio.DataHubCallout.raiseException = true;
        Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
        List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        destinationRecordList.Add(destinationRecord);
        
        String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';
        String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);

        String objectTypeName = 'Contact';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('POST', objectTypeName, objectBodySerialized));

        HttpResponse response = Syntilio.DataHubCallout.onPost(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
        Test.stopTest();
        System.assertEquals(null, response);
    }
    
    @isTest
    public static void onGetObjectTriggerCallout_Not_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
                                                
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            String queryParameters = '?Id=1';

            Test.setMock(HttpCalloutMock.class, new MockNotSuccessfulDataHubCallout('GET', objectTypeName, queryParameters, 400));

            response = Syntilio.DataHubCallout.onGet(objectTypeName, queryParameters, dataHubModeldDestinationsSerialized);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(400, response.getStatusCode());
    }
    
    @isTest
    public static void onGetObjectTriggerCallout_Exception_Test() {
        try{
            Test.startTest();
            Syntilio.DataHubCallout.onGet('', '', '');
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }
    
    @isTest
    public static void onGetObjectTriggerCallout_Callable_Interface_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String queryParameters = '?Id=1';
            
            Map<String, Object> calloutArguments = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'queryParameters'=> queryParameters,
                    'destinationsModelSerialized' => dataHubModeldDestinationsSerialized
                    };
                
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('GET', objectTypeName, queryParameters));

            String callableExtensionClassName = 'Syntilio.DataHubCallout';
            Callable callableExtensionClass = (Callable) Type.forName(callableExtensionClassName).newInstance();
            response = (HttpResponse) callableExtensionClass.call('onGet', calloutArguments);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    
    @isTest
    public static void onPostObjectTriggerCallout_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);

            String objectTypeName = 'Contact';
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('POST', objectTypeName, objectBodySerialized));

            response = Syntilio.DataHubCallout.onPost(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    
    @isTest
    public static void onPostFileTransferCallout_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', '');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            Map<String, String> fileDetails = new Map<String, String>{
                'fileName'=> 'runwithme.pdf',
                 'content'=> 'JVBERi1jb250ZW50JSVFT0Y='
            };
            List<Object> objectsBodyList = new List<Object>();
            objectsBodyList.Add(fileDetails);   
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String dataHubModeldObjectsBodyListSerialized = JSON.serializePretty(objectsBodyList);

            String objectTypeName = 'file';
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('POST', objectTypeName, dataHubModeldObjectsBodyListSerialized));

            response = Syntilio.DataHubCallout.onPost(objectTypeName, dataHubModeldObjectsBodyListSerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onPostObjectTriggerCallout_Not_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland"}]';
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);

            String objectTypeName = 'Contact';
            String objectId = '';
            Test.setMock(HttpCalloutMock.class, new MockNotSuccessfulDataHubCallout('POST', objectTypeName, objectBodySerialized, 400));

            response = Syntilio.DataHubCallout.onPost(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(400, response.getStatusCode());
    }
    
    @isTest
    public static void onPostObjectTriggerCallout_Exception_Test() {
        try{
            Test.startTest();
            
            Syntilio.DataHubCallout.onPost('', '', '');
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }
    
    @isTest
    public static void onPostObjectTriggerCallout_Callable_Interface_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland"}]';
            
            Map<String, Object> calloutArguments  = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'objectsBodySerialized'=> objectBodySerialized,
                    'destinationsModelSerialized' => dataHubModeldDestinationsSerialized
                    };
                
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('POST', objectTypeName, objectBodySerialized));

            String callableExtensionClassName = 'Syntilio.DataHubCallout';
            Callable callableExtensionClass = (Callable) Type.forName(callableExtensionClassName).newInstance();
            response = (HttpResponse) callableExtensionClass.call('onPost', calloutArguments);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onPutObjectTriggerCallout_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            
            String objectTypeName = 'Contact';
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('PUT', objectTypeName, objectBodySerialized));

            response = Syntilio.DataHubCallout.onPut(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onPutObjectTriggerCallout_Not_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            
            String objectTypeName = 'Contact';
            Test.setMock(HttpCalloutMock.class, new MockNotSuccessfulDataHubCallout('PUT', objectTypeName, objectBodySerialized, 400));

            response = Syntilio.DataHubCallout.onPut(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(400, response.getStatusCode());
    }
    
    @isTest
    public static void onPutObjectTriggerCallout_Exception_Test() {
        try{
            Test.startTest();
            Syntilio.DataHubCallout.onPut('', '', '');
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }
    
    @isTest
    public static void onPutObjectTriggerCallout_Callable_Interface_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';
            
            Map<String, Object> calloutArguments  = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'objectsBodySerialized'=> objectBodySerialized,
                    'destinationsModelSerialized' => dataHubModeldDestinationsSerialized
                    };
                
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('PUT', objectTypeName, objectBodySerialized));

            String callableExtensionClassName = 'Syntilio.DataHubCallout';
            Callable callableExtensionClass = (Callable) Type.forName(callableExtensionClassName).newInstance();
            response = (HttpResponse) callableExtensionClass.call('onPut', calloutArguments);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onPatchObjectTriggerCallout_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            
            String objectTypeName = 'Contact';
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('PATCH', objectTypeName, objectBodySerialized));

            response = Syntilio.DataHubCallout.onPatch(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onPatchObjectTriggerCallout_Not_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            
            String objectTypeName = 'Contact';
            Test.setMock(HttpCalloutMock.class, new MockNotSuccessfulDataHubCallout('PATCH', objectTypeName, objectBodySerialized, 400));

            response = Syntilio.DataHubCallout.onPatch(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(400, response.getStatusCode());
    }
    
    @isTest
    public static void onPatchObjectTriggerCallout_Exception_Test() {
        try{
            Test.startTest();
            
            Syntilio.DataHubCallout.onPatch('', '', '');
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }
    
    @isTest
    public static void onPatchObjectTriggerCallout_Callable_Interface_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';
            
            Map<String, Object> calloutArguments  = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'objectsBodySerialized'=> objectBodySerialized,
                    'destinationsModelSerialized' => dataHubModeldDestinationsSerialized
                    };
                
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('PATCH', objectTypeName, objectBodySerialized));

            String callableExtensionClassName = 'Syntilio.DataHubCallout';
            Callable callableExtensionClass = (Callable) Type.forName(callableExtensionClassName).newInstance();
            response = (HttpResponse) callableExtensionClass.call('onPatch', calloutArguments);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void onDeleteObjectTriggerCallout_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm" }]';

            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('DELETE', objectTypeName, objectBodySerialized));

            response = Syntilio.DataHubCallout.onDelete(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onDeleteObjectTriggerCallout_Not_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm" }]';

            Test.setMock(HttpCalloutMock.class, new MockNotSuccessfulDataHubCallout('DELETE', objectTypeName, objectBodySerialized, 400));

            response = Syntilio.DataHubCallout.onDelete(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(400, response.getStatusCode());
    }
    
    @isTest
    public static void onDeleteObjectTriggerCallout_Exception_Test() {
        try{
            Test.startTest();
            Syntilio.DataHubCallout.onDelete('', '', '');
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }    
    
    @isTest
    public static void onDeleteObjectTriggerCallout_Callable_Interface_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';
            
            Map<String, Object> calloutArguments  = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'objectsBodySerialized'=> objectBodySerialized,
                    'destinationsModelSerialized' => dataHubModeldDestinationsSerialized
                    };
                
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('DELETE', objectTypeName, objectBodySerialized));

            String callableExtensionClassName = 'Syntilio.DataHubCallout';
            Callable callableExtensionClass = (Callable) Type.forName(callableExtensionClassName).newInstance();
            response = (HttpResponse) callableExtensionClass.call('onDelete', calloutArguments);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    public static void onHeadObjectTriggerCallout_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm" }]';

            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('HEAD', objectTypeName, objectBodySerialized));

            response = Syntilio.DataHubCallout.onHead(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onHeadObjectTriggerCallout_Not_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm" }]';

            Test.setMock(HttpCalloutMock.class, new MockNotSuccessfulDataHubCallout('HEAD', objectTypeName, objectBodySerialized, 400));

            response = Syntilio.DataHubCallout.onHead(objectTypeName, objectBodySerialized, dataHubModeldDestinationsSerialized);
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(400, response.getStatusCode());
    }
    
    @isTest
    public static void onHeadObjectTriggerCallout_Exception_Test() {
        try{
            Test.startTest();
            Syntilio.DataHubCallout.onHead('', '', '');
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        List<Syntilio__Exception__c> exceptionList = new List<Syntilio__Exception__c>([SELECT Id, Name, Syntilio__ExceptionMessage__c FROM Syntilio__Exception__c]);
        system.assertNotEquals(0, exceptionList.size());
    }    
    
    @isTest
    public static void onHeadObjectTriggerCallout_Callable_Interface_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland" }]';
            
            Map<String, Object> calloutArguments  = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'objectsBodySerialized'=> objectBodySerialized,
                    'destinationsModelSerialized' => dataHubModeldDestinationsSerialized
                    };
                
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('HEAD', objectTypeName, objectBodySerialized));

            String callableExtensionClassName = 'Syntilio.DataHubCallout';
            Callable callableExtensionClass = (Callable) Type.forName(callableExtensionClassName).newInstance();
            response = (HttpResponse) callableExtensionClass.call('onHead', calloutArguments);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(200, response.getStatusCode());
    }
    
    @isTest
    public static void onPostObjectTriggerCallout_Callable_Interface_Not_Successful_Test() {
        HttpResponse response;
        try{
            Test.startTest();
            
            Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            destinationRecordList.Add(destinationRecord);
            
            String dataHubModeldDestinationsSerialized = JSON.serializePretty(destinationRecordList);
            String objectTypeName = 'Contact';
            
            String objectBodySerialized = '[{"Id": "01140rbjrfvnhm", "Title": "Patient", "LastName": "Jansen", "Birthdate": "1960-07-15", "Phone": "+31-238728372", "HomePhone": "23232232", "Email": "jansen@nl.com", "MailingStreet": "Street 2", "MailingPostalCode": "2222", "MailingState": "Noord Holland", "MailingCity": "Amsterdam", "MailingCountry": "Nederland"}]';
            
            Map<String, Object> calloutArguments  = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'objectsBodySerialized'=> objectBodySerialized,
                    'destinationsModelSerialized' => dataHubModeldDestinationsSerialized
                    };
                
            Test.setMock(HttpCalloutMock.class, new Syntilio.MockSuccessfulDataHubCallout('POST', objectTypeName, objectBodySerialized));

            String callableExtensionClassName = 'Syntilio.DataHubCallout';
            Callable callableExtensionClass = (Callable) Type.forName(callableExtensionClassName).newInstance();
            response = (HttpResponse) callableExtensionClass.call('unknownMethod', calloutArguments);

            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertEquals(null, response);
    }
}
