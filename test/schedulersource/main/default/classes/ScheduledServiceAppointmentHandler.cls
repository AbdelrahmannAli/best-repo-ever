public with sharing class ScheduledServiceAppointmentHandler implements Schedulable {
    public Id recordId;

    public ScheduledServiceAppointmentHandler(Id recordId) {
        this.recordId = recordId;
    }

    public void execute(SchedulableContext SC) {
        Map<String, Object> flowInputs = new Map<String, Object>();
        flowInputs.put('recordId', recordId);

        Flow.Interview.Route_Case_To_Agent_in_Omni_Channel flow = new Flow.Interview.Route_Case_To_Agent_in_Omni_Channel(flowInputs);
        if(!Test.isRunningTest()){
            flow.start();
        }
    }
}