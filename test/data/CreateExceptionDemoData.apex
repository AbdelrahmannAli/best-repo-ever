Syntilio__Exception__c logExceptioApexSourcenRecord1 = new Syntilio__Exception__c (
    Name = 'Exception ' + String.valueOf(system.now()),
    Syntilio__ExceptionMessage__c = 'Exception type caught: System.TypeException'  + ',\n' + 'Message:  Invalid decimal: &' + ',\n' + 'Cause: null' + ',\n' + 'Line number: 21' + ',\n' + 'Stack trace: Class.Syntilio.DataHubUtilities.safeParseDecimal: line 21, column 1 Class.Syntilio.DataHubUtilities.castStringArrayToDecimalArray: line 8, column 1 Class.Syntilio.QueryCasesToCloseInSyntilioFlow.execute: line 14, column 1',
    Syntilio__ExceptionSource__c = 'Apex'
);
insert logExceptioApexSourcenRecord1;

Syntilio__Exception__c logExceptionFlowSourceRecord2 = new Syntilio__Exception__c (
    Name = 'Exception ' + String.valueOf(system.now()),
    Syntilio__ExceptionMessage__c = 'Flow Error 1',
    Syntilio__ExceptionSource__c = 'Flow'
);
insert logExceptionFlowSourceRecord2;

Syntilio__Exception__c logExceptionFlowSourceRecord3 = new Syntilio__Exception__c (
    Name = 'Exception ' + String.valueOf(system.now()),
    Syntilio__ExceptionMessage__c = 'Flow Error 2',
    Syntilio__ExceptionSource__c = 'Flow'
);
insert logExceptionFlowSourceRecord3;