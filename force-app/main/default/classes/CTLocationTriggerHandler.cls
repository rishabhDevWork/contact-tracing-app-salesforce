public with sharing class CTLocationTriggerHandler {
    public static void beforInsert(List<Location__c> locations){
        for(Location__c loc: locations){
            loc.Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Location__c> locations, Map<Id, Location__c> locationMap){
        for(Location__c loc : locations){
            if(locationMap.get(loc.Id).Status__c != loc.Status__c){
                loc.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> locations, Map<Id, Location__c> locationMap){
        Set<Id> redStatusLoc = new Set<Id>();
        for(Location__c loc : locations){
            if(locationMap.get(loc.Id).Status__c != 'Red' && loc.Status__c == 'Red'){
                redStatusLoc.add(loc.Id);
          }
        }
        Set<Id> persons = new Set<Id>();
        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByLocationIds(redStatusLoc);
        for (Location_Tracing__c loc : locationTraces) {
           persons.add(loc.Person__c); 
        }
        List<Person__c> peopleToUpdate = new List<Person__c>();
        for(Id pid : persons){
            peopleToUpdate.add(new Person__c(Id=pid, Health_Status__c='Yellow'));
        }
        if(peopleToUpdate.size()>0){
            update peopleToUpdate;
        }
    }
}