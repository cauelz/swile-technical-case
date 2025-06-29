# AbsenceService Documentation

## Overview

The `AbsenceService` Apex class is responsible for handling business logic when a Team Member returns from an absence. Its main function is to ensure that, upon return, the Team Member's `Counter__c` field is updated to match the highest counter among their Commercial Team, if necessary.

## Main Method

### `processReturnedFromAbsence(List<Absence__c> absences, Map<Id, Absence__c> oldMap)`

- **Purpose:**
  - Processes a list of `Absence__c` records and updates the related Team Members who have just returned from absence.
  - For each returned Team Member, finds the Team Member in the same Commercial Team with the highest `Counter__c` and updates the returned Team Member's counter if it is not already the highest.

- **Parameters:**
  - `absences`: List of new `Absence__c` records (after update/trigger context).
  - `oldMap`: Map of old `Absence__c` records (before update/trigger context).

- **Logic Flow:**
  1. Identifies Team Members who have just returned (where `Is_Returned__c` changed from `false` to `true`).
  2. Retrieves their associated Commercial Teams.
  3. For each Commercial Team, finds the Team Member with the highest `Counter__c`.
  4. Updates the returned Team Member's `Counter__c` to match the highest value in their team, if needed.

## Helper Methods

- `getReturnedTeamMemberIds(...)`: Returns IDs of Team Members who have just returned from absence.
- `getReturnedTeamMembers(...)`: Retrieves Team Member records by ID.
- `getCommercialTeamIds(...)`: Extracts Commercial Team IDs from Team Members.
- `getAllTeamMembersByCommercialTeams(...)`: Retrieves all Team Members for given Commercial Teams.
- `getHighestCounterByTeam(...)`: Finds the Team Member with the highest `Counter__c` for each Commercial Team.
- `prepareReturnedTeamMemberUpdates(...)`: Prepares the list of Team Members to update, setting their `Counter__c` as needed.

## Example Use Case

This class is typically called from a trigger or batch process when absences are updated. For example, when a Team Member returns from absence, this service ensures their workload counter is aligned with the most active member of their team.

## Notes
- The class assumes the existence of the following custom objects and fields:
  - `Absence__c` (with `Is_Returned__c`, `Team_Member__c`)
  - `Team_Member__c` (with `Commercial_Team__c`, `Counter__c`)
  - `CommercialTeam__c`
- Only Team Members whose `Is_Returned__c` changes from `false` to `true` are processed.
- If the returned Team Member already has the highest counter, no update is performed.

## Maintenance
- If new business rules are added (e.g., updating more fields), extend the `prepareReturnedTeamMemberUpdates` method.
- Ensure that all referenced fields and objects exist and have the correct permissions in your Salesforce org.
