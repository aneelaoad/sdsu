@isTest
private with sharing class MigrateAccountAffiliationBatchTest {

    public static Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
    public static Map<String, Schema.RecordTypeInfo> rtMapByName  = d.getRecordTypeInfosByName();
    public static Id refRTID = rtMapByName.get('ref_affiliationroletype').getRecordTypeId();
    
    public static Schema.DescribeSObjectResult d1 = JIACAF__Affiliation_Role_Type__c.SObjectType.getDescribe();
    public static Map<String, Schema.RecordTypeInfo> rtMapByName1  = d1.getRecordTypeInfosByName();
    public static Id refRTID1 = rtMapByName1.get('ref_affiliationroletype').getRecordTypeId();
    
    static testMethod void myUnitTest() {
        Account accRec = new Account(Name='TestAccount');
        insert accRec;
        
        Contact conRec = new Contact(LastName='TestLastName');
        insert conRec;
        
        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__isActive__c = true, JIHIRCRM__HubRecordID__c = 123);
        insert refRec;
        
        JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c
                                                                (JIHIRCRM__Account__c = accRec.id,
                                                                JIHIRCRM__Contact__c = conRec.id,
                                                                JIHIRCRM__AffiliationType__c = refRec.id);
        insert affiliationRec;
        
        JIACAF__Affiliation_Role_Type__c roleTypeRec = new JIACAF__Affiliation_Role_Type__c(
                                                                      Affiliation_Role_Id__c=refRec.id,
                                                                      RecordTypeId = refRTID1 ,
                                                                      JIACAF__isActive__c = true);
        insert roleTypeRec;
        
        Test.startTest();
            Database.executeBatch(new MigrateAccountAffiliationBatch());
        Test.stopTest();
    }
    
     static testMethod void myUnitTestNeg() {
        Account accRec = new Account(Name='TestAccount');
        insert accRec;
        
        Contact conRec = new Contact(LastName='TestLastName');
        insert conRec;
        
        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__isActive__c = true, JIHIRCRM__HubRecordID__c = 123);
        insert refRec;
        
        JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c
                                                                (JIHIRCRM__Account__c = accRec.id,
                                                                JIHIRCRM__Contact__c = conRec.id,
                                                                JIHIRCRM__AffiliationType__c = refRec.id);
        insert affiliationRec;
        
        Test.startTest();
            Database.executeBatch(new MigrateAccountAffiliationBatch());
        Test.stopTest();
    }
}