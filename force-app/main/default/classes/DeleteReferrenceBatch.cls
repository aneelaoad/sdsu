global class DeleteReferrenceBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
        Map<String, Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Id rtId = rtMapByName.get('ref_affiliationroletype').getRecordTypeId();

        return Database.getQueryLocator([Select Id, Name, JIHIRCRM__City__c, JIHIRCRM__CountryCode__c,
                                                JIHIRCRM__Description__c, JIHIRCRM__ErrorLink__c, JIHIRCRM__IsActive__c,
                                                JIHIRCRM__MaxHours__c, JIHIRCRM__MinHours__c, JIHIRCRM__oca__c,
                                                JIHIRCRM__OriginatingSourceSystemID__c, JIHIRCRM__SortPosition__c,
                                                JIHIRCRM__Source__c, JIHIRCRM__State__c
                                        from JIHIRCRM__Reference__c
                                        where RecordTypeId = :rtId]);
    }

    global void execute(Database.BatchableContext BC, List<JIHIRCRM__Reference__c> scope) {
        delete scope;
    }
    global void finish(Database.BatchableContext BC) {}
}