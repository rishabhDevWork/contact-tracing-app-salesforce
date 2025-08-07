public with sharing class CTPersonViewController {

    @AuraEnabled
    public static void UpdateHealthStatusToRed(String personId) {
        
        Person__c person = new Person__c(Id=personId, Health_Status__c='Red');
        update person;      
    }
}