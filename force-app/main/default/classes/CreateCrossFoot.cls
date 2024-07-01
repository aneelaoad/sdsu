/* Functionality : This class contains Methods for creating external records and related crossfooting events.
 *
 *
 * Revision History: 
 *
 * Version     Author               Date             Description.
 * 1.0        Dipika Rajput       13/04/2017       Initial Draft.
 */
public class CreateCrossFoot {
public static final String DATATYPE_DOUBLE = 'DOUBLE';
public static void createExternalRecords(List<SObject> lstContact,Set<Id> pSetInternalId, String pObjectName, boolean isUpdate){
        List<JIENS__External_Record__c> lstExternalRecordsToInsert = new List<JIENS__External_Record__c>();
        List<JIENS__External_Record__c> lstExternalRecordsToUpdate = new List<JIENS__External_Record__c>();
        Map<String,Id> mapSystemExternalIdtoId = new Map<String,Id>();
        Set<String> lstLocalSystemId = new Set<String>();
        Set<String> lstSourceSystemExternalId = new Set<String>();
        Map<String,Id> mapUniqueKeyToId = new Map<String,Id>();
        Map<Id,RecordType> mapRecordTypes = New Map<Id,RecordType>([SELECT Id, 
                                                                           DeveloperName 
                                                                     FROM RecordType 
                                                                     WHERE sObjectType = : pObjectName]);
        List<JIENS__Event__c> lstCrossfootingEvents = New List<JIENS__Event__c>();
        Set<String> systemExternalIdSet = new Set<String>();
        Set<Id> localSystemIds = new Set<Id>();
        String strExternalRecordField = '';
        Map<String,JIENSHIRCRM__UnlinkObject__c> MapLinkSetting = JIENSHIRCRM__UnlinkObject__c.getAll();
        if(isUpdate && pSetInternalId != null && !pSetInternalId.isEmpty()){
            for(JIENS__External_Record__c objExternalRecord : [Select Id,
                                                                      JIENS__InternalID__c,
                                                                      JIENS__SystemID__c,
                                                                      JIENS__LocalSystemID__c 
                                                                From JIENS__External_Record__c 
                                                                where JIENS__InternalID__c IN :pSetInternalId]){
                String Key = objExternalRecord.JIENS__InternalID__c + '_' + objExternalRecord.JIENS__SystemID__c + '_' + objExternalRecord.JIENS__LocalSystemID__c;
                mapUniqueKeyToId.put(Key,objExternalRecord.Id);
            }
        }
        
        for(JIENSHIRCRM__UnlinkObject__c settingItr: MapLinkSetting.values()){
            if(settingItr.JIENSHIRCRM__Object__c.EqualsIgnoreCase(pObjectName)){
                if(String.IsNotBlank(settingItr.JIENSHIRCRM__SourceSystem__c) && String.isNotBlank(settingItr.JIENSHIRCRM__LocalSystem__c) && String.isNotBlank(settingItr.JIENSHIRCRM__ExternalId__c)){
                    String strDataType = getFieldDataType(pObjectName,settingItr.JIENSHIRCRM__ExternalId__c);
                    systemExternalIdSet.add(settingItr.JIENSHIRCRM__LocalSystem__c);
                    systemExternalIdSet.add(settingItr.JIENSHIRCRM__SourceSystem__c);
                    lstSourceSystemExternalId.add(settingItr.JIENSHIRCRM__SourceSystem__c + ',' + settingItr.JIENSHIRCRM__LocalSystem__c+','+settingItr.JIENSHIRCRM__ExternalId__c + ',' +  strDataType);               
                }
                
            }
        }
        for(JIENS__System__c objSystem : [SELECT Id,
                                                 JIENS__SystemExternalId__c,
                                                 JIENS__SystemMetadataExternalID__c,
                                                 JIENS__IsLocal__c 
                                            FROM JIENS__System__c 
                                            WHERE JIENS__SystemMetadataExternalID__c IN: systemExternalIdSet]){
            mapSystemExternalIdtoId.put(objSystem.JIENS__SystemMetadataExternalID__c, objSystem.Id);
            if(objSystem.JIENS__IsLocal__c){
                localSystemIds.add(objSystem.id);
            }
        }
        if(!mapSystemExternalIdtoId.isEmpty()){
            for(SObject obj : lstContact){
               for(String systemExternalId : lstSourceSystemExternalId){
                        String[] arrExternalIds = systemExternalId.split(',');
                        String sourceSystemId = mapSystemExternalIdtoId.containsKey(arrExternalIds[0]) ? mapSystemExternalIdtoId.get(arrExternalIds[0]) : null;
                        String localSystemId = mapSystemExternalIdtoId.containsKey(arrExternalIds[1])? mapSystemExternalIdtoId.get(arrExternalIds[1]) : null;
                        String strUniqueKey = obj.Id + '_' + sourceSystemId + '_' + localSystemId;
                        String strExternalIdDataType = arrExternalIds[3];
                       
                        String strExternalId = '';  
                        
                        if(strExternalIdDataType.equalsIgnoreCase(DATATYPE_DOUBLE))
                        {
                            strExternalId = String.valueOf(Integer.valueof(obj.get(arrExternalIds[2])));
                        }
                        else
                        {
                            strExternalId = String.valueOf(obj.get(arrExternalIds[2]));
                        }
                        if(String.IsNotBlank(sourceSystemId) && String.isNotBlank(localSystemId) && String.IsNotBlank(strExternalId)){
                            JIENS__External_Record__c objExternalRecord = createExeternalRecord(pObjectName,
                                                                                                obj,
                                                                                                sourceSystemId,
                                                                                                !mapRecordTypes.isEmpty() && 
                                                                                                    obj.get('RecordTypeId') != null && 
                                                                                                    mapRecordTypes.containsKey(Id.valueOf(String.valueOf(obj.get('RecordTypeId')))) ? 
                                                                                                        mapRecordTypes.get(Id.valueOf(String.valueOf(obj.get('RecordTypeId')))).DeveloperName : null,
                                                                                                String.valueOf(strExternalId),
                                                                                                localSystemId
                                                                                                );
                            if(objExternalRecord != null){
                                if(mapUniqueKeyToId.containsKey(strUniqueKey)){
                                    objExternalRecord.id = mapUniqueKeyToId.get(strUniqueKey);
                                    objExternalRecord.JIENS__UniqueKey__c = '';
                                    objExternalRecord.JIENS__SystemUniqueKey__c = '';
                                    lstExternalRecordsToUpdate.add(objExternalRecord);
                                    
                                }else{
                                    lstExternalRecordsToInsert.add(objExternalRecord);
                                }
                                
                            }                                                                                               
                        }
                }
                
            }
        }
        
        List<JIENS__Topic__c> lstCrossfootingTopics = New List<JIENS__Topic__c>();
        if(!lstExternalRecordsToInsert.isEmpty() || !lstExternalRecordsToUpdate.isEmpty()){
            lstCrossfootingTopics = [SELECT Id, 
                                           JIENS__LocalSystemID__r.JIENS__SystemExternalId__c,
                                           JIENS__SourceSystemID__c, 
                                           JIENS__TopicARN__c, 
                                           JIENS__LocalSystemID__c,
                                           JIENS__TopicId__c
                                      FROM JIENS__Topic__c 
                                      WHERE JIENS__SourceSystemID__c IN: localSystemIds 
                                            AND JIENS__isInitialDataLoad__c = false  
                                            AND JIENS__TopicArea__r.Name = :Label.JIENS.Crossfooting_Event_Topic_Area 
                                            AND JIENS__IsActive__c = true];
        }
        if(!lstExternalRecordsToUpdate.isEmpty()){
            Database.SaveResult[] lstSr = Database.update(lstExternalRecordsToUpdate,false);
            for(Database.SaveResult sr : lstSr){
                if(sr.isSuccess() && !lstCrossfootingTopics.isEmpty()){
                    lstCrossfootingEvents.add(createCrossfootingEvent(sr,lstCrossfootingTopics));
                }
            }
        }
        if(!lstExternalRecordsToInsert.isEmpty()){
             Database.SaveResult[] lstSr = Database.insert(lstExternalRecordsToInsert,false);
             for(Database.SaveResult sr : lstSr){
                if(sr.isSuccess() && !lstCrossfootingTopics.isEmpty()){
                    lstCrossfootingEvents.add(createCrossfootingEvent(sr,lstCrossfootingTopics));
                }
            }
        }
        if(!lstCrossfootingEvents.isEmpty()){
             insert lstCrossfootingEvents;
        }
    }
    
