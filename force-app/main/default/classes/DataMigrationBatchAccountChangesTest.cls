@isTest
public class DataMigrationBatchAccountChangesTest{

    static List<Account> getAccounts(integer numberOfRecords) {
        List<Account> listToReturn = new List<Account>();
        for(integer i=0; i< numberOfRecords; i++){
            Account accObj = new Account(name = 'Test Account '+i);
            listToReturn.add(accObj);
        }
        return listToReturn;
    }
    
    static List<JIACAF__Affiliation_Role_Type__c> getAffRoleTypes(integer numberOfRecords) {
        List<JIACAF__Affiliation_Role_Type__c> listToReturn = new List<JIACAF__Affiliation_Role_Type__c>();
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.JIACAF__Affiliation_Role_Type__c; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();  
        for(integer i=0; i< numberOfRecords; i++){
            JIACAF__Affiliation_Role_Type__c affRtypeObj = new JIACAF__Affiliation_Role_Type__c(name = 'Test Account '+i,
                                                                                                recordTypeId = RecordTypeInfo.get('ref_accounttype').getRecordTypeId());
            listToReturn.add(affRtypeObj);
        }
        return listToReturn;
    }
    
    static List<JIHIRCRM__Reference__c> getAccTypes(integer numberOfRecords) {
        List<JIHIRCRM__Reference__c> listToReturn = new List<JIHIRCRM__Reference__c>();
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.JIHIRCRM__Reference__c; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();  
        for(integer i=0; i< numberOfRecords; i++){
            JIHIRCRM__Reference__c affRtypeObj = new JIHIRCRM__Reference__c(recordTypeId = RecordTypeInfo.get('ref_accounttype').getRecordTypeId());
            listToReturn.add(affRtypeObj);
        }
        return listToReturn;
    }
    
    static testMethod void DataMigrationBatch(){
        
        List<Account> accList = DataMigrationBatchAccountChangesTest.getAccounts(2);
        List<JIACAF__Affiliation_Role_Type__c> affRoleTypes = DataMigrationBatchAccountChangesTest.getAffRoleTypes(2);
        List<JIHIRCRM__Reference__c> refAccTypes = DataMigrationBatchAccountChangesTest.getAccTypes(2);
        refAccTypes[0].name = 'Affiliated Organization';
        refAccTypes[0].JIHIRCRM__HubRecordID__c = 123;
        refAccTypes[1].name = 'Affiliated Organization';
        refAccTypes[1].JIHIRCRM__HubRecordID__c = 456;
        insert refAccTypes;
        
        affRoleTypes[0].name = 'Affiliated Organization';
        affRoleTypes[0].Affiliation_Role_Id__c = refAccTypes[0].Id;
        affRoleTypes[1].name = 'Other Than Affiliated Organization';
        affRoleTypes[1].Affiliation_Role_Id__c = refAccTypes[1].Id;
        insert affRoleTypes;
        
        accList[0].JIHIRCRM__OrganizationTypeID__c = refAccTypes[0].id;
        accList[1].JIHIRCRM__OrganizationTypeID__c = refAccTypes[1].id;
        insert accList;
        Test.startTest();
            Database.executeBatch(new DataMigrationForAccountChanges());
        Test.stopTest(); 
        List<Account> accListToAssert = [SELECT id,JIHIRCRM__IsApprovalRequired__c,JIHIRCRM__IsPublic__c FROM Account WHERE JIHIRCRM__IsApprovalRequired__c = true];
        system.assert(accListToAssert.size() == 1);   
    }   

}