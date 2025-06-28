public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        new AssignmentService(Trigger.new).processAssignments();
    }
}