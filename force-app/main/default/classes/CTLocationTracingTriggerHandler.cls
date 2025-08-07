public with sharing class CTLocationTracingTriggerHandler {
    public static void checkDuplicates(List<Location_Tracing__c> locations){
        List<Location_Tracing__c> duplicates = CTLocationTracingController.checkDuplicates(locations);
        for(Location_Tracing__c trace: duplicates){
            trace.addError('Duplicate record found. Location Id'+trace.Location__c+'Person Id:'+trace.Person__c);
        }
    }
}