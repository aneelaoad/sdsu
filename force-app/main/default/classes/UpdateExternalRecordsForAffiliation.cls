/* 
 * Description : Batch class for deleting sObject 
 */
global class UpdateExternalRecordsForAffiliation implements Database.batchable<sObject>{
    
    global UpdateExternalRecordsForAffiliation(){}
    
   
    public Database.queryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Affiliation_Id__c,
						                        Id
						                   FROM JIACAF__Account_Affiliation__c
						                  WHERE Affiliation_Id__c != null]);
    }
    
    public void execute(Database.BatchableContext BC, List<JIACAF__Account_Affiliation__c> scope){
        Set<String> affiliationIds = new Set<String>();
        Map<String,Id> affiliationIdMap = new Map<String,Id>();
        List<JIENS__External_Record__c> extLsttoUpdate = new List<JIENS__External_Record__c>();
        
        for(JIACAF__Account_Affiliation__c scopeItr : scope){
            affiliationIds.add(scopeItr.Affiliation_Id__c+'%');
            affiliationIdMap.put(scopeItr.Affiliation_Id__c,scopeItr.id);
            scopeItr.Affiliation_Id__c = '';
        }
        
        for(JIENS__External_Record__c objExternal : [SELECT Id,
                                                            JIENS__InternalID__c,
                                                            JIENS__InternalType__c
                                                       FROM JIENS__External_Record__c 
                                                      WHERE JIENS__UniqueKey__c LIKE :affiliationIds]){
            
            if(affiliationIdMap.containsKey(objExternal.JIENS__InternalID__c)){
                objExternal.JIENS__InternalID__c = affiliationIdMap.get(objExternal.JIENS__InternalID__c);
                objExternal.JIENS__InternalType__c = Schema.JIACAF__Account_Affiliation__c.sObjectType.getDescribe().getName();
                extLsttoUpdate.add(objExternal);
            }
        }
        
        if(!extLsttoUpdate.isEmpty()){
            update extLsttoUpdate;
        }
        
        update scope;
    }
   
    // Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext
    public void finish(Database.BatchableContext BC){
       
    }
}