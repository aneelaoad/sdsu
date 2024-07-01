@isTest
private class MigrateAffiliationRoleTypeBatchTest {

    static testMethod void testDataMigrated() {
        Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
		Map<String, Schema.RecordTypeInfo> rtMapByName  = d.getRecordTypeInfosByName();
		Id rtId = rtMapByName.get('ref_affiliationroletype').getRecordTypeId();
        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = rtId, JIHIRCRM__HubRecordID__c = 123);
        insert refRec;

        Test.startTest();
            Id jobId = Database.executeBatch(new MigrateAffiliationRoleTypeBatch());
        Test.stopTest();

        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :jobId
                            limit 1];
        List<JIACAF__Affiliation_Role_Type__c> roleTypes = [select Id, Affiliation_Role_Id__c
                                                            from JIACAF__Affiliation_Role_Type__c];
        System.assertEquals(0, job.NumberOfErrors);
        System.assertEquals(refRec.Id, roleTypes[0].Affiliation_Role_Id__c);
    }
}