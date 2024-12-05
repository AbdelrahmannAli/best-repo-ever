@NamespaceAccessible
public with sharing class PostalCodeInfoHandler {
    @NamespaceAccessible
    public static void handleContactInsert(Map<Id, Contact> newMap) {
        List<Syntilio__CountryCode__mdt> countryCodes = getCountryCodes();
        Map<String, Object> countryLabelToCode = Test.isRunningTest()? 
            new Map<String, Object>{'Netherlands' => 'NL'} :
			Syntilio.DataHubUtilities.listToMap('DeveloperName', 'Label', countryCodes);
        List<Id> contactsToInsert = new List<Id>();
        
        for(Contact contact : newMap.values()) {
            if(contact.MailingCountry == null || contact.MailingPostalCode == null) {
                continue;
            }
            if(countryLabelToCode.get(contact.MailingCountry) == null) {
                continue;
            }
            contactsToInsert.add(contact.Id);
        }
        
        if(contactsToInsert.size() > 0) {
            handlePostalCodes(JSON.serialize(contactsToInsert), JSON.serialize(countryLabelToCode));
        }
    }
    
    @NamespaceAccessible
    public static void handleContactUpdate(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        List<Syntilio__CountryCode__mdt> countryCodes = getCountryCodes();
        Map<String, Object> countryLabelToCode = Test.isRunningTest()? 
            new Map<String, Object>{'Netherlands' => 'NL'} :
            Syntilio.DataHubUtilities.listToMap('DeveloperName', 'Label', countryCodes);
        List<Id> contactsToUpdate = new List<Id>();
        
        for(Id contactId : newMap.keySet()) {
            Contact contact = newMap.get(contactId);
            Contact oldContact = oldMap.get(contactId);
            if(contact.MailingCountry == oldContact.MailingCountry && contact.MailingPostalCode == oldContact.MailingPostalCode){
                continue;
            }
            if(contact.MailingCountry == null || contact.MailingPostalCode == null) {
                continue;
            }
            if(countryLabelToCode.get(contact.MailingCountry) == null) {
                continue;
            }
            contactsToUpdate.add(contact.Id);
        }
        
        if(contactsToUpdate.size() > 0) {
            handlePostalCodes(JSON.serialize(contactsToUpdate), JSON.serialize(countryLabelToCode));
        }
    }
    
    private static List<Syntilio__CountryCode__mdt> getCountryCodes() {
        return [
            SELECT Label, DeveloperName
            FROM Syntilio__CountryCode__mdt
            WITH SECURITY_ENFORCED
            LIMIT 200
        ];
    }
    
    @NamespaceAccessible
    @future(callout=true)
    public static void handlePostalCodes(String contactIdsSerialized, String countryLabelToCodeSerialized) {
        Map<String, Object> countryLabelToCode = (Map<String, Object>) JSON.deserializeUntyped(countryLabelToCodeSerialized);
        List<Object> contactIdsObject = (List<Object>) JSON.deserializeUntyped(contactIdsSerialized);
        List<String> contactIds = new List<String>();
        for(Object contactId : contactIdsObject) {
            contactIds.add((String) contactId);
        }
        List<Contact> contacts = [
            SELECT Id, MailingCountry, MailingPostalCode 
            FROM Contact
            WHERE Id IN :contactIds
            WITH SECURITY_ENFORCED
        ];
        Set<String> postalCodes = new Set<String>();
        for(Contact contact : contacts) {
            postalCodes.add(contact.MailingPostalCode);
        }
        Map<String, Syntilio__PostalCodeInfo__c> postalCodesMap = getPostalCodeInfo(new List<String>(postalCodes));

        Map<String, Set<String>> countryCodeToPostalCodes = new Map<String, Set<String>>();
        for(Contact contact : contacts) {
            String countryCode = (String) countryLabelToCode.get(contact.MailingCountry);
            Syntilio__PostalCodeInfo__c postalCodeInfo = postalCodesMap.get(countryCode + ' ' + contact.MailingPostalCode);
            if(postalCodeInfo != null){
                continue;
            }
            Set<String> countryPostalCodes = countryCodeToPostalCodes.get(countryCode);
            if(countryPostalCodes == null){
                countryPostalCodes = new Set<String>();
            }
            countryPostalCodes.add(contact.MailingPostalCode);
            countryCodeToPostalCodes.put(countryCode, countryPostalCodes);
        }
        
        if(countryCodeToPostalCodes != null && countryCodeToPostalCodes.keySet().size() > 0) {
        	syncPostalCodes(countryCodeToPostalCodes, postalCodesMap);
        }
        
        for(Contact contact : contacts) {
            String countryCode = (String) countryLabelToCode.get(contact.MailingCountry);
            Syntilio__PostalCodeInfo__c postalCodeInfo = postalCodesMap.get(countryCode + ' ' + contact.MailingPostalCode);
            contact.Syntilio__PostalCodeInfo__c = postalCodeInfo.Id;
        }
        List<Database.SaveResult> updatedCases = Syntilio.UpsertToDatabase.updateAction(contacts, false);
        
    }
    
    @NamespaceAccessible
    public static void syncPostalCodes(Map<String, Set<String>> countryCodeToPostalCodes, Map<String, Syntilio__PostalCodeInfo__c> postalCodesMap) {
        List<Syntilio.DataHubModel.Destination> destinationRecordList = new List<Syntilio.DataHubModel.Destination>();
        Syntilio.DataHubModel.Destination destination = new Syntilio.DataHubModel.Destination();
        destination.technology = 'ZipCodeStack';
        destinationRecordList.add(destination);
        String destinationsModelSerialized = JSON.serializePretty(destinationRecordList);
        
        List<Syntilio__PostalCodeInfo__c> postalCodeInfoToInsert = new List<Syntilio__PostalCodeInfo__c>();
        for(String countryCode : countryCodeToPostalCodes.keySet()){
            HttpResponse response =  Syntilio.DataHubCallout.onGet(
                'postalcodeinfo',
                '?country=' + countryCode + '&codes=' + String.join(new List<String>(countryCodeToPostalCodes.get(countryCode)), ','), 
                destinationsModelSerialized
            );
            if(response.getBody() == null)
                continue;
            Map<String, Object> responseDeserialized = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> results = (List<Object>) responseDeserialized.get(destination.technology);
            for(Object postalCodeData : results) {
                Map<String, Object> postalCodeDataMap = (Map<String, Object>) postalCodeData;
                Syntilio__PostalCodeInfo__c newPostalCodeInfo = new Syntilio__PostalCodeInfo__c(
                    Name = (String) postalCodeDataMap.get('code'),
                    Syntilio__CountryCode__c = (String) postalCodeDataMap.get('countryCode'),
                    Syntilio__City__c = (String) postalCodeDataMap.get('city'),
                    Syntilio__State__c = (String) postalCodeDataMap.get('state')
                );
                postalCodesMap.put(newPostalCodeInfo.Syntilio__CountryCode__c + ' ' + newPostalCodeInfo.Name, newPostalCodeInfo);                
                postalCodeInfoToInsert.add(newPostalCodeInfo);
            }
            List<Database.SaveResult> insertedCallLogs = Syntilio.UpsertToDatabase.insertAction(postalCodeInfoToInsert, false);
        }
    }
    
    @NamespaceAccessible
    public static Map<String, Syntilio__PostalCodeInfo__c> getPostalCodeInfo(List<String> postalCodes) {
        List<Syntilio__PostalCodeInfo__c> postalCodesFound = [
            SELECT Name, Syntilio__CountryCode__c, Syntilio__State__c, Syntilio__City__c
            FROM Syntilio__PostalCodeInfo__c
            WHERE Name IN :postalCodes
            WITH SECURITY_ENFORCED
        ];
        Map<String, Syntilio__PostalCodeInfo__c> countryCodePostalCodeToPostalCodeInfo = new Map<String, Syntilio__PostalCodeInfo__c>();
        for(Syntilio__PostalCodeInfo__c postalCodeInfo : postalCodesFound) {
            countryCodePostalCodeToPostalCodeInfo.put(
                postalCodeInfo.Syntilio__CountryCode__c + ' ' + postalCodeInfo.Name, 
                postalCodeInfo
            );
        }
        return countryCodePostalCodeToPostalCodeInfo;
    }
}