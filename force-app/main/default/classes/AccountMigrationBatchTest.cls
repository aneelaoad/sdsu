@isTest
public class AccountMigrationBatchTest {
  /*  @isTest static void AccountMigrationBatch_NoHeaderTest() {
        String csvString = 'DeletedID,SurvivingAccountSFID\r\n1,2\r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }
    
    @isTest static void AccountMigrationBatch_BlankValueTest() {
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1, \r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }
    
    @isTest static void AccountMigrationBatch_BlankValueNoExtRecForBothTest() {
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }
    
    @isTest static void AccountMigrationBatch_BlankValueNoFirstExtRecTest() {
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        Account acc = new Account(Name = 'Test');
        insert acc;
        JIENS__External_Record__c externalRecord = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__ExternalID__c = '2', JIENS__InternalID__c = acc.Id, JIENS__InternalType__c = 'Account', JIENS__LocalSystemID__c = systemRecord.Id);
        insert externalRecord;
        
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }
    
    @isTest static void AccountMigrationBatch_BlankValueNoSecondExtRecTest() {
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        Account acc = new Account(Name = 'Test');
        insert acc;
        JIENS__External_Record__c externalRecord = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__ExternalID__c = '1', JIENS__InternalID__c = acc.Id, JIENS__InternalType__c = 'Account', JIENS__LocalSystemID__c = systemRecord.Id);
        insert externalRecord;
        
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }

    @isTest static void AccountMigrationBatch_PositiveTest() {
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        Contact cnt = new Contact(LastName = 'Test');
        insert cnt;
        JIACAF__Affiliation_Role_Type__c rtStatus = new JIACAF__Affiliation_Role_Type__c(Name = 'Active', RecordTypeId = Schema.SObjectType.JIACAF__Affiliation_Role_Type__c.getRecordTypeInfosByName()
                  .get('ref_accountaffiliationstatus').getRecordTypeId());
        insert rtStatus;
        JIACAF__Affiliation_Role_Type__c rt = new JIACAF__Affiliation_Role_Type__c(Name = 'Test', RecordTypeId = Schema.SObjectType.JIACAF__Affiliation_Role_Type__c.getRecordTypeInfosByName()
                  .get('ref_affiliationroletype').getRecordTypeId());
        insert rt;
        
        JIACAF__Account_Affiliation__c aff = new JIACAF__Account_Affiliation__c(Name = 'Test', JIACAF__Account__c = acc1.Id, JIACAF__Contact__c = cnt.Id, JIACAF__AffiliationType__c = rt.Id, JIACAF__StatusID__c = rtStatus.Id);
        insert aff;
        JIHIRCRM__Membership__c mem = new JIHIRCRM__Membership__c(JIHIRCRM__AccountID__c = acc1.Id, JIHIRCRM__MembershipID__c = 124);
        insert mem;
        JIHIRCRM__HiRActivity__c act = new JIHIRCRM__HiRActivity__c(JIHIRCRM__AccountID__c = acc1.Id, JIHIRCRM__OrderItemID__c = 122, JIHIRCRM__PersonID__c = 111);
        insert act;
        JIHIRCRM__HiRInquiry__c inq = new JIHIRCRM__HiRInquiry__c(JIHIRCRM__AccountID__c = acc1.Id, JIHIRCRM__ID__c = 1232);
        insert inq;
        JIHIRCRM__HiRWaitList__c wtl = new JIHIRCRM__HiRWaitList__c(JIHIRCRM__Account__c = acc1.Id, JIHIRCRM__WaitListEntryID__c = 1112);
        insert wtl;
        
        Account acc2 = new Account(Name = 'Test');
        insert acc2;
        JIENS__External_Record__c externalRecord1 = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__ExternalID__c = '1', JIENS__InternalID__c = acc1.Id, JIENS__InternalType__c = 'Account', JIENS__LocalSystemID__c = systemRecord.Id);
        insert externalRecord1;
        JIENS__External_Record__c externalRecord2 = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__ExternalID__c = '2', JIENS__InternalID__c = acc2.Id, JIENS__InternalType__c = 'Account', JIENS__LocalSystemID__c = systemRecord.Id);
        insert externalRecord2;
        
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }
    
    @isTest static void AccountMigrationBatch_DeleteAccountNotPresentTest() {
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        Account acc1 = new Account(Name = 'Test');
        insert acc1;
        JIENS__External_Record__c externalRecord1 = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__ExternalID__c = '2', JIENS__InternalID__c = acc1.Id, JIENS__InternalType__c = 'Account', JIENS__LocalSystemID__c = systemRecord.Id);
        insert externalRecord1;
        JIENS__External_Record__c externalRecord2 = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__ExternalID__c = '1', JIENS__InternalID__c = '001f400000GLsBW', JIENS__InternalType__c = 'Account', JIENS__LocalSystemID__c = systemRecord.Id);
        insert externalRecord2;
        
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }
    
    @isTest static void generateErrorLogs_ErrorLogPresentTest() {
        String csvString = 'DeletedAccountID,SurvivingAccountID\r\n1,2\r\n';
        AccountMigrationBatch batchObj = new AccountMigrationBatch(Blob.valueOf(csvString));
        Id batchInstanceId;
        
        System.Test.startTest();
            batchInstanceId = Database.executeBatch(batchObj, 1);
            JIENS__ErrorLogs__c errorLog = new JIENS__ErrorLogs__c(JIENS__RecordID__c = batchInstanceId);
            insert errorLog;
        System.Test.stopTest();

        System.assertNotEquals(null, batchInstanceId);
    }
  */  
}