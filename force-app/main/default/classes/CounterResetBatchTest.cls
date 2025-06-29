@isTest
public with sharing class CounterResetBatchTest {
    @testSetup
    static void setupData() {
        // Cria usuários de teste
        User u1 = new User(
            Username = 'user1swile@test.com',
            LastName = 'User1',
            Email = 'user1swile@test.com',
            Alias = 'user1',
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'pt_BR'
        );
        insert u1;

        Id recordTypeId = Schema.SObjectType.CommercialTeam__c.getRecordTypeInfosByDeveloperName().get('France_Commercial_Team').getRecordTypeId();

        CommercialTeam__c team = new CommercialTeam__c(
            Name = 'Equipe Teste',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500',
            Product_Interest__c = 'Gift',
            RecordTypeId = recordTypeId
        );
        insert team;

        // Cria Team Members com contadores diferentes
        Team_Member__c tm1 = new Team_Member__c(User__c = u1.Id, Counter__c = 5, Commercial_Team__c = team.Id);
        Team_Member__c tm2 = new Team_Member__c(User__c = u1.Id, Counter__c = 0, Commercial_Team__c = team.Id);
        insert new List<Team_Member__c>{tm1, tm2};
    }

    @isTest
    static void testBatchResetsNonZeroCounters() {
        List<Team_Member__c> before = [SELECT Id, Counter__c FROM Team_Member__c];

        System.assertEquals(5, before[0].Counter__c, 'Initial counter should be 5');
        System.assertEquals(0, before[1].Counter__c, 'Initial counter should be 0');

        Test.startTest();
        CounterResetBatch batch = new CounterResetBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Team_Member__c> after = [SELECT Id, Counter__c FROM Team_Member__c ORDER BY Id];
        System.assertEquals(0, after[0].Counter__c, 'Counter should be reset to 0');
        System.assertEquals(0, after[1].Counter__c, 'Counter was already 0 and should remain 0');
    }

    @isTest
    static void testBatchWithNoNonZeroCounters() {
        // Zera todos os contadores
        List<Team_Member__c> tms = [SELECT Id FROM Team_Member__c];
        for (Team_Member__c tm : tms) {
            tm.Counter__c = 0;
        }
        update tms;
        Test.startTest();
        CounterResetBatch batch = new CounterResetBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        List<Team_Member__c> after = [SELECT Id, Counter__c FROM Team_Member__c];
        for (Team_Member__c tm : after) {
            System.assertEquals(0, tm.Counter__c, 'Counter should remain 0');
        }
    }
}