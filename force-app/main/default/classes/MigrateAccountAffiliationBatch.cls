global class MigrateAccountAffiliationBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id, Name, JIHIRCRM__Account__c, JIHIRCRM__AffiliationType__c, '
                    +'JIHIRCRM__Contact__c, JIHIRCRM__ErrorLink__c, JIHIRCRM__IsActive__c, '
                    +'JIHIRCRM__oca__c, JIHIRCRM__OriginatingSourceSystemID__c, '
                    +'JIHIRCRM__Source__c '
                    +'from JIHIRCRM__Account_Affiliation__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<JIHIRCRM__Account_Affiliation__c> scope) {
        // Create map of Reference and corresponding Affiliation Role Type Ids
        Map<Id, Id> refRoleTypeMap = new Map<Id, Id>();
        for(JIACAF__Affiliation_Role_Type__c affRoleType : [select Id, Affiliation_Role_Id__c,RecordType.Name
                                                            from JIACAF__Affiliation_Role_Type__c Where RecordType.Name = 'ref_affiliationroletype']) {
            refRoleTypeMap.put(affRoleType.Affiliation_Role_Id__c, affRoleType.Id);
        }
        if(refRoleTypeMap.size() == 0)
            return;
        // Iterate on scope and create Account Affiliation records for JIACAF package
        List<JIACAF__Account_Affiliation__c> accAffiliations = new List<JIACAF__Account_Affiliation__c>();
        for(JIHIRCRM__Account_Affiliation__c accAff : scope) {
            JIACAF__Account_Affiliation__c accAffiliation = new JIACAF__Account_Affiliation__c();
            accAffiliation.Name = accAff.Name;
            accAffiliation.JIACAF__Account__c = accAff.JIHIRCRM__Account__c;
            accAffiliation.JIACAF__Contact__c = accAff.JIHIRCRM__Contact__c;
            accAffiliation.JIACAF__AffiliationType__c = refRoleTypeMap.get(accAff.JIHIRCRM__AffiliationType__c);
            accAffiliation.JIACAF__ErrorLink__c = accAff.JIHIRCRM__ErrorLink__c;
            accAffiliation.JIACAF__IsActive__c = accAff.JIHIRCRM__IsActive__c;
            accAffiliation.JIACAF__oca__c = accAff.JIHIRCRM__oca__c;
            accAffiliation.JIACAF__OriginatingSourceSystemID__c = accAff.JIHIRCRM__OriginatingSourceSystemID__c;
            accAffiliation.JIACAF__Source__c = accAff.JIHIRCRM__Source__c;
            // Populate field which stores original record Id
            accAffiliation.Affiliation_Id__c = accAff.Id;
            accAffiliations.add(accAffiliation);
        }
        // Insert Account Affiliation records
        insert accAffiliations;
    }

    global void finish(Database.BatchableContext BC) {

    }

}