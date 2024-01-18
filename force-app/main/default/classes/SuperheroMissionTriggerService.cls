/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public inherited sharing class SuperheroMissionTriggerService {
    
    public static void notifyGuildMembers(){
        List<String> emailsAddresses = new List<String>();
        Set<Id> guildsIds = new Set<Id>();

        for(Superhero_Mission__c mission : ((List<Superhero_Mission__c>)Trigger.new)){
            guildsIds.add(mission.Guild__c);
        }

        if(!guildsIds.isEmpty() && !Test.isRunningTest()){
            EmailMessagingBatch batchEmail = new EmailMessagingBatch(guildsIds);
            Database.executeBatch(batchEmail);
        }

    }
}