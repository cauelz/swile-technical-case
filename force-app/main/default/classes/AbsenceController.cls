public with sharing class AbsenceController {

    @AuraEnabled(cacheable=true)
    public static List<Absence__c> getTeamAbsences(Id teamId) {
        return [
            SELECT Id, Name, Start_Date__c, End_Date__c, Is_Returned__c, Team_Member__c, 
                   Team_Member__r.Name
            FROM Absence__c
            WHERE Team_Member__r.Commercial_Team__c = :teamId
            ORDER BY Start_Date__c DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Absence__c> getAllAbsences() {
        return [
            SELECT Id, Name, Start_Date__c, End_Date__c, Is_Returned__c, Team_Member__c, 
                   Team_Member__r.Name
            FROM Absence__c
            ORDER BY Start_Date__c DESC
        ];
    }

    @AuraEnabled
    public static Absence__c upsertAbsence(Absence__c abs) {
        upsert abs;
        return abs;
    }

    @AuraEnabled
    public static void deleteAbsence(Id absenceId) {
        delete [SELECT Id FROM Absence__c WHERE Id = :absenceId];
    }
}