    private static JIENS__Event__c createCrossfootingEvent(Database.SaveResult sr, 
                                                           List<JIENS__Topic__c> lstCrossfootingTopics){
        JIENS__Event__c objEvent =  New JIENS__Event__c();
        objEvent.JIENS__ContentJSON__c = '{ \n"'+ label.JIENSHIRCRM.Id + '":"'+ sr.getId() +'" \n }';
        objEvent.JIENS__EventTime__c = System.today(); 
        objEvent.JIENS__LocalSystem__c = lstCrossfootingTopics[0].JIENS__LocalSystemID__c ; 
        objEvent.JIENS__SourceSystem__c = lstCrossfootingTopics[0].JIENS__SourceSystemID__c ; 
        objEvent.JIENS__Topic__c = lstCrossfootingTopics[0].Id; 
        objEvent.JIENS__TopicId__c = lstCrossfootingTopics[0].JIENS__TopicId__c; 
        objEvent.JIENS__TopicARN__c = lstCrossfootingTopics[0].JIENS__TopicARN__c ; 
        objEvent.JIENS__OriginatingSourceSystemID__c = lstCrossfootingTopics[0].JIENS__LocalSystemID__r.JIENS__SystemExternalId__c; 
        return objEvent;            
    }
    
    public static JIENS__External_Record__c createExeternalRecord(String sObjectName,
                                                                  Sobject sobjRec,
                                                                  String sourceSystemId,
                                                                  String recordTypeId,
                                                                  String pExternalId, 
                                                                  String localSystemId){

        JIENS__External_Record__c externalRec = new JIENS__External_Record__c();
        externalRec.JIENS__InternalType__c = sObjectName;
        externalRec.JIENS__InternalID__c = sObjRec.Id;
        externalRec.JIENS__ExternalID__c = pExternalId;
        externalRec.JIENS__SystemID__c = sourceSystemId;
        externalRec.JIENS__RecordType__c = recordTypeId != null? recordTypeId:'';
        externalRec.JIENS__localSystemId__c = localSystemId;
        return externalRec;

    }
    public static String getFieldAPIName(String pStrObjectName, String pStrFieldLabel) {
       Map<String,Schema.SObjectType> describeObj;
       string originatingfieldLabel;
    
       describeObj = Schema.getGlobalDescribe();
       if(pStrObjectName != null && !String.isEmpty(pStrObjectName)) {
           Schema.DescribeSObjectResult dsResult =  describeObj.get(pStrObjectName).getDescribe();
           if(dsResult != null){
               Map<String, Schema.SObjectField> acRecObjMap = dsResult.fields.getMap();
               for(String strField : acRecObjMap.keySet()){ 
                         Schema.Describefieldresult fieldResult = acRecObjMap.get(strField).getDescribe();
                         If(fieldResult.getLabel() == pStrFieldLabel){
                            originatingfieldLabel = fieldResult.getName();
                             break; 
                         }
                }
           }
       }
       
       return originatingfieldLabel;
    }
    public static String getFieldDataType(String pStrObjectName, String pStrFieldLabel) {
       Map<String,Schema.SObjectType> describeObj;
       string strDataType;
       Integer intScale = -1;
       describeObj = Schema.getGlobalDescribe();
       if(pStrObjectName != null && !String.isEmpty(pStrObjectName)) {
           Schema.DescribeSObjectResult dsResult =  describeObj.get(pStrObjectName).getDescribe();
           if(dsResult != null){
               Map<String, Schema.SObjectField> acRecObjMap = dsResult.fields.getMap();
               for(String strField : acRecObjMap.keySet()){ 
                         Schema.Describefieldresult fieldResult = acRecObjMap.get(strField).getDescribe();
                         If(fieldResult.getName().equalsIgnoreCase(pStrFieldLabel)){
                            Schema.Displaytype dsType = fieldResult.getType();
                            strDataType = String.valueOf(dsType);
                             break; 
                         }
                }
           }
       }
       
       return strDataType;
    }
    
}