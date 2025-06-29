public with sharing class CounterResetBatch implements Database.Batchable<SObject>, Database.Stateful {
    /**
     * QueryLocator for all Team Members whose counter is non-zero.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Counter__c FROM Team_Member__c WHERE Counter__c != 0'
        );
    }

    /**
     * Reset the counter field to zero for each Team Member in the batch scope.
     */
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Team_Member__c> toUpdate = new List<Team_Member__c>();
        for (SObject sObj : scope) {
            Team_Member__c tm = (Team_Member__c) sObj;
            tm.Counter__c = 0;
            toUpdate.add(tm);
        }
        
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    /**
     * Optional finish hook; can be used for notifications or logging.
     */
    public void finish(Database.BatchableContext bc) {
        // No post-processing required.
    }
}