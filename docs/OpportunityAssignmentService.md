# OpportunityAssignmentService

## Purpose

The `OpportunityAssignmentService` Apex class automates the assignment of Opportunity records to Team Members, ensuring balanced workload distribution according to business rules. It implements the `Assignment` interface and leverages the repository pattern for data access.

## Algorithm

**Round Robin with Least-Loaded Assignment:**  
Each Opportunity is assigned to the Team Member (within the matching Commercial Team) who currently has the lowest workload, as measured by the `Counter__c` field. This ensures fair and balanced distribution of Opportunities among available Team Members.

## Core Functionality

### `process(List<SObject> records)`
- **Description:**  
  Processes a list of records, filters for Opportunities, enriches them with Account data, and assigns each Opportunity to the most suitable Team Member based on workload and matching criteria.
- **Workflow:**
  1. **Filter Opportunities:** Extracts Opportunity records from the input list.
  2. **Account Enrichment:** Fetches related Account records for each Opportunity and uses Account fields (`Employee_Range__c`, `Country_Code__c`) in the assignment logic.
  3. **Key Mapping:** Maps Opportunities using a composite key: `Product_Interest__c` (from Opportunity), `Country_Code__c` and `Employee_Range__c` (from Account).
  4. **Fetch Team Members:** Retrieves available Team Members for each key using the repository.
  5. **Assignment:** Assigns each Opportunity to the Team Member with the lowest `Counter__c` (workload) in the relevant Commercial Team.
  6. **Update Records:** Increments the assigned Team Member’s `Counter__c` and updates the Opportunity’s `OwnerId`.
  7. **Return Value:** Returns the original list of Opportunities (as `List<SObject>`), regardless of assignment success.

## Helper Methods

- **`getOpportunitiesToProcess(records)`**  
  Filters and returns only Opportunity records from the input list.

- **`extractAccountIdsFromOpportunities(opportunities)`**  
  Extracts unique Account IDs from the Opportunity records.

- **`buildAccountMap(accounts)`**  
  Builds a map of Account IDs to Account records for quick lookup.

- **`buildOpportunityMappedByKey(opportunities, accountMap)`**  
  Maps Opportunities by a composite key using Opportunity and Account fields for assignment logic.

- **`extractEmployeeRangesFromAccounts(accountMap)`**  
  Extracts unique Employee Ranges from Account records.

- **`extractCountryCodesFromAccounts(accountMap)`**  
  Extracts unique Country Codes from Account records.

- **`extractProductInterestsFromOpportunities(opportunities)`**  
  Extracts unique Product Interests from Opportunity records.

- **`getAvailableTeamMembers(employeeRanges, countryCodes, productInterests)`**  
  Fetches Team Members matching the relevant Commercial Team criteria.

- **`assignOpportunitiesToTeamMembers(opportunities, teamMembers, accountMap)`**  
  Assigns Opportunities to Team Members, updates counters, and returns the processed Opportunities.

## Assignment Rules

- Each Opportunity is assigned to a Team Member in the matching Commercial Team with the lowest workload (`Counter__c`).
- Team Member counters are incremented after assignment.
- Opportunities without a matching Team Member or missing required Account data are skipped.

## Implementation Notes

- Utilizes the `TeamMemberRespository` and `AccountRepository` for data access.
- Includes debug logging for troubleshooting and monitoring.
- No explicit error handling for DML failures; all updates are attempted in bulk.
- Requires custom fields:
  - On Opportunity: `Product_Interest__c`, `AccountId`
  - On Account: `Country_Code__c`, `Employee_Range__c`
  - On Team_Member__c: `Counter__c`, `User__c`, `Commercial_Team__r.Key__c`
- Designed for use in triggers or batch processes for automated Opportunity assignment.
