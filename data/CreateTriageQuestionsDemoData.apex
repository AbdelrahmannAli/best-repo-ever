Syntilio__Questionnaire__c standardTriageQuestionnaire = new Syntilio__Questionnaire__c(
    Name = 'Standard Triage Questionnaire',
    Syntilio__Active__c = true
);

insert standardTriageQuestionnaire;

Syntilio__Questionnaire__c videoTriageQuestionnaire = new Syntilio__Questionnaire__c(
    Name = 'Video Triage Questionnaire',
    Syntilio__Active__c = true
);

insert videoTriageQuestionnaire;

Syntilio__Questionnaire__c patientKarelGroenendijkDiabetesQuestionnaire= new Syntilio__Questionnaire__c(
    Name = 'Patient Karel Groenendijk Diabetes Questionnaire',
    Syntilio__Active__c = true
);

insert patientKarelGroenendijkDiabetesQuestionnaire;

List<Syntilio__Question__c> standardTriageQuestionsList = new List<Syntilio__Question__c>();
List<Syntilio__Question__c> videoTriageQuestionsList = new List<Syntilio__Question__c>();
List<Syntilio__Question__c> additionalVideoTriageQuestionsToInsertList = new List<Syntilio__Question__c>();

Syntilio__Question__c anxietyQuestion = new Syntilio__Question__c(
    Name = 'Anxiety',
    Syntilio__Question__c = 'Degree of patient anxiety on a scale from 0 to 5?',
    Syntilio__Type__c = 'Slider',
    Syntilio__Options__c = '0;5'
);
standardTriageQuestionsList.add(anxietyQuestion);
videoTriageQuestionsList.add(anxietyQuestion);

Syntilio__Question__c feverQuestion = new Syntilio__Question__c(
    Name = 'Fever',
    Syntilio__Question__c = 'Degree of patient fever on a scale from 0 to 5?',
    Syntilio__Type__c = 'Slider',
    Syntilio__Options__c = '0;5'
);
standardTriageQuestionsList.add(feverQuestion);
videoTriageQuestionsList.add(feverQuestion);

Syntilio__Question__c irregularHeartRateQuestion = new Syntilio__Question__c(
    Name = 'Heart Rate',
    Syntilio__Question__c = 'Degree of patient irregular heart rate on a scale from 0 to 5?',
    Syntilio__Type__c = 'Slider',
    Syntilio__Options__c = '0;5'
);
standardTriageQuestionsList.add(irregularHeartRateQuestion);
videoTriageQuestionsList.add(irregularHeartRateQuestion);

Syntilio__Question__c snoringQuestion = new Syntilio__Question__c(
    Name = 'Snoring',
    Syntilio__Question__c = 'Degree of patient snoring Loudly on a scale from 0 to 5?',
    Syntilio__Type__c = 'Slider',
    Syntilio__Options__c = '0;5'
);
standardTriageQuestionsList.add(snoringQuestion);
videoTriageQuestionsList.add(snoringQuestion);

Syntilio__Question__c feelingTiredDayTimeQuestion = new Syntilio__Question__c(
    Name = 'Tired/Fatigued/Sleepy Daytime',
    Syntilio__Question__c = 'Degree of patient feeling Tired, Fatigued, or Sleepy during the daytime on a scale from 0 to 5?',
    Syntilio__Type__c = 'Slider',
    Syntilio__Options__c = '0;5'
);
standardTriageQuestionsList.add(feelingTiredDayTimeQuestion);
videoTriageQuestionsList.add(feelingTiredDayTimeQuestion);

Syntilio__Question__c feelingTiredNightTimeQuestion = new Syntilio__Question__c(
    Name = 'Tired/Fatigued Night Time',
    Syntilio__Question__c = 'Degree of patient feeling Tired or Fatigued, during the night time on a scale from 0 to 5?',
    Syntilio__Type__c = 'Slider',
    Syntilio__Options__c = '0;5'
);
standardTriageQuestionsList.add(feelingTiredNightTimeQuestion);
videoTriageQuestionsList.add(feelingTiredNightTimeQuestion);

Syntilio__Question__c chokingQuestion = new Syntilio__Question__c(
    Name = 'Stopped Breathing or Choking/Gasping on Sleep',
    Syntilio__Question__c = 'Degree of patient stopped Breathing or Choking/Gasping during his sleep on a scale from 0 to 5?',
    Syntilio__Type__c = 'Slider',
    Syntilio__Options__c = '0;5'
);
standardTriageQuestionsList.add(chokingQuestion);

Syntilio__Question__c historyQuestion = new Syntilio__Question__c(
    Name = 'Medical and Surgical History',
    Syntilio__Question__c = 'What Are Your Medical and Surgical Histories?',
    Syntilio__Type__c = 'Text'
);
standardTriageQuestionsList.add(historyQuestion);

Syntilio__Question__c medicationsQuestion = new Syntilio__Question__c(
    Name = 'Medications',
    Syntilio__Question__c = 'What Prescription and Non-Prescription Medications Do You Take?',
    Syntilio__Type__c = 'Text'
);
standardTriageQuestionsList.add(medicationsQuestion);

