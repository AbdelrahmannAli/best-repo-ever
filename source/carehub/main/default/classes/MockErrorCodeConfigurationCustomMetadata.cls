@NamespaceAccessible
@isTest
public with sharing class MockErrorCodeConfigurationCustomMetadata implements IErrorCodeConfigurationCustomMetadata{
    Syntilio__ErrorCodeConfiguration__mdt mockErrorCodeConfigurationCustomMetadata;
    public MockErrorCodeConfigurationCustomMetadata(Syntilio__ErrorCodeConfiguration__mdt mockErrorCodeConfigurationCustomMetadata ){
        this.mockErrorCodeConfigurationCustomMetadata = mockErrorCodeConfigurationCustomMetadata;   
    }
    public Syntilio__ErrorCodeConfiguration__mdt getErrorCodeConfigurationCustomMetadata(String taskIssueReasonMappedToFlowErrorCodes){
        return mockErrorCodeConfigurationCustomMetadata;
    }
}