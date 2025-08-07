public with sharing class CTPeopleTracingTriggerHandler {
   
    public static void checkDuplicates(List<People_Tracing__c> peopleTraces){
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        duplicates = CTPeopleTracingContoller.checkDuplicates(peopleTraces);
        for(People_Tracing__c traces : duplicates){
            traces.addError('Duplicate record found. Person 1 - '+ traces.Person_1__c+ 'and Person 2- '+ traces.Person_2__c);
        }
    }
}