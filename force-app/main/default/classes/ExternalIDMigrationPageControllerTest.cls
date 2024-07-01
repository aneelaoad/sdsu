@isTest
private class ExternalIDMigrationPageControllerTest {

    static testMethod void migrationTest() {
        Boolean isBatchComplete = true;
        PageReference pageRef = Page.ExternalRecordMigration;
        Test.setCurrentPage(pageRef);
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();

        Test.startTest();
            ctrl.exeMigrationBatch();
            ctrl.pollBatchResult();
        Test.stopTest();

        ctrl.pollBatchResult();
        AsyncApexJob job = [
            SELECT Id
                 , ApexClass.Name
                 , NumberOfErrors
              FROM AsyncApexJob
             WHERE Id = :ctrl.currentJobId
             LIMIT 1
        ];

        System.assertEquals(0, job.NumberOfErrors);
    }

    static testMethod void deleteExternalRecordsTest() {
        Boolean isBatchComplete = true;
        PageReference pageRef = Page.ExternalRecordMigration;
        Test.setCurrentPage(pageRef);
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();

        Test.startTest();
            ctrl.deleteExternalRecords();
            ctrl.pollBatchResult();
        Test.stopTest();

        ctrl.pollBatchResult();
        AsyncApexJob job = [
            SELECT Id
                 , ApexClass.Name
                 , NumberOfErrors
              FROM AsyncApexJob
             WHERE Id = :ctrl.currentJobId
             LIMIT 1
        ];

        System.assertEquals(0, job.NumberOfErrors);
    }

    static testMethod void getErrorRecordsTest() {
        Account accountRecord = new Account(Name = 'Test Account');
        insert accountRecord;
        JIHIRCRM__Product__c productRecord = new JIHIRCRM__Product__c(JIHIRCRM__ProductID__c = 12345, Name = 'Test Product');
        insert productRecord;
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        JIENS__External_Record__c externalRecord = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__InternalID__c = accountRecord.Id, JIENS__InternalType__c = 'Account');
        insert externalRecord;
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();

        Test.startTest();
            ctrl.getErrorRecords();
        Test.stopTest();

