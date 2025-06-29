# LeadAssignmentService Documentation

## Overview

The `LeadAssignmentService` Apex class is responsible for assigning Leads to Team Members based on business rules and balancing workload. It implements the `Assignment` interface and uses a repository pattern to fetch available Team Members.

## Main Method

### `process(List<SObject> records)`
- **Purpose:** Processes a list of Lead records, assigning each to an appropriate Team Member and updating their workload counter.
- **Logic Flow:**
  1. Filters the input list to only include Leads.
  2. Maps Leads by a composite key (Product Interest, Country Code, Employee Range).
  3. Fetches available Team Members for each key using the repository.
  4. Assigns each Lead to the Team Member with the lowest `Counter__c` in the relevant team.
  5. Updates the Team Member's `Counter__c` and the Lead's `OwnerId`.

## Helper Methods
- `getLeadsToProcess(...)`: Filters and returns only Lead records from the input.
- `buildLeadMappedByKey(...)`: Maps Leads by a composite key for assignment logic.
- `getAvailableTeamMembers(...)`: Fetches Team Members for the relevant Commercial Teams.
- `assignLeadsToTeamMembers(...)`: Core logic for assigning Leads and updating counters.

## Assignment Logic
- Each Lead is assigned to a Team Member in the matching Commercial Team with the lowest workload (`Counter__c`).
- Team Member counters are incremented after assignment.
- If no Team Member is available for a Lead, it is skipped.

## Notes
- Uses the `TeamMemberRespository` for data access.
- Assumes the existence of custom fields: `Product_Interest__c`, `Country_Code__c`, `Employee_Range__c` on Lead and `Counter__c`, `User__c`, `Commercial_Team__r.Key__c` on Team_Member__c.
- Designed for use in triggers or batch processes for automated Lead assignment.
