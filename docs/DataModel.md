# Swile Salesforce Data Model

This document describes the custom data model for fair, per-month Lead/Opportunity assignment.

---

## Objects & Fields

### User
- **Id** (standard)
- **Is_Manager__c** (Checkbox)  
  Flag to indicate whether the user is a “manager” allowed to declare absences.

### Commercial_Team__c
- **Id** (standard)
- **CountryCode__c** (Picklist: BR, FR)  
- **Product__c** (Picklist: e.g. Meal Voucher, Flex Benefit)  
- **EmployeeRange__c** (Picklist: e.g. 1–50, 51–200)

> Represents a sales team by country, product and company-size bracket.

### Team_Member__c
- **Id** (Auto-Number TM-{0000})
- **User__c** (Lookup → User)  
- **CommercialTeam__c** (Lookup → Commercial_Team__c)  
- **Count__c** (Number)  
  Running total of assignments for the **current** month.

> Junction between User and Commercial Team, with an inline monthly counter.

### Absence__c
- **Id** (Auto-Number ABS-{0000})
- **TeamMember__c** (Lookup → Team_Member__c)
- **StartDate__c** (Date)  
- **EndDate__c** (Date, optional)  
- **Returned__c** (Checkbox)  

> Tracks when a team member is out; used to skip them during assignment.

### Assignment_Log__c
- **Id** (Auto-Number LOG-{0000})
- **TeamMember__c** (Lookup → Team_Member__c)  
- **Lead__c** (Lookup → Lead, optional)  
- **Opportunity__c** (Lookup → Opportunity, optional)  
- **AssignedDate__c** (DateTime)  

> Audits every assignment event for historical reporting and reconciliation.

### Account (standard)
- **Id**  
- **Country_Code__c** (Text)  
- **Employee_Range__c** (Text)  

> Holds the source country and employee-range for related Opportunities.

### Lead (standard)
- **Id**  
- **Country_Code__c** (Text)  
- **Product_Interest__c** (Picklist/Text)  
- **Employee_Range__c** (Picklist/Text)  

> Enriched with the same fields as Commercial_Team to drive assignment logic.

### Opportunity (standard)
- **Id**  
- **AccountId** (Lookup → Account)  
- **Product_Interest__c** (Picklist/Text)  
- **Country_Code__c** (Formula → Account.Country_Code__c)  
- **Employee_Range__c** (Formula → Account.Employee_Range__c)  

> Mirrors Lead fields via formulas and links to Account for consistency.

---

## Relationships

- **User** 1–* **Team_Member__c**  
- **Commercial_Team__c** 1–* **Team_Member__c**  
- **Team_Member__c** 1–* **Absence__c**  
- **Team_Member__c** 1–* **Assignment_Log__c**  
- **Lead** 1–* **Assignment_Log__c**  
- **Opportunity** 1–* **Assignment_Log__c**  
- **Account** 1–* **Opportunity**

---

## ER-Diagram (Mermaid)

<details>
<summary>Click to expand/render diagram</summary>

```mermaid
erDiagram
    USER ||--o{ TEAM_MEMBER        : belongs_to
    COMMERCIAL_TEAM ||--o{ TEAM_MEMBER : has
    TEAM_MEMBER ||--o{ ABSENCE        : has
    TEAM_MEMBER ||--o{ ASSIGNMENT_LOG : logs
    LEAD ||--o{ ASSIGNMENT_LOG       : logged_in
    OPPORTUNITY ||--o{ ASSIGNMENT_LOG : logged_in
    ACCOUNT ||--o{ OPPORTUNITY       : has

    USER {
        string Id
        bool   Is_Manager__c
    }
    COMMERCIAL_TEAM {
        string Id
        string CountryCode__c
        string Product__c
        string EmployeeRange__c
    }
    TEAM_MEMBER {
        string Id
        string User__c
        string CommercialTeam__c
        int    Count__c
    }
    ABSENCE {
        string Id
        string TeamMember__c
        date   StartDate__c
        date   EndDate__c
        bool   Returned__c
    }
    ASSIGNMENT_LOG {
        string Id
        string TeamMember__c
        string Lead__c
        string Opportunity__c
        datetime AssignedDate__c
    }
    LEAD {
        string Id
        string Country_Code__c
        string Product_Interest__c
        string Employee_Range__c
    }
    OPPORTUNITY {
        string Id
        string Product_Interest__c
        string AccountId
    }
    ACCOUNT {
        string Id
        string Country_Code__c
        string Employee_Range__c
    }
