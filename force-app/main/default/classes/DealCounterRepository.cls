public with sharing class DealCounterRepository implements Repository {
    public DealCounterRepository() {

    }

    public SObject findById(String Id) {

        Deals_Counter__c result = [
            SELECT Id, Name, OwnerId, Count__c, Team_Member__c, Key__c
            FROM Deals_Counter__c
            WHERE Id = :Id
        ];

        return (SObject) result;
    }

    public List<Deals_Counter__c> findByKey(List<String> keys) {
        return [
            SELECT Id, Name, OwnerId, Count__c, Team_Member__c, Key__c
            FROM Deals_Counter__c
            WHERE Key__c IN :keys
        ];
    }

    public void insertRecords(List<SObject> records) {
        List<Deals_Counter__c> deals = new List<Deals_Counter__c>();
        for (SObject s : records) {
            if (s instanceof Deals_Counter__c) {
                deals.add((Deals_Counter__c)s);
            }
        }
        if (!deals.isEmpty()) {
            insert deals;
        }
    }

    public void updateRecords(List<SObject> records) {
        List<Deals_Counter__c> deals = new List<Deals_Counter__c>();
        for (SObject s : records) {
            if (s instanceof Deals_Counter__c) {
                deals.add((Deals_Counter__c)s);
            }
        }
        if (!deals.isEmpty()) {
            update deals;
        }
    }

    public void deleteRecords(List<SObject> records) {
        List<Deals_Counter__c> deals = new List<Deals_Counter__c>();
        for (SObject s : records) {
            if (s instanceof Deals_Counter__c) {
                deals.add((Deals_Counter__c)s);
            }
        }
        if (!deals.isEmpty()) {
            delete deals;
        }
    }

    public void upsertRecords(List<SObject> records) {
        List<Deals_Counter__c> deals = new List<Deals_Counter__c>();
        for (SObject s : records) {
            if (s instanceof Deals_Counter__c) {
                deals.add((Deals_Counter__c)s);
            }
        }
        if (!deals.isEmpty()) {
            upsert deals;
        }
    }
}