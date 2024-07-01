public with sharing class MigrationBatchHandler {
    public static void execute(List<JIENS__External_Record__c> externalRecordList) {
        Map<Id, Id> externalIdVsSFIDMap = new Map<Id, Id>();
        List<Sobject> recordsToUpdateList = new List<SObject>();
        Map<Id, Sobject> sObjectRecordMap = new Map<Id, Sobject>();
        Map<String, String> mapObjectNameExtIdField = new Map<String, String>();
        Map<String, String> mapObjectNameLocalSysField = new Map<String, String>();
        Map<String, String> mapObjectNameSourceSysField = new Map<String, String>();

        List<sObject_ExternalID_Mapping__mdt> ObjectExternalIDMappingList = [
            SELECT ExternalD_Field_Name__c
                 , ObjectName__c
                 , Source_System__c
                 , Local_System__c
              FROM sObject_ExternalID_Mapping__mdt
        ];

        for(sObject_ExternalID_Mapping__mdt ObjectExternalIDMappingRecord : ObjectExternalIDMappingList) {
            mapObjectNameExtIdField.put(ObjectExternalIDMappingRecord.ObjectName__c.toLowerCase(), ObjectExternalIDMappingRecord.ExternalD_Field_Name__c);
            mapObjectNameLocalSysField.put(ObjectExternalIDMappingRecord.ObjectName__c.toLowerCase(), ObjectExternalIDMappingRecord.Local_System__c);
            mapObjectNameSourceSysField.put(ObjectExternalIDMappingRecord.ObjectName__c.toLowerCase(), ObjectExternalIDMappingRecord.Source_System__c);
        }

        Set<String> sObjectNameList = new Set<String>();
        List<Id> internalIdList = new List<Id>();
        for(JIENS__External_Record__c externalRecord : externalRecordList) {
            sObjectNameList.add(externalRecord.JIENS__InternalType__c);
            internalIdList.add(externalRecord.JIENS__InternalID__c);
        }

        for(String sObjectName : sObjectNameList) {
            String queryToGetRecord = ' SELECT Id ' +
                                        ' FROM ' + sObjectName +
                                       ' WHERE Id IN :internalIdList ';
            for(sObject sObj : Database.query(queryToGetRecord)) {
                sObjectRecordMap.put(sObj.Id, sObj);
            }
        }

        if(!sObjectRecordMap.isEmpty() ) {
            for(JIENS__External_Record__c externalRecord : externalRecordList) {
                if( mapObjectNameExtIdField.containsKey(externalRecord.JIENS__InternalType__c.toLowerCase()) &&
                    mapObjectNameExtIdField.get(externalRecord.JIENS__InternalType__c.toLowerCase()) != null && 
                    mapObjectNameLocalSysField.containsKey(externalRecord.JIENS__InternalType__c.toLowerCase()) &&
                    mapObjectNameLocalSysField.get(externalRecord.JIENS__InternalType__c.toLowerCase()) != null && 
                    mapObjectNameSourceSysField.containsKey(externalRecord.JIENS__InternalType__c.toLowerCase()) &&
                    mapObjectNameSourceSysField.get(externalRecord.JIENS__InternalType__c.toLowerCase()) != null ) {
                    sObject sObjectRecord = sObjectRecordMap.get(Id.valueOf(externalRecord.JIENS__InternalID__c));
                    if(sObjectRecord != null) {
                        sObjectRecord.put(mapObjectNameExtIdField.get(externalRecord.JIENS__InternalType__c.toLowerCase()), Integer.valueOf(externalRecord.JIENS__ExternalID__c));
                        sObjectRecord.put(mapObjectNameLocalSysField.get(externalRecord.JIENS__InternalType__c.toLowerCase()), externalRecord.JIENS__LocalSystemID__c);
                        sObjectRecord.put(mapObjectNameSourceSysField.get(externalRecord.JIENS__InternalType__c.toLowerCase()), externalRecord.JIENS__SystemID__c);
                        recordsToUpdateList.add(sObjectRecord);
                    }
                }
            }
        }

        if(!recordsToUpdateList.isEmpty()) {
            Database.SaveResult[] saveResult = Database.update(recordsToUpdateList, false);
        }

    }
}