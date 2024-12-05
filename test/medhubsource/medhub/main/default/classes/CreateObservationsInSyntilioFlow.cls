public with sharing class CreateObservationsInSyntilioFlow {
    
    @invocableMethod(label='Create Care Observation and Care Observation Component Records')
    public static List<OutputVariables> execute (List<InputVariables> inputVariables) {
        List<OutputVariables> outputVariablesList = new List<OutputVariables>();
        List<CareObservation> careObservationRecordsList = new List<CareObservation>();
        Id observationRecordCreatedId;
        
        if(inputVariables == null)
            return null;
        
        for(InputVariables inputVariable : inputVariables){
            try {
                If(inputVariable.sObjectType == 'CareObservation'){
                    CareObservation careObservationRecord = new CareObservation(
                        Name = inputVariable.name,
                        ObservedSubjectId = inputVariable.observedSubjectId,
                        CodeId = inputVariable.codeId,
                        ObservationStatus = 'Preliminary',
                        ObservedValueType = 'Quantity',
                        NumericValue = Double.valueOf(inputVariable.numericValue),
                        EffectiveDateTime = system.now(),
                        Syntilio__Questionnaire__c = inputVariable.questionnaireId
                    );

                    insert careObservationRecord;
                    observationRecordCreatedId = careObservationRecord.Id;
                }
                else If(inputVariable.sObjectType == 'CareObservationComponent') {
                    CareObservationComponent careObservationComponentRecord = new CareObservationComponent(
                        Name = inputVariable.name,
                        CareObservationId = inputVariable.careObservationId,
                        ComponentTypeCodeId = inputVariable.codeSetBundleId,
                        ObservationStartDateTime = system.now(),
                        Syntilio__Question__c = inputVariable.questionId
                    );
                    if(inputVariable.numericValue.isNumeric() ) {
                        careObservationComponentRecord.NumericValue = Double.valueOf(inputVariable.numericValue);
                    } else {
                        careObservationComponentRecord.ObservedValueText = inputVariable.numericValue;
                    }
                    insert careObservationComponentRecord;
                    observationRecordCreatedId = careObservationComponentRecord.Id;
                }
                else
                    return null;
                
            } catch(Exception e){
                Syntilio.HandleException.logException(e);
            }
            
            OutputVariables outputVariables = new OutputVariables();
            outputVariables.observationRecordCreatedId = observationRecordCreatedId;
            outputVariablesList.add(outputVariables);
            
        }
        return outputVariablesList;
    }
    
    public class InputVariables {
        @invocableVariable
        public String sObjectType;
        @invocableVariable
        public String name;
        @invocableVariable
        public Id observedSubjectId;
        @invocableVariable
        public Id codeId ;
        @invocableVariable
        public String numericValue;
        @invocableVariable
        public Id questionnaireId;
        @invocableVariable
        public Id careObservationId;
        @invocableVariable
        public Id codeSetBundleId;
        @invocableVariable
        public Id questionId;
        
    }
    
    public class OutputVariables {
        @invocableVariable
        public Id observationRecordCreatedId;
    }
}