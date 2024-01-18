/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-18-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class AppTest {
    
    @testSetup static void setup() {
        Account testAcc = new Account(Name = 'TestAccountApp');
        insert testAcc;  

        // Create common test contacs
        List<Contact> testContacts = new List<Contact>();
        for(Integer i=0;i<2;i++) {
            testContacts.add(
                new Contact(
                    LastName = 'TestCon'+i,
                    AccountId = testAcc.Id,
                    Email = 'testConEmail'+i+'@testApp.com'
                )
            );
        }
        insert testContacts;
        
        //Create GUILD
        Guild__c guild = new Guild__c(Name = 'TestGuild', Vision__c = 'Testision');
        insert guild;
        
        //Create HEROES
        List<Hero__c> heroes = new List<Hero__c>();
        for(Contact con : testContacts){
            heroes.add(new Hero__c(Name = 'HeroTest'+con.Name, Guild__c = guild.Id, Rank__c = 'D', Contact__c = con.Id));
        }

        insert heroes;

        //Crerae SuperMissions
        List<Superhero_Mission__c> missions = new List<Superhero_Mission__c>();
        missions.add(new Superhero_Mission__c(
            Guild__c = guild.Id, 
            Subject__c = 'Test1', 
            Is_Public__c = true,
            Deadline__c = System.now().Date(),
            Reward__c = 10000,
            Complexity_Rank__c = 'D'
        ));
        missions.add(new Superhero_Mission__c(
            Guild__c = guild.Id, 
            Subject__c = 'Test2', 
            Is_Public__c = false,
            Deadline__c = System.now().Date(),
            Reward__c = 20000,
            Complexity_Rank__c = 'C'
        ));
        insert missions;

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name ='Customer Community User' LIMIT 1];
        User user = new User(
                firstName='Test' + System.now().millisecond(),
                lastName = 'VGTESTAPPSA',
                Alias = 'VG' + System.now().millisecond(),
                Email='VG' + System.now().millisecond() + '@testapp.com',
                EmailEncodingKey='UTF-8',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = adminProfile.Id,
                TimeZoneSidKey='America/Los_Angeles',
                UserName='VG' + System.now().millisecond() + '@testapp.com',
                ContactId=testContacts[0].Id
        );

        insert user;
        

    }

    @isTest static void testGetAllMissions() {
        User us = [SELECT Id FROM User WHERE LastName = 'VGTESTAPPSA' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Hero_Admin'];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);
        System.runAs(us){
            String allMissionsStr = AllMissionsCtrl.getAllMissions();
            List<AllMissionsCtrl.AllMissionsData> data = (List<AllMissionsCtrl.AllMissionsData>)JSON.deserialize(allMissionsStr, List<AllMissionsCtrl.AllMissionsData>.class);
            Assert.areEqual(2, data.size());
        }
    }

    @isTest static void testGetMissionDetail() {
        User us = [SELECT Id FROM User WHERE LastName = 'VGTESTAPPSA' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Hero_Admin'];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);
        Superhero_Mission__c sm = [SELECT Id FROM Superhero_Mission__c WHERE Subject__c = 'Test2' LIMIT 1];
        System.runAs(us){
        Superhero_Mission__c mission = MissionDeailCtrl.getMissionDetail(sm.Id);
        Assert.areEqual(mission.Complexity_Rank__c, 'C');
        }
    }

    @isTest static void testWorkWithMission() {
        User us = [SELECT Id FROM User WHERE LastName = 'VGTESTAPPSA' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Hero_Admin'];
        insert new PermissionSetAssignment(AssigneeId = us.Id, PermissionSetId = ps.Id);
        Superhero_Mission__c sm = [SELECT Id FROM Superhero_Mission__c WHERE Subject__c = 'Test1' LIMIT 1];
        System.runAs(us){
        MissionDeailCtrl.acceptMission(sm.Id);
        Mission_Assignment__c ma = [SELECT Status__c FROM Mission_Assignment__c WHERE Mission__c = :sm.Id LIMIT 1];
        Assert.areEqual(ma.Status__c, 'In Progress');
        MissionDeailCtrl.completeMission(sm.Id);
        List<Mission_Assignment__c> mas = [SELECT Status__c FROM Mission_Assignment__c WHERE Mission__c = :sm.Id];
        Assert.areEqual(mas.size(), 1);
        Assert.areEqual(mas[0].Status__c, 'Completed');
        }
        
    }

    @isTest static void testEmailMessagingBatch() {
        Set<Id> guilds = new Set<Id>();
        for(Guild__c guild : [SELECT Id FROM Guild__c]){
            guilds.add(guild.Id);
        }
        Test.startTest();
            EmailMessagingBatch batchEmail = new EmailMessagingBatch(guilds);
            Database.executeBatch(batchEmail);
        Test.stopTest();

        Assert.areEqual(Database.countquery('SELECT COUNT() FROM Hero__c'), 2);  

    }
}