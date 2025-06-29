public with sharing class AbsenceTriggerHandler extends TriggerHandler {
    
    public override void beforeUpdate() {
        List<Absence__c> absences = (List<Absence__c>) Trigger.new;
        Map<Id, Absence__c> oldMap = (Map<Id,Absence__c>) Trigger.oldMap;
        AbsenceService service = new AbsenceService();
        
        service.processReturnedFromAbsence(absences, oldMap);
    }
}