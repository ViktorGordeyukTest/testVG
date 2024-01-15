/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MissionDeailCtrl {

    public static final Hero__c HERO {
        get{
            if(HERO == null){
                User currentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
                if(currentUser.ContactId == null){
                    return new HERO__c(Rank__c = 'A', Guild__c = 'a00Wy000003TvFiIAK', Contact__c = '003Wy000000YRsDIAW');
                }
                HERO = [SELECT Id, Rank__c, Guild__c, Contact__c FROM Hero__c WHERE Contact__c =: currentUser.ContactId LIMIT 1];
            }
            return HERO;
        }
        set{}
    }
    
    @AuraEnabled
    public static Superhero_Mission__c getMissionDetail(String Id){

        return [
            SELECT Id, Subject__c, Reward__c, Guild__c, Guild__r.Name, Details__c, Deadline__c, Complexity_Rank__c, OwnerId, Is_Public__c, 
                (SELECT Id, Status__c FROM Mission_Assignments__r WHERE Hero__c =: HERO.Id) 
            FROM Superhero_Mission__c
            WHERE Id =: Id
        ];
        
    }

    @AuraEnabled
    public static void acceptMission(String Id){

        if(getMissionCount() >= 3){
            throw new AuraHandledException('Too many missions. You can\'t get more than 3 mission');
        }

        Mission_Assignment__c mAssignment = new Mission_Assignment__c();
        mAssignment.Hero__c = HERO.Id;
        mAssignment.Mission__c = Id;
        mAssignment.Status__c = 'In Progress';

        insert mAssignment;

    }   
    
    @AuraEnabled
    public static void completeMission(String Id){

        Mission_Assignment__c mAssignment = [
            SELECT Id, Status__c 
            FROM Mission_Assignment__c 
            WHERE Hero__c =: HERO.Id
                AND Mission__c =: Id
        ];

        mAssignment.Status__c = 'Completed';

        update mAssignment;
    }  

    public static Integer getMissionCount(){
        return [SELECT Count() FROM Mission_Assignment__c WHERE Hero__c =: HERO.Id AND Status__c != 'Completed'];
    }
}