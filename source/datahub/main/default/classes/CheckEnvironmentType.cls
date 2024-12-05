/*************************************************************************   
@description Class is responsible for checking which Environment Type is used in the Salesforce Organisation Configurations to dynamically access the right external callout api.*/
@namespaceAccessible
public with sharing class CheckEnvironmentType {
   
        @NamespaceAccessible
        public static String checkCustomMetadata(String salesforceNamedCredentialsApiName){

        String calloutAPIEndpoint = '';

        Syntilio__DataHubAppConfiguration__mdt  dataHubAppConfiguration = Syntilio__DataHubAppConfiguration__mdt.getInstance('DataHubAppConfiguration');
        
        if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'staging')
        	calloutAPIEndpoint = salesforceNamedCredentialsApiName != null? 'callout:Syntilio__' + salesforceNamedCredentialsApiName + 'staging' : '';
        else if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'production')
        	calloutAPIEndpoint = salesforceNamedCredentialsApiName != null? 'callout:Syntilio__' + salesforceNamedCredentialsApiName : '';
        else 
        	calloutAPIEndpoint = salesforceNamedCredentialsApiName != null? 'callout:Syntilio__' + salesforceNamedCredentialsApiName + 'test' : '';   
    
        return calloutAPIEndpoint;
    }
}