@istest
public class TestDataCreation{


    public static void createData(){
    
        Integer limitVal = 150;
        
        
        
        JIENS__System__c systemREc = new JIENS__System__c();
        insert systemREc;
        
        // Reference
       List<JIHIRCRM__Reference__c> refLst = new List<JIHIRCRM__Reference__c>();
        for(Integer i=0;i<=limitVal;i++){
            JIHIRCRM__Reference__c  refRecords = new JIHIRCRM__Reference__c();  
            refRecords.recordTypeId = '01228000000AV8b';
            refLst.add(refRecords); 
            
        }    
        Insert refLst;
        
        
        // External Records
        List<JIENS__External_Record__c  > extRecLst = new List<JIENS__External_Record__c>();
        for(Integer i=0;i<=limitVal;i++){
            JIENS__External_Record__c  extRec = new JIENS__External_Record__c();
            extRec.JIENS__InternalID__c = refLst[i].id;
            extRec.JIENS__ExternalID__c = refLst[i].id;
            extRec.JIENS__SystemID__c = systemREc.id;
            extRec.JIENS__InternalType__c = 'JIHIRCRM__Reference__c';
            extRec.JIENS__RecordType__c = 'ref__affiliationroletype';
            extRecLst.add(extRec );
            
        }
       // Insert extRecLst;
        
        
        // Account
        List<Account> accLst = new List<Account>();
        for(Integer i=0;i<=limitVal;i++){
            Account accRec = new Account();
            accRec.Name = 'Test Account '+i;   
            accLst.add(accRec);
        }
        insert accLst;
        
        //Contact
        List<Contact> conLst = new List<Contact>();
        for(Integer i=0;i<=limitVal;i++){
            Contact conObj = new Contact();
            conObj.LastName = 'Test LastName '+i;
            conLst.add(conObj);
        }
        insert conLst;
        
        // Account Affiliation
        List<JIHIRCRM__Account_Affiliation__c> accAffLst = new List<JIHIRCRM__Account_Affiliation__c>();
        for(Integer i=0;i<=limitVal;i++){
            JIHIRCRM__Account_Affiliation__c accAffRec = new JIHIRCRM__Account_Affiliation__c();
            accAffRec.JIHIRCRM__Account__c = accLst[i].id;
            accAffRec.JIHIRCRM__Contact__c = conLst[i].id;
            accAffRec.JIHIRCRM__AffiliationType__c = refLst[i].id;
            accAffLst.add(accAffRec);
        }
        insert accAffLst;
        
        
        //External Records
        List<JIENS__External_Record__c> extLstNew = new List<JIENS__External_Record__c>();
        for(Integer i=0;i<=limitVal;i++){
            JIENS__External_Record__c  extRec = new JIENS__External_Record__c();
            extRec.JIENS__InternalID__c = accAffLst[i].id;
            extRec.JIENS__ExternalID__c = accAffLst[i].id;
            extRec.JIENS__SystemID__c = systemREc.id;
            extRec.JIENS__InternalType__c = 'JIHIRCRM__Account_Affiliation__c';
            extLstNew.add(extRec );
        }
        extRecLst.addAll(extLstNew);
        insert extRecLst;
        
    
    
    }




}