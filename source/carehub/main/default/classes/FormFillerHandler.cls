/*
    Documentation:
    https://www.notion.so/syntilio/Syntilio-Salesforce-Dynamic-Protocols-Using-SurveyJS-c90a9f7cbd4e460390a383d94d18008a?pvs=4
*/
@NamespaceAccessible
public with sharing class FormFillerHandler {
    
    @AuraEnabled
    public static String handleGetForm(String protocolId, String caseId){
        Syntilio__Protocol__c protocol = Syntilio.CaseProtocolHandler.getProtocolById(protocolId);
        if(protocol == null){
            return new Syntilio.ResponseMessage(
                null,
                'Protocol not found.',
                Syntilio.ResponseMessage.MessageType.ERROR
            ).serialize();
        }
        Map<String, Object> survey = protocol.Syntilio__JSON__c != null? 
            (Map<String, Object>) JSON.deserializeUntyped(protocol.Syntilio__JSON__c) 
            : new Map<String, Object>();
        
        List<Map<String, Object>> pages = Syntilio.CaseProtocolHandler.getProtocolPagesListByProtocol(protocolId);
        for(Map<String, Object> page : pages){
            String pageId = (String) page.get('Id');
            page.put('elements', Syntilio.CaseProtocolHandler.getProtocolPageQuestionsListByPage(pageId));
            page.remove('Id');
        }
        survey.put('pages', pages);
        
        Map<String, Object> results = getProtocolResultsMap(protocolId, caseId);
        
        return new Syntilio.ResponseMessage(
            JSON.serialize(new Map<String, Object>{
                	'survey' => survey,
                    'results' => results
                }
			),
            null,
            Syntilio.ResponseMessage.MessageType.SUCCESS
        ).serialize();
    }
    
    @NamespaceAccessible
    public static Map<String, Object> getProtocolResultsMap(String protocolId, String caseId){
        List<Syntilio__ProtocolResult__c> protocolResults = Syntilio.CaseProtocolHandler.getProtocolResults(protocolId, caseId);
        if(protocolResults.size() == 0 || protocolResults[0].Syntilio__ProtocolPageQuestionResults__r == null){
            return null;
        }
        return Syntilio.DataHubUtilities.listToMap(
            'Syntilio__ProtocolPageQuestionId__r.Syntilio__QuestionId__r.Name', 
            'Syntilio__Answer__c',
            protocolResults[0].Syntilio__ProtocolPageQuestionResults__r
        );
    }

    @AuraEnabled
    public static Boolean handleGetActions(String protocolId){
        List <Syntilio__ProtocolPage__c> pages = [SELECT Id , Name , Syntilio__JSON__c , Syntilio__Title__c FROM Syntilio__ProtocolPage__c  WHERE Syntilio__ProtocolId__c = :protocolId AND Name LIKE '%Action%' LIMIT 1];
        if (pages.size() == 0){
            return false;
        }
        Id actionPageId = pages[0].Id;
        List <Syntilio__ProtocolPageQuestion__c> pageQuestions = [SELECT Name , Syntilio__JSON__c FROM Syntilio__ProtocolPageQuestion__c WHERE Syntilio__ProtocolPageId__c = :actionPageId];
        Boolean containsActions = pageQuestions.size() > 0;
        return containsActions;
        }
    
    @AuraEnabled
    public static String handlePostForm(String body, String protocolId, String caseId){
        Savepoint sp = Database.setSavepoint();
        try{
            Map<String, Object> resultBody = (Map<String, Object>) JSON.deserializeUntyped(body);
            Id protocolResultId;
            List<Syntilio__ProtocolResult__c> protocolResults = Syntilio.CaseProtocolHandler.getProtocolResults(protocolId, caseId);
            List<Syntilio__ProtocolPageQuestionResult__c> recordsToDelete = new List<Syntilio__ProtocolPageQuestionResult__c>();
        	List<Syntilio__ProtocolPageQuestionResult__c> recordsToUpsert = new List<Syntilio__ProtocolPageQuestionResult__c>();
            if(protocolResults.size() > 0){
                protocolResultId = protocolResults[0].Id;
                setupResultBodyAndRecords(protocolResultId, resultBody, recordsToDelete, recordsToUpsert);
			}else{       
                Syntilio__ProtocolResult__c protocolResult = new Syntilio__ProtocolResult__c(
                    Syntilio__ProtocolId__c = protocolId,
                    Syntilio__CaseId__c = caseId
                );
                List<SObject> sObjectList = new List<SObject>();
                sObjectList.add(protocolResult);
                Syntilio.UpsertToDatabase.insertAction(sObjectList,false);
                protocolResultId = protocolResult.Id;
			}
            
            recordsToUpsert.addAll(generateProtocolPageQuestionResultsToInsert(
            	protocolResultId, protocolId, resultBody
            ));
            Syntilio.UpsertToDatabase.upsertAction(recordsToUpsert, true);
            Syntilio.UpsertToDatabase.deleteAction(recordsToDelete, true);
            
			return new Syntilio.ResponseMessage(
                JSON.serialize(new Map<String, Object>{
                    'toDelete' => recordsToDelete,
                    'toUpdate' => recordsToUpsert
                }),
                null,
                Syntilio.ResponseMessage.MessageType.SUCCESS
            ).serialize();          
        }catch(Exception e){
            Database.rollback(sp);
            Syntilio.HandleException.logException(e);
            return new Syntilio.ResponseMessage(
                null,
                e.getMessage() + ' ' + e.getStackTraceString(),
                Syntilio.ResponseMessage.MessageType.ERROR
            ).serialize();
        }
    }
	@NamespaceAccessible
    public static void setupResultBodyAndRecords(
        Id protocolResultId, 
        Map<String, Object> resultBody, 
        List<Syntilio__ProtocolPageQuestionResult__c> recordsToDelete,
        List<Syntilio__ProtocolPageQuestionResult__c> recordsToUpdate
    ){
            List<Syntilio__ProtocolPageQuestionResult__c> protocolPageQuestionResult = [
                SELECT Id, Syntilio__ProtocolPageQuestionId__r.Syntilio__QuestionId__r.Name, Syntilio__Answer__c
                FROM Syntilio__ProtocolPageQuestionResult__c 
                WHERE Syntilio__ProtocolResultId__c = :protocolResultId
                WITH SECURITY_ENFORCED
            ];
            
            for(Syntilio__ProtocolPageQuestionResult__c result : protocolPageQuestionResult){
                String questionName = result.Syntilio__ProtocolPageQuestionId__r.Syntilio__QuestionId__r.Name;
                String questionAnswer = result.Syntilio__Answer__c;
                if(resultBody.containsKey(questionName)){
                    if(JSON.serialize(questionAnswer) != JSON.serialize(resultBody.get(questionName))){
                        result.Syntilio__Answer__c = JSON.serialize(resultBody.get(questionName));
                        recordsToUpdate.add(result);
                    }
                    resultBody.remove(questionName);
                }else{
                    recordsToDelete.add(result);
                }
            }
    }
    @NamespaceAccessible
    public static List<Syntilio__ProtocolPageQuestionResult__c> generateProtocolPageQuestionResultsToInsert(
        Id protocolResultId, String protocolId, Map<String, Object> resultBody) {
            Map<String, Object> protocolPageQuestionsMap = getProtocolPageQuestionsMap(protocolId);
            List<Syntilio__ProtocolPageQuestionResult__c> protocolPageQuestionResults = new List<Syntilio__ProtocolPageQuestionResult__c>();
            for(String questionName : resultBody.keySet()){
                String protocolPageQuestionId = (String) protocolPageQuestionsMap.get(questionName);
                if(protocolPageQuestionId == null){
                    continue;
                }
                protocolPageQuestionResults.add(
                    new Syntilio__ProtocolPageQuestionResult__c(
                        Syntilio__ProtocolPageQuestionId__c = protocolPageQuestionId,
                        Syntilio__ProtocolResultId__c = protocolResultId,
                        Syntilio__Answer__c = JSON.serialize(resultBody.get(questionName))
                    )
                );
            }
            return protocolPageQuestionResults;
    }
    @NamespaceAccessible
    public static Map<String, Object> getProtocolPageQuestionsMap(String protocolId){
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = Syntilio.CaseProtocolHandler.getProtocolPageQuestionsByProtocol(protocolId);
       	return Syntilio.DataHubUtilities.listToMap(
            'Syntilio__QuestionId__r.Name', 
            'Id', 
            protocolPageQuestions
        );
    }
}