public class CaseOwnerController {
    public Id caseId { get; set; }
    public Case caseRecord { get; set; }
    public Id currentUserId { get; set; }
    public Boolean isCurrentOwner { get; set; } 

    public CaseOwnerController(ApexPages.StandardController controller) {
        
        caseId = (Id)controller.getId(); 
        if (caseId != null) {
            caseRecord = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId LIMIT 1];
            currentUserId = UserInfo.getUserId();
            isCurrentOwner = (caseRecord.OwnerId == currentUserId);
        }
    }

    
    @RemoteAction
    public static Boolean changeOwner(Id caseId) {
        Id currentUserId = UserInfo.getUserId();
        List <Case> caseRecord = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId LIMIT 1];
        if (caseRecord[0].OwnerId != currentUserId) {
            caseRecord[0].OwnerId = currentUserId;
            List<Database.SaveResult> updatedCases = Syntilio.UpsertToDatabase.updateAction(caseRecord, false);
            return true; 
        }
        return false; 
    }
}