        System.assertNotEquals(null, ctrl.sObjectVsErrorRecordsMap);
    }
    
    static testMethod void getErrorRecordsBulkTest() {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < 200; i++) {
            accountList.add(new Account(Name = 'Test Account'));
        }
        insert accountList;
        List<JIHIRCRM__Product__c> productList = new List<JIHIRCRM__Product__c>();
        for(Integer i = 0; i < 200; i++) {
            productList.add(new JIHIRCRM__Product__c(JIHIRCRM__ProductID__c = i, Name = 'Test Product'));
        }
        insert productList;
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        List<JIENS__External_Record__c> externalRecordList = new List<JIENS__External_Record__c>();
        for(Integer i = 0; i < 200; i++) {
            externalRecordList.add(new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__InternalID__c = accountList[i].Id, JIENS__InternalType__c = 'Account', JIENS__ExternalID__c = ''+i));
        }
        for(Integer i = 0; i < 200; i++) {
            externalRecordList.add(new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__InternalID__c = productList[i].Id, JIENS__InternalType__c = 'JIHIRCRM__Product__c', JIENS__ExternalID__c = ''+i+'200'));
        }
        insert externalRecordList;
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();

        Test.startTest();
            ctrl.getErrorRecords();
        Test.stopTest();

        System.assertNotEquals(null, ctrl.sObjectVsErrorRecordsMap);
    }

    static testMethod void getErrornousRecordsUnidirectionalTest() {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i <= 200; i++) {
            accountList.add(new Account(Name = 'Test Account'));
        }
        insert accountList;
        JIHIRCRM__Product__c productRecord = new JIHIRCRM__Product__c(JIHIRCRM__ProductID__c = 12345, Name = 'Test Product');
        insert productRecord;
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        List<JIENS__External_Record__c> externalRecordList = new List<JIENS__External_Record__c>();
        for(Integer i = 0; i <= 200; i++) {
            externalRecordList.add(new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__InternalID__c = accountList[i].Id, JIENS__InternalType__c = 'Account', JIENS__ExternalID__c = ''+i));
        }
        insert externalRecordList;
        
        PageReference myVfPage = Page.ExternalRecordMigration;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('sObjectName', 'JIHIRCRM__Product__c');
        ApexPages.currentPage().getParameters().put('op', 'next');
        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();

        Test.startTest();
            ctrl.getErrorRecords();
            ctrl.getErrornousRecords();
            ApexPages.currentPage().getParameters().put('op', 'pre');
            ctrl.getErrornousRecords();
            ApexPages.currentPage().getParameters().put('op', 'last');
            ctrl.getErrornousRecords();
        Test.stopTest();

        System.assertEquals('JIHIRCRM__Product__c', ctrl.sObjectRendered);
    }
    
    static testMethod void getErrornousRecordsBidirectionalTest() {
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i <= 200; i++) {
            accountList.add(new Account(Name = 'Test Account'));
        }
        insert accountList;
        JIHIRCRM__Product__c productRecord = new JIHIRCRM__Product__c(JIHIRCRM__ProductID__c = 12345, Name = 'Test Product');
        insert productRecord;
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        List<JIENS__External_Record__c> externalRecordList = new List<JIENS__External_Record__c>();
        for(Integer i = 0; i <= 200; i++) {
            externalRecordList.add(new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__InternalID__c = accountList[i].Id, JIENS__InternalType__c = 'Account', JIENS__ExternalID__c = ''+i));
        }
        insert externalRecordList;
        
        PageReference myVfPage = Page.ExternalRecordMigration;
        Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('sObjectName', 'Account');
        ApexPages.currentPage().getParameters().put('op', 'next');
        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();

        Test.startTest();
            ctrl.getErrorRecords();
            ctrl.getErrornousRecords();
            ApexPages.currentPage().getParameters().put('op', 'pre');
            ctrl.getErrornousRecords();
            ApexPages.currentPage().getParameters().put('op', 'last');
            ctrl.getErrornousRecords();
        Test.stopTest();

        System.assertEquals('Account', ctrl.sObjectRendered);
    }
    
    static testMethod void fetchErrorRecordsBlankTest() {        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();
        List<sObject> errorRecordList;
        
        Test.startTest();
            errorRecordList = ctrl.fetchErrorRecords('', '', '', '', '', false);
        Test.stopTest();

        System.assertNotEquals(null, errorRecordList);
    }
    
    static testMethod void setUniDirectionalErrorRecordsBlankTest() {        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();
        Boolean res;
        
        Test.startTest();
            res = ctrl.setUniDirectionalErrorRecords('', '');
        Test.stopTest();

        System.assertNotEquals(true, res);
    }
    
    static testMethod void setBiDirectionalErrorRecordsBlankTest() {        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();
        Boolean res;
        
        Test.startTest();
            res = ctrl.setBiDirectionalErrorRecords('', '');
        Test.stopTest();

        System.assertNotEquals(true, res);
    }
    
    static testMethod void reverseListBlankTest() {        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();
        List<sObject> sObjectReverseList;
        
        Test.startTest();
            sObjectReverseList = ctrl.reverseList(null);
        Test.stopTest();

        System.assertNotEquals(null, sObjectReverseList);
    }
    
    static testMethod void getRecordCountBlankTest() {        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();
        Integer res;
        
        Test.startTest();
            res = ctrl.getRecordCount('');
        Test.stopTest();

        System.assertEquals(0, res);
    }
    
    static testMethod void deleteFailedExternalRecordsTest() {        
        JIHIRCRM__Product__c productRecord = new JIHIRCRM__Product__c(JIHIRCRM__ProductID__c = 12345, Name = 'Test Product');
        insert productRecord;
        JIENS__System__c systemRecord = new JIENS__System__c();
        insert systemRecord;
        JIENS__External_Record__c externalRecord = new JIENS__External_Record__c(JIENS__SystemID__c = systemRecord.Id, JIENS__InternalID__c = productRecord.Id, JIENS__InternalType__c = 'JIHIRCRM__Product__c', JIENS__ExternalID__c = '124');
        insert externalRecord;
        
        ExternalIDMigrationPageController ctrl = new ExternalIDMigrationPageController();
        
        Test.startTest();
            ctrl.deleteFailedExternalRecords();
        Test.stopTest();

        System.assertEquals(1, ctrl.RecordsNotProcessed);
    }

}