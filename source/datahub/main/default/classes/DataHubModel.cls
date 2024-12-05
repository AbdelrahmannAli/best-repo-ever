/*************************************************************************   
    @description The DataHubModel is composed from the objects body that represents what data will be synchronised in the external callouts and the intended target destinations*/
@JsonAccess(serializable='always' deserializable='always')
global with sharing class DataHubModel {
    global List<Destination> destinations {get; set;}
    global List<Object> objectsBody {get; set;}
    
    /*************************************************************************   
    @description The Destination Model is composed from the Destination Name and which Technology is being used if available*/
    @JsonAccess(serializable='always' deserializable='always')
    global with sharing class Destination {
        global String technology {get; set;}
        global String destinationName {get; set;}
    }
}