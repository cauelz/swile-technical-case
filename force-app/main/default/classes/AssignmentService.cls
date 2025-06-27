public with sharing class AssignmentService {

    private Assignment service;
    private List<SObject> records;

    public AssignmentService(List<SObject> records ) {

        if(records == null && records.isEmpty()) {
            throw new IllegalArgumentException('Records list cannot be null or empty');
        }

        if (records[0] instanceof Lead) {
            this.service = new LeadAssignmentService();
        } else if (records[0] instanceof Opportunity) {
            this.service = new OpportunityAssignmentService();
        } else {
            throw new IllegalArgumentException('Unsupported record type: ' + records[0].getSObjectType());
        }

        this.records = records;

    }

    public void processAssignments() {
        List<SObject> recordsToUpdate = this.service.process(this.records);
        update recordsToUpdate;
    }
}