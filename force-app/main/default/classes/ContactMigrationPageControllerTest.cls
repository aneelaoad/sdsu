@isTest
public  class ContactMigrationPageControllerTest {
    public Static String contactRecordtypeId = Contact.SobjectType.getdescribe().getRecordTypeInfosByName().get('HIRCRM').getRecordTypeId();
    
    static testMethod void testContactDataMigration() {
        Boolean isBatchComplete = true;
        PageReference pageRef = Page.ContactMigrationPage;
        Test.setCurrentPage(pageRef);
        ContactMigrationPageController ctrl = new ContactMigrationPageController();
        Test.startTest();
            ctrl.exeContactMigrationBatch();
            ctrl.exeExternalRecMigrationBatch();
            ctrl.pollBatchResult();
        Test.stopTest();
        ctrl.pollBatchResult();
        
        AsyncApexJob job = [SELECT Id,
                                   ApexClass.Name,
                                   NumberOfErrors
                            FROM AsyncApexJob
                            WHERE Id = :ctrl.currentJobId
                            LIMIT 1];
        System.assertEquals(0, job.NumberOfErrors);
    }
}