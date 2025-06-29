@isTest
public with sharing class CounterResetSchedulerTest {
    @isTest
    static void testSchedulerIsScheduled() {
        String cronExp = '0 0 0 1 * ?';

        Test.startTest();
        String jobId = System.schedule('Test Counter Reset Scheduler', cronExp, new CounterResetScheduler());
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job Id should not be null');
    }
}