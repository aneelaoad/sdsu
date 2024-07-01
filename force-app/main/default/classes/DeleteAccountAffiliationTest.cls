@isTest
private with sharing class DeleteAccountAffiliationTest{

    static testMethod void myUnitTest() {
      Account accRec = new Account(Name='TestAccount');
      insert accRec;
      
      Contact conRec = new Contact(LastName='TestLastName');
      insert conRec;
      
      JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(JIHIRCRM__HubRecordID__c = 123);
      insert refRec;
      
      JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c
                                                              (JIHIRCRM__Account__c = accRec.id,
                                                              JIHIRCRM__Contact__c = conRec.id,
                                                              JIHIRCRM__AffiliationType__c = refRec.id);
      insert affiliationRec;
        
        Test.startTest();
            Database.executeBatch(new DeleteAccountAffiliationBatch());
        Test.stopTest();
        
      System.assertEquals(0, [select Id from JIHIRCRM__Account_Affiliation__c ].size());
    }
}