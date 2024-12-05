public with sharing class AddServiceAppointmentFields {
    public class ServiceAppointmentFields{
        @InvocableVariable(label='UpdateAllOccurrences boolean value')
        public boolean UpdateAllOccurrences;
        
        @InvocableVariable(label='String representing JSON for ServiceAppointmentFields')
		public String jsonStr;
    }
    
    @InvocableMethod(label='Add Service Appointment Fields' description='Add Service Appointment Fields by updating serviceAppointmentFields')
    public static List<String> serviceAppointmentFieldsHandler(List<ServiceAppointmentFields> serviceAppointmentFieldsInputs) {
        List<String> result = new List<String>();
        for(ServiceAppointmentFields serviceAppointmentFieldsInput : serviceAppointmentFieldsInputs) {
            result.add(serviceAppointmentFieldsInput.jsonStr.split('}')[0] + ', "UpdatedByAgent__c" : true, "UpdateAllOccurrences__c": ' + serviceAppointmentFieldsInput.UpdateAllOccurrences + '}');
        }
        return result;
    }
}