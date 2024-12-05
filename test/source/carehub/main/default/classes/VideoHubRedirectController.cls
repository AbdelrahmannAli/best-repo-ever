@NamespaceAccessible
public with sharing class VideoHubRedirectController {
    private ApexPages.StandardController standardController;
    public String redirectURL { get; private set; }
    @NamespaceAccessible
    public VideoHubRedirectController(ApexPages.StandardController stdController) {
        standardController = stdController;
        
        // Get the Contact ID from the standard controller
        String caseId = (String) standardController.getId();
        String loggedInUserName = UserInfo.getName();
        
        List<Case> requested_case = [SELECT ContactId, Contact.LastName, Contact.Syntilio__VideoToken__c , Contact.Syntilio__VoIPToken__c FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED LIMIT 1];
        
        Syntilio__DataHubAppConfiguration__mdt  dataHubAppConfiguration = Syntilio__DataHubAppConfiguration__mdt.getInstance('DataHubAppConfiguration');
        Syntilio__CareHubAppConfiguration__mdt  careHubAppConfiguration = Syntilio__CareHubAppConfiguration__mdt.getInstance('CareHubAppConfiguration');
        boolean isVideoCallAllowed;

        string orgName = [SELECT Name FROM Organization WITH SECURITY_ENFORCED LIMIT 1].Name;

        if(Test.isRunningTest())
           isVideoCallAllowed = true;
        else
           isVideoCallAllowed = Syntilio.SubscriptionHandler.isVideoCallingAllowed(requested_case[0].ContactId);
        
        if(careHubAppConfiguration.Syntilio__VideoHubAccessLevel__c == 'Standalone' || (isVideoCallAllowed == true && careHubAppConfiguration.Syntilio__VideoHubAccessLevel__c == 'Subscription')) {
            if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'staging')
                redirectURL = 'https://videohub-staging.syntilio.com';        
            else if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'production')
                redirectURL = 'https://videohub.syntilio.com';
            else 
                redirectURL = 'https://videohub-test.syntilio.com';
            
            if(requested_case.size() == 0){
                return;
            }

            redirectURL = redirectURL + '?caseId='+ caseId + '&loggedInUser=' 
                + loggedInUserName +  '&token=' + requested_case[0].Contact.Syntilio__VideoToken__c 
                + '&voipToken=' + requested_case[0].Contact.Syntilio__VoIPToken__c + '&contactName=' 
                + requested_case[0].Contact.LastName + '&orgName=' 
                + orgName + '&contactId=' + requested_case[0].ContactId;            
        }
    }
}
