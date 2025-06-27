@isTest
public with sharing class LeadAssignmentServiceTest {

    @testSetup
    static void setupUsers() {
        User user1Id = createTestUser('user1swile@test.com', 'User1');
        User user2Id = createTestUser('user2swile@test.com', 'User2');
        User user3Id = createTestUser('user3swile@test.com', 'User3');
        User user4Id = createTestUser('user4swile@test.com', 'User4');
        insert new List<User>{user1Id, user2Id, user3Id, user4Id};
    }

    private static User createTestUser(String email, String lastName) {
        User u = new User(
            Username = email,
            LastName = lastName,
            Email = email,
            Alias = lastName.length() > 4 ? lastName.substring(0, 4) : lastName,
            TimeZoneSidKey = 'America/Sao_Paulo',
            LocaleSidKey = 'pt_BR',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'pt_BR'
        );
        return u;
    }

    @isTest
    static void testLeadAssignmentProcess() {
        
        Id recordTypeId = Schema.SObjectType.CommercialTeam__c.getRecordTypeInfosByDeveloperName().get('France_Commercial_Team').getRecordTypeId();

        CommercialTeam__c team = new CommercialTeam__c(
            Name='Equipe Teste', 
            Country_Code__c='FR', 
            Employee_Range__c='101-500',
            Product_Interest__c='Gift',
            RecordTypeId=recordTypeId);
        insert team;

        List<User> users = [SELECT Id FROM User WHERE LastName IN ('User1', 'User2', 'User3', 'User4')];

        Team_Member__c tm1 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[0].Id);
        Team_Member__c tm2 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[1].Id);
        Team_Member__c tm3 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[2].Id);
        Team_Member__c tm4 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[3].Id);
        insert new List<Team_Member__c>{tm1, tm2, tm3, tm4};
        System.debug('Team Members inserted: ' + [SELECT Id, User__c FROM Team_Member__c WHERE Commercial_Team__c = :team.Id]);
        // Gerar o mês atual no formato yyyy/MM
        Date today = Date.today();
        String year = String.valueOf(today.year());
        String month = String.valueOf(today.month());
        if (month.length() == 1) {
            month = '0' + month;
        }
        String currentMonth = year + '/' + month;

        Deals_Counter__c dc1 = new Deals_Counter__c(Team_Member__c=tm1.Id, Count__c=0, Month__c=currentMonth);
        Deals_Counter__c dc2 = new Deals_Counter__c(Team_Member__c=tm2.Id, Count__c=0, Month__c=currentMonth);
        Deals_Counter__c dc3 = new Deals_Counter__c(Team_Member__c=tm3.Id, Count__c=0, Month__c=currentMonth);
        Deals_Counter__c dc4 = new Deals_Counter__c(Team_Member__c=tm4.Id, Count__c=0, Month__c=currentMonth);
        insert new List<Deals_Counter__c>{dc1, dc2, dc3, dc4};
        System.debug('Counters inserted: ' + [SELECT Id, Month__c, Key__c FROM Deals_Counter__c WHERE Team_Member__c IN :new List<Id>{tm1.Id, tm2.Id, tm3.Id, tm4.Id}]);
        Lead lead1 = new Lead(
            LastName = 'Teste1',
            Company = 'Empresa1',
            Product_Interest__c = 'Gift',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );
        Lead lead2 = new Lead(
            LastName = 'Teste2',
            Company = 'Empresa2',
            Product_Interest__c = 'Gift',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );
        Lead lead3 = new Lead(
            LastName = 'Teste3',
            Company = 'Empresa3',
            Product_Interest__c = 'Gift',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );
        Lead lead4 = new Lead(
            LastName = 'Teste4',
            Company = 'Empresa4',
            Product_Interest__c = 'Gift',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );
        

        List<SObject> records = new List<SObject>{lead1, lead2, lead3, lead4};
        Test.startTest();
        insert new List<Lead>{lead1, lead2, lead3, lead4};
        Test.stopTest();

        // Verifica se cada Lead foi atribuído a um usuário diferente
        List<Lead> updatedLeads = [SELECT Id, OwnerId FROM Lead WHERE Id IN :new List<Id>{lead1.Id, lead2.Id, lead3.Id, lead4.Id}];
        Set<Id> ownerIds = new Set<Id>();
        for (Lead l : updatedLeads) {
            ownerIds.add(l.OwnerId);
        }
        System.assertEquals(4, ownerIds.size(), 'Every Lead should be assigned to a different user');

        // Verifica se os OwnerIds são exatamente os usuários criados
        Set<Id> expectedOwners = new Set<Id>{users[0].Id, users[1].Id, users[2].Id, users[3].Id};
        System.assertEquals(expectedOwners, ownerIds, 'Owner should be the users created in setup');

        // Verifica se os counters dos Deals_Counter__c foram incrementados corretamente
        List<Deals_Counter__c> counters = [SELECT Id, Count__c FROM Deals_Counter__c WHERE Team_Member__c IN :new List<Id>{tm1.Id, tm2.Id, tm3.Id, tm4.Id}];
        for (Deals_Counter__c dc : counters) {
            System.assertEquals(1, dc.Count__c, 'Every Counter should be incremented by 1');
        }
    }
}