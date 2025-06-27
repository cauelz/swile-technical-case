trigger Lead on Lead (before insert, before update) {
    new LeadTriggerHandler().run();
}