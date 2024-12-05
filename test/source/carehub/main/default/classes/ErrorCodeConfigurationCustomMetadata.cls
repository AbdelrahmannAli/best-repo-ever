@NamespaceAccessible
public with sharing class ErrorCodeConfigurationCustomMetadata implements IErrorCodeConfigurationCustomMetadata {
    @NamespaceAccessible
    public Syntilio__ErrorCodeConfiguration__mdt getErrorCodeConfigurationCustomMetadata(String taskIssueReasonMappedToFlowErrorCodes){
        Syntilio__ErrorCodeConfiguration__mdt mapErrorCodeObjects = Syntilio__ErrorCodeConfiguration__mdt.getAll().get(taskIssueReasonMappedToFlowErrorCodes);                    
        return mapErrorCodeObjects;
    }

}