public with sharing class LeadAssignmentService implements Assignment {

    private Repository teamMemberRepository;

    public LeadAssignmentService() {
        this.teamMemberRepository = new TeamMemberRespository();
    }

    public List<Lead> process (List<SObject> records) {
        List<Lead> leads = getLeadsToProcess(records);
        Map<String, Lead> leadMap = buildLeadMappedByKey(leads);
        List<Team_Member__c> teamMembers = getAvailableTeamMembers(leadMap);
        List<Lead> processedLeads = assignLeadsToTeamMembers(leads, teamMembers);

        if(processedLeads != null && !processedLeads.isEmpty()) {
            return (List<SObject>) processedLeads;
        }
        return new List<Lead>();
    }

    private List<Team_Member__c> getAvailableTeamMembers(Map<String, Lead> leadMap) {
        return ((TeamMemberRespository)this.teamMemberRepository)
            .findByCommercialTeamKey(new List<String>(leadMap.keySet()));
    }

    private List<Lead> assignLeadsToTeamMembers(List<Lead> leads, List<Team_Member__c> teamMembers) {
        Map<Id, Team_Member__c> teamMemberMap = new Map<Id, Team_Member__c>();
        Map<String, List<Id>> keyToTeamMemberIds = new Map<String, List<Id>>();

        for (Team_Member__c tm : teamMembers) {
            teamMemberMap.put(tm.Id, tm);
            String key = tm.Commercial_Team__r.Key__c;
            if (!keyToTeamMemberIds.containsKey(key)) {
                keyToTeamMemberIds.put(key, new List<Id>());
            }
            keyToTeamMemberIds.get(key).add(tm.Id);
        }

        List<Team_Member__c> membersToUpdate = new List<Team_Member__c>();

        for (Lead l : leads) {
            String key = l.Product_Interest__c + '-' + l.Country_Code__c + '-' + l.Employee_Range__c;
            List<Id> possibleTms = keyToTeamMemberIds.get(key);
            if (possibleTms == null || possibleTms.isEmpty()) {
                continue;
            }

            Team_Member__c chosen = null;
            for (Id tmId : possibleTms) {
                Team_Member__c tm = teamMemberMap.get(tmId);
                if (chosen == null || tm.Counter__c < chosen.Counter__c) {
                    chosen = tm;
                }
            }

            if (chosen != null) {
                l.OwnerId = chosen.User__c;
                chosen.Counter__c += 1;
                if (!membersToUpdate.contains(chosen)) {
                    membersToUpdate.add(chosen);
                }
            }
        }

        if (!membersToUpdate.isEmpty()) {
            update membersToUpdate;
        }

        return leads;
    }

    private List<Lead> getLeadsToProcess(List<SObject> records) {
        List<Lead> leads = new List<Lead>();
        for (SObject record : records) {
            if (record instanceof Lead) {
                leads.add((Lead) record);
            }
        }
        return leads;
    }

    private Map<String, Lead> buildLeadMappedByKey(List<Lead> lead) {
        Map<String, Lead> leadMap = new Map<String, Lead>();
        for (Lead l : lead) {
            String key = l.Product_Interest__c + '-' + l.Country_Code__c + '-' + l.Employee_Range__c;
            leadMap.put(key, l);
        }
        return leadMap;
    }

}