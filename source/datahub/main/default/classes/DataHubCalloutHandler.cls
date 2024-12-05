/*************************************************************************   
@description In this class, it is more like a middleware to create a http callout to the dynamic api based on the trigger type. This class is made inorder to be able to handle the http elsewhere in the Syntilio.DataHubCallout class*/
@NamespaceAccessible
public with sharing class DataHubCalloutHandler { //initiate async & handle response
    
    @future(callout=true) @NamespaceAccessible
    public static void initiatePostCallout(String objectTypeName, String objectsBody, String dataHubModeldestinations) {
        try{
            String objectTypeLower = objectTypeName.tolowercase();
            Map<String, Object> postCalloutDetails = new Map<String, String>{
                'objectTypeName'=> objectTypeName,
                    'objectsBodySerialized'=> objectsBody,
                    'destinationsModelSerialized' => dataHubModeldestinations
                    };
                        
                        String extensionClass = 'Syntilio.DataHubCallout';
            Callable extension = (Callable) Type.forName(extensionClass).newInstance();
            HttpResponse response = (HttpResponse) extension.call('onPost', postCalloutDetails);
            if (response == null){    
                return;
            }
            Map<String, Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(response.getBody());
            
            ResponseHandler.handlePostResponse(objectTypeName, objectsBody, dataHubModeldestinations, responseMap);
            
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
    }
    
    @future(callout=true) @NamespaceAccessible
    public static void initiatePutCallout(String objectTypeName, String objectsBody, String dataHubModeldestinations) {
        try{
            HttpResponse response = Syntilio.DataHubCallout.onPut(objectTypeName, objectsBody, dataHubModeldestinations);
        }catch(Exception e){
            Syntilio.HandleException.logException(e);
        }
    }
    
    @future(callout=true) @NamespaceAccessible
    public static void initiateDeleteCallout(String objectTypeName, String objectsBody, String dataHubModeldestinations) {
        HttpResponse response = Syntilio.DataHubCallout.onDelete(objectTypeName, objectsBody, dataHubModeldestinations);
    }
}