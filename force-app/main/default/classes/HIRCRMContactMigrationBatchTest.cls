@isTest
public with sharing class HIRCRMContactMigrationBatchTest {
    public Static String contactRecordtypeId = Contact.SobjectType.getdescribe().getRecordTypeInfosByName().get('HIRCRM').getRecordTypeId();
    
    static testMethod void testContactDataMigration() {
     List<Contact> listContact = new List<Contact>();
     
     Contact firstObj = new Contact(LastName = 'testContact1',JIHIRCRM__PersonID__c = 1);
     listContact.add(firstObj);
     Contact secondObj = new Contact(LastName = 'testContact2',JIHIRCRM__PersonID__c = 2);
     listContact.add(secondObj);
     
     insert listContact;
     
     Test.startTest();
        database.executebatch(new HIRCRMContactMigrationBatch(),200);
     Test.stopTest();
    }
}