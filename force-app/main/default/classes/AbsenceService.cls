public with sharing class AbsenceService {
    
    public void processReturnedFromAbsence(List<Absence__c> absences, Map<Id, Absence__c> oldMap) {
        List<Id> returnedTeamMemberIds = getReturnedTeamMemberIds(absences, oldMap);
        if (returnedTeamMemberIds.isEmpty()) {
            return;
        }

        Map<Id, Team_Member__c> returnedTeamMembers = getReturnedTeamMembers(returnedTeamMemberIds);
        Set<Id> commercialTeamIds = getCommercialTeamIds(returnedTeamMembers);
        if (commercialTeamIds.isEmpty()) {
            return;
        }

        List<Team_Member__c> allTeamMembers = getAllTeamMembersByCommercialTeams(commercialTeamIds);

        Map<Id, Team_Member__c> highestCounterByTeam = getHighestCounterByTeam(allTeamMembers);
        
        List<Team_Member__c> teamMemberToUpdate = prepareReturnedTeamMemberUpdates(returnedTeamMembers, highestCounterByTeam);

        update teamMemberToUpdate;
    }

    private List<Id> getReturnedTeamMemberIds(List<Absence__c> absences, Map<Id, Absence__c> oldMap) {
        List<Id> ids = new List<Id>();
        for (Absence__c absence : absences) {
            Absence__c oldAbsence = oldMap.get(absence.Id);
            if (oldAbsence != null && oldAbsence.Is_Returned__c == false && absence.Is_Returned__c == true) {
                if (absence.Team_Member__c != null) {
                    ids.add(absence.Team_Member__c);
                }
            }
        }
        return ids;
    }

    private Map<Id, Team_Member__c> getReturnedTeamMembers(List<Id> ids) {
        Map<Id, Team_Member__c> result = new Map<Id, Team_Member__c>();
        for (Team_Member__c tm : [SELECT Id, Commercial_Team__c FROM Team_Member__c WHERE Id IN :ids]) {
            result.put(tm.Id, tm);
        }
        return result;
    }

    private Set<Id> getCommercialTeamIds(Map<Id, Team_Member__c> teamMembers) {
        Set<Id> ids = new Set<Id>();
        for (Team_Member__c tm : teamMembers.values()) {
            if (tm.Commercial_Team__c != null) {
                ids.add(tm.Commercial_Team__c);
            }
        }
        return ids;
    }

    private List<Team_Member__c> getAllTeamMembersByCommercialTeams(Set<Id> commercialTeamIds) {
        return [SELECT Id, Commercial_Team__c, Counter__c FROM Team_Member__c WHERE Commercial_Team__c IN :commercialTeamIds];
    }

    private Map<Id, Team_Member__c> getHighestCounterByTeam(List<Team_Member__c> allTeamMembers) {
        Map<Id, Team_Member__c> highest = new Map<Id, Team_Member__c>();
        for (Team_Member__c tm : allTeamMembers) {
            if (!highest.containsKey(tm.Commercial_Team__c) ||
                (tm.Counter__c != null && (highest.get(tm.Commercial_Team__c).Counter__c == null || tm.Counter__c > highest.get(tm.Commercial_Team__c).Counter__c))) {
                highest.put(tm.Commercial_Team__c, tm);
            }
        }
        return highest;
    }

    private List<Team_Member__c> prepareReturnedTeamMemberUpdates(Map<Id, Team_Member__c> returnedTeamMembers, Map<Id, Team_Member__c> highestCounterByTeam) {
        List<Team_Member__c> updates = new List<Team_Member__c>();
        for (Team_Member__c returnedTM : returnedTeamMembers.values()) {
            Team_Member__c highestTM = highestCounterByTeam.get(returnedTM.Commercial_Team__c);
            if (highestTM != null && returnedTM.Id != highestTM.Id) {
                returnedTM.Counter__c = highestTM.Counter__c;
                updates.add(returnedTM);
            }
        }
        return updates;
    }
}