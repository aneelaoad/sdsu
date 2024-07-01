@isTest
private class AccountAffiliationMigrationCtrlTest {
    public static Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
    public static Map<String, Schema.RecordTypeInfo> rtMapByName  = d.getRecordTypeInfosByName();
    public static Id refRTID = rtMapByName.get('ref_affiliationroletype').getRecordTypeId();

    static testMethod void testReferenceDataMigrated() {

        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c= 123);
        refRec.JIHIRCRM__isActive__c = true;
        insert refRec;

        PageReference pageRef = Page.AccountAffiliationMigration;
        Test.setCurrentPage(pageRef);
        AccountAffiliationMigrationController ctrl = new AccountAffiliationMigrationController();
        Test.startTest();
            ctrl.exeAffRoleTypeBatch();
            ctrl.pollAffRoleTypeAction();
        Test.stopTest();
        // Called again to check functionality after job is completed
        ctrl.pollAffRoleTypeAction();

        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollAffRoleTypeBatchId
                            limit 1];
        List<JIACAF__Affiliation_Role_Type__c> roleTypes = [select Id, Affiliation_Role_Id__c
                                                            from JIACAF__Affiliation_Role_Type__c];
        System.assertEquals(0, job.NumberOfErrors);
        System.assertEquals(refRec.Id, roleTypes[0].Affiliation_Role_Id__c);
    }

    static testMethod void testAccountAffiliationDataMigrated() {

        Account accRec = new Account(Name='TestAccount');
        insert accRec;

        Contact conRec = new Contact(LastName='TestLastName');
        insert conRec;

        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c= 123);
        refRec.JIHIRCRM__isActive__c = true;
        insert refRec;
        


        JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c
                                                                (JIHIRCRM__Account__c = accRec.id,
                                                                JIHIRCRM__Contact__c = conRec.id,
                                                                JIHIRCRM__AffiliationType__c = refRec.id);
        insert affiliationRec;

        PageReference pageRef = Page.AccountAffiliationMigration;
        Test.setCurrentPage(pageRef);
        AccountAffiliationMigrationController ctrl = new AccountAffiliationMigrationController();
        Test.startTest();
            ctrl.exeAffRoleTypeBatch();
            ctrl.exeAccAffBatch();
            ctrl.pollAffRoleTypeAction();
        Test.stopTest();
        // Called again to check functionality after job is completed
        ctrl.pollAffRoleTypeAction();

        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollAffRoleTypeBatchId
                            limit 1];
        System.assertEquals(0, job.NumberOfErrors);
    }

    static testMethod void testUpdateExternalRecords1() {

        Account accRec = new Account(Name='TestAccount');
        insert accRec;

        Contact conRec = new Contact(LastName='TestLastName');
        insert conRec;

        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c = 123);
        refRec.JIHIRCRM__isActive__c = true;
        insert refRec;
        

        JIENS__System__c systemRec = new JIENS__System__c();
        insert systemRec;

        JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c(
                                                                JIHIRCRM__Account__c = accRec.id,
                                                                JIHIRCRM__Contact__c = conRec.id,
                                                                JIHIRCRM__AffiliationType__c = refRec.id);
        insert affiliationRec;

        JIENS__External_Record__c externalRec = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '123',
                                                                              JIENS__InternalID__c = refRec.Id,
                                                                              JIENS__InternalType__c = 'test1',
                                                                              JIENS__UniqueKey__c = refRec.Id);
        insert externalRec;

        JIENS__External_Record__c externalRecAff = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '124',
                                                                              JIENS__InternalID__c = affiliationRec.Id,
                                                                              JIENS__InternalType__c = 'test2',
                                                                              JIENS__UniqueKey__c = affiliationRec.Id);
        insert externalRecAff;

        PageReference pageRef = Page.AccountAffiliationMigration;
        Test.setCurrentPage(pageRef);
        AccountAffiliationMigrationController ctrl = new AccountAffiliationMigrationController();
        Test.startTest();
            ctrl.exeAffRoleTypeBatch();
            ctrl.exeAccAffBatch();
            ctrl.exeAffRoleTypeExternalRecBatch();
        Test.stopTest();
        ctrl.pollAffRoleTypeAction();

        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollAffRoleTypeBatchId
                            limit 1];
        System.assertEquals(0, job.NumberOfErrors);
    }

    static testMethod void testUpdateExternalRecords2() {

        Account accRec = new Account(Name='TestAccount');
        insert accRec;

        Contact conRec = new Contact(LastName='TestLastName');
        insert conRec;

        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c = 123);
        refRec.JIHIRCRM__isActive__c = true;
        insert refRec;
        
        
        JIENS__System__c systemRec = new JIENS__System__c();
        insert systemRec;

        JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c(
                                                                JIHIRCRM__Account__c = accRec.id,
                                                                JIHIRCRM__Contact__c = conRec.id,
                                                                JIHIRCRM__AffiliationType__c = refRec.id);
        insert affiliationRec;

        JIENS__External_Record__c externalRec = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '123',
                                                                              JIENS__InternalID__c = refRec.Id,
                                                                              JIENS__InternalType__c = 'test1',
                                                                              JIENS__UniqueKey__c = refRec.Id);
        insert externalRec;

        JIENS__External_Record__c externalRecAff = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '124',
                                                                              JIENS__InternalID__c = affiliationRec.Id,
                                                                              JIENS__InternalType__c = 'test2',
                                                                              JIENS__UniqueKey__c = affiliationRec.Id);
        insert externalRecAff;

        PageReference pageRef = Page.AccountAffiliationMigration;
        Test.setCurrentPage(pageRef);
        AccountAffiliationMigrationController ctrl = new AccountAffiliationMigrationController();
        Test.startTest();
            ctrl.exeAffRoleTypeBatch();
            ctrl.exeAccAffBatch();
            ctrl.exeAffRoleTypeExternalRecBatch();
            ctrl.pollAffRoleTypeAction();
            ctrl.exeAccAffTypeExternalRecBatch();
        Test.stopTest();
        ctrl.pollAffRoleTypeAction();

        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollAffRoleTypeBatchId
                            limit 1];
        System.assertEquals(0, job.NumberOfErrors);
    }
}