public with sharing class CTLocationController {
    
    public static List<Location__c> getRecentStatusChanges() {

        return [SELECT Id, Address__c, Name, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c Order By Status_Update_Date__c desc NULLS LAST LIMIT 100];
    }

    public static List<Location__c> searchLocations(String searchTerm) {

        searchTerm = searchTerm + '%';

        return [SELECT Id, Address__c, Name, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                FROM Location__c where Name LIKE :searchTerm
                OR Pincode__c LIKE : searchTerm
                OR Address__c LIKE : searchTerm Order By Status_Update_Date__c desc NULLS LAST LIMIT 100];
    }

    public static Location__c getLocationById(String LocationId) {

        List<Location__c> location = [SELECT Id, Address__c, Name, Pincode__c, Red_Score__c, Status_Update_Date__c, Status__c 
                                         FROM Location__c WHERE Id = : LocationId];

            if(location != null && location.size() >0) {

                return location[0];
            } else {
                return null;
            }
    }

    public static Map<String,Integer> getStatusCount(){
        AggregateResult[] result = [SELECT Status__c, Count(Id) FROM Location__c Group By Status__c]; 
        
        if(result != null && result.size() > 0){
            Map<String, Integer> locationMap = new Map<String, Integer>();
            for(AggregateResult ar : result) {

                locationMap.put(String.valueOf(ar.get('Status__c')), Integer.valueOf(ar.get('expr0')));
            }
    
            return locationMap;
        }
        return null;
       
    }

    public static void updateLocationRedScore(Set<Id> locationIds){
        List<Location__c> locationToUpdate = new List<Location__c>();
        AggregateResult[] redPeoplePerLocation = [SELECT Location__c, COUNT(Id) total FROM Location_Tracing__c
            WHERE Location__c IN : locationIds
            AND Person__r.Health_Status__c = 'Red'
            AND Visit_Date__c = LAST_N_DAYS : 10
            GROUP BY Location__c];

            for(AggregateResult ar : redPeoplePerLocation){
                String locationId = String.valueOf(ar.get('Location__c'));
                Integer redScore = Integer.valueOf(ar.get('total'));
                String status = getStatus(redScore);
                locationToUpdate.add(new Location__c(Id= locationId, Red_Score__c = redScore, Status__c = status));
            }
            if(locationToUpdate != null && locationToUpdate.size() > 0){
                update locationToUpdate;
            }
    }

    public static string getStatus(Integer redScore){
        if(redScore == 0){
            return 'Green';
        } else if(redScore <= 5){
            return 'Yellow';
        } else if (redScore <= 10){
            return 'Orange';
        } else {
            return 'Red';
        }
    }

}