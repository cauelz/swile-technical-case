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
    static void shouldDistributeLeadsEquallyAmongTeamMembers_WhenProcessingLeads() {
        
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

        // Verifica se os contadores dos Team Members foram incrementados corretamente
        List<Team_Member__c> updatedTeamMembers = [SELECT Id, Counter__c FROM Team_Member__c WHERE Id IN :new List<Id>{tm1.Id, tm2.Id, tm3.Id, tm4.Id}];
        System.assertEquals(1, updatedTeamMembers[0].Counter__c, 'Counter for Team Member 1 should be 1');
        System.assertEquals(1, updatedTeamMembers[1].Counter__c, 'Counter for Team Member 2 should be 1');
        System.assertEquals(1, updatedTeamMembers[2].Counter__c, 'Counter for Team Member 3 should be 1');
        System.assertEquals(1, updatedTeamMembers[3].Counter__c, 'Counter for Team Member 4 should be 1');
    }

    @isTest
    static void shouldIgnoreLeadsWithoutAvailableTeamMember() {
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
            Country_Code__c = 'BR',
            Employee_Range__c = '101-500'
        );
        
        List<SObject> records = new List<SObject>{lead1, lead2};

        Test.startTest();

        insert records;

        Test.stopTest();

        User user1 = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1];
        Lead updatedLead1 = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead1.Id];
        Lead updatedLead2 = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead2.Id];

        System.assertEquals(user1.Id, updatedLead1.OwnerId, 'Lead1 should be assigned');
        System.assertNotEquals(user1.Id, updatedLead2.OwnerId, 'Lead2 should keep the original owner');
    }

    @isTest
    static void shouldAssignAllLeadsToSingleTeamMember_WhenOnlyOneAvailable() {
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
        List<SObject> records = new List<SObject>{lead1, lead2};
        Test.startTest();
        insert new List<Lead>{lead1, lead2};
        Test.stopTest();
        // Ambos os Leads devem ser atribuídos ao mesmo usuário
        List<Lead> updatedLeads = [SELECT Id, OwnerId FROM Lead WHERE Id IN :new List<Id>{lead1.Id, lead2.Id}];
        Set<Id> ownerIds = new Set<Id>();
        for (Lead l : updatedLeads) {
            ownerIds.add(l.OwnerId);
        }
        System.assertEquals(1, ownerIds.size(), 'Both Leads should be assigned to the same user');
        // O contador do Team Member deve ser 2
        Team_Member__c updatedTm = [SELECT Id, Counter__c FROM Team_Member__c WHERE Id = :tm1.Id];
        System.assertEquals(2, updatedTm.Counter__c, 'Counter for Team Member should be 2');
    }

    @isTest
    static void shouldNotAssignLead_WhenOnlyTeamMemberIsOnAbsence() {
        Id recordTypeId = Schema.SObjectType.CommercialTeam__c.getRecordTypeInfosByDeveloperName().get('France_Commercial_Team').getRecordTypeId();
        CommercialTeam__c team = new CommercialTeam__c(
            Name='Equipe Férias', 
            Country_Code__c='FR', 
            Employee_Range__c='101-500',
            Product_Interest__c='Gift',
            RecordTypeId=recordTypeId);
        insert team;
        
        List<User> users = [SELECT Id FROM User WHERE LastName = 'User1'];
        Team_Member__c tm1 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=users[0].Id, Counter__c=0);
        insert tm1;

        Absence__c absence = new Absence__c(
            Team_Member__c = tm1.Id,
            Start_Date__c = System.today().addDays(-1),
            End_Date__c = System.today().addDays(1),
            Is_Returned__c = false
        );
        insert absence;

        Lead lead1 = new Lead(
            LastName = 'Teste1',
            Company = 'Empresa1',
            Product_Interest__c = 'Gift',
            Country_Code__c = 'FR',
            Employee_Range__c = '101-500'
        );

        Test.startTest();
        insert lead1;
        Test.stopTest();

        Lead updatedLead = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead1.Id];
        User user1 = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1];
        System.assertNotEquals(user1.Id, updatedLead.OwnerId, 'Lead should not be assigned if the only Team Member is on absence');
    }
}