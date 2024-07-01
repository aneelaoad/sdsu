global with sharing class MigrationBatch implements Database.Batchable<Sobject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator( ' SELECT JIENS__InternalType__c ' +
                                              ' , JIENS__InternalID__c ' +
                                              ' , JIENS__LocalSystemID__c ' +
                                              ' , JIENS__SystemID__c ' +
                                              ' , JIENS__ExternalID__c ' +
                                           ' FROM JIENS__External_Record__c ' +
                                          ' WHERE JIENS__LocalSystemID__c != null ' +
                                            ' AND JIENS__SystemID__c != null ' +
                                            ' AND JIENS__InternalID__c != null ' +
                                            ' AND JIENS__InternalType__c != null ' +
                                            ' AND JIENS__ExternalID__c != null ORDER BY JIENS__InternalType__c' );
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        MigrationBatchHandler.execute(scope);
    }

    global void finish(Database.BatchableContext BC) {

    }
}