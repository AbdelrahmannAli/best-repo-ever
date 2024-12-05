@NamespaceAccessible
public with sharing class CaseProtocolHandler {
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getProtocols(Id caseId) {
        List<Map<String, Object>> protocolMapsList = new List<Map<String, Object>>();
        List<Case> casesFound = [
            SELECT Id, ContactId, Syntilio__Event__c
            FROM Case
            WHERE Id = :caseId
            WITH SECURITY_ENFORCED
        ];

        if(casesFound.size() == 0){
            return protocolMapsList;
        }
        
        Case requestedCase = casesFound[0];

        List<Syntilio__GroupMember__c> memberList = [
            SELECT Syntilio__GroupId__c 
            FROM Syntilio__GroupMember__c 
            WHERE (
                    Syntilio__ContactId__c = :requestedCase.ContactId 
                    AND Syntilio__GroupId__r.Syntilio__ObjectType__c = 'Contact'
                ) 
            OR (
                    Syntilio__EventConfigurationId__c = :requestedCase.Syntilio__Event__c 
                    AND Syntilio__GroupId__r.Syntilio__ObjectType__c = 'Event Configuration'
                )
            WITH SECURITY_ENFORCED
        ];

        List<Id> groupIds = new List<Id>();
        
        for(Syntilio__GroupMember__c groupMember : memberList) {
            groupIds.add(groupMember.Syntilio__GroupId__c);
        }
        

        List<Syntilio__Protocol__c> protocolsList = [
            SELECT Name, Syntilio__Image__c, Syntilio__Description__c, Syntilio__EstimatedTime__c, Syntilio__Flow__c
            FROM Syntilio__Protocol__c 
            WHERE Id IN (
                SELECT Syntilio__Protocol__c
                FROM Syntilio__ProtocolActivator__c
                WHERE Syntilio__Active__c = true
                AND (
                    (Syntilio__ContactId__c != null AND Syntilio__ContactId__c = :requestedCase.ContactId)
                    OR (Syntilio__Event__c != null AND Syntilio__Event__c  = :requestedCase.Syntilio__Event__c) 
                    OR (Syntilio__GroupId__c != null AND Syntilio__GroupId__c IN :groupIds) 
                    OR (Syntilio__Global__c = true)
                    
                )
            )
            WITH SECURITY_ENFORCED
        ];
        List<Id> protocolIds = Syntilio.DataHubUtilities.sObjectListToIdList(protocolsList);
        List<Syntilio__ProtocolResult__c> protocolResults = [
            SELECT Id, Syntilio__ProtocolId__c,
            	(SELECT Syntilio__Answer__c, Syntilio__ProtocolPageQuestionId__r.Syntilio__Required__c 
                 FROM Syntilio__ProtocolPageQuestionResults__r 
                 WHERE Syntilio__ProtocolPageQuestionId__r.Syntilio__QuestionId__r.Syntilio__QuestionType__c = 'action')
            FROM Syntilio__ProtocolResult__c 
            WHERE Syntilio__CaseId__c = :caseId
            AND Syntilio__ProtocolId__c IN :protocolIds
            WITH SECURITY_ENFORCED
        ];
        
        Map<String, Object> protocolResultsGroupedByProtocolId = 
            Syntilio.DataHubUtilities.listToMap('Syntilio__ProtocolId__c', null, protocolResults);
        
        for(Syntilio__Protocol__c protocol : protocolsList){
            Map<String, Object> protocolMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(protocol));
            Syntilio__ProtocolResult__c result = (Syntilio__ProtocolResult__c) protocolResultsGroupedByProtocolId.get(protocol.Id);
            if(result == null){
                protocolMap.put('status', 'required');
            	protocolMapsList.add(protocolMap);
                continue;
            }
            protocolMap.put('status', 'finished');

            if(result.Syntilio__ProtocolPageQuestionResults__r == null){
            	protocolMapsList.add(protocolMap);
                continue;
            }
            for(Syntilio__ProtocolPageQuestionResult__c questionResult : result.Syntilio__ProtocolPageQuestionResults__r){
                if(questionResult.Syntilio__ProtocolPageQuestionId__r.Syntilio__Required__c && questionResult.Syntilio__Answer__c == 'false'){
                    protocolMap.put('status', 'actions');
                    break;
                }
            }
            protocolMapsList.add(protocolMap);
        }
        
        return protocolMapsList;
    }
    @AuraEnabled(cacheable=false)
    public static Boolean checkFlowApiName(String flowApiName) {
    
    List<FlowDefinitionView> activeFlows = [
        SELECT Id
        FROM FlowDefinitionView
        WHERE ApiName = :flowApiName AND IsActive = true
        WITH SECURITY_ENFORCED
    ];
    
    
    if (activeFlows.size() > 0) {
        return true;
    }
    
    return false;
}

    @NamespaceAccessible
    public static List<Map<String, Object>> getProtocolPagesListByProtocol(String protocolId){
        List<Map<String, Object>> pagesList = new List<Map<String, Object>>();
        List<Syntilio__ProtocolPage__c> protocolPages = [
            SELECT Id, Name, Syntilio__Title__c, Syntilio__JSON__c
            FROM Syntilio__ProtocolPage__c
            WHERE Syntilio__ProtocolId__c = :protocolId
            WITH SECURITY_ENFORCED
            ORDER BY Syntilio__Order__c ASC
        ];
        for(Syntilio__ProtocolPage__c protocolPage : protocolPages){
            Map<String, Object> pageObject = protocolPage.Syntilio__JSON__c != null? 
                (Map<String, Object>) JSON.deserializeUntyped(protocolPage.Syntilio__JSON__c) 
                : new Map<String, Object>();
            pageObject.put('Id', protocolPage.Id);
            pageObject.put('name', protocolPage.Name);
            if(protocolPage.Syntilio__Title__c != null){
                pageObject.put('title', protocolPage.Syntilio__Title__c);
            }
            pagesList.add(pageObject);
        }
        return pagesList;
    }
    @NamespaceAccessible
    public static List<Map<String, Object>> getProtocolPageQuestionsListByPage(String pageId){
        List<Map<String, Object>> pageQuestionsList = new List<Map<String, Object>>();
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = [
            SELECT Id, Syntilio__QuestionId__r.Name, Syntilio__QuestionId__r.Syntilio__Title__c, 
            	Syntilio__QuestionId__r.Syntilio__QuestionType__c, Syntilio__QuestionId__r.Syntilio__Choices__c, Syntilio__JSON__c,
            	Syntilio__Required__c
            FROM Syntilio__ProtocolPageQuestion__c
            WHERE Syntilio__ProtocolPageId__c = :pageId
            WITH SECURITY_ENFORCED
            ORDER BY Syntilio__Order__c ASC
        ];
        for(Syntilio__ProtocolPageQuestion__c protocolPageQuestion : protocolPageQuestions){
            Map<String, Object> pageQuestionObject = protocolPageQuestion.Syntilio__JSON__c != null? 
                (Map<String, Object>) JSON.deserializeUntyped(protocolPageQuestion.Syntilio__JSON__c) 
                : new Map<String, Object>();
            pageQuestionObject.put('name', protocolPageQuestion.Syntilio__QuestionId__r.Name);
            pageQuestionObject.put('type', protocolPageQuestion.Syntilio__QuestionId__r.Syntilio__QuestionType__c);
            if(protocolPageQuestion.Syntilio__QuestionId__r.Syntilio__Title__c != null){
                pageQuestionObject.put('title', protocolPageQuestion.Syntilio__QuestionId__r.Syntilio__Title__c);
            }
            if(!String.isBlank(protocolPageQuestion.Syntilio__QuestionId__r.Syntilio__Choices__c)){
                pageQuestionObject.put('choices', JSON.deserializeUntyped(protocolPageQuestion.Syntilio__QuestionId__r.Syntilio__Choices__c));
            }
            if(protocolPageQuestion.Syntilio__Required__c){
                pageQuestionObject.put('isRequired', protocolPageQuestion.Syntilio__Required__c);
            }
            pageQuestionsList.add(pageQuestionObject);
        }
        return pageQuestionsList;
    }
    @NamespaceAccessible
    public static Syntilio__Protocol__c getProtocolById(String protocolId){
        List<Syntilio__Protocol__c> protocolsFound = [
            SELECT Id, Syntilio__JSON__c
            FROM Syntilio__Protocol__c
            WHERE Id = :protocolId
            WITH SECURITY_ENFORCED
        ];
        if(protocolsFound.size() > 0){
            return protocolsFound[0];
        }
        return null;
    }
    
    @NamespaceAccessible
    public static Syntilio__ProtocolPage__c getProtocolPageByName(String name, String protocolId){
        List<Syntilio__ProtocolPage__c> pagesFound = [
            SELECT Id, Name, Syntilio__Title__c, Syntilio__JSON__c, Syntilio__ProtocolId__c
            FROM Syntilio__ProtocolPage__c
            WHERE Name = :name
            AND Syntilio__ProtocolId__c = :protocolId
            WITH SECURITY_ENFORCED
        ];
        if(pagesFound.size() > 0){
            return pagesFound[0];
        }
        return new Syntilio__ProtocolPage__c(
            Name = name,
            Syntilio__ProtocolId__c = protocolId
        );
    }
    @NamespaceAccessible
    public static Syntilio__ProtocolPageQuestion__c getProtocolPageQuestionByName(String name, String pageId){
        List<Syntilio__ProtocolPageQuestion__c> pageQuestionsFound = [
            SELECT Id, Syntilio__QuestionId__c, Syntilio__QuestionId__r.Name, Syntilio__QuestionId__r.Syntilio__Title__c, Syntilio__JSON__c, Syntilio__ProtocolPageId__c
            FROM Syntilio__ProtocolPageQuestion__c
            WHERE Syntilio__QuestionId__r.Name = :name
            AND Syntilio__ProtocolPageId__c = :pageId
            WITH SECURITY_ENFORCED
        ];
        if(pageQuestionsFound.size() > 0){
            return pageQuestionsFound[0];
        }
        return new Syntilio__ProtocolPageQuestion__c(
            Name = name,
            Syntilio__ProtocolPageId__c = pageId
        );
    }
    @NamespaceAccessible
    public static Syntilio__Question__c getQuestionByName(String name){
        List<Syntilio__Question__c> questionsFound = [
            SELECT Id, Name, Syntilio__Title__c, Syntilio__QuestionType__c, Syntilio__JSON__c, Syntilio__Choices__c
            FROM Syntilio__Question__c
            WHERE Name = :name
            WITH SECURITY_ENFORCED
        ];
        if(questionsFound.size() > 0){
            return questionsFound[0];
        }
        return new Syntilio__Question__c(
            Name = name
        );
    }
    @NamespaceAccessible
    public static List<Syntilio__ProtocolResult__c> getProtocolResults(String protocolId, String caseId){
        return [
            SELECT Name, Syntilio__ProtocolId__c, Syntilio__CaseId__c, (SELECT 
                Syntilio__Answer__c, Syntilio__ProtocolPageQuestionId__r.Syntilio__QuestionId__r.Name 
                FROM Syntilio__ProtocolPageQuestionResults__r)
            FROM Syntilio__ProtocolResult__c
            WHERE Syntilio__ProtocolId__c = :protocolId
            AND Syntilio__CaseId__c = :caseId
            WITH SECURITY_ENFORCED
        ];
    }
    @NamespaceAccessible
    public static List<Syntilio__ProtocolPageQuestion__c> getProtocolPageQuestionsByProtocol(String protocolId){
        return [
            SELECT Syntilio__QuestionId__r.Name
            FROM Syntilio__ProtocolPageQuestion__c
            WHERE Syntilio__ProtocolPageId__r.Syntilio__ProtocolId__c = :protocolId
            WITH SECURITY_ENFORCED
        ];
    }
}