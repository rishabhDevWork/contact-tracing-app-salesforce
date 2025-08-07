public with sharing class CTPeopleTracingContoller {
    
    public static List<People_Tracing__c> getTraces(String recordId) {

        return [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c 
                FROM People_Tracing__c WHERE (Person_1__c =: recordId OR Person_2__c =: recordId) AND Contact_Date__c = LAST_N_DAYS:30 ORDER BY Contact_Date__c DESC];
    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces) {

        //unique person Ids
        Set <Id> personIds = new Set<Id>();
        for (People_Tracing__c trace : newPeopleTraces) {
            personIds.add(trace.Person_1__c);
            personIds.add(trace.Person_2__c);
        }

        // list of duplicate Ids
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        
        // map of id and set<Id>
        Map<Id, Set<Id>> mapOfExcisitngRecords = new Map<Id, Set<Id>>();

        // query existing records
        List<People_Tracing__c> existingRecords = [SELECT Id, Name, Person_1__c, Person_2__c FROM People_Tracing__c 
        WHERE Person_1__c IN : personIds OR Person_2__c IN : personIds];

        if(existingRecords != null && existingRecords.size()>0) {
            for (People_Tracing__c trace : existingRecords) {
                
                if(!mapOfExcisitngRecords.containsKey(trace.Person_1__c)){
                    mapOfExcisitngRecords.put(trace.Person_1__c, new Set<Id>());
                }
                
                mapOfExcisitngRecords.get(trace.Person_1__c).add(trace.Person_2__c);

                // again mapping for person_2__c
                if(!mapOfExcisitngRecords.containsKey(trace.Person_2__c)){
                    mapOfExcisitngRecords.put(trace.Person_2__c, new Set<Id>());
                }
                
                mapOfExcisitngRecords.get(trace.Person_2__c).add(trace.Person_1__c);
            }
        }

        for (People_Tracing__c trace : newPeopleTraces) {
            
            if(
                (mapOfExcisitngRecords.containsKey(trace.Person_1__c) && mapOfExcisitngRecords.get(trace.Person_1__c).contains(trace.Person_2__c))
              ||(mapOfExcisitngRecords.containsKey(trace.Person_2__c) && mapOfExcisitngRecords.get(trace.Person_2__c).contains(trace.Person_1__c))
                )
                {
                    duplicates.add(trace);
                }
        }

        return duplicates;
    }
}