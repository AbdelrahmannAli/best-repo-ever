@isTest
public with sharing class VideoHubRedirectControllerTest {
    
    private static String checkEnvironmentType(){
        
       	String redirectURL = '';

        Syntilio__DataHubAppConfiguration__mdt  dataHubAppConfiguration = Syntilio__DataHubAppConfiguration__mdt.getInstance('DataHubAppConfiguration');
        
        if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'staging')
            redirectURL = 'https://videohub-staging.syntilio.com';        
        else if (dataHubAppConfiguration.Syntilio__EnvironmentType__c.toLowerCase() == 'production')
            redirectURL = 'https://videohub.syntilio.com';
        else 
            redirectURL = 'https://videohub-test.syntilio.com';
        
        return redirectURL;
    }
    
    @isTest
    static void videoHubRedirectURLTest_WithCase(){
        
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert contact;
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
            	'ContactId' => contact.Id
        	}
        );
        insert newCase;

        String caseId = (String) newCase.Id;
        caseId = caseId.substring(0, caseId.length()-3);
        Contact contactRecord = [SELECT Id, LastName, Syntilio__VideoToken__c, Syntilio__VoIPToken__c FROM Contact LIMIT 1];
        String orgName = [SELECT Name FROM Organization].Name;
        System.runAs(new User(Id = UserInfo.getUserId(), LastName='MockedUser')) {
            ApexPages.StandardController standardController = new ApexPages.StandardController(newCase);
            Syntilio.VideoHubRedirectController controller = new Syntilio.VideoHubRedirectController(standardController);
            String actualReturnUrl = controller.redirectURL;
            String expectedReturnUrl = checkEnvironmentType();
			expectedReturnUrl = expectedReturnUrl;
            
            System.assert(actualReturnUrl.contains(expectedReturnUrl));
        }
    }
    
    @isTest
    static void videoHubRedirectURLTest_WithoutCase(){
        
        Contact contact = Syntilio.CareHubTestDataFactory.createContact(null);
        insert contact;
        Case newCase = Syntilio.CareHubTestDataFactory.createCase(
            new Map<String, Object>{
            	'ContactId' => contact.Id
        	}
        );
        
        System.runAs(new User(Id = UserInfo.getUserId(), LastName='MockedUser')) {
            ApexPages.StandardController standardController = new ApexPages.StandardController(newCase);
            Syntilio.VideoHubRedirectController controller = new Syntilio.VideoHubRedirectController(standardController);
            String actualReturnUrl = controller.redirectURL;
            String expectedReturnUrl = checkEnvironmentType();
            System.assertEquals(expectedReturnUrl, actualReturnUrl, 'Expected returnURL does not match the actual.');
        }
    }
}