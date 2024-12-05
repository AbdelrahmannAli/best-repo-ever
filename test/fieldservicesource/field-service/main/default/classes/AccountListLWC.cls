@NamespaceAccessible
public with sharing class AccountListLWC {
  @AuraEnabled(cacheable=true)
  public static List<Account> getAccounts() {
    try {
      List<Account> accountList = [SELECT id, Name, Website, Phone FROM Account];
      return accountList;
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
  }
}