global class CounterResetScheduler implements Schedulable {
    /**
     * Scheduled job entry point. Executes the CounterResetBatch.
     */
    global void execute(SchedulableContext sc) {
        CounterResetBatch batchJob = new CounterResetBatch();
        // Execute batch in chunks of 200
        Database.executeBatch(batchJob, 200);
    }
}