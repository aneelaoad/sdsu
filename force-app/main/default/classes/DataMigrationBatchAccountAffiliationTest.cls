@isTest
public class DataMigrationBatchAccountAffiliationTest{

    static List<JIACAF__Account_Affiliation__c> getAccountAffiliation(integer numberOfRecords) {
        List<contact> conList = DataMigrationBatchAccountAffiliationTest.getContact(1);
        List<account> accList = DataMigrationBatchAccountAffiliationTest.getAccount(1);
        List<JIACAF__Affiliation_Role_Type__c> affRoleTypes = DataMigrationBatchAccountAffiliationTest.getAffRoleTypes(1);
        insert(conList);
        insert(accList);
        insert(affRoleTypes);
        List<JIACAF__Account_Affiliation__c> listToReturn = new List<JIACAF__Account_Affiliation__c>();
        for(integer i=0; i< numberOfRecords; i++){
            JIACAF__Account_Affiliation__c accAffObj = new JIACAF__Account_Affiliation__c(name = 'Test Account '+i,
                                                                                          JIACAF__Account__c = accList[0].id,
                                                                                          JIACAF__Contact__c = conList[0].id,
                                                                                          JIACAF__AffiliationType__c = affRoleTypes[0].id);
            listToReturn.add(accAffObj);
        }
        return listToReturn;
    }
    
    static List<JIACAF__Affiliation_Role_Type__c> getAffRoleTypesStatus(integer numberOfRecords) {
        List<JIACAF__Affiliation_Role_Type__c> listToReturn = new List<JIACAF__Affiliation_Role_Type__c>();
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.JIACAF__Affiliation_Role_Type__c; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        for(integer i=0; i< numberOfRecords; i++){
            JIACAF__Affiliation_Role_Type__c affRtypeObj = new JIACAF__Affiliation_Role_Type__c(name = 'Test Account'+i,
                                                                                                JIACAF__IsActive__c = true,
                                                                                                recordTypeId = RecordTypeInfo.get('ref_accountaffiliationstatus').getRecordTypeId());
            listToReturn.add(affRtypeObj);
        }
        return listToReturn;
    }
    static List<JIACAF__Affiliation_Role_Type__c> getAffRoleTypes(integer numberOfRecords) {
        List<JIACAF__Affiliation_Role_Type__c> listToReturn = new List<JIACAF__Affiliation_Role_Type__c>();
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.JIACAF__Affiliation_Role_Type__c; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        for(integer i=0; i< numberOfRecords; i++){
            JIACAF__Affiliation_Role_Type__c affRtypeObj = new JIACAF__Affiliation_Role_Type__c(name = 'Test Account'+i,
                                                                                                JIACAF__IsActive__c = true,
                                                                                                recordTypeId = RecordTypeInfo.get('ref_affiliationroletype').getRecordTypeId());
            listToReturn.add(affRtypeObj);
        }
        return listToReturn;
    }
    
    static List<account> getAccount(integer numberOfRecords) {
        List<account> listToReturn = new List<account>();
        for(integer i=0; i< numberOfRecords; i++){
            account accObj = new account(name = 'Test Account'+i);
            listToReturn.add(accObj);
        }
        return listToReturn;
    }
    
    static List<Contact> getContact(integer numberOfRecords) {
        List<Contact> listToReturn = new List<Contact>();
        for(integer i=0; i< numberOfRecords; i++){
            Contact conObj = new Contact(Lastname = 'Test Account'+i);
            listToReturn.add(conObj);
        }
        return listToReturn;
    }
    
    static testMethod void DataMigrationBatchAccountAffiliation(){
        
        
        List<JIACAF__Account_Affiliation__c> accAffList = DataMigrationBatchAccountAffiliationTest.getAccountAffiliation(2);
        List<JIACAF__Affiliation_Role_Type__c> affRoleTypes = DataMigrationBatchAccountAffiliationTest.getAffRoleTypesStatus(2);
        affRoleTypes[0].name = 'Active';
        affRoleTypes[1].name = 'InActive';
        insert affRoleTypes;
        
        accAffList[0].JIACAF__IsActive__c = true;
        accAffList[1].JIACAF__IsActive__c = false;
        insert accAffList;
        
        JIENS__System__c objSystem = new JIENS__System__c();
        objSystem.JIENS__Name__c = 'Source System';
        objSystem.JIENS__SystemExternalId__c = '1';
        objSystem.JIENS__IsLocal__c = false;
        objSystem.JIENS__OutboundSettings__c = 'On';
        insert objSystem;
        
        JIENS__External_Record__c externalRecord = new JIENS__External_Record__c(JIENS__SystemID__c = objSystem.Id,
                                                                         JIENS__InternalType__c = 'JIACAF__Affiliation_Role_Type__c',
                                                                         JIENS__InternalID__c =  affRoleTypes[0].Id,
                                                                         JIENS__ExternalID__c = '1',
                                                                         JIENS__RecordType__c = 'ref_accountaffiliationstatus');
        JIENS__External_Record__c externalRecord1 = new JIENS__External_Record__c(JIENS__SystemID__c = objSystem.Id,
                                                                         JIENS__InternalType__c = 'JIACAF__Affiliation_Role_Type__c',
                                                                         JIENS__InternalID__c =  affRoleTypes[1].Id,
                                                                         JIENS__ExternalID__c = '2',
                                                                         JIENS__RecordType__c = 'ref_accountaffiliationstatus');
        insert New LIst<JIENS__External_Record__c>{externalRecord, externalRecord1};
        
        Test.startTest();
            Database.executeBatch(new DataMigrationBatchAccountAffiliation());
        Test.stopTest(); 
        List<JIACAF__Account_Affiliation__c> accListToAssert = [SELECT id,JIACAF__IsActive__c ,JIACAF__StatusID__c,JIACAF__StatusID__r.name FROM JIACAF__Account_Affiliation__c WHERE JIACAF__StatusID__c != null];
        system.assert(accListToAssert.isEmpty() == false); 
        for(JIACAF__Account_Affiliation__c obj : accListToAssert){
            if(obj.JIACAF__IsActive__c == true){
                system.assert(obj.JIACAF__StatusID__r.name.equalsIgnoreCase('active'));
            }
        }     
    } 

}