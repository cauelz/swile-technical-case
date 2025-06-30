@isTest
public with sharing class OpportunityAssignmentServiceTest {

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
    static void shouldDistributeOpportunitiesEquallyAmongTeamMembers_WhenProcessingOpportunities() {
        Id recordTypeId = Schema.SObjectType.CommercialTeam__c.getRecordTypeInfosByDeveloperName().get('France_Commercial_Team').getRecordTypeId();
        CommercialTeam__c team = new CommercialTeam__c(
            Name='Equipe Teste', 
            Country_Code__c='FR', 
            Employee_Range__c='101-500',
            Product_Interest__c='Gift',
            RecordTypeId=recordTypeId);
        insert team;
        List<User> users = [SELECT Id FROM User WHERE LastName IN ('User1', 'User2', 'User3', 'User4')];
        Team_Member__c tm1 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[0].Id, Counter__c=0);
        Team_Member__c tm2 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[1].Id, Counter__c=0);
        Team_Member__c tm3 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[2].Id, Counter__c=0);
        Team_Member__c tm4 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[3].Id, Counter__c=0);
        insert new List<Team_Member__c>{tm1, tm2, tm3, tm4};

        Account account = new Account(
            Name = 'Test Account',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );
        insert account;

        Opportunity opp1 = new Opportunity(
            Name = 'Opp1',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = account.Id
        );

        Opportunity opp2 = new Opportunity(
            Name = 'Opp2',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = account.Id
        );

        Opportunity opp3 = new Opportunity(
            Name = 'Opp3',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = account.Id
        );
        
        Opportunity opp4 = new Opportunity(
            Name = 'Opp4',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = account.Id
        );

        List<SObject> records = new List<SObject>{opp1, opp2, opp3, opp4};

        Test.startTest();
        insert new List<Opportunity>{opp1, opp2, opp3, opp4};
        Test.stopTest();

        List<Opportunity> updatedOpps = [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :new List<Id>{opp1.Id, opp2.Id, opp3.Id, opp4.Id}];
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity o : updatedOpps) {
            ownerIds.add(o.OwnerId);
        }
        System.assertEquals(4, ownerIds.size(), 'Every Opportunity should be assigned to a different user');
        Set<Id> expectedOwners = new Set<Id>{users[0].Id, users[1].Id, users[2].Id, users[3].Id};
        System.assertEquals(expectedOwners, ownerIds, 'Owner should be the users created in setup');
    }

    @isTest
    static void shouldIgnoreOpportunitiesWithoutAvailableTeamMember() {
        Id recordTypeId = Schema.SObjectType.CommercialTeam__c.getRecordTypeInfosByDeveloperName().get('France_Commercial_Team').getRecordTypeId();
        CommercialTeam__c team = new CommercialTeam__c(
            Name='Equipe Teste', 
            Country_Code__c='FR', 
            Employee_Range__c='101-500',
            Product_Interest__c='Gift',
            RecordTypeId=recordTypeId);
        insert team;
        List<User> users = [SELECT Id FROM User WHERE LastName IN ('User1')];
        Team_Member__c tm1 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[0].Id, Counter__c=0);
        insert tm1;
        Account accountFR = new Account(
            Name = 'Test Account FR',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );
        insert accountFR;
        Account accountBR = new Account(
            Name = 'Test Account BR',
            Country_Code__c = 'BR',
            Employee_Range__c = '101-500'
        );
        insert accountBR;
        Opportunity opp1 = new Opportunity(
            Name = 'Opp1',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = accountFR.Id
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Opp2',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = accountBR.Id
        );

        List<SObject> records = new List<SObject>{opp1, opp2};

        Test.startTest();
        insert records;
        Test.stopTest();

        Opportunity updatedOpp1 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp1.Id];
        Opportunity updatedOpp2 = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :opp2.Id];

        System.assertEquals(users[0].Id, updatedOpp1.OwnerId, 'Opp1 should be assigned');
        System.assertEquals(UserInfo.getUserId(), updatedOpp2.OwnerId, 'Opp2 should keep the original owner');
    }

    @isTest
    static void shouldAssignAllOpportunitiesToSingleTeamMember_WhenOnlyOneAvailable() {
        Id recordTypeId = Schema.SObjectType.CommercialTeam__c.getRecordTypeInfosByDeveloperName().get('France_Commercial_Team').getRecordTypeId();
        CommercialTeam__c team = new CommercialTeam__c(
            Name='Equipe Única', 
            Country_Code__c='FR', 
            Employee_Range__c='101-500',
            Product_Interest__c='Gift',
            RecordTypeId=recordTypeId);
        insert team;

        List<User> users = [SELECT Id FROM User WHERE LastName = 'User1'];
        Team_Member__c tm1 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[0].Id, Counter__c=0);
        insert tm1;

        Account account = new Account(
            Name = 'Test Account',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );
        insert account;

        Opportunity opp1 = new Opportunity(
            Name = 'Opp1',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = account.Id
        );
        Opportunity opp2 = new Opportunity(
            Name = 'Opp2',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Product_Interest__c = 'Gift',
            AccountId = account.Id
        );
        List<SObject> records = new List<SObject>{opp1, opp2};

        Test.startTest();
        insert new List<Opportunity>{opp1, opp2};
        Test.stopTest();

        List<Opportunity> updatedOpps = [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :new List<Id>{opp1.Id, opp2.Id}];
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity o : updatedOpps) {
            ownerIds.add(o.OwnerId);
        }
        System.assertEquals(1, ownerIds.size(), 'Both Opportunities should be assigned to the same user');
        Team_Member__c updatedTm = [SELECT Id, Counter__c FROM Team_Member__c WHERE Id = :tm1.Id];
        System.assertEquals(2, updatedTm.Counter__c, 'Counter for Team Member should be 2');
    }
}