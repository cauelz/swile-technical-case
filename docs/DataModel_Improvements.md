# Data Model Improvement Suggestions

This document lists potential improvements for the Swile Salesforce data model, based on the current `DataModel.md` and best practices for Salesforce architecture.

## 1. Field Naming Consistency
- Standardize custom field names (e.g., use `Country_Code__c` everywhere instead of mixing `CountryCode__c` and `Country_Code__c`).
- Use consistent casing and delimiters for all custom fields.

## 2. Formula Fields and Redundancy
- Review the necessity of formula fields in `Opportunity` that mirror `Account` fields. Consider using report types or SOQL relationships instead of duplicating data.
- Avoid redundant fields between `Lead`, `Opportunity`, and `Commercial_Team__c` unless required for performance or reporting.

## 3. Junction Object Integrity
- Ensure `Team_Member__c` enforces uniqueness (one user per team at a time) using validation rules or unique constraints.
- Consider adding effective date fields (start/end) to support historical team membership if needed.

## 4. Counters and Performance
- The `Count__c` field in `Team_Member__c` may cause concurrency issues. Consider using roll-up summaries or calculating assignment counts on demand.
- If real-time performance is not critical, prefer calculated fields over stored counters.

## 5. Absence Tracking
- The `Returned__c` checkbox in `Absence__c` may be redundant if `EndDate__c` is always set. Consider using only dates to determine absence status.
- Add validation to ensure logical consistency (e.g., `EndDate__c` after `StartDate__c`).

## 6. Assignment Log Optimization
- Ensure `Assignment_Log__c` has proper indexes for high-volume reporting.
- Add a status or event type field if more detailed audit trails are needed.

## 7. Picklist Management
- Use Global Value Sets for picklists like `Product_Interest__c` and `Employee_Range__c` to ensure consistency across objects.

## 9. Relationship Enhancements
- If users can belong to multiple teams over time, add validity periods to `Team_Member__c`.
- Consider master-detail relationships where appropriate for automatic sharing and roll-ups.