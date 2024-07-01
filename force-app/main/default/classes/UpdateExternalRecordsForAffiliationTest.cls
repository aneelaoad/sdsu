@isTest
private class UpdateExternalRecordsForAffiliationTest {

    static testMethod void myUnitTest() {
        Schema.DescribeSObjectResult d = JIACAF__Affiliation_Role_Type__c.SObjectType.getDescribe();
        Map<String, Schema.RecordTypeInfo> rtMapByName  = d.getRecordTypeInfosByName();
        Id refRTID = rtMapByName.get('ref_affiliationroletype').getRecordTypeId();

        JIENS__System__c systemRec = new JIENS__System__c();
        insert systemRec;

        JIENS__External_Record__c externalRec = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '123',
                                                                              JIENS__InternalID__c = '564',
                                                                              JIENS__InternalType__c = 'test',
                                                                              JIENS__UniqueKey__c = '564');
        insert externalRec;

        JIACAF__Affiliation_Role_Type__c affiliatioRole = new JIACAF__Affiliation_Role_Type__c(RecordTypeId = refRTID,
                                                                                               JIACAF__IsActive__c = true );
        insert affiliatioRole;

        Account accRec = new Account(Name='testAccount');
        insert accRec;

        Contact conRec = new Contact(LastName='test');
        insert conRec;

        JIACAF__Account_Affiliation__c affRoleRec = new JIACAF__Account_Affiliation__c
                                                          (Affiliation_Id__c = '564',
                                                          JIACAF__Account__c = accRec.id,
                                                          JIACAF__Contact__c = conRec.id,
                                                          JIACAF__AffiliationType__c = affiliatioRole.id);
        insert affRoleRec;

        system.debug([SELECT JIENS__InternalID__c,JIENS__UniqueKey__c,
                                                              JIENS__InternalType__c
                                                         FROM JIENS__External_Record__c
                                                        WHERE Id =: externalRec.id]);
        Test.startTest();
            Database.executeBatch(new UpdateExternalRecordsForAffiliation());
        Test.stopTest();

        List<JIENS__External_Record__c> externalLst = [SELECT JIENS__InternalID__c,JIENS__UniqueKey__c,
                                                              JIENS__InternalType__c
                                                         FROM JIENS__External_Record__c
                                                        WHERE Id =: externalRec.id];

        system.assertEquals(externalLst[0].JIENS__InternalType__c,Schema.JIACAF__Account_Affiliation__c.sObjectType.getDescribe().getName());
        system.assertEquals(externalLst[0].JIENS__InternalID__c,affRoleRec.id);
    }
}