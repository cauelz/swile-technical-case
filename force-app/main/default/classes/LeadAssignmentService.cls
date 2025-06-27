public with sharing class LeadAssignmentService implements Assignment {

    private Repository teamMemberRepository;
    private Repository dealsCounterRepository;

    public LeadAssignmentService() {
        this.teamMemberRepository = new TeamMemberRespository();
        this.dealsCounterRepository = new DealCounterRepository();
        
    }

    public List<Lead> process (List<SObject> records) {
        List<Lead> leads = getLeadsToProcess(records);
        Map<String, Lead> leadMap = buildLeadMappedByKey(leads);
        List<Team_Member__c> teamMembers = getAvailableTeamMembers(leadMap);
        List<Deals_Counter__c> dealsCounters = getDealsCounters(teamMembers);
        System.debug('Deals Counters: ' + dealsCounters);
        List<TeamMemberCounter> teamMemberCounters = buildTeamMemberCounters(teamMembers, dealsCounters);
        System.debug('teamMemberCounters: ' + teamMemberCounters);
        List<Lead> processedLeads = assignLeadsToTeamMembers(leads, teamMembers, teamMemberCounters);
        System.debug('Processed Leads: ' + processedLeads);
        if(processedLeads != null && !processedLeads.isEmpty()) {
            return (List<SObject>) processedLeads;
        }
        return new List<Lead>();
    }

    private List<Team_Member__c> getAvailableTeamMembers(Map<String, Lead> leadMap) {
        return ((TeamMemberRespository)this.teamMemberRepository)
            .findByCommercialTeamKey(new List<String>(leadMap.keySet()));
    }

    private List<Deals_Counter__c> getDealsCounters(List<Team_Member__c> teamMembers) {
        List<String> dealsCounterKeys = buildDealsCountKeysFromTeamMembers(teamMembers);
        System.debug('Team Members: ' + teamMembers);
        System.debug('Deals Counter Keys: ' + dealsCounterKeys);
        return ((DealCounterRepository)this.dealsCounterRepository).findByKey(dealsCounterKeys);
    }

    private List<Lead> assignLeadsToTeamMembers(List<Lead> leads, List<Team_Member__c> teamMembers, List<TeamMemberCounter> teamMemberCounters) {
        Map<Id, TeamMemberCounter> tmCounterMap = new Map<Id, TeamMemberCounter>();
        for (TeamMemberCounter tmc : teamMemberCounters) {
            tmCounterMap.put(tmc.teamMemberId, tmc);
        }
        Map<String, List<Id>> keyToTeamMemberIds = new Map<String, List<Id>>();
        for (Team_Member__c tm : teamMembers) {
            String key = tm.Commercial_Team__r.Key__c;
            if (!keyToTeamMemberIds.containsKey(key)) {
                keyToTeamMemberIds.put(key, new List<Id>());
            }
            keyToTeamMemberIds.get(key).add(tm.Id);
        }
        List<Deals_Counter__c> countersToUpdate = new List<Deals_Counter__c>();
        for (Lead l : leads) {
            String key = l.Product_Interest__c + '-' + l.Country_Code__c + '-' + l.Employee_Range__c;
            List<Id> possibleTms = keyToTeamMemberIds.get(key);
            if (possibleTms == null || possibleTms.isEmpty()) {
                continue;
            }
            TeamMemberCounter chosen = null;
            for (Id tmId : possibleTms) {
                TeamMemberCounter tmc = tmCounterMap.get(tmId);
                if (chosen == null || tmc.counter < chosen.counter) {
                    chosen = tmc;
                }
            }
            if (chosen != null) {
                l.OwnerId = chosen.userId;
                chosen.counter += 1;
                // Atualiza Deals_Counter__c
                countersToUpdate.add(new Deals_Counter__c(Id=chosen.dealCounter, Count__c=chosen.counter));
            }
        }

        if (!countersToUpdate.isEmpty()) {
            update countersToUpdate;
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

    private List<String> buildDealsCountKeysFromTeamMembers(List<Team_Member__c> teamMembers) {
        List<String> keys = new List<String>();
        Date today = Date.today();
        String year = String.valueOf(today.year());
        String month = String.valueOf(today.month());

        if (month.length() == 1) {
            month = '0' + month;
        }

        String currentMonth = year + '/' + month;
        
        for (Team_Member__c tm : teamMembers) {
            keys.add(tm.Id + '-' + currentMonth);
        }
        return keys;
    }

    private List<TeamMemberCounter> buildTeamMemberCounters(List<Team_Member__c> teamMembers, List<Deals_Counter__c> dealsCounters) {
        Map<Id, Deals_Counter__c> teamMemberIdToCounter = new Map<Id, Deals_Counter__c>();
        for (Deals_Counter__c dc : dealsCounters) {
           
            teamMemberIdToCounter.put(dc.Team_Member__c, dc);
        }
        List<TeamMemberCounter> teamMemberCounters = new List<TeamMemberCounter>();
        for (Team_Member__c tm : teamMembers) {
            if (!teamMemberIdToCounter.containsKey(tm.Id)) {
                continue; // Skip if no counter found for the team member
            }
            System.debug('Team Member: ' + tm.Id + ', User: ' + tm.User__c);
            Deals_Counter__c counter = teamMemberIdToCounter.get(tm.Id);
            teamMemberCounters.add(new TeamMemberCounter(tm.Id, counter.Id, tm.User__c, counter.Count__c));
        }
        return teamMemberCounters;
    }

    public class TeamMemberCounter {
        public Id teamMemberId;
        public Id dealCounter;
        public Id userId;
        public Decimal counter;

        public TeamMemberCounter(Id teamMemberId, Id dealCounter, Id userId, Decimal counter) {
            this.teamMemberId = teamMemberId;
            this.dealCounter = dealCounter;
            this.userId = userId;
            this.counter = counter;
        }
    }
}