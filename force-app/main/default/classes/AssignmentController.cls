public with sharing class AssignmentController {

    public class AssignmentRequest {
        @InvocableVariable(required=true)
        public List<SObject> records;
    }

    public class AssignmentResult {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Reassign Records' description='Reassign Leads or Opportunities using AssignmentService')
    public static List<AssignmentResult> reassignRecords(List<AssignmentRequest> requests) {
        List<AssignmentResult> results = new List<AssignmentResult>();
        // Aggregate all records from all requests into a single list
        List<SObject> allRecords = new List<SObject>();
        for (AssignmentRequest req : requests) {
            if (req != null && req.records != null) {
                allRecords.addAll(req.records);
            }
        }
        AssignmentResult res = new AssignmentResult();
        try {
            AssignmentService service = new AssignmentService(allRecords);
            service.processAssignments();
            res.success = true;
            res.message = 'Reassignment completed.';
        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }
        results.add(res);
        return results;
    }
}