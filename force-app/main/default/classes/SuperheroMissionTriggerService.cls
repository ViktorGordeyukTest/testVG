/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public inherited sharing class SuperheroMissionTriggerService {
    
    public static void notifyGuildMembes(){
        List<String> emailsAddresses = new List<String>();
        Set<Id> guildsIds = new Set<Id>();

        for(Superhero_Mission__c mission : ((List<Superhero_Mission__c>)Trigger.new)){
            guildsIds.add(mission.Guild__c);
        }

        for(Hero__c hero : [SELECT Contact__c, Contact__r.Email FROM Hero__c WHERE Guild__c IN :guildsIds]){
            emailsAddresses.add(hero.Contact__r.Email);
        }

        EmailMessagingService.sendEmails(emailsAddresses, 'Mission Created, please check new advvetures', 'Mission Created');

    }
}