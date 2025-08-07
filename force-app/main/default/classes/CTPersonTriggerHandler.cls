public with sharing class CTPersonTriggerHandler {
    public static void beforeInsert(List<Person__c> persons){
        for(Person__c person: persons) {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    public static void beforeUpdate(List<Person__c> persons, Map<Id,Person__c> personMap){
        for(Person__c person: persons){
            if(personMap.get(person.Id).Health_Status__c != person.Health_Status__c) {
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Person__c> persons, Map<Id,Person__c> personMap){
        Set<Id> statusChange = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();

        for(Person__c person : persons){

            if(personMap.get(person.Id).Health_Status__c != person.Health_Status__c) {
                statusChange.add(person.Id);

            }
            if(personMap.get(person.Id).Health_Status__c != 'Red' && person.Health_Status__c == 'Red') {
                redStatus.add(person.Id);
            }
        }

        Set<Id> alreadyProcessed = new Set<Id>();
        alreadyProcessed.addAll(redStatus);

        Set<Id> yellowStatus = new Set<Id>();
        Set<Id> orangeStatus = new Set<Id>();

        List<Person__c> personToUpdate = new List<Person__c>();

        //Get all the cohabitamts for person with redStatus
        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, alreadyProcessed));
        //Get all primary contacts for a person with red status
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, alreadyProcessed);
        orangeStatus.addAll(primaryContacts);
        //Get all neighbours for person with red status
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, alreadyProcessed));
        //Get all secondary contacts for a person with red status.(Using primary contacts for sec contacts)
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, alreadyProcessed));

        for(Id pid : orangeStatus){
            personToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Orange'));
        }
        for(Id pid : yellowStatus){
            personToUpdate.add(new Person__c(Id = pid, Health_Status__c = 'Yellow'));
        }
        
        if(personToUpdate.size() > 0){
            update personToUpdate;
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationByPersonIds(statusChange);
        if(locationTraces.size() > 0) {
            Set<Id> locationIds = new Set<Id>();
            for (Location_Tracing__c trace : locationTraces) {
                locationIds.add(trace.Location__c);
            }

            CTLocationController.updateLocationRedScore(locationIds);
        }

    }
}