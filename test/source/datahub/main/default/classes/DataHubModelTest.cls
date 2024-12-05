@isTest
public with sharing class DataHubModelTest {
    @isTest
    static void dataHubModel_Test() {
        Syntilio.DataHubModel dataHubModel;
        try{
            Test.startTest();
            
            List<Object> objectsBodyList = new List<Object>();

            Map<String, Object> fileDetails = new Map<String, String>{'fileName'=> 'runwithme.pdf', 'content'=> 'JVBERi1jb250ZW50JSVFT0Y='};
            objectsBodyList.Add(fileDetails);
            
            List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
            Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
			destinationRecord.technology = 'Ons';
            destinationRecord.destinationName = 'CareOrganisation1';            
            destinationRecordList.Add(destinationRecord);
            
            dataHubModel = new Syntilio.DataHubModel();
            dataHubModel.destinations = destinationRecordList;
            dataHubModel.objectsBody = objectsBodyList;
            
            Test.stopTest(); 
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        System.assertNotEquals(null, dataHubModel);
    }
    
}