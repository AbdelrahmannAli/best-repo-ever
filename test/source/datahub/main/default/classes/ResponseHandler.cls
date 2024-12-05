public with sharing class ResponseHandler {

    public static void handlePostResponse(String objectTypeName, String requestBodySerialized, String dataHubModeldestinations, Map<String, Object> responseMap){
        try{
            List<Object> requestBody = (List<Object>) JSON.deserializeUntyped(requestBodySerialized);
            List<Syntilio.DataHubModel.Destination> dataHubModeldestinationsDeserialized = (List<Syntilio.DataHubModel.Destination>) JSON.deserialize(dataHubModeldestinations, List<Syntilio.DataHubModel.Destination>.class);
            Map<String, Object> body = (Map<String, Object>) requestBody[0];
            
            List<Syntilio__ExternalId__c> externalIdsToInsert = new List<Syntilio__ExternalId__c>();

            for(Syntilio.DataHubModel.Destination destination : dataHubModeldestinationsDeserialized){
                String responseKey = String.isBlank(destination.destinationName)? destination.technology : destination.destinationName + '_' + destination.technology;
                Map<String, Object> responseBody = (Map<String, Object>) responseMap.get(responseKey);
                List<Object> returnedIds = (List<Object>) responseBody.get('ResultIds');
                Syntilio.ResponseMessage externalSystemIdResponse = Syntilio.DataHubUtilities.getExternalSystemId(destination.technology);
                if (externalSystemIdResponse.type == Syntilio.ResponseMessage.MessageType.ERROR) {
                    return;
                }
                String externalSystemId = (String) externalSystemIdResponse.data;

                Map<String, Object> destinationBody = (Map<String, Object>) body.get(responseKey);
                String externalIdName = (String) destinationBody.get('ExternalIdName');
                List<Syntilio__ExternalId__c> externalIds = new List<Syntilio__ExternalId__c>();
                
                for(Object oneIdObj : returnedIds){
                    Map<String, Object> oneId = (Map<String, Object>) oneIdObj; 
                    Syntilio__ExternalId__c externalId = new Syntilio__ExternalId__c();
                    externalId.Name = String.valueOf(oneId.get('Name'));
                    externalId.Syntilio__Id__c = String.valueOf(oneId.get('Id'));
                    externalId.Syntilio__ExternalSystemId__c = (Id) externalSystemId;
                    externalId.Syntilio__Account__c = (Id) body.get('AccountId');
                    externalId.Syntilio__ContactId__c = objectTypeName == 'Contact'? (Id) body.get('Id') : (Id) body.get('ContactId');
                    if(objectTypeName != 'Contact'){
                        externalId.Syntilio__RelatedSalesforceInternalId__c = (Id) body.get('Id');
                    }
                    externalIds.add(externalId);
                }
                externalIdsToInsert.addAll(externalIds);
			}
            List<Database.SaveResult> insertedExternalIds = Syntilio.UpsertToDatabase.insertAction(externalIdsToInsert, false);
            Syntilio.DataHubUtilities.createTasks(insertedExternalIds, 'Account', new List<Id>{(Id) body.get('AccountId')}, 'Error while inserting external ID', 'High');
        } catch(Exception e){
            Syntilio.HandleException.LogException(e);
        }
    }
}