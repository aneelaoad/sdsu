global class WaitlistMigrationBatch implements Database.Batchable<sObject> {
    
    global WaitlistMigrationBatch() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, 
                                                JIHIRCRM__SourceModule__c,
                                                JIHIRCRM__Section__c,
                                                JIHIRCRM__Student__c,
                                                JIHIRCRM__SectionID__c, 
                                                JIHIRCRM__SourceID__c, 
                                                JIHIRCRM__Purchaser__c
                                        FROM JIHIRCRM__HiRWaitList__c 
                                        WHERE JIHIRCRM__Student__c = null
                                        AND JIHIRCRM__SourceID__c != null
                                        AND JIHIRCRM__SectionID__c != null]);
    }

    global void execute(Database.BatchableContext BC, List<JIHIRCRM__HiRWaitList__c> scope) {
        WaitlistMigrationBatchHandler.migrateRecords(scope);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    

}