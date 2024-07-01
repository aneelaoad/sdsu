public with sharing class WaitlistMigrationBatchHandler {
    
    public static void migrateRecords(List<JIHIRCRM__HiRWaitList__c> scope){
        Map<String, String> sourceIdLocalId = new Map<String, String>();
        Map<String, String> sectionIdLocalId = new Map<String, String>();
        Set<String> sourceIds = new Set<String>();
        Set<String> sectionIds = new Set<String>();
        List<JIHIRCRM__HiRWaitList__c> waitlistToUpdate = new List<JIHIRCRM__HiRWaitList__c>();

        for(JIHIRCRM__HiRWaitList__c waitlist : scope){         
            sourceIds.add(String.valueOf(Integer.valueOf(waitlist.JIHIRCRM__SourceID__c)));
            sectionIds.add(String.valueOf(Integer.valueOf(waitlist.JIHIRCRM__SectionID__c)));           
        }
        
        fillHiRCrossfootingInfo(sourceIds, 'JIHIRCRM__Reference__c', 'ref_sourcemodule', sourceIdLocalId);      
        fillHiRCrossfootingInfo(sectionIds, 'JIHIRCRM__Product__c', 'Section', sectionIdLocalId);       

        for(JIHIRCRM__HiRWaitList__c waitlist : scope){
            String srcid = String.valueOf(Integer.valueOf(waitlist.JIHIRCRM__SourceID__c));
            String secid = String.valueOf(Integer.valueOf(waitlist.JIHIRCRM__SectionID__c));

            if(sourceIdLocalId.containskey(srcid) && waitlist.JIHIRCRM__SourceModule__c == null){
                waitlist.JIHIRCRM__SourceModule__c = sourceIdLocalId.get(srcid);                
            }
            if(sectionIdLocalId.containskey(secid) && waitlist.JIHIRCRM__Section__c == null){
                waitlist.JIHIRCRM__Section__c = sectionIdLocalId.get(secid);
            }
            if(waitlist.JIHIRCRM__Student__c == null){
                waitlist.JIHIRCRM__Student__c = waitlist.JIHIRCRM__Purchaser__c;
            }
            waitlistToUpdate.add(waitlist);
        }       
        if(!waitlistToUpdate.isEmpty()){
            update waitlistToUpdate;
        }
    }


    public static void fillHiRCrossfootingInfo(Set<String> externalIds, 
                                               String objectName, 
                                               String recordType, 
                                               Map<String,String> crossfootingInfo){
        for(JIENS__External_Record__c externalRec : [SELECT Id, 
                                                            JIENS__ExternalID__c, 
                                                            JIENS__InternalID__c 
                                                    FROM JIENS__External_Record__c 
                                                    WHERE JIENS__ExternalID__c IN :externalIds
                                                    AND JIENS__InternalType__c = :objectName 
                                                    AND JIENS__RecordType__c = :recordType
                                                    AND JIENS__SystemID__r.JIENS__SystemMetadataExternalID__c = 'hir.1']){
            crossfootingInfo.put(externalRec.JIENS__ExternalID__c, 
                                externalRec.JIENS__InternalID__c);
        }
    }
}