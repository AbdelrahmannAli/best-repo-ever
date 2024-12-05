/*************************************************************************   
    @description The DataHubSyncModel is composed from message which represents the synchronisation status information and the data which represents the logging of Salesforce CRUD oprerations*/
global  with sharing class DataHubSyncModel {
	global  static Boolean isSyncing = false;
	global  String message {get; set;}
	global  Object data {get; set;}
}