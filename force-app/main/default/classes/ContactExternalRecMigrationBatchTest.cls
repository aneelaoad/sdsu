@isTest
public with sharing class ContactExternalRecMigrationBatchTest {
    
    static testMethod void testContactDataMigration() {
     
     JIENS__System__c sysTestInst = new JIENS__System__c(JIENS__Name__c = 'HIR',
                                               JIENS__Description__c = 'Test System',
                                               JIENS__SystemExternalID__c = '1',
                                               JIENS__IsLocal__c = false);
     insert sysTestInst;
     
     Contact firstObj = new Contact(LastName = 'testContact1',JIHIRCRM__PersonID__c = 1);
     insert firstObj;
     Contact secondObj = new Contact(LastName = 'testContact2',JIHIRCRM__PersonID__c = 2);
     insert secondObj;
     
     JIENS__External_Record__c exeobjfirst = new JIENS__External_Record__c(JIENS__ExternalID__c = '1',
                                                                           JIENS__InternalID__c = firstObj.id,
                                                                           JIENS__InternalType__c = 'Contact',
                                                                           JIENS__SystemID__c = sysTestInst.id);
     insert exeobjfirst;
     
     JIENS__External_Record__c exeobjSecond = new JIENS__External_Record__c(JIENS__ExternalID__c = '2',
                                                                           JIENS__InternalID__c = secondObj.id,
                                                                           JIENS__InternalType__c = 'Contact',
                                                                           JIENS__SystemID__c = sysTestInst.id);
     insert exeobjSecond;
     
     Test.startTest();
        database.executebatch(new ContactExternalRecMigrationBatch(),200);
     Test.stopTest();
    }
}