public class ContactExternalRecMigrationBatch implements Database.Batchable<sObject>,Database.Stateful{
    public static final String strContactObjName = 'Contact';  
    
    public ContactExternalRecMigrationBatch() {}
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,
                                                Name, 
                                                JIHIRCRM__FirstName__c,
                                                JIHIRCRM__PersonID__c,
                                                JIHIRCRM__LastName__c
                                         FROM Contact
                                         WHERE JIHIRCRM__PersonID__c != null
                                         AND recordType.DeveloperName = :Label.HIRCRMContactRecordType]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        set<String> setcontactId = new set<String>();
        set<String> setpersonId = new set<String>();
        List<JIENS__External_Record__c> listExternalRec = new List<JIENS__External_Record__c>();
        for(Contact conObj : scope) {
          
           setcontactId.add(conObj.Id);
           setpersonId.add(String.valueOf(conObj.JIHIRCRM__PersonID__c.intValue()));
        }
        for(JIENS__External_Record__c objExternalRec : [SELECT Id,
                                                               JIENS__SystemID__r.JIENS__SystemExternalId__c,
                                                               JIENS__InternalID__c,
                                                               JIENS__InternalType__c,
                                                               JIENS__RecordType__c,
                                                               JIENS__ExternalID__c 
                                                        FROM JIENS__External_Record__c 
                                                        WHERE JIENS__InternalType__c = :strContactObjName 
                                                        AND JIENS__InternalID__c IN :setcontactId
                                                        AND JIENS__ExternalID__c IN :setpersonId
                                                        AND JIENS__SystemID__r.JIENS__SystemExternalId__c = '1'
                                                        AND JIENS__RecordType__c = '']) {
            objExternalRec.JIENS__RecordType__c = Label.HIRCRMContactRecordType; 
            listExternalRec.add(objExternalRec);
        }
       if(listExternalRec.isEmpty() == false) {
           update listExternalRec;
       }
    }
    
    public void finish(Database.BatchableContext BC) {
    
    } 
}