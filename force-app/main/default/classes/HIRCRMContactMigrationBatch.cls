public  class HIRCRMContactMigrationBatch implements Database.Batchable<sObject>,Database.Stateful {
    public Static String contactRecordtypeId = Contact.SobjectType.getdescribe().getRecordTypeInfosByName().get('HIRCRM').getRecordTypeId();
    
    public HIRCRMContactMigrationBatch() {}
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,
                                                Name, 
                                                JIHIRCRM__FirstName__c,
                                                JIHIRCRM__PersonID__c,
                                                JIHIRCRM__LastName__c
                                         FROM Contact
                                         WHERE JIHIRCRM__PersonID__c != null
                                         AND recordTypeId = null]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
    	list<String> listcontactId = New List<String>();
        for(Contact conObj : scope) {
           conObj.recordTypeId = contactRecordtypeId;
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext BC) {
    
    } 
}