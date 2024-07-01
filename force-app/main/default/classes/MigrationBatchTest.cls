@isTest
private class MigrationBatchTest {

    static testMethod void migrationTest() {
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        Contact contactRecord = new Contact(Lastname = 'Test');
        insert contactRecord;
        JIENS__External_Record__c externalRecord = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__ExternalID__c = '12345', JIENS__InternalID__c = contactRecord.Id, JIENS__InternalType__c = 'Contact', JIENS__LocalSystemID__c = systemRecord.Id);
        insert externalRecord;
        
        Test.startTest();
            Id jobId = Database.executeBatch(new MigrationBatch(), 200);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId);  
    }
}