global class DataMigrationBatchAccountAffiliation implements Database.batchable<sobject>,Database.stateful{ 
   String query = 'SELECT id, JIACAF__StatusID__c ,JIACAF__IsActive__c FROM JIACAF__Account_Affiliation__c WHERE JIACAF__StatusID__c = null';
   static final Set<String> setExternalIds = New Set<String>{'1','2'};
   Map<String,String> mapStatusExtIdSfId = New Map<String,String>();
      
   global DataMigrationBatchAccountAffiliation(){
        for(JIENS__External_Record__c objRecord : [SELECT Id,
                                 JIENS__InternalID__c, 
                                 JIENS__ExternalID__c 
                             FROM JIENS__External_Record__c 
                             WHERE JIENS__InternalType__c = :Schema.SobjectType.JIACAF__Affiliation_Role_Type__c.getName()
                             AND JIENS__RecordType__c = 'ref_accountaffiliationstatus' 
                             AND JIENS__ExternalID__c IN :setExternalIds]){
         mapStatusExtIdSfId.put(objRecord.JIENS__ExternalID__c, objRecord.JIENS__InternalID__c);                            
       }
   }
   
   global Database.QueryLocator start(Database.BatchableContext info){ 
       return Database.getQueryLocator(query);
   }    
    
   global void execute(Database.BatchableContext info, List<JIACAF__Account_Affiliation__c> scope){
        List<JIACAF__Account_Affiliation__c> toUpdateList = new List<JIACAF__Account_Affiliation__c>();
        if(mapStatusExtIdSfId.isEmpty() == false && mapStatusExtIdSfId.containskey('1') && mapStatusExtIdSfId.containskey('2')){
            for(JIACAF__Account_Affiliation__c accAffObj : scope){
                if(accAffObj.JIACAF__IsActive__c == true){
                    accAffObj.JIACAF__StatusID__c =  mapStatusExtIdSfId.get('1');
                    toUpdateList.add(accAffObj);
                }
                else{
                    accAffObj.JIACAF__StatusID__c = mapStatusExtIdSfId.get('2');
                    toUpdateList.add(accAffObj);
                }
            }
        }
        if(toUpdateList.isEmpty() == false){
          //Issue 9515 : Note #3,Added boolean flag
          JIACAF.AccountAffValidationTriggerHandler.isPreventRoleTypeValidation = true;
            Database.update(toUpdateList,false);
            JIACAF.AccountAffValidationTriggerHandler.isPreventRoleTypeValidation = false;
        }
   }   
     
   global void finish(Database.BatchableContext info){ 
   } 
}