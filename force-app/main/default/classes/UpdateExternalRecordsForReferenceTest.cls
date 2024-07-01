@isTest
private class UpdateExternalRecordsForReferenceTest {

    static testMethod void myUnitTest() {

        JIENS__System__c systemRec = new JIENS__System__c();
        insert systemRec;

        JIENS__External_Record__c externalRec = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '123',
                                                                              JIENS__InternalID__c = '564',
                                                                              JIENS__InternalType__c = 'test',
                                                                              JIENS__UniqueKey__c = '564');
        insert externalRec;

        JIACAF__Affiliation_Role_Type__c affRoleRec = new JIACAF__Affiliation_Role_Type__c
                                                          (Affiliation_Role_Id__c = '564');
        insert affRoleRec;

        system.debug([SELECT JIENS__InternalID__c,JIENS__UniqueKey__c,
                                                              JIENS__InternalType__c
                                                         FROM JIENS__External_Record__c
                                                        WHERE Id =: externalRec.id]);
        Test.startTest();
            Database.executeBatch(new UpdateExternalRecordsForReference());
        Test.stopTest();

        List<JIENS__External_Record__c> externalLst = [SELECT JIENS__InternalID__c,JIENS__UniqueKey__c,
                                                              JIENS__InternalType__c
                                                         FROM JIENS__External_Record__c
                                                        WHERE Id =: externalRec.id];

        system.assertEquals(externalLst[0].JIENS__InternalType__c,Schema.JIACAF__Affiliation_Role_Type__c.sObjectType.getDescribe().getName());
        system.assertEquals(externalLst[0].JIENS__InternalID__c,affRoleRec.id);
    }
}