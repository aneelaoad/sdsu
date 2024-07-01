global class CreatecrossfootBatch implements Database.Batchable<Sobject>
{
    String obj;
    String query;
    global CreatecrossfootBatch(String SobjectName)
    {
        obj = SobjectName;
    }
     
     global Database.QueryLocator start(Database.BatchableContext BC)
     {
       
         Map<String,List<String>> mapofSobjectToFields = new Map<String,List<String>>();
         List<String>accFields = new List<String>();
         List<String>conFields = new List<String>();
         accFields.add('JIHIRCRM__AccountID__c');
         accFields.add('JIHIRCRM__AccountName__c');
         accFields.add('JIHIRCRM__oca__c');
         conFields.add('JIHIRCRM__PersonID__c');
         conFields.add('JIHIRCRM__LastName__c');
         conFields.add('JIHIRCRM__FirstName__c');
         conFields.add('RecordType.Name');
         mapofSobjectToFields.put('Contact',conFields);
         mapofSobjectToFields.put('Account',accFields);
         if(obj == 'Account')
         {
             query = 'Select Id, ';
             List<String>FieldList = mapofSobjectToFields.get(obj);
             query += String.join(FieldList,',');
             query = query + ' FROM '+ obj + ' WHERE JIHIRCRM__AccountID__c != Null';   
            
         }
         else if(obj == 'Contact')
         {
             query = 'SELECT Id, ';
             List<String>FieldList = mapofSobjectToFields.get(obj);
             query += String.join(FieldList,',');
             query = query + ' FROM '+ obj + ' WHERE JIHIRCRM__PersonID__c != Null'; 
         }
         return Database.getQueryLocator(query);
     }
     global void execute(Database.BatchableContext BC, List<Sobject> objRecordsLst) 
     {
         map<id, Sobject> records = new map<id, Sobject>(objRecordsLst);
         
         CreateCrossFoot.createExternalRecords(records.values(),records.keySet(),obj,False);
     }
     global void finish(Database.BatchableContext BC)
     {
         
     }
}