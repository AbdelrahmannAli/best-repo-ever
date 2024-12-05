public with sharing class FeedbackController {
    
    public FeedbackController() {}

    @AuraEnabled
    public static String generatePublicURL(String contentDocumentId) {
        ContentVersion file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId WITH SECURITY_ENFORCED LIMIT 1000];

        ContentDistribution cd = new ContentDistribution(
            ContentVersionId = file.Id,
            Name = file.Title,
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true,
            PreferencesNotifyOnVisit = false,
            PreferencesPasswordRequired = false,
            PreferencesAllowOriginalDownload = true
        );
        insert cd;
        ContentDistribution updatedCd = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id WITH SECURITY_ENFORCED LIMIT 1000];
        return updatedCd.DistributionPublicUrl;
    }

    @future(callout=true)
    @AuraEnabled
    public static void postFeedback(String FeedbackType, String Problem, String URL, String Steps, 
                                    String Expected, String Actual, String Severity, List<String> FileUrls) {
        try{
        List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        Syntilio.DataHubModel.Destination destinationRecord = new Syntilio.DataHubModel.Destination();
        destinationRecord.destinationName = 'Notion';
        destinationRecordList.add(destinationRecord);

        // Create a map to store the feedback data with new fields
        Map<String, Object> feedbackData = new Map<String, Object>{
            'name' => UserInfo.getName(),
            'email' => UserInfo.getUserEmail(),
            'type' => FeedbackType,
            'problem' => Problem,
            'url' => URL,
            'steps' => Steps,
            'expected' => Expected,
            'actual' => Actual,
            'priority' => Severity,
            'mediaLinks' => FileUrls
        };

        String endpoint = 'feedback';
        String objectsBodySerialized = JSON.serialize(feedbackData);
        String serializedDestinationRecordList = JSON.serialize(destinationRecordList);
        HttpResponse response = Syntilio.DataHubCallout.onPost(endpoint, objectsBodySerialized, serializedDestinationRecordList);
        }
        catch (Exception e) {
            Syntilio.HandleException.LogException(e);
        }
    }
}