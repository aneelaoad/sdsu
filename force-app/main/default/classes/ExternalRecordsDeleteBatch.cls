global with sharing class ExternalRecordsDeleteBatch implements Database.Batchable<Sobject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(' SELECT Id ' +
                                          ' FROM JIENS__External_Record__c ');
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Database.delete(scope);
    }

    global void finish(Database.BatchableContext BC) {

    }
}