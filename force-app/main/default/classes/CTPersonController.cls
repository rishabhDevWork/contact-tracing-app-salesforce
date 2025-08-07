public with sharing class CTPersonController {

    public static String getToken(String mobile){

        Blob targetBlob = Blob.valueOf(mobile);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        String hashString = EncodingUtil.base64Encode(hash);

        return hashString;
    }

    public static List<Person__c> getRecentHealthChanges(){
                        
        return [SELECT Id,Name, Mobile__c, Token__c, Health_Status__c, Status_Update_Date__c 
                FROM Person__c Order BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    public static List<Person__c> searchPeople(String searchTerm){

        searchTerm = searchTerm + '%';

        return [SELECT Id,Name, Mobile__c, Token__c, Health_Status__c, Status_Update_Date__c 
                FROM Person__c 
                where Name LIKE :searchTerm 
                OR Mobile__c LIKE :searchTerm
                OR Token__c  LIKE :searchTerm
                Order BY Status_Update_Date__c DESC NULLS LAST LIMIT 100];
    }

    public static Person__c getPersonId(String personId) {

        List<Person__c> people = [SELECT Id,Name, Mobile__c, Token__c, Health_Status__c, Status_Update_Date__c 
        FROM Person__c where Id = : personId];

        if(people != null && people.size() >0){
            return people[0];
        } else {
            return null;
        }
    }

    public static Map<String,Integer> getHealthStatusCount(){
        AggregateResult[] result = [SELECT Health_Status__c, Count(Id) FROM Person__c Group By Health_Status__c];

        if(result != null && result.size() > 0){
            Map<String, Integer> personMap = new Map<String, Integer>();
            for(AggregateResult ar : result) {

                personMap.put(String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('expr0')));
            }
            return personMap;
        }
        return null;
        
    }

    public static Set<Id> getCohabitants(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatus = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> pt = [SELECT Id, Person_2__c, Person_1__c 
                                      FROM People_Tracing__c where (Person_1__c IN : personIds OR Person_2__c IN : personIds) 
                                      AND Contact_Type__c = 'Cohabitant'
                                      AND (Person_1__r.Health_Status__c IN : healthStatus OR Person_2__r.Health_Status__c IN : healthStatus )];
        Set<Id> cohabitants = new Set<Id>();
        for(People_Tracing__c peopleRec: pt){
            if(!alreadyProcessed.contains(peopleRec.Person_1__c)){
                cohabitants.add(peopleRec.Person_1__c);
                alreadyProcessed.add(peopleRec.Person_1__c);
            }
            if(!alreadyProcessed.contains(peopleRec.Person_2__c)){
                cohabitants.add(peopleRec.Person_2__c);
                alreadyProcessed.add(peopleRec.Person_2__c);
            }
        }
        return cohabitants;
    }

    public static Set<Id> getNeighbours(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<People_Tracing__c> pt = [SELECT Id, Person_2__c, Person_1__c 
                                      FROM People_Tracing__c where (Person_1__c IN : personIds OR Person_2__c IN : personIds) 
                                      AND Contact_Type__c = 'Neighbour'
                                      AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green' )];
        Set<Id> neighbours = new Set<Id>();
        for(People_Tracing__c peopleRec: pt){
            if(!alreadyProcessed.contains(peopleRec.Person_1__c)){
                neighbours.add(peopleRec.Person_1__c);
                alreadyProcessed.add(peopleRec.Person_1__c);
            }
            if(!alreadyProcessed.contains(peopleRec.Person_2__c)){
                neighbours.add(peopleRec.Person_2__c);
                alreadyProcessed.add(peopleRec.Person_2__c);
            }
        }
        return neighbours;
    }

    public static Set<Id> getPrimaryContacts(Set<Id> personIds, Set<Id> alreadyProcessed){
        List<String> healthStatus = new List<String>{'Green', 'Yellow'};
        List<People_Tracing__c> pt = [SELECT Id, Person_2__c, Person_1__c 
                                      FROM People_Tracing__c where (Person_1__c IN : personIds OR Person_2__c IN : personIds) 
                                      AND Contact_Type__c = 'Other'
                                      AND (Person_1__r.Health_Status__c IN : healthStatus OR Person_2__r.Health_Status__c IN : healthStatus )
                                      AND People_Tracing__c.Contact_Date__c = LAST_N_DAYS:10];
        Set<Id> primaryContacts = new Set<Id>();
        for(People_Tracing__c peopleRec: pt){
            if(!alreadyProcessed.contains(peopleRec.Person_1__c)){
                primaryContacts.add(peopleRec.Person_1__c);
                alreadyProcessed.add(peopleRec.Person_1__c);
            }
            if(!alreadyProcessed.contains(peopleRec.Person_2__c)){
                primaryContacts.add(peopleRec.Person_2__c);
                alreadyProcessed.add(peopleRec.Person_2__c);
            }
        }
        return primaryContacts;
    }

    public static Set<Id> getSecondaryContacts(Set<Id> primaryContactIds, Set<Id> alreadyProcessed){
        List<People_Tracing__c> pt = [SELECT Id, Person_2__c, Person_1__c 
                                      FROM People_Tracing__c where (Person_1__c IN : primaryContactIds OR Person_2__c IN : primaryContactIds) 
                                      AND Contact_Type__c = 'Other'
                                      AND People_Tracing__c.Contact_Date__c = LAST_N_DAYS:10
                                      AND (Person_1__r.Health_Status__c = 'Green' OR Person_2__r.Health_Status__c = 'Green')];
        Set<Id> secondaryContacts = new Set<Id>();
        for(People_Tracing__c peopleRec: pt){
            if(!alreadyProcessed.contains(peopleRec.Person_1__c)){
                secondaryContacts.add(peopleRec.Person_1__c);
                alreadyProcessed.add(peopleRec.Person_1__c);
            }
            if(!primaryContactIds.contains(peopleRec.Person_2__c)){
                secondaryContacts.add(peopleRec.Person_2__c);
                alreadyProcessed.add(peopleRec.Person_2__c);
            }
        }
        return secondaryContacts;
    }


}