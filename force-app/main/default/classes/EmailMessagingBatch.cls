/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EmailMessagingBatch implements Database.Batchable<sObject>{
    
    public Set<Id> guildIds;

    public EmailMessagingBatch(Set<Id> guilds){
        guildIds = guilds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Contact__c, Contact__r.Email FROM Hero__c WHERE Guild__c IN :guildIds';
        return Database.getQueryLocator(query);
     }
  
     public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<String> emailsAddresses = new List<String>();
        for(Sobject s : scope){
            emailsAddresses.add(((Hero__c)s).Contact__r.Email);
        } 

        if(!emailsAddresses.isEmpty()){
            EmailMessagingService.sendEmails(emailsAddresses, 'Mission Created, please check new advvetures', 'Mission Created');
        }
     }
  
     public void finish(Database.BatchableContext BC){
  
     }

}