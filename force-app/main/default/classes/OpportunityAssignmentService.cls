public with sharing class OpportunityAssignmentService implements Assignment {

    private Repository teamMemberRepository;
    private Repository accountRepository;

    public OpportunityAssignmentService() {
        this.teamMemberRepository = new TeamMemberRespository();
        this.accountRepository = new AccountRepository();
    }

    public List<SObject> process(List<SObject> records) {
        List<Opportunity> opportunities = getOpportunitiesToProcess(records);
        List<String> accountIds = extractAccountIdsFromOpportunities(opportunities);
        List<SObject> accounts = ((AccountRepository)this.accountRepository).findByIds(accountIds);
        System.debug('Accounts: ' + accounts);
        Map<Id, Account> accountMap = buildAccountMap(accounts);
        Map<String, Opportunity> opportunityMap = buildOpportunityMappedByKey(opportunities, accountMap);
        List<String> employeeRanges = extractEmployeeRangesFromAccounts(accountMap);
        List<String> countryCodes = extractCountryCodesFromAccounts(accountMap);
        List<String> productInterests = extractProductInterestsFromOpportunities(opportunities);
        System.debug('Employee Ranges: ' + employeeRanges);
        System.debug('Country Codes: ' + countryCodes);
        System.debug('Product Interests: ' + productInterests);
        if(employeeRanges.isEmpty() || countryCodes.isEmpty() || productInterests.isEmpty()) {
            return new List<SObject>();
        }
        
        List<Team_Member__c> teamMembers = getAvailableTeamMembers(employeeRanges, countryCodes, productInterests);
        System.debug('Team Members: ' + teamMembers);
        List<Opportunity> processedOpportunities = assignOpportunitiesToTeamMembers(opportunities, teamMembers, accountMap);
        return (List<SObject>) opportunities;
    }

    private Map<Id, Account> buildAccountMap(List<SObject> accounts) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (SObject s : accounts) {
            if (s instanceof Account) {
                Account acc = (Account) s;
                accountMap.put(acc.Id, acc);
            }
        }
        return accountMap;
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

    private Map<String, Opportunity> buildOpportunityMappedByKey(List<Opportunity> opportunities, Map<Id, Account> accountMap) {
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
        for (Opportunity opp : opportunities) {
            Account acc = accountMap.get(opp.AccountId);
            String employeeRange = acc != null ? acc.Employee_Range__c : null;
            String countryCode = acc != null ? acc.Country_Code__c : null;
            String key = opp.Product_Interest__c + '-' + countryCode + '-' + employeeRange;
            opportunityMap.put(key, opp);
        }
        return opportunityMap;
    }

    private List<Team_Member__c> getAvailableTeamMembers(
        List<String> employeeRanges, 
        List<String> countryCodes,
        List<String> productInterests
    ) {
        return ((TeamMemberRespository)this.teamMemberRepository)
            .findByCommercialTeamKey(employeeRanges, countryCodes, productInterests);
    }

    private List<String> extractAccountIdsFromOpportunities(List<Opportunity> opportunities) {
        Set<String> accountIds = new Set<String>();
        for (Opportunity opp : opportunities) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        return new List<String>(accountIds);
    }

    private List<String> extractEmployeeRangesFromAccounts(Map<Id, Account> accountMap) {
        Set<String> employeeRanges = new Set<String>();
        for (Account acc : accountMap.values()) {
            if (acc.Employee_Range__c != null) {
                employeeRanges.add(acc.Employee_Range__c);
            }
        }
        return new List<String>(employeeRanges);
    }

    private List<String> extractCountryCodesFromAccounts(Map<Id, Account> accountMap) {
        Set<String> countryCodes = new Set<String>();
        for (Account acc : accountMap.values()) {
            if (acc.Country_Code__c != null) {
                countryCodes.add(acc.Country_Code__c);
            }
        }
        return new List<String>(countryCodes);
    }

    private List<String> extractProductInterestsFromOpportunities(List<Opportunity> opportunities) {
        Set<String> productInterests = new Set<String>();
        for (Opportunity opp : opportunities) {
            if (opp.Product_Interest__c != null) {
                productInterests.add(opp.Product_Interest__c);
            }
        }
        return new List<String>(productInterests);
    }

    private List<Opportunity> assignOpportunitiesToTeamMembers(
        List<Opportunity> opportunities, 
        List<Team_Member__c> teamMembers,
        Map<Id, Account> accountMap
    ) {
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

            Account acc = accountMap.get(opp.AccountId);
            String employeeRange = acc != null ? acc.Employee_Range__c : null;
            String countryCode = acc != null ? acc.Country_Code__c : null;

            if (employeeRange == null || countryCode == null) {
                continue;
            }

            String key = opp.Product_Interest__c + '-' + countryCode + '-' + employeeRange;
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