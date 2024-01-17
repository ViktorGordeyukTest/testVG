/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-17-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public inherited sharing class MissionAssignmentTriggerHandler {
    
    public static void handle(){
        if(Trigger.IsAfter){
            if(Trigger.IsUpdate){
                MissionAssignmentTriggerService.handleMissionAssignments();
            }
        }
    }
}