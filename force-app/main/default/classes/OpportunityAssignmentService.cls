public with sharing class OpportunityAssignmentService implements Assignment {

    private Repository teamMemberRepository;

    public OpportunityAssignmentService() {
        this.teamMemberRepository = new TeamMemberRespository();
    }

    public List<SObject> process(List<SObject> records) {
        List<Opportunity> opportunities = getOpportunitiesToProcess(records);
        Map<String, Opportunity> opportunityMap = buildOpportunityMappedByKey(opportunities);
        List<Team_Member__c> teamMembers = getAvailableTeamMembers(opportunityMap);
        List<Opportunity> processedOpportunities = assignOpportunitiesToTeamMembers(opportunities, teamMembers);

        return (List<SObject>) opportunities;
    }

    private List<Opportunity> getOpportunitiesToProcess(List<SObject> records) {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (SObject record : records) {
            if (record instanceof Opportunity) {
                opportunities.add((Opportunity) record);
            }
        }
        return opportunities;
    }

    private Map<String, Opportunity> buildOpportunityMappedByKey(List<Opportunity> opportunities) {
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
        for (Opportunity opp : opportunities) {
            String key = opp.Product_Interest__c + '-' + opp.Country_Code__c + '-' + opp.Employee_Range__c;
            opportunityMap.put(key, opp);
        }
        return opportunityMap;
    }

    private List<Team_Member__c> getAvailableTeamMembers(Map<String, Opportunity> opportunityMap) {
        return ((TeamMemberRespository)this.teamMemberRepository)
            .findByCommercialTeamKey(new List<String>(opportunityMap.keySet()));
    }

    private List<Opportunity> assignOpportunitiesToTeamMembers(List<Opportunity> opportunities, List<Team_Member__c> teamMembers) {
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

        for (Opportunity opp : opportunities) {
            String key = opp.Product_Interest__c + '-' + opp.Country_Code__c + '-' + opp.Employee_Range__c;
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
                opp.OwnerId = chosen.User__c;
                chosen.Counter__c += 1;
                if (!membersToUpdate.contains(chosen)) {
                    membersToUpdate.add(chosen);
                }
            }
        }

        if (!membersToUpdate.isEmpty()) {
            update membersToUpdate;
        }

        return opportunities;
    }
}