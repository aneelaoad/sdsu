@isTest
private with sharing class DeleteReferrenceBatchTest{
    public static Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
    public static Map<String, Schema.RecordTypeInfo> rtMapByName  = d.getRecordTypeInfosByName();
    private static Id refRTID = rtMapByName.get('ref_affiliationroletype').getRecordTypeId();
    
    static testMethod void myUnitTest() {        
        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID , JIHIRCRM__HubRecordID__c = 123);
        insert refRec;
        
        Test.startTest();
            Database.executeBatch(new DeleteReferrenceBatch());
        Test.stopTest();
        
        System.assertEquals(0, [select Id from JIHIRCRM__Reference__c].size());
    }
}