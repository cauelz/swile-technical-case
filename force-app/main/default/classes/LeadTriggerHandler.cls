public with sharing class LeadTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        new AssignmentService(Trigger.new).processAssignments();
    }
}