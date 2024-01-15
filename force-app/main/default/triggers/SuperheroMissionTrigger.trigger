/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger SuperheroMissionTrigger on Superhero_Mission__c (after insert) {
    SuperheroMissionTriggerHandleer.handle();
}