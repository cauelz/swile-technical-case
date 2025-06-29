# OpportunityAssignmentService Documentation

## Overview

The `OpportunityAssignmentService` Apex class automates the assignment of Opportunity records to Team Members, balancing workload and ensuring fair distribution. It implements the `Assignment` interface and uses a repository pattern for Team Member retrieval.

## Main Method

### `process(List<SObject> records)`
- **Purpose:** Processes a list of Opportunity records, assigning each to an appropriate Team Member and updating their workload counter.
- **Logic Flow:**
  1. Filters the input list to only include Opportunities.
  2. Maps Opportunities by a composite key (Product Interest, Country Code, Employee Range).
  3. Fetches available Team Members for each key using the repository.
  4. Assigns each Opportunity to the Team Member with the lowest `Counter__c` in the relevant team.
  5. Updates the Team Member's `Counter__c` and the Opportunity's `OwnerId`.

## Helper Methods
- `getOpportunitiesToProcess(...)`: Filters and returns only Opportunity records from the input.
- `buildOpportunityMappedByKey(...)`: Maps Opportunities by a composite key for assignment logic.
- `getAvailableTeamMembers(...)`: Fetches Team Members for the relevant Commercial Teams.
- `assignOpportunitiesToTeamMembers(...)`: Core logic for assigning Opportunities and updating counters.

## Assignment Logic
- Each Opportunity is assigned to a Team Member in the matching Commercial Team with the lowest workload (`Counter__c`).
- Team Member counters are incremented after assignment.
- If no Team Member is available for an Opportunity, it is skipped.

## Notes
- Uses the `TeamMemberRespository` for data access.
- Assumes the existence of custom fields: `Product_Interest__c`, `Country_Code__c`, `Employee_Range__c` on Opportunity and `Counter__c`, `User__c`, `Commercial_Team__r.Key__c` on Team_Member__c.
- Designed for use in triggers or batch processes for automated Opportunity assignment.