Syntilio__Question__c allergiesQuestion = new Syntilio__Question__c(
    Name = 'Allergies',
    Syntilio__Question__c = 'What Allergies Do You Have?',
    Syntilio__Type__c = 'Text'
);
standardTriageQuestionsList.add(allergiesQuestion);

Syntilio__Question__c illicitHistoryQuestion = new Syntilio__Question__c(
    Name = 'Illicit History',
    Syntilio__Question__c = 'What is Your Smoking, Alcohol, and Illicit Drug Use History?',
    Syntilio__Type__c = 'Picklist',
    Syntilio__Options__c = 'Smoking;Alcohol;Drugs;None'
);
standardTriageQuestionsList.add(illicitHistoryQuestion);

Syntilio__Question__c servedArmyQuestion = new Syntilio__Question__c(
    Name = 'Armed Forces',
    Syntilio__Question__c = 'Have You Served in the Armed Forces?',
    Syntilio__Type__c = 'RadioButton',
    Syntilio__Options__c = 'Yes;No'
);
standardTriageQuestionsList.add(servedArmyQuestion);

insert standardTriageQuestionsList;


//Addtional of Video Triage Questionnaire
Syntilio__Question__c diarrheaOrVomitingQuestion = new Syntilio__Question__c(
    Name = 'Diarrhea or Vomiting',
    Syntilio__Question__c = 'Are you experiencing any diarrhea or vomiting?',
    Syntilio__Type__c = 'Text',
    Syntilio__Options__c = null
);
videoTriageQuestionsList.add(diarrheaOrVomitingQuestion);
additionalVideoTriageQuestionsToInsertList.Add(diarrheaOrVomitingQuestion);
Syntilio__Question__c contactWithSomeoneHospitalizedQuestion = new Syntilio__Question__c(
    Name = 'Contact with Someone Hospitalized',
    Syntilio__Question__c = 'Have you been in contact with someone who has been hospitalized recently?',
    Syntilio__Type__c = 'Text',
    Syntilio__Options__c = null
);
videoTriageQuestionsList.add(contactWithSomeoneHospitalizedQuestion);
additionalVideoTriageQuestionsToInsertList.Add(contactWithSomeoneHospitalizedQuestion);

Syntilio__Question__c viralInfectionQuestion = new Syntilio__Question__c(
    Name = 'Viral Infection',
    Syntilio__Question__c = 'Are you experiencing any symptoms of a viral infection, such as fatigue or body aches?',
    Syntilio__Type__c = 'Picklist',
    Syntilio__Options__c = 'Fatigue;Body Aches;None'
);
videoTriageQuestionsList.add(viralInfectionQuestion);
additionalVideoTriageQuestionsToInsertList.Add(viralInfectionQuestion);

Syntilio__Question__c fungalInfectionQuestion = new Syntilio__Question__c(
    Name = 'Fungal Infection',
    Syntilio__Question__c = 'Are you experiencing any symptoms of a fungal infection, such as itching or rash?',
    Syntilio__Type__c = 'Picklist',
    Syntilio__Options__c = 'Itching;Rash;None'
);
videoTriageQuestionsList.add(fungalInfectionQuestion);
additionalVideoTriageQuestionsToInsertList.Add(fungalInfectionQuestion);

insert additionalVideoTriageQuestionsToInsertList;

List<Syntilio__Question__c> patientKarelGroenendijkDiabetesQuestionsList = new List<Syntilio__Question__c>();


Syntilio__Question__c reasonQuestion = new Syntilio__Question__c(
    Name = 'Reason',
    Syntilio__Question__c = 'What is the reason for the call?',
    Syntilio__Type__c = 'Text',
    Syntilio__Options__c = null
);
patientKarelGroenendijkDiabetesQuestionsList.add(reasonQuestion);

Syntilio__Question__c difficultyBreathingQuestion = new Syntilio__Question__c(
    Name = 'Difficulty Breathing',
    Syntilio__Question__c = 'Are you experiencing any difficulty breathing?',
    Syntilio__Type__c = 'RadioButton',
    Syntilio__Options__c = 'Yes;No'
);
patientKarelGroenendijkDiabetesQuestionsList.add(difficultyBreathingQuestion);

Syntilio__Question__c diabetesMedicationsQuestion = new Syntilio__Question__c(
    Name = 'Diabetes Medications',
    Syntilio__Question__c = 'Are you currently taking any medications for your diabetes?',
    Syntilio__Type__c = 'RadioButton',
    Syntilio__Options__c = 'Yes;No'
);
patientKarelGroenendijkDiabetesQuestionsList.add(diabetesMedicationsQuestion);

Syntilio__Question__c weightChangeQuestion = new Syntilio__Question__c(
    Name = 'Weight Change',
    Syntilio__Question__c = 'Have you experienced any recent changes in your weight?',
    Syntilio__Type__c = 'RadioButton',
    Syntilio__Options__c = 'Yes;No'
);
patientKarelGroenendijkDiabetesQuestionsList.add(weightChangeQuestion);

