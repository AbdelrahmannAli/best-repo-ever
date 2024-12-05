/*************************************************************************   
@description Class is responsible for composing the intended target destinations with the agreed format with Syntilio API */
@namespaceAccessible
public with sharing class DataHubDestinations {

    @NamespaceAccessible
    public static String composeDestinations(List<Syntilio.DataHubModel.Destination> dataHubModelDestinationsList) {
        List<String> destinationList = new List<String>();
        String destinations;
        try{
            for(Syntilio.DataHubModel.Destination dataHubModelDestinationRecord : dataHubModelDestinationsList){
                if(String.isBlank(dataHubModelDestinationRecord.technology) && String.isBlank(dataHubModelDestinationRecord.destinationName))
                    continue;
                String accountNameAndTechnology  = !String.isBlank(dataHubModelDestinationRecord.destinationName) && !String.isBlank(dataHubModelDestinationRecord.technology) ? dataHubModelDestinationRecord.destinationName.deleteWhitespace() + '_' + dataHubModelDestinationRecord.technology.deleteWhitespace() : !String.isBlank(dataHubModelDestinationRecord.technology) ? dataHubModelDestinationRecord.technology.deleteWhitespace() : dataHubModelDestinationRecord.destinationName.deleteWhitespace();
                destinationList.Add(accountNameAndTechnology);
            }
            destinations = String.join(destinationList, ',');
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
        return destinations;
    }
}