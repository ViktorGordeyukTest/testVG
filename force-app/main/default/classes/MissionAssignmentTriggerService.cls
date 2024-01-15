/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public inherited sharing class MissionAssignmentTriggerService {
    
    public static void handleMissionAssignments(){

        Set<Id> missionIds = new Set<Id>();
        Set<Id> missionAssignmentIds = new Set<Id>();
        List<Mission_Assignment__c> misionAssignmentsFailed = new List<Mission_Assignment__c>();

        for(Mission_Assignment__c mAssignment : ((List<Mission_Assignment__c>)Trigger.new)){
            if(Trigger.oldMap.get(mAssignment.Id) != null && 
                ((Mission_Assignment__c)Trigger.oldMap.get(mAssignment.Id)).Status__c != mAssignment.Status__c &&
                mAssignment.Status__c.equalsIgnoreCase('Completed'))
            {
                missionIds.add(mAssignment.Mission__c);
                missionAssignmentIds.add(mAssignment.Id);
            }
        }

        if(!missionIds.isEmpty()){
            for(Mission_Assignment__c mAssignmentItem : [
                SELECT Id, Status__c 
                FROM Mission_Assignment__c 
                WHERE Mission__c IN :missionIds AND Id NOT IN :missionAssignmentIds
            ]){
                mAssignmentItem.Status__c = 'Failed';
                misionAssignmentsFailed.add(mAssignmentItem);
            }
        }

        if(!misionAssignmentsFailed.isEmpty()){
            update misionAssignmentsFailed;
        }
    }

    public static void notifyMissionOwner(){

        List<String> emailsAddresses = new List<String>();
        Set<Id> missionIds = new Set<Id>();

        for(Mission_Assignment__c mAssignment : ((List<Mission_Assignment__c>)Trigger.new)){
            if(Trigger.oldMap.get(mAssignment.Id) != null && 
                ((Mission_Assignment__c)Trigger.oldMap.get(mAssignment.Id)).Status__c != mAssignment.Status__c &&
                mAssignment.Status__c.equalsIgnoreCase('Completed'))
            {
                missionIds.add(mAssignment.Mission__c);
            }
        }

        for(Superhero_Mission__c mission : [SELECT OwnerId, Owner.Email FROM Superhero_Mission__c WHERE Id IN :missionIds]){
            emailsAddresses.add(mission.Owner.Email);
        }

        EmailMessagingService.sendEmails(emailsAddresses, 'Mission Completed', 'COMPLETED');

    }
}