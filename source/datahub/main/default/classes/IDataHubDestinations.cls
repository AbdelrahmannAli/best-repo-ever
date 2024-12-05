/*************************************************************************   
@description A class for populating the intended target destinations along with the required fields for the Dynamic API callouts. It recieves one parameter, which is the trigger list serialized .*/
global interface IDataHubDestinations {
	Syntilio.DataHubModel dataHubCalloutDestinations(String objectsList);
}