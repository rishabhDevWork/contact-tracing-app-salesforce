public with sharing class CTPersonTabController {

    @AuraEnabled
    public static UserInformation getPersonDetails(String recordId){

        UserInformation info = new UserInformation();
        Person__c person = CTPersonController.getPersonId(recordId);

        if(person !=null ) {
            info.name = person.Name;
            info.token = person.Token__c;
            info.statusUpdatedOn = person.Status_Update_Date__c;
            info.phone = person.Mobile__c;
            info.status = person.Health_Status__c;
        }
       

        List<People_Tracing__c> traces = CTPeopleTracingContoller.getTraces(recordId);
        if(traces != null && traces.size() > 0){
            List<CloseContacts> closeContacts = new List<CloseContacts>();
            Set<Id> uniqueIds = new Set<Id>();
            uniqueIds.add(recordId);
    
            for(People_Tracing__c trace : traces){
            CloseContacts cc = new CloseContacts();
            if(!uniqueIds.contains(trace.Person_1__c)){
                    cc.id = trace.Person_1__c;
                    cc.status = trace.Person_1__r.Health_Status__c;
                    cc.token = trace.Person_1__r.Token__c;
                     cc.contactDate = trace.Contact_Date__c;
            }
            if(!uniqueIds.contains(trace.Person_2__c)){
                cc.id = trace.Person_2__c;
                cc.status = trace.Person_2__r.Health_Status__c;
                cc.token = trace.Person_2__r.Token__c;
                cc.contactDate = trace.Contact_Date__c;
            }
            closeContacts.add(cc);
          }
          info.contacts = closeContacts;
          info.contactCount = closeContacts.size();

        }
        return info;
    }

    public class UserInformation{
        @AuraEnabled public string name;
        @AuraEnabled public string token;
        @AuraEnabled public string phone;
        @AuraEnabled public string status;
        @AuraEnabled public Date statusUpdatedOn;
        @AuraEnabled public Integer contactCount = 0;
        @AuraEnabled public List<CloseContacts> contacts;
    }

    public class CloseContacts {
        @AuraEnabled public string id;
        @AuraEnabled public string token;
        @AuraEnabled public string status;
        @AuraEnabled public Date contactDate;

    }
}