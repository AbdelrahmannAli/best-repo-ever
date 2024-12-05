@isTest
public with sharing class DataHubDestinationsTest {
    
    
    private static DataHubModel.Destination createDestinationRecords (String technology, String destinationName) {
        DataHubModel.Destination destinationRecord = new DataHubModel.Destination();
        destinationRecord.technology = technology;
        destinationRecord.destinationName = destinationName;
        return destinationRecord;
    }

    @isTest
    static void createDataHubDestinations_Test() {
        
		Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('Ons', 'CareOrganisation1');
		List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        destinationRecordList.Add(destinationRecord);
        
        String destinations = DataHubDestinations.composeDestinations(destinationRecordList);
        System.assertEquals('CareOrganisation1_Ons', destinations);
    }
    
    @isTest
    static void createDataHubDestinations_Empty_Test() {
        
		Syntilio.DataHubModel.Destination destinationRecord = createDestinationRecords('', '');
		List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        destinationRecordList.Add(destinationRecord);
        
        String destinations = DataHubDestinations.composeDestinations(destinationRecordList);
        System.assertEquals('', destinations);
    }
}