public with sharing class TeamMemberRespository implements Repository {

    public SObject findById(String Id) {
        Team_Member__c result = [
            SELECT Id, Commercial_Team__c
            FROM Team_Member__c
            WHERE Id = :Id
        ];
        return (SObject) result;
    }

    // Método utilitário extra, não faz parte da interface
    public List<Team_Member__c> findByCommercialTeamKey(List<String> key) {
        return [
            SELECT Id, Commercial_Team__c, User__c, Commercial_Team__r.Key__c
            FROM Team_Member__c
            WHERE Commercial_Team__r.Key__c IN :key
            AND Id NOT IN (SELECT Team_Member__c 
                                FROM Absence__c 
                                WHERE
                                    Start_Date__c <= :System.today() 
                                    AND End_Date__c >= :System.today()
                                    AND Is_Returned__c = false
                            )
        ];
    }

    public void insertRecords(List<SObject> records) {
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        for (SObject s : records) {
            if (s instanceof Team_Member__c) {
                teamMembers.add((Team_Member__c)s);
            }
        }
        if (!teamMembers.isEmpty()) {
            insert teamMembers;
        }
    }

    public void updateRecords(List<SObject> records) {
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        for (SObject s : records) {
            if (s instanceof Team_Member__c) {
                teamMembers.add((Team_Member__c)s);
            }
        }
        if (!teamMembers.isEmpty()) {
            update teamMembers;
        }
    }

    public void deleteRecords(List<SObject> records) {
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        for (SObject s : records) {
            if (s instanceof Team_Member__c) {
                teamMembers.add((Team_Member__c)s);
            }
        }
        if (!teamMembers.isEmpty()) {
            delete teamMembers;
        }
    }

    public void upsertRecords(List<SObject> records) {
        List<Team_Member__c> teamMembers = new List<Team_Member__c>();
        for (SObject s : records) {
            if (s instanceof Team_Member__c) {
                teamMembers.add((Team_Member__c)s);
            }
        }
        if (!teamMembers.isEmpty()) {
            upsert teamMembers;
        }
    }
}