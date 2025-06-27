public with sharing class OpportunityAssignmentService implements Assignment {

    public List<SObject> process(List<SObject> records) {
        List<Opportunity> opportunities = getOpportunitiesToProcess(records);

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
}