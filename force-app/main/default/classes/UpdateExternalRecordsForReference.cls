/* 
 * Description : 
 */
global class UpdateExternalRecordsForReference implements Database.batchable<sObject>{
    
    global UpdateExternalRecordsForReference(){}
    
   
    public Database.queryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Affiliation_Role_Id__c,
                                                Id
                                          FROM JIACAF__Affiliation_Role_Type__c
                                          WHERE Affiliation_Role_Id__c != null]);
    }
    
    public void execute(Database.BatchableContext BC, List<JIACAF__Affiliation_Role_Type__c> scope){
        Set<String> affiliationIds = new Set<String>();
        Map<String,Id> affiliationIdMap = new Map<String,Id>();
        List<JIENS__External_Record__c> extLsttoUpdate = new List<JIENS__External_Record__c>();
        
        for(JIACAF__Affiliation_Role_Type__c scopeItr : scope){
            affiliationIds.add(scopeItr.Affiliation_Role_Id__c+'%');
            affiliationIdMap.put(scopeItr.Affiliation_Role_Id__c,scopeItr.id);
            //scopeItr.Affiliation_Role_Id__c = '';
        }
        system.debug('affiliation===='+affiliationIds);
        for(JIENS__External_Record__c objExternal : [SELECT Id,
                                                            JIENS__InternalID__c,
                                                            JIENS__InternalType__c
                                                       FROM JIENS__External_Record__c 
                                                      WHERE JIENS__UniqueKey__c LIKE :affiliationIds]){
            
            if(affiliationIdMap.containsKey(objExternal.JIENS__InternalID__c)){
                objExternal.JIENS__InternalID__c = affiliationIdMap.get(objExternal.JIENS__InternalID__c);
                objExternal.JIENS__InternalType__c = Schema.JIACAF__Affiliation_Role_Type__c.sObjectType.getDescribe().getName();
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