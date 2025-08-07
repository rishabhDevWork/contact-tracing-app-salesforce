public with sharing class CTLocationTracingController {
    
    /**
     * Get last 30 days visitors
     * @param locationId
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getVisitors(String LocationId){

        return [SELECT Id, Person__c, Location__c, Visit_Date__c , Person__r.Token__c, Person__r.Health_Status__c FROM Location_Tracing__c 
                WHERE Id = :LocationId ORDER BY Visit_Date__c DESC NULLS LAST];
    }

    /**
     * Get all location ids for visitors
     * @param personIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationByPersonIds(Set<Id> personIds){

        return [SELECT Id, Person__c, Location__c FROM Location_Tracing__c 
                WHERE Person__c IN :personIds AND Visit_Date__c = LAST_N_DAYS:10];
    }

    /**
     * Get all visitor ids for locations
     * @param locationIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationByLocationIds(Set<Id> LocationIds){

        return [SELECT Id, Person__c, Location__c, Person__r.Health_Status__c FROM Location_Tracing__c 
                WHERE Location__c IN :LocationIds AND Person__r.Health_Status__c = 'Green' AND Visit_Date__c = LAST_N_DAYS:10];
    }

    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){

        // add unique location Ids
        Set<Id> locationIds = new Set<Id>();
        // add unique person ids
        Set<Id> personIds = new Set<Id>();

        for (Location_Tracing__c traces : newLocationTraces) {
            locationIds.add(traces.Location__c);
            personIds.add(traces.Person__c);
        }

        // map of location id and person ids in that location
        Map<Id, Set<Id>> mapOfExcisitngRecords = new Map<Id, Set<Id>>();

        // query existing tracing records for above
        List<Location_Tracing__c> currentRecords = [SELECT Id, Person__c, Location__c FROM Location_Tracing__c 
                                                    WHERE Person__c IN :personIds 
                                                    AND Location__c in : locationIds];

        if(currentRecords != null && currentRecords.size() >0){

            for (Location_Tracing__c trace : currentRecords) {
                // check if map already has the location id key
                if(!mapOfExcisitngRecords.containsKey(trace.Location__c)) {
                    //if map does not has the location id key
                    // add the new item in them map using locatuion id as key
                    //and blank Set<Id> as value
                    mapOfExcisitngRecords.put(trace.Location__c, new Set<Id>());
                }

                //get map item for locationId 
                Set<Id> personId = mapOfExcisitngRecords.get(trace.Location__c);
                // add person Id to it
                personId.add(trace.Person__c);
                // overwrite the map
                mapOfExcisitngRecords.put(trace.Location__c, personId);

                //mapOfExcisitngRecords.get(trace.Location__c).add(trace.Person__c);

            }
        }
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();

        for (Location_Tracing__c trace : newLocationTraces) {

            if(mapOfExcisitngRecords.containsKey(trace.Location__c) && mapOfExcisitngRecords.get(trace.Location__c).contains(trace.Person__c)){
            
                duplicates.add(trace);

            }
            
        }
        return duplicates;

    }
    

    
}