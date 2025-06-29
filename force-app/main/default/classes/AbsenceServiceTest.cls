@isTest
public with sharing class AbsenceServiceTest {

    @testSetup
    static void setupData() {
        // Create test users
        User u1 = createTestUser('user1swile@test.com', 'User1');
        User u2 = createTestUser('user2swile@test.com', 'User2');
        insert new List<User>{u1, u2};

        // Create Commercial Team
        CommercialTeam__c team = new CommercialTeam__c(Name='Equipe Teste');
        insert team;

        // Create Team Members
        Team_Member__c tm1 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=u1.Id, Counter__c=1);
        Team_Member__c tm2 = new Team_Member__c(Commercial_Team__c=team.Id, User__c=u2.Id, Counter__c=5);
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
    static void shouldUpdateReturnedTeamMemberWithHighestCounter() {
        // Arrange
        Team_Member__c returnedTM = [SELECT Id, Commercial_Team__c, Counter__c FROM Team_Member__c LIMIT 1];
        Team_Member__c highestTM = [SELECT Id, Counter__c, Commercial_Team__c FROM Team_Member__c WHERE Id != :returnedTM.Id LIMIT 1];
        Absence__c oldAbs = new Absence__c(
            Team_Member__c=returnedTM.Id, 
            Start_Date__c=Date.today(),
            End_Date__c=Date.today().addDays(1),
            Is_Returned__c=false
        );
        insert oldAbs;
        
        Absence__c newAbs = new Absence__c(
            Id = oldAbs.Id,
            Team_Member__c=returnedTM.Id,
            Is_Returned__c=true
        );

        Test.startTest();
        update newAbs;
        Test.stopTest();

        Team_Member__c updatedTM = [SELECT Id, Counter__c FROM Team_Member__c WHERE Id = :returnedTM.Id];
        System.assertEquals(highestTM.Counter__c, updatedTM.Counter__c, 'Returned Team Member should have Counter__c updated to highest');
    }

    @isTest
    static void shouldNotUpdateIfReturnedTeamMemberAlreadyHasHighestCounter() {
        // Arrange
        Team_Member__c highestTM = [SELECT Id, Commercial_Team__c, Counter__c FROM Team_Member__c ORDER BY Counter__c DESC LIMIT 1];
        Absence__c oldAbs = new Absence__c(
            Team_Member__c=highestTM.Id,
            Start_Date__c=Date.today(),
            End_Date__c=Date.today().addDays(1),
            Is_Returned__c=false
        );
        insert oldAbs;

        Absence__c newAbs = new Absence__c(
            Id = oldAbs.Id,
            Team_Member__c=highestTM.Id,
            Is_Returned__c=true
        );

        Test.startTest();
        update newAbs;
        Test.stopTest();

        Team_Member__c updatedTM = [SELECT Id, Counter__c FROM Team_Member__c WHERE Id = :highestTM.Id];
        System.assertEquals(highestTM.Counter__c, updatedTM.Counter__c, 'Counter__c should remain unchanged if already highest');
    }
}