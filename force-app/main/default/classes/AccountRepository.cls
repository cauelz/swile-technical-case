public with sharing class AccountRepository implements Repository {
    
    public SObject findById(String Id) {
        Account result = [
            SELECT Id, Name, Industry, Type
            FROM Account
            WHERE Id = :Id
        ];
        return (SObject) result;
    }

    public List<SObject> findByIds(List<String> ids) {
        List<Account> results = [
            SELECT Id, Name, Employee_Range__c, Country_Code__c
            FROM Account
            WHERE Id IN :ids
        ];
        return (List<SObject>) results;
    }

    public void insertRecords(List<SObject> records) {
        List<Account> accounts = new List<Account>();
        for (SObject s : records) {
            if (s instanceof Account) {
                accounts.add((Account)s);
            }
        }
        if (!accounts.isEmpty()) {
            insert accounts;
        }
    }

    public void updateRecords(List<SObject> records) {
        List<Account> accounts = new List<Account>();
        for (SObject s : records) {
            if (s instanceof Account) {
                accounts.add((Account)s);
            }
        }
        if (!accounts.isEmpty()) {
            update accounts;
        }
    }

    public void deleteRecords(List<SObject> records) {
        List<Account> accounts = new List<Account>();
        for (SObject s : records) {
            if (s instanceof Account) {
                accounts.add((Account)s);
            }
        }
        if (!accounts.isEmpty()) {
            delete accounts;
        }
    }

    public void upsertRecords(List<SObject> records) {
        List<Account> accounts = new List<Account>();
        for (SObject s : records) {
            if (s instanceof Account) {
                accounts.add((Account)s);
            }
        }
        if (!accounts.isEmpty()) {
            upsert accounts;
        }
    }
}