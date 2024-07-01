@isTest
private class CleanUpAccountAffiliationCtrlTest {

	 public static Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
	 public static Map<String, Schema.RecordTypeInfo> rtMapByName  = d.getRecordTypeInfosByName();
	 public static Id refRTID = rtMapByName.get('ref_affiliationroletype').getRecordTypeId();

	static testMethod void testDeleteAccountAffiliations() {

		Account accRec = new Account(Name='TestAccount');
	    insert accRec;

	    Contact conRec = new Contact(LastName='TestLastName');
	    insert conRec;

	    JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID , JIHIRCRM__HubRecordID__c =123);
	    insert refRec;

	    JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c
	                                                            (JIHIRCRM__Account__c = accRec.id,
	                                                            JIHIRCRM__Contact__c = conRec.id,
	                                                            JIHIRCRM__AffiliationType__c = refRec.id);
	    insert affiliationRec;

		PageReference pageRef = Page.CleanUpAccountAffiliation;
		Test.setCurrentPage(pageRef);
		CleanUpAccountAffiliationController ctrl = new CleanUpAccountAffiliationController();
        Test.startTest();
            ctrl.exeDeleteAccAffBatch();
			ctrl.pollResults();
        Test.stopTest();

        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollDelAccAffBatchId
                            limit 1];
        System.assertEquals(0, job.NumberOfErrors);
    }

	static testMethod void testDeleteReference() {

		Account accRec = new Account(Name='TestAccount');
	    insert accRec;

	    Contact conRec = new Contact(LastName='TestLastName');
	    insert conRec;

	    JIHIRCRM__Reference__c refRec = new JIHIRCRM__Reference__c(RecordTypeId = refRTID, JIHIRCRM__HubRecordID__c = 123);
	    insert refRec;

	    JIHIRCRM__Account_Affiliation__c affiliationRec = new  JIHIRCRM__Account_Affiliation__c
	                                                            (JIHIRCRM__Account__c = accRec.id,
	                                                            JIHIRCRM__Contact__c = conRec.id,
	                                                            JIHIRCRM__AffiliationType__c = refRec.id);
	    insert affiliationRec;

		PageReference pageRef = Page.CleanUpAccountAffiliation;
		Test.setCurrentPage(pageRef);
		CleanUpAccountAffiliationController ctrl = new CleanUpAccountAffiliationController();
        Test.startTest();
            ctrl.exeDeleteAccAffBatch();
			ctrl.exeDeleteReferenceBatch();
			ctrl.pollResults();
        Test.stopTest();

        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollDelRefBatchId
                            limit 1];
        System.assertEquals(0, job.NumberOfErrors);
    }

}