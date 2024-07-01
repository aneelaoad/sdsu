/* Test class for ExternalRecordTriggerHandler
 *
 * Revision History:
 *
 * Version     Author           Date         Description
 * 1.0         Ajinkya H        23/02/2016   Initial Draft
 */

@isTest
private class ExternalRecordTriggerHandlerTest {

 	static testMethod void testEventRaised() {
		// Create System Records for local and target
		List<JIENS__System__c> systems = new List<JIENS__System__c>();
		JIENS__System__c rcaSystem = new JIENS__System__c(JIENS__Name__c = 'rca',
														  JIENS__IsLocal__c = true);
		JIENS__System__c olaSystem = new JIENS__System__c(JIENS__Name__c = 'ola',
														  JIENS__IsLocal__c = false);
		insert rcaSystem;
		insert olaSystem;
		// Create External Record
		JIENS__External_Record__c externalRec = new JIENS__External_Record__c();
		externalRec.JIENS__SystemID__c = olaSystem.Id;
		externalRec.JIENS__LocalSystemID__c = rcaSystem.Id;
		externalRec.JIENS__ExternalID__c = '1';
		externalRec.JIENS__InternalID__c = '1';
		insert externalRec;

		Test.startTest();
			externalRec.JIENS__InternalID__c = '2';
			update externalRec;
		Test.stopTest();
	}

}