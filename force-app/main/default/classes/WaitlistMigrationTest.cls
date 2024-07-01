@isTest
private class WaitlistMigrationTest
{
    private static String moduleId = JIHIRCRM__Reference__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('ref_sourcemodule').getRecordTypeId();
    private static String sectionId = JIHIRCRM__Product__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Section').getRecordTypeId();
    private static Integer WAITLISTID = 100;

    @isTest
    static void migrateWaitlist()
    {
        Pagereference objpage = Page.WaitlistMigration;
        Test.setCurrentpage(objpage);
        WaitlistMigrationController controller = new WaitlistMigrationController();
        Test.starttest();
            controller.migrateWaitlist();           
        Test.stopTest();
        controller.pollAccTypeAction();
        List<JIHIRCRM__HiRWaitList__c> waitlists = [SELECT Id, 
                                                           JIHIRCRM__SourceModule__c, 
                                                           JIHIRCRM__Section__c, 
                                                           JIHIRCRM__Student__c,
                                                           JIHIRCRM__Purchaser__c                                                            
                                                    FROM JIHIRCRM__HiRWaitList__c 
                                                    WHERE JIHIRCRM__WaitListEntryID__c= :WAITLISTID];
        for(JIHIRCRM__HiRWaitList__c waitlist : waitlists){
            system.assertEquals(waitlist.JIHIRCRM__Purchaser__c, waitlist.JIHIRCRM__Student__c);
            system.assertNotEquals(waitlist.JIHIRCRM__SourceModule__c, null);
            system.assertNotEquals(waitlist.JIHIRCRM__Section__c, null);
        }
    }
    @testSetup
    public static void insertWaitlistData(){
        Contact con = new Contact();
        con.lastname = 'Obama';
        insert con;

        JIHIRCRM__Reference__c objRef = New JIHIRCRM__Reference__c();
        objRef.Name = 'HiR';
        objRef.RecordTypeId = moduleId;
        objRef.JIHIRCRM__HubRecordID__c = 123;
        insert objRef;

        JIENS__System__c systemRec = new JIENS__System__c();
        systemRec.JIENS__SystemMetadataExternalID__c = 'hir.1';
        insert systemRec;

        JIENS__External_Record__c externalRec = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '123',
                                                                              JIENS__InternalID__c = objRef.Id,
                                                                              JIENS__InternalType__c = 'JIHIRCRM__Reference__c',
                                                                              JIENS__RecordType__c = 'ref_sourcemodule');
        insert externalRec;

        JIHIRCRM__Product__c objProduct = new JIHIRCRM__Product__c();
        objProduct.Name = 'BE';
        objProduct.JIHIRCRM__ProductID__c = 123;
        objProduct.RecordTypeid = sectionId;
        insert objProduct;

        JIENS__External_Record__c externalRec1 = new JIENS__External_Record__c(JIENS__SystemID__c = systemRec.id,
                                                                              JIENS__ExternalID__c = '123',
                                                                              JIENS__InternalID__c = objProduct.Id,
                                                                              JIENS__InternalType__c = 'JIHIRCRM__Product__c',
                                                                              JIENS__RecordType__c = 'Section');
        insert externalRec1;

        JIHIRCRM__HiRWaitList__c waitlist = new JIHIRCRM__HiRWaitList__c();
        waitlist.JIHIRCRM__Purchaser__c = con.Id;
        waitlist.JIHIRCRM__SectionID__c = 123;
        waitlist.JIHIRCRM__SourceID__c = 123;
        waitlist.JIHIRCRM__WaitListEntryID__c = WAITLISTID;
        insert waitlist;
    }
}