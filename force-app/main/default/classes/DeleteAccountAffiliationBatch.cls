global class DeleteAccountAffiliationBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {   
        return Database.getQueryLocator([Select Id, Name, JIHIRCRM__Account__c, JIHIRCRM__AffiliationType__c,
                                                JIHIRCRM__Contact__c, JIHIRCRM__ErrorLink__c, JIHIRCRM__IsActive__c,
                                                JIHIRCRM__oca__c, JIHIRCRM__OriginatingSourceSystemID__c,
                                                JIHIRCRM__Source__c
                                         from JIHIRCRM__Account_Affiliation__c]);
    }

    global void execute(Database.BatchableContext BC, List<JIHIRCRM__Account_Affiliation__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
    }
}