Syntilio__Question__c monitoringBloodGlucoseQuestion = new Syntilio__Question__c(
    Name = 'Monitoring Blood Glucose',
    Syntilio__Question__c = 'Are you monitoring your blood glucose levels regularly?',
    Syntilio__Type__c = 'RadioButton',
    Syntilio__Options__c = 'Yes;No'
);
patientKarelGroenendijkDiabetesQuestionsList.add(monitoringBloodGlucoseQuestion);

Syntilio__Question__c woundsOrSoresThatAreSlowToHealQuestion = new Syntilio__Question__c(
    Name = 'Wounds or Sores that are Slow to Heal',
    Syntilio__Question__c = 'Have you noticed any wounds or sores that are slow to heal?',
    Syntilio__Type__c = 'RadioButton',
    Syntilio__Options__c = 'Yes;No;None'
);
patientKarelGroenendijkDiabetesQuestionsList.add(woundsOrSoresThatAreSlowToHealQuestion);

Syntilio__Question__c bloodPressureCheckedRecentlyQuestion = new Syntilio__Question__c(
    Name = 'Blood Pressure Checked Recently',
    Syntilio__Question__c = 'Have you had your blood pressure checked recently?',
    Syntilio__Type__c = 'RadioButton',
    Syntilio__Options__c = 'Yes;No'
);
patientKarelGroenendijkDiabetesQuestionsList.add(bloodPressureCheckedRecentlyQuestion);

Syntilio__Question__c increasedThirstFrequentUrinationOrUnexplainedFatigueQuestion = new Syntilio__Question__c(
    Name = 'Increased Thirst, Frequent Urination, or Unexplained Fatigue',
    Syntilio__Question__c = 'Are you experiencing any symptoms such as increased thirst, frequent urination, or unexplained fatigue?',
    Syntilio__Type__c = 'Picklist',
    Syntilio__Options__c = 'increased thirst;Frequent urination;Fatigue;None'
);
patientKarelGroenendijkDiabetesQuestionsList.add(increasedThirstFrequentUrinationOrUnexplainedFatigueQuestion);

Syntilio__Question__c visionProblemsQuestion = new Syntilio__Question__c(
    Name = 'Vision Problems',
    Syntilio__Question__c = 'Are you experiencing any vision problems?',
    Syntilio__Type__c = 'Text',
    Syntilio__Options__c = null
);
patientKarelGroenendijkDiabetesQuestionsList.add(visionProblemsQuestion);

insert patientKarelGroenendijkDiabetesQuestionsList;

List<Syntilio__QuestionnaireQuestion__c> standardTriageQuestionnaireQuestionList = new List<Syntilio__QuestionnaireQuestion__c>();
List<Syntilio__QuestionnaireQuestion__c> patientKarelGroenendijkDiabetesQuestionnaireQuestionList = new List<Syntilio__QuestionnaireQuestion__c>();
List<Syntilio__QuestionnaireQuestion__c> videoTriageQuestionnaireQuestionList = new List<Syntilio__QuestionnaireQuestion__c>();

For (Syntilio__Question__c standardTriageQuestionsRecord: standardTriageQuestionsList){
    Syntilio__QuestionnaireQuestion__c questionnaireQuestionRecord = new Syntilio__QuestionnaireQuestion__c(
    Syntilio__Question__c = standardTriageQuestionsRecord.Id,
    Syntilio__Questionnaire__c = standardTriageQuestionnaire.Id
    );
    standardTriageQuestionnaireQuestionList.add(questionnaireQuestionRecord);
}

insert standardTriageQuestionnaireQuestionList;

For (Syntilio__Question__c patientKarelGroenendijkDiabetesQuestionsRecord: patientKarelGroenendijkDiabetesQuestionsList){
    Syntilio__QuestionnaireQuestion__c questionnaireQuestionRecord = new Syntilio__QuestionnaireQuestion__c(
    Syntilio__Question__c = patientKarelGroenendijkDiabetesQuestionsRecord.Id,
    Syntilio__Questionnaire__c = patientKarelGroenendijkDiabetesQuestionnaire.Id
    );
    patientKarelGroenendijkDiabetesQuestionnaireQuestionList.add(questionnaireQuestionRecord);
}
insert patientKarelGroenendijkDiabetesQuestionnaireQuestionList;

For (Syntilio__Question__c videoTriageQuestionsRecord : videoTriageQuestionsList ){
    Syntilio__QuestionnaireQuestion__c questionnaireQuestionRecord = new Syntilio__QuestionnaireQuestion__c(
    Syntilio__Question__c = videoTriageQuestionsRecord.Id,
    Syntilio__Questionnaire__c = videoTriageQuestionnaire.Id
    );
    videoTriageQuestionnaireQuestionList.add(questionnaireQuestionRecord);
}
insert videoTriageQuestionnaireQuestionList;

