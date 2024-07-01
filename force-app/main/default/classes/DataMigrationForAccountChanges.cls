global class DataMigrationForAccountChanges implements Database.batchable<sobject>{ 
   
   static final string AFF_ROLE_TYPE_NAME= Label.affRoleTypeName;
   String query = 'SELECT Id, JIHIRCRM__OrganizationTypeID__c, JIACAF__AccountTypeID__c FROM Account' + 
                  ' WHERE JIHIRCRM__OrganizationTypeID__c <> null AND JIACAF__AccountTypeID__c = null';
   
   global Database.QueryLocator start(Database.BatchableContext info){ 
       return Database.getQueryLocator(query);
   }     
   
   global void execute(Database.BatchableContext info, List<Account> scope){
        List<account> accListToUpdate = new List<account>();
        List<account> accList = new List<account>();
        Map<String,String> mapRefIdToRoleTypeId = New Map<String,String>();
        for(JIACAF__Affiliation_Role_Type__c objRoleType : [SELECT Affiliation_Role_Id__c,
                                                                   Id
                                                            FROM JIACAF__Affiliation_Role_Type__c
                                                            WHERE Affiliation_Role_Id__c != null]){
            mapRefIdToRoleTypeId.put(objRoleType.Affiliation_Role_Id__c, objRoleType.Id);
        }
        for(Account accObj : scope){
            if(accObj.JIHIRCRM__OrganizationTypeID__c <> null && 
                mapRefIdToRoleTypeId.containsKey(accObj.JIHIRCRM__OrganizationTypeID__c)){
                accObj.JIACAF__AccountTypeID__c = mapRefIdToRoleTypeId.get(accObj.JIHIRCRM__OrganizationTypeID__c);
                accListToUpdate.add(accObj);
            }
        }
        if(accListToUpdate.isEmpty() == false){
            update accListToUpdate;
        }
        for(Account accObj : [SELECT id, 
                                     JIHIRCRM__OrganizationTypeID__c, 
                                     JIACAF__AccountTypeID__c ,
                                     JIACAF__AccountTypeID__r.name 
                              FROM Account 
                              WHERE Id IN : scope]){
            
            if(accObj.JIACAF__AccountTypeID__c != null){
                accObj.JIHIRCRM__IsPublic__c = false;
                if(accObj.JIACAF__AccountTypeID__r.Name.equalsIgnoreCase(AFF_ROLE_TYPE_NAME)){
                    accObj.JIHIRCRM__IsApprovalRequired__c = true;     
                }
                else{
                    accObj.JIHIRCRM__IsApprovalRequired__c= false;
                }
                accList.add(accObj);
            }
        }
        if(accList.isEmpty() == false){
            update accList; 
        }
   }     
   
   global void finish(Database.BatchableContext info){ 
    
   } 
}