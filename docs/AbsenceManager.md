# AbsenceManager LWC Component

## Overview
`AbsenceManager` is a Lightning Web Component (LWC) for managing absences (`Absence__c` records) related to a specific `CommercialTeam__c` record. It provides a user-friendly interface for viewing, creating, editing, and deleting absences, using Salesforce standard UI elements and best practices.

## Features
- Lists absences for the selected Commercial Team in a datatable.
- Allows creation of new absences via a modal form.
- Enables editing and deletion of existing absences with row actions.
- Handles loading states, empty states, and error feedback.
- Uses `lightning-datatable` for display and `lightning-record-edit-form` for record management.

## How It Works
- The component receives the `recordId` of a `CommercialTeam__c` record when placed on its record page.
- It uses the Apex method `getTeamAbsences` to fetch all `Absence__c` records for the team.
- Absences are displayed in a datatable with actions for editing and deleting.
- Creating or editing an absence opens a modal with a record form.
- After a successful create, edit, or delete, the list of absences is refreshed using `refreshApex`.
- Shows a spinner while loading and a friendly message if no absences are found.

## Key Files
- `absenceManager.js`: Handles data fetching, modal control, event handling, and error management.
- `absenceManager.html`: Template with datatable, modal, forms, and conditional rendering for loading and empty states.
- `absenceManager.js-meta.xml`: Exposes the component for use on record pages.

## Apex Methods Used
- `getTeamAbsences(teamId)`: Returns absences for a given team.
- `upsertAbsence(absence)`: Creates or updates an absence (used by the record form).
- `deleteAbsence(absenceId)`: Deletes an absence (called from the JS controller).

## Usage
1. Add the component to a `CommercialTeam__c` record page in the Lightning App Builder.
2. The component will automatically receive the `recordId` and display the related absences.
3. Use the "New Absence" button to create a new record, or the row actions to edit or delete.

## Considerations
- The user must have access to the `Absence__c` and `Team_Member__c` objects and fields.
- The `Team_Member__c` field in the form must be visible and editable for the modal to work correctly.
- Lookup filters or field-level security may affect the usability of the modal form.
- The component uses computed properties (`hasAbsences`, `showNoAbsencesMessage`) for template logic.
- Error messages are logged to the console and can be surfaced to users as needed.

## Troubleshooting
- If the modal appears but is not editable, check field permissions and lookup filters for `Team_Member__c`.
- If no absences are displayed, ensure the Apex method returns data for the given team and the user has access.
- If actions (edit/delete) do not work, ensure the Apex methods are exposed and the user has the necessary permissions.

---
For further customization or issues, review the component's JS and HTML files or contact the development team.
