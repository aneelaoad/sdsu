/* Test class for Account Type Migration Controller
 *
 * Revision History:
 *
 * Version     Author           Date         Description
 * 1.0         Mujjammil khan   16/08/2016   Initial Draft
 */
 @isTest
private class RelationshipMigrationControllerTest{

    public static Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
    public static Map<String, Schema.RecordTypeInfo> rtMapByName  = d.getRecordTypeInfosByName();
    public static Id refRTID = rtMapByName.get('ref_accounttype').getRecordTypeId();
    
    public static Schema.DescribeSObjectResult roleTypeDesc = JIACAF__Affiliation_Role_Type__c.SObjectType.getDescribe();
    public static Map<String, Schema.RecordTypeInfo> rtRoleTypeMapByName  = roleTypeDesc.getRecordTypeInfosByName();
    public static Id roleTypeRTID = rtRoleTypeMapByName.get('ref_accounttype').getRecordTypeId();
    
    static testMethod void testAccountTypeDataMigrated() {

        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c = 123);
        insert refRec;

        PageReference pageRef = Page.RelationShipMigrationPage;
        Test.setCurrentPage(pageRef);
        RelationshipMigrationController ctrl = new RelationshipMigrationController();
        Test.startTest();
            ctrl.exeAccTypeBatch();
            ctrl.pollAccTypeAction();
        Test.stopTest();
        // Called again to check functionality after job is completed
        ctrl.pollAccTypeAction();

