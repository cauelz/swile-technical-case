@isTest
public with sharing class AbsenceControllerTest {
    @testSetup
    static void setupData() {
        // Cria usuários de teste
        User u1 = createTestUser('user1swile@test.com', 'User1');
        User u2 = createTestUser('user2swile@test.com', 'User2');
        insert new List<User>{u1, u2};

        // Cria Commercial Team
        CommercialTeam__c team = new CommercialTeam__c(Name='Equipe Teste');
        insert team;

        // Cria Team Members
        Team_Member__c tm1 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=u1.Id, Counter__c=1);
        Team_Member__c tm2 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=u2.Id, Counter__c=2);
        insert new List<Team_Member__c>{tm1, tm2};
    }

    private static User createTestUser(String email, String lastName) {
        return new User(
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
    }

    @isTest
    static void testGetTeamAbsences() {
        CommercialTeam__c team = [SELECT Id FROM CommercialTeam__c LIMIT 1];
        Team_Member__c tm = [SELECT Id FROM Team_Member__c WHERE Commercial_Team__c = :team.Id LIMIT 1];
        Absence__c abs = new Absence__c(
            Team_Member__c = tm.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(2),
            Is_Returned__c = false
        );
        insert abs;
        Test.startTest();
        List<Absence__c> absences = AbsenceController.getTeamAbsences(team.Id);
        Test.stopTest();
        System.assert(!absences.isEmpty(), 'Should return absences for the team');
    }

    @isTest
    static void testGetAllAbsences() {
        List<Absence__c> absences = AbsenceController.getAllAbsences();
        System.assert(absences != null, 'Deve retornar uma lista (mesmo que vazia)');
    }

    @isTest
    static void testUpsertAndDeleteAbsence() {
        Team_Member__c tm = [SELECT Id FROM Team_Member__c LIMIT 1];
        Absence__c abs = new Absence__c(
            Team_Member__c = tm.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1),
            Is_Returned__c = false
        );
        Absence__c upserted = AbsenceController.upsertAbsence(abs);
        System.assert(upserted.Id != null, 'Absence should be inserted');
        AbsenceController.deleteAbsence(upserted.Id);
        Absence__c deleted = [SELECT Id, isDeleted FROM Absence__c WHERE Id = :upserted.Id LIMIT 1 ALL ROWS];
        System.assert(deleted.IsDeleted == TRUE, 'Absence should be deleted');
    }
}