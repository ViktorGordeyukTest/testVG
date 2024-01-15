/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AllMissionsCtrl {

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
    public static String getAllMissions(){

        Set<Id> missionIds = new Set<Id>();
        List<AllMissionsData> data = new List<AllMissionsData>();

        List<Superhero_Mission__c> missions = [
            SELECT Id, Complexity_Rank__c, Guild__r.Name, Guild__c, Is_Public__c, Subject__c, OwnerId, 
                (SELECT Id, Status__c FROM Mission_Assignments__r) 
            FROM Superhero_Mission__c
            WHERE Guild__c =: HERO.Guild__c OR Is_Public__c = true
            ORDER BY CreatedDate DESC
        ];

        for(Superhero_Mission__c mission : missions){
            String status = '';
            for(Mission_Assignment__c missionAssignment : mission.Mission_Assignments__r){
                if(missionAssignment.Status__c == 'Completed'){
                    status = 'Completed';
                    break;
                } else {
                    status = missionAssignment.Status__c;
                } 
            }
            if(String.isBlank(status)){
                status = 'Available';
            }

            data.add(new AllMissionsData(mission, status, HERO.Rank__c));

        } 

        return JSON.serialize(data);
    }


    public class AllMissionsData {
        @AuraEnabled
        public String Id {get; set;} 
        @AuraEnabled
        public String missionSubject {get; set;} 
        @AuraEnabled
        public String missionGuildName {get; set;} 
        @AuraEnabled
        public String missionRank {get; set;} 
        @AuraEnabled
        public String heroRank {get; set;} 
        @AuraEnabled
        public String missionStatus {get; set;} 
        @AuraEnabled
        public String cssClass {get; set;} 
        @AuraEnabled
        public Boolean isOwner {get; set;} 

        public AllMissionsData(Superhero_Mission__c mission, String status, String rank){
            this.Id = mission.Id;
            this.missionSubject = mission.Subject__c;
            this.missionGuildName = mission.Guild__r.Name;
            this.missionRank = mission.Complexity_Rank__c;
            this.heroRank = rank;
            this.missionStatus = status;
            if( UserInfo.getUserId() == mission.OwnerId){
                this.isOwner = true;
            } else {
                this.isOwner = false;
            }
            if(status.equalsIgnoreCase('Completed')){
                this.cssClass = 'slds-truncate statusClassCompleted';
            } else if(status.equalsIgnoreCase('In Progress')){
                this.cssClass = 'slds-truncate statusClassInProgress';
            } else if(status.equalsIgnoreCase('Available')){
                this.cssClass = 'slds-truncate statusClassAvailable';
            }
        }
       
    }
    
}