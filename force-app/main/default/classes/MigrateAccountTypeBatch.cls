/* Batch class for Account Type Migration from Reference object
 *
 * Revision History:
 *
 * Version     Author           Date         Description
 * 1.0         Mujjammil khan   16/08/2016   Initial Draft
 */
global class MigrateAccountTypeBatch implements Database.Batchable<sObject> {

	global Database.QueryLocator start(Database.BatchableContext BC) {
		Schema.DescribeSObjectResult d = JIHIRCRM__Reference__c.SObjectType.getDescribe();
		Map<String, Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
		Id rtId = rtMapByName.get('ref_accounttype').getRecordTypeId();
		
		List<JIACAF__Affiliation_Role_Type__c> lstRoleTypetoUpdate = New List<JIACAF__Affiliation_Role_Type__c>();
		for(JIACAF__Affiliation_Role_Type__c objRec : [SELECT Affiliation_Role_Id__c,
                                                			  Id
                                                       FROM JIACAF__Affiliation_Role_Type__c
                                          			   WHERE Affiliation_Role_Id__c != null]){
            objRec.Affiliation_Role_Id__c = '';
            lstRoleTypetoUpdate.add(objRec);                              	
        }
        // Updating role Id field in case previous migration is done.
		if(!lstRoleTypetoUpdate.isEmpty()){
			update lstRoleTypetoUpdate;
		}
		return Database.getQueryLocator([Select Id, Name, JIHIRCRM__City__c, JIHIRCRM__CountryCode__c,
											JIHIRCRM__Description__c, JIHIRCRM__ErrorLink__c, JIHIRCRM__IsActive__c,
											JIHIRCRM__MaxHours__c, JIHIRCRM__MinHours__c, JIHIRCRM__oca__c,
											JIHIRCRM__OriginatingSourceSystemID__c, JIHIRCRM__SortPosition__c,
											JIHIRCRM__Source__c, JIHIRCRM__State__c
											from JIHIRCRM__Reference__c
											where RecordTypeId = :rtId]);
	}

   	global void execute(Database.BatchableContext BC, List<JIHIRCRM__Reference__c> scope) {
		// 
		Schema.DescribeSObjectResult d = JIACAF__Affiliation_Role_Type__c.SObjectType.getDescribe();
		Map<String, Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
		Id affRoleTypeRTId = rtMapByName.get('ref_accounttype').getRecordTypeId();
		// Iterate on scope and create Affiliation Role Type records
		List<JIACAF__Affiliation_Role_Type__c> affRoleTypes = new List<JIACAF__Affiliation_Role_Type__c>();
		for(JIHIRCRM__Reference__c refRec : scope) {
			JIACAF__Affiliation_Role_Type__c affRoleType = new JIACAF__Affiliation_Role_Type__c();
			affRoleType.Name = refRec.Name;
			affRoleType.JIACAF__City__c = refRec.JIHIRCRM__City__c;
			affRoleType.JIACAF__CountryCode__c = refRec.JIHIRCRM__CountryCode__c;
			affRoleType.JIACAF__Description__c = refRec.JIHIRCRM__Description__c;
			affRoleType.JIACAF__ErrorLink__c = refRec.JIHIRCRM__ErrorLink__c;
			affRoleType.JIACAF__IsActive__c = refRec.JIHIRCRM__IsActive__c;
			affRoleType.JIACAF__MaxHours__c = refRec.JIHIRCRM__MaxHours__c;
			affRoleType.JIACAF__MinHours__c = refRec.JIHIRCRM__MinHours__c;
			affRoleType.JIACAF__oca__c = refRec.JIHIRCRM__oca__c;
			affRoleType.JIACAF__OriginatingSourceSystemID__c = refRec.JIHIRCRM__OriginatingSourceSystemID__c;
			affRoleType.JIACAF__SortPosition__c = refRec.JIHIRCRM__SortPosition__c;
			affRoleType.JIACAF__Source__c = refRec.JIHIRCRM__Source__c;
			affRoleType.JIACAF__State__c = refRec.JIHIRCRM__State__c;
			affRoleType.RecordTypeId = affRoleTypeRTId;
			// Populate field which stores original record Id
			affRoleType.Affiliation_Role_Id__c = refRec.Id;
			affRoleTypes.add(affRoleType);
		}
		insert affRoleTypes;
	}

	global void finish(Database.BatchableContext BC) {

	}

}