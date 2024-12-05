/* 
    Documentation:
    https://www.notion.so/syntilio/Syntilio-Salesforce-Dynamic-Protocols-Using-SurveyJS-c90a9f7cbd4e460390a383d94d18008a?pvs=4#66b69823982845319dfbbd348b335053
*/
@NamespaceAccessible
public with sharing class FormBuilderHandler {
    
    @AuraEnabled
    public static String handleGetForm(String protocolId){
        Syntilio__Protocol__c protocol = Syntilio.CaseProtocolHandler.getProtocolById(protocolId);
        if(protocol == null){
            return new Syntilio.ResponseMessage(
                null,
                'Protocol not found.',
                Syntilio.ResponseMessage.MessageType.ERROR
            ).serialize();
        }
        Map<String, Object> formObject = protocol.Syntilio__JSON__c != null? 
            (Map<String, Object>) JSON.deserializeUntyped(protocol.Syntilio__JSON__c) 
            : new Map<String, Object>();
        
        List<Map<String, Object>> pages = Syntilio.CaseProtocolHandler.getProtocolPagesListByProtocol(protocolId);
        for(Map<String, Object> page : pages){
            String pageId = (String) page.get('Id');
            page.put('elements', Syntilio.CaseProtocolHandler.getProtocolPageQuestionsListByPage(pageId));
            page.remove('Id');
        }
        formObject.put('pages', pages);
        List<Syntilio__Question__c> reusableQuestions = [
            SELECT Name, Syntilio__Title__c, Syntilio__QuestionType__c, 
            Syntilio__Choices__c, Syntilio__JSON__c 
            FROM Syntilio__Question__c 
            WHERE Syntilio__QuestionType__c != null
            WITH SECURITY_ENFORCED
        ];
        return new Syntilio.ResponseMessage(
            JSON.serialize(new Map<String, Object>{
                	'creatorJSON' => formObject,
                    'reusableQuestions' => reusableQuestions
                }
			),
            null,
            Syntilio.ResponseMessage.MessageType.SUCCESS
        ).serialize();
    }
    @AuraEnabled
    public static String handlePostForm(String body, String protocolId){
        Savepoint sp = Database.setSavepoint();
        try{
            Map<String, Object> surveyBody = (Map<String, Object>) JSON.deserializeUntyped(body);
            if(surveyBody == null){
                return new Syntilio.ResponseMessage(
                    null,
                    'Forms must have at least 1 page.',
                    Syntilio.ResponseMessage.MessageType.ERROR
                ).serialize();
            }
            List<Object> bodyPages = (List<Object>) surveyBody.get('pages');
            if(bodyPages == null || bodyPages.size() == 0){
                return new Syntilio.ResponseMessage(
                    null,
                    'Forms must have at least 1 page.',
                    Syntilio.ResponseMessage.MessageType.ERROR
                ).serialize();
            }
            
            Syntilio__Protocol__c protocol = Syntilio.CaseProtocolHandler.getProtocolById(protocolId);
            if(protocol == null){
                return new Syntilio.ResponseMessage(
                    null,
                    'Protocol not found ' + protocolId,
                    Syntilio.ResponseMessage.MessageType.ERROR
                ).serialize();
            }
            Map<String, Object> surveyBodyClone = surveyBody.clone();
            if(surveyBodyClone.containsKey('pages')){
                surveyBodyClone.remove('pages');
            }
            protocol.Syntilio__JSON__c = JSON.serialize(surveyBodyClone);
            List<SObject> sObjectList = new List<SObject>();
            sObjectList.add(protocol);
            Syntilio.UpsertToDatabase.updateAction(sObjectList,false);

            List<Syntilio__ProtocolPage__c> pages = setupPagesToUpsert(bodyPages, protocolId);
            Syntilio.UpsertToDatabase.upsertAction(pages,true);
            List<Id> pagesIds = Syntilio.DataHubUtilities.sObjectListToIdList(pages);

            List<Syntilio__Question__c> questions = setupQuestionsToUpsert(bodyPages);
            Syntilio.UpsertToDatabase.upsertAction(questions,true);

            List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestions = setupProtocolPageQuestionsToUpsert(bodyPages, pages);
            for(Integer i = 0; i < protocolPageQuestions.size(); i++){
                protocolPageQuestions[i].Syntilio__QuestionId__c = questions[i].Id;
            }
            Syntilio.UpsertToDatabase.upsertAction(protocolPageQuestions, true);
            List<Id> protocolPageQuestionsIds = Syntilio.DataHubUtilities.sObjectListToIdList(protocolPageQuestions);

            List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestionsToDelete = new List<Syntilio__ProtocolPageQuestion__c>();
            for(Id pageId : pagesIds){
                protocolPageQuestionsToDelete.addAll(getProtocolPageQuestionsToDelete(protocolPageQuestionsIds, pageId));
            }
            
            List<Syntilio__ProtocolPage__c> pagesToDelete = getProtocolPagesToDelete(pagesIds, protocolId);
            
            List<SObject> objectsToDelete = new List<SObject>();
            objectsToDelete.addAll(protocolPageQuestionsToDelete);
            objectsToDelete.addAll(pagesToDelete);
            Syntilio.UpsertToDatabase.deleteAction(objectsToDelete,true);
            
			return new Syntilio.ResponseMessage(
                null,
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
    public static List<Syntilio__ProtocolPage__c> setupPagesToUpsert(List<Object> bodyPages, String protocolId){
        List<Syntilio__ProtocolPage__c> pagesToUpsert = new List<Syntilio__ProtocolPage__c>();
        for(Integer i = 0; i < bodyPages.size(); i++){
            Map<String, Object> bodyPage = (Map<String, Object>) bodyPages[i];
            Syntilio__ProtocolPage__c page = Syntilio.CaseProtocolHandler.getProtocolPageByName((String) bodyPage.get('name'), protocolId);
            page.Syntilio__Title__c = (String) bodyPage.get('title');
            page.Syntilio__Order__c = i + 1;
            page.Syntilio__JSON__c = generatePageJSON(bodyPage);
            pagesToUpsert.add(page);
        } 
        return pagesToUpsert;
    }
    @NamespaceAccessible
    public static List<Syntilio__Question__c> setupQuestionsToUpsert(List<Object> bodyPages){
        List<Syntilio__Question__c> questionsToUpsert = new List<Syntilio__Question__c>();
        for(Integer i = 0; i < bodyPages.size(); i++){
            Map<String, Object> bodyPage = (Map<String, Object>) bodyPages[i];
            List<Object> elements = (List<Object>) bodyPage.get('elements');
            if(elements == null){
                continue;
            }
            for(Integer j = 0; j < elements.size(); j++){
                Map<String, Object> element = (Map<String, Object>) elements[j];
                Syntilio__Question__c question = Syntilio.CaseProtocolHandler.getQuestionByName((String) element.get('name'));
                question.Syntilio__Title__c = (String) element.get('title');
                question.Syntilio__QuestionType__c = (String) element.get('type');
                if(element.get('choices') != null){
                	question.Syntilio__Choices__c = JSON.serialize(element.get('choices'));
                }
                questionsToUpsert.add(question);
            }
            
        } 
        return questionsToUpsert;
    }
    @NamespaceAccessible
    public static List<Syntilio__ProtocolPageQuestion__c> setupProtocolPageQuestionsToUpsert(List<Object> bodyPages, List<Syntilio__ProtocolPage__c> pages){
        List<Syntilio__ProtocolPageQuestion__c> protocolPageQuestionsToUpsert = new List<Syntilio__ProtocolPageQuestion__c>();
        for(Integer i = 0; i < bodyPages.size(); i++){
            Map<String, Object> bodyPage = (Map<String, Object>) bodyPages[i];
            Id pageId = pages[i].Id;
            List<Object> elements = (List<Object>) bodyPage.get('elements');
            if(elements == null){
                continue;
            }
            for(Integer j = 0; j < elements.size(); j++){
                Map<String, Object> element = (Map<String, Object>) elements[j];
                Syntilio__ProtocolPageQuestion__c pageQuestion = Syntilio.CaseProtocolHandler.getProtocolPageQuestionByName((String) element.get('name'), pageId);
                pageQuestion.Syntilio__Order__c = j + 1;
                if(element.get('isRequired') != null){
                	pageQuestion.Syntilio__Required__c = (Boolean) element.get('isRequired');
                }
                pageQuestion.Syntilio__JSON__c = generateProtocolPageQuestionJSON(element);
                protocolPageQuestionsToUpsert.add(pageQuestion);
            }
        } 
        return protocolPageQuestionsToUpsert;
    }
    private static String generatePageJSON(Map<String, Object> bodyPage){
        Map<String, Object> bodyPageClone = bodyPage.clone();
        bodyPageClone.remove('name');
        bodyPageClone.remove('elements');
        if(bodyPageClone.containsKey('title')){
            bodyPageClone.remove('title');
        }
        return JSON.serialize(bodyPageClone);
    }
    private static String generateProtocolPageQuestionJSON(Map<String, Object> protocolPageQuestion){
        Map<String, Object> protocolPageQuestionClone = protocolPageQuestion.clone();
        protocolPageQuestionClone.remove('name');
        if(protocolPageQuestionClone.containsKey('type')){
            protocolPageQuestionClone.remove('type');
        }
        if(protocolPageQuestionClone.containsKey('title')){
            protocolPageQuestionClone.remove('title');
        }
        if(protocolPageQuestionClone.containsKey('isRequired')){
            protocolPageQuestionClone.remove('isRequired');
        }
        return JSON.serialize(protocolPageQuestionClone);
    }
    @NamespaceAccessible
    public static List<Syntilio__ProtocolPageQuestion__c> getProtocolPageQuestionsToDelete(List<Id> pageQuestionsIds, Id pageId){
        List<Syntilio__ProtocolPageQuestion__c> pageQuestionsFound = [
            SELECT Id
            FROM Syntilio__ProtocolPageQuestion__c
            WHERE Id NOT IN :pageQuestionsIds
            AND Syntilio__ProtocolPageId__c = :pageId
            WITH SECURITY_ENFORCED
        ];
        return pageQuestionsFound;
    }
    @NamespaceAccessible
    public static List<Syntilio__ProtocolPage__c> getProtocolPagesToDelete(List<Id> pagesIds, String protocolId){
        List<Syntilio__ProtocolPage__c> pagesFound = [
            SELECT Id
            FROM Syntilio__ProtocolPage__c
            WHERE Id NOT IN :pagesIds
            AND Syntilio__ProtocolId__c = :protocolId
            WITH SECURITY_ENFORCED
        ];
        return pagesFound;
    }
}