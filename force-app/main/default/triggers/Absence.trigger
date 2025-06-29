trigger Absence on Absence__c (before update) {
    new AbsenceTriggerHandler().run();
}