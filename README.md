> # Swile Salesforce Developer Case Study
>
> This repository contains my solution to Swile’s Salesforce Developer test case, focused on automating the fair and efficient assignment of Leads and Opportunities.
>
> **Key features:**
>
> * **Data model & schema** for Users, Commercial Teams, Leads, Accounts, Opportunities, and custom counters
> * **Apex implementation**: Triggers, Classes and Batch jobs to
>
>   * Automatically distribute records based on employee range, country, and product interest
>   * Ensure fair distribution by assigning to the user with the fewest recent assignments
>   * Exclude absent users and realign counters upon return
>   * Reset assignment counters monthly
> * **(Bonus)** Lightning Web Component for managers to view team availability and mark users as absent/present
>
> **Contents:**
>
> 1. `docs/` – ER diagrams and schema exports
> 2. `force-app/main/default/objects/` – Custom object and field definitions
> 3. `force-app/main/default/classes/` – Apex classes and batch jobs
> 4. `force-app/main/default/triggers/` – Apex triggers for Lead, Opportunity, and Reassign actions
> 5. `force-app/main/default/lwc/` – Manager availability component
>
> **How to deploy:**
>
> 1. Authorize a Trailhead Playground or scratch org
> 2. `git clone` this repo and `cd` into it
> 3. `sfdx force:source:push`
> 4. Run tests: `sfdx force:apex:test:run`
>
> Enjoy exploring the code, and feel free to reach out with any questions!