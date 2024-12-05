/*************************************************************************   
@description A http class with Singleton pattern that allows for the existence of only one instance of a http client object specifically for Syntilio, but everyone has global access to that object.*/
@namespaceAccessible
public with sharing class SyntilioHttpClient extends HttpClient {

    //private static instance of the class
    private static SyntilioHttpClient instance = null;
    
    /*************************************************************************   
    @description A method that initiates a new instance of SyntilioHttpClient if not already created*/
    @NamespaceAccessible
    public static SyntilioHttpClient getInstance(){
        if(instance == null){
            instance = new SyntilioHttpClient();
        }
        return instance;
    }
    //private constructor to avoid creating an instance
    private SyntilioHttpClient() {
        super(null,'syntilioapi');
    }

}