        AsyncApexJob job = [SELECT Id, 
                                   NumberOfErrors
                            FROM AsyncApexJob
                            WHERE Id = :ctrl.pollAccTypeBatchId
                            LIMIT 1];
        List<JIACAF__Affiliation_Role_Type__c> roleTypes = [SELECT Id, 
                                                                   Affiliation_Role_Id__c
                                                            FROM JIACAF__Affiliation_Role_Type__c];
        System.assertEquals(0, job.NumberOfErrors);
        System.assertEquals(refRec.Id, roleTypes[0].Affiliation_Role_Id__c);
    }

    static testMethod void testUpdateExternalRecords() {

        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c = 123);
        insert refRec;
        JIACAF__Affiliation_Role_Type__c roleTypeRec = new JIACAF__Affiliation_Role_Type__c(RecordTypeId = roleTypeRTID,
                                                                                     Affiliation_Role_Id__c = refRec.Id);
        insert roleTypeRec;
        JIENS__System__c systemRec = new JIENS__System__c();
        insert systemRec;

        JIENS__External_Record__c externalRec = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '123',
                                                                              JIENS__InternalID__c = refRec.Id,
                                                                              JIENS__InternalType__c = 'test1',
                                                                              JIENS__UniqueKey__c = refRec.Id);
        insert externalRec;

        PageReference pageRef = Page.RelationShipMigrationPage;
        Test.setCurrentPage(pageRef);
        RelationshipMigrationController ctrl = new RelationshipMigrationController();
        Test.startTest();
            ctrl.exeAccTypeExternalRecBatch();
            ctrl.pollAccTypeAction();
        Test.stopTest();
        ctrl.pollAccTypeAction();

        AsyncApexJob job = [SELECT Id, 
                                   NumberOfErrors
                            FROM AsyncApexJob
                            WHERE Id = :ctrl.pollAccTypeExtRecBatchId
                            limit 1];
        List<JIENS__External_Record__c> lstExternalRecs = [SELECT Id, 
                                                                  JIENS__ExternalID__c, 
                                                                  JIENS__InternalID__c, 
                                                                  JIENS__InternalType__c
                                                            FROM JIENS__External_Record__c];
        System.assertEquals(0, job.NumberOfErrors);
        System.assertEquals(lstExternalRecs[0].JIENS__InternalType__c, JIACAF__Affiliation_Role_Type__c.SObjectType.getDescribe().getName());
    }
    static testMethod void testExistingDataMigration() {

        JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c = 123);
        insert refRec;
        JIACAF__Affiliation_Role_Type__c roleTypeRec = new JIACAF__Affiliation_Role_Type__c(RecordTypeId = roleTypeRTID);
        roleTypeRec.Affiliation_Role_Id__c = refRec.Id;
        insert roleTypeRec;
        PageReference pageRef = Page.RelationShipMigrationPage;
        Test.setCurrentPage(pageRef);
        RelationshipMigrationController ctrl = new RelationshipMigrationController();
        Test.startTest();
            ctrl.exeAccTypeBatch();
            ctrl.pollAccTypeAction();
        Test.stopTest();
        // Called again to check functionality after job is completed
        ctrl.pollAccTypeAction();

        AsyncApexJob job = [SELECT Id, 
                                   NumberOfErrors
                            FROM AsyncApexJob
                            WHERE Id = :ctrl.pollAccTypeBatchId
                            LIMIT 1];
        List<JIACAF__Affiliation_Role_Type__c> roleTypes = [SELECT Id, 
                                                                   Affiliation_Role_Id__c
                                                            FROM JIACAF__Affiliation_Role_Type__c
                                                            WHERE Affiliation_Role_Id__c <> null];
        System.assertEquals(0, job.NumberOfErrors);
        System.assertEquals(refRec.Id, roleTypes[0].Affiliation_Role_Id__c);
    }
    
    static testMethod void testScriptPositive() {
        JIENS__Topic_Area__c topicAreaPull = new JIENS__Topic_Area__c(name='Pull Request',JIENS__TopicAreaExternalID__c='ens.304');
        insert topicAreaPull;
        
        JIENS__Topic_Area__c topicAreaStub = new JIENS__Topic_Area__c(name='Stub',JIENS__TopicAreaExternalID__c='ens.301');
        insert topicAreaStub;
        
        JIENS__System__c sourceSystem = new JIENS__System__c(JIENS__Name__c='HIR',JIENS__IsLocal__c=false,JIENS__SystemExternalId__c='1',JIENS__SystemMnemonic__c='staging-hir',JIENS__SystemExternalIdUnique__c='1',JIENS__InboundSettings__c='On',JIENS__OutboundSettings__c='On');
        insert sourceSystem;
        
        JIENS__System__c localSystem = new JIENS__System__c(JIENS__Name__c='HIRCRM',JIENS__IsLocal__c=true,JIENS__SystemExternalId__c='5',JIENS__SystemMnemonic__c='hir-i',JIENS__SystemExternalIdUnique__c='5',JIENS__InboundSettings__c='On',JIENS__OutboundSettings__c='On');
        insert localSystem;
        
        JIENS__Topic__c topicPull = new JIENS__Topic__c(JIENS__TopicArea__c=topicAreaPull.id,JIENS__Name__c='Pull Request',JIENS__SourceSystemID__c=localSystem.id,JIENS__LocalSystemID__c=localSystem.id,JIENS__TopicId__c='45',JIENS__TopicARN__c='arn:aws:sns:us-east-1:854131707530:test-hir-i',JIENS__IsActive__c=true,JIENS__IsRestricted__c=false,JIENS__Scope__c=1,JIENS__TopicExternalID__c='hir.11137');
        insert topicPull;
        
        JIENS__Topic__c topicStub = new JIENS__Topic__c(JIENS__TopicArea__c=topicAreaStub.id,JIENS__Name__c='Affiliation Role Type Stub',JIENS__SourceSystemID__c=localSystem.id,JIENS__LocalSystemID__c=localSystem.id,JIENS__TopicId__c='120',JIENS__TopicARN__c='arn:aws:sns:us-east-1:854131707530:test-hir-i',JIENS__IsActive__c=true,JIENS__IsRestricted__c=true,JIENS__Scope__c=1,JIENS__TopicExternalID__c='hir.11202',JIENS__ObjectName__c='JIACAF__Affiliation_Role_Type__c');
        insert topicStub;
        
        
        JIACAF__Affiliation_Role_Type__c StudentRoleType = new JIACAF__Affiliation_Role_Type__c(Name='Student',JIACAF__SortPosition__c=0,JIACAF__oca__c=1,JIACAF__SelfIdentifying__c=false,JIACAF__IsActive__c=false);
        insert StudentRoleType;
        
        JIENS__External_Record__c extrnlRecord = new JIENS__External_Record__c(JIENS__SystemID__c = sourceSystem.id,JIENS__LocalSystemID__c=localSystem.id, JIENS__ExternalID__c='0',JIENS__InternalID__c=StudentRoleType.id,JIENS__InternalType__c='JIACAF__Affiliation_Role_Type__c',JIENS__RecordType__c='ref_affiliationroletype');
        insert extrnlRecord;
        
        
        PageReference pageRef = Page.RelationShipMigrationPage;
        Test.setCurrentPage(pageRef);
        RelationshipMigrationController ctrl = new RelationshipMigrationController();
        Test.startTest();
            ctrl.executeEventGenerationScript();
            system.assertEquals('3 events for Pull & Stub got created successfully.',ctrl.eventsInfo);
        Test.stopTest();
        
    }
    static testMethod void testScriptNegative() {
        JIENS__Topic_Area__c topicAreaPull = new JIENS__Topic_Area__c(name='Pull Request',JIENS__TopicAreaExternalID__c='ens.304');
        insert topicAreaPull;
        
        JIENS__Topic_Area__c topicAreaStub = new JIENS__Topic_Area__c(name='Stub',JIENS__TopicAreaExternalID__c='ens.301');
        insert topicAreaStub;
        
        JIENS__System__c sourceSystem = new JIENS__System__c(JIENS__Name__c='HIR',JIENS__IsLocal__c=false,JIENS__SystemExternalId__c='1',JIENS__SystemMnemonic__c='staging-hir',JIENS__SystemExternalIdUnique__c='1',JIENS__InboundSettings__c='On',JIENS__OutboundSettings__c='On');
        insert sourceSystem;
        
        JIENS__System__c localSystem = new JIENS__System__c(JIENS__Name__c='HIRCRM',JIENS__IsLocal__c=true,JIENS__SystemExternalId__c='5',JIENS__SystemMnemonic__c='hir-i',JIENS__SystemExternalIdUnique__c='5',JIENS__InboundSettings__c='On',JIENS__OutboundSettings__c='On');
        insert localSystem;
        
        JIACAF__Affiliation_Role_Type__c StudentRoleType = new JIACAF__Affiliation_Role_Type__c(Name='Student',JIACAF__SortPosition__c=0,JIACAF__oca__c=1,JIACAF__SelfIdentifying__c=false,JIACAF__IsActive__c=false);
        insert StudentRoleType;
        
        JIENS__External_Record__c extrnlRecord = new JIENS__External_Record__c(JIENS__SystemID__c = sourceSystem.id,JIENS__LocalSystemID__c=localSystem.id, JIENS__ExternalID__c='0',JIENS__InternalID__c=StudentRoleType.id,JIENS__InternalType__c='JIACAF__Affiliation_Role_Type__c',JIENS__RecordType__c='ref_affiliationroletype');
        insert extrnlRecord;
        
        
        PageReference pageRef = Page.RelationShipMigrationPage;
        Test.setCurrentPage(pageRef);
        RelationshipMigrationController ctrl = new RelationshipMigrationController();
        Test.startTest();
            ctrl.executeEventGenerationScript();
            system.assertEquals('Some problem occurred while creating events',ctrl.eventsInfo);
        Test.stopTest();
        
    }
    
    
    
    
}