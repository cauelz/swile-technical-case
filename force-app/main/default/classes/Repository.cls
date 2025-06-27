public interface Repository {

    SObject findById(String Id);
    void insertRecords(List<SObject> records);
    void updateRecords(List<SObject> records);
    void deleteRecords(List<SObject> records);
    void upsertRecords(List<SObject> records);
}