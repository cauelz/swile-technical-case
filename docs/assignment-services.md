# Assignment Services

## LeadAssignmentService
- Implements the `Assignment` interface for Lead distribution.
- Filters the provided record list for Lead records.
- Groups leads by Product Interest, Country Code and Employee Range.
- Looks up available team members matching those keys.
- Assigns each lead to the member with the lowest counter and updates counters.

## OpportunityAssignmentService
- Implements the `Assignment` interface for Opportunity distribution.
- Extracts Opportunity records from the list and groups them by the same key.
- Retrieves eligible team members for those keys.
- Assigns each opportunity to the least-used member and increments counters.
