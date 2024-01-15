/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger MissionAssignmentTrigger on Mission_Assignment__c (after update) {

    MissionAssignmentTriggerHandler.handle();
}