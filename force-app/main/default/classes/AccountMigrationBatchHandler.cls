/*
* Batch handler for processing the csv file for account migration
*
* Revision History:
*
* Version     Author           Date         Description
* 1.0                        03/07/2018    Initial Draft
*/
public with sharing class AccountMigrationBatchHandler {
    public static String execute(String externalIdPairString, Integer deleteIndex, Integer replaceIndex, string SEPERATOR) {
        List<String> accountRecordDataList = externalIdPairString.split(SEPERATOR);
        System.debug('accountRecordDataList'+ accountRecordDataList);

        List<String> externalIdList = new List<String>{accountRecordDataList[deleteIndex], accountRecordDataList[replaceIndex]};
        System.debug('externalIdList'+ externalIdList);

        if(externalIdList.size() < 2 || String.isBlank(externalIdList[0]) || String.isBlank(externalIdList[1])) {
            // return externalIdPairString + SEPERATOR + System.Label.Acc_Migration_Blank_Value_Err_Msg;
            return externalIdPairString + SEPERATOR + 'System.Label.Acc_Migration_Blank_Value_Err_Msg';
        } else {
            List<JIENS__External_Record__c> externalRecordList = [
                SELECT Id
                     , JIENS__InternalID__c
                     , JIENS__ExternalID__c
                  FROM JIENS__External_Record__c
                 WHERE JIENS__ExternalID__c IN :externalIdList
                   AND JIENS__InternalType__c = 'Account'
            ];

            if(externalRecordList.size() < 2) {
                // external records not found
                // String errorMessage = System.Label.Acc_Migration_Ext_Rec_Not_Found_Err_Msg;
                String errorMessage = 'System.Label.Acc_Migration_Ext_Rec_Not_Found_Err_Msg';
                if(externalRecordList.size() == 0) {
                    errorMessage = errorMessage.replace('<1>', externalIdList[0]);
                    errorMessage = errorMessage.replace('<2>', ' and ' + externalIdList[1]);
                } else if(externalRecordList.size() == 1) {
                    if(externalIdList.indexOf(externalRecordList[0].JIENS__ExternalID__c) == 0) {
                        errorMessage = errorMessage.replace('<1>', externalIdList[1]);
                    } else {
                        errorMessage = errorMessage.replace('<1>', externalIdList[0]);
                    }
                    errorMessage = errorMessage.replace('<2>', '');
                }
                return externalIdPairString + SEPERATOR + errorMessage;
            } else {
                Map<String, JIENS__External_Record__c> externalRecordMap = new Map<String, JIENS__External_Record__c>();
                for(JIENS__External_Record__c externalRecord : externalRecordList) {
                    externalRecordMap.put(externalRecord.JIENS__ExternalID__c, externalRecord);
                }
                System.debug('0----------'+ externalRecordMap.get(accountRecordDataList[deleteIndex]).JIENS__InternalID__c);
                System.debug('1----------'+ externalRecordMap.get(accountRecordDataList[replaceIndex]).JIENS__InternalID__c);

                try {
                    List<sObject> sObjectList = updateRelatedSObjectRecords(externalRecordMap.get(accountRecordDataList[deleteIndex]).JIENS__InternalID__c, externalRecordMap.get(accountRecordDataList[replaceIndex]).JIENS__InternalID__c);
                    System.debug('sObjectList.size()----------'+ sObjectList.size());

                    if(sObjectList.size() >= 9995) {
                        // too many related records
                        // return externalIdPairString + SEPERATOR + System.Label.Acc_Migration_Too_Many_Relared_Recs_Err_Msg;
                        return externalIdPairString + SEPERATOR + 'System.Label.Acc_Migration_Too_Many_Relared_Recs_Err_Msg';
                    } else {
                        update sObjectList;

                        List<Account> accountToUnlink = [
                            SELECT Id
                                 , JIHIRCRM__AccountID__c
                              FROM Account
                             WHERE Id = :externalRecordMap.get(accountRecordDataList[deleteIndex]).JIENS__InternalID__c
                        ];
                        System.debug('accountToUnlink----------'+ accountToUnlink);

                        if(!accountToUnlink.isEmpty()) {
                            try {
                                System.debug('accountToUnlink----------'+ accountToUnlink);
                                System.debug('ext record----------'+ externalRecordMap.get(accountRecordDataList[deleteIndex]));
                                delete accountToUnlink;
                                delete externalRecordMap.get(accountRecordDataList[deleteIndex]);
                            } catch(DmlException e) {
                                // dml exception for sObjectList
                                return externalIdPairString + SEPERATOR + e.getMessage();
                            }
                        } else {
                            // Account not present
                            String errorMessage = System.Label.Acc_Migration_Acc_Rec_Not_Found_Err_Msg;
                            System.debug('errorMessage----------'+ errorMessage);
                            errorMessage = errorMessage.replace('<1>', externalRecordMap.get(accountRecordDataList[deleteIndex]).JIENS__InternalID__c);
                            System.debug('errorMessage----------'+ errorMessage);
                            return externalIdPairString + SEPERATOR + errorMessage;
                        }
                    }
                } catch(DmlException e) {
                    // dml exception for account
                    return externalIdPairString + SEPERATOR + e.getMessage();
                }
            }
        }
        return '';
    }

    public static List<sObject> updateRelatedSObjectRecords(String idToReplace, String newID) {
        List<sObject> sObjectList = new List<sObject>();

        for(JIACAF__Account_Affiliation__c accountAffiliation : [ SELECT Id
                                                               , JIACAF__Account__c
                                                            FROM JIACAF__Account_Affiliation__c
                                                           WHERE JIACAF__Account__c = :idToReplace ]) {
            accountAffiliation.JIACAF__Account__c = newID;
            sObjectList.add(accountAffiliation);
        }

        for(JIHIRCRM__Membership__c membership : [ SELECT Id
                                              , JIHIRCRM__AccountID__c
                                           FROM JIHIRCRM__Membership__c
                                          WHERE JIHIRCRM__AccountID__c = :idToReplace ]) {
            membership.JIHIRCRM__AccountID__c = newID;
            sObjectList.add(membership);
        }

        for(JIHIRCRM__HiRActivity__c activity : [ SELECT Id
                                             , JIHIRCRM__AccountID__c
                                          FROM JIHIRCRM__HiRActivity__c
                                         WHERE JIHIRCRM__AccountID__c = :idToReplace ]) {
            activity.JIHIRCRM__AccountID__c = newID;
            sObjectList.add(activity);
        }

        for(JIHIRCRM__HiRInquiry__c inquiry : [ SELECT Id
                                           , JIHIRCRM__AccountID__c
                                        FROM JIHIRCRM__HiRInquiry__c
                                       WHERE JIHIRCRM__AccountID__c = :idToReplace ]) {
            inquiry.JIHIRCRM__AccountID__c = newID;
            sObjectList.add(inquiry);
        }

        for(JIHIRCRM__HiRWaitList__c waitList : [ SELECT Id
                                             , JIHIRCRM__Account__c
                                          FROM JIHIRCRM__HiRWaitList__c
                                         WHERE JIHIRCRM__Account__c = :idToReplace ]) {
            waitList.JIHIRCRM__Account__c = newID;
            sObjectList.add(waitList);
        }

        return sObjectList;
    }

    public static void generateErrorLogs(Id batchId, String csvData, Integer count, string strHeader, Integer MAXFILESIZE) {
        String csvToAdd = '\r\n' + csvData;
        JIENS__ErrorLogs__c errorLog;
        Attachment attach;

        List<JIENS__ErrorLogs__c> errorLogList = [
            SELECT Id
                 , JIENS__RecordID__c
              FROM JIENS__ErrorLogs__c
             WHERE JIENS__RecordID__c = :batchId
        ];
        System.debug('errorLogList----------'+ errorLogList);

        if(!errorLogList.isEmpty()) {
            errorLog = errorLogList[0];

            List<Attachment> attachmentList = [
                SELECT id
                     , parentId
                     , BodyLength
                     , Body
                  FROM Attachment
                 WHERE parentId = :errorLog.Id
              ORDER BY Name DESC
                 LIMIT 1
            ];
            System.debug('attachmentList----------'+ attachmentList);

            if(!attachmentList.isEmpty() && attachmentList[0].BodyLength + csvToAdd.length() < MAXFILESIZE) {
                attach = attachmentList[0];
                attach.Body = Blob.valueof(attach.Body.toString() + csvToAdd);
            } else {
                attach = new Attachment();
                attach.Body = Blob.valueof(strHeader + csvToAdd);
                attach.parentId = errorLog.Id;
                attach.Name = 'Error_' + batchId + '_' + count++ + '.csv';
            }
        } else {
            errorLog = new JIENS__ErrorLogs__c(JIENS__RecordID__c = batchId);
            insert errorLog;

            attach = new Attachment();
            attach.Body = Blob.valueof(strHeader + csvToAdd);
            attach.parentId = errorLog.Id;
            attach.Name = 'Error_' + batchId + '_' + count++ + '.csv';
        }
        System.debug('errorLog----------'+ errorLog);
        System.debug('attach----------'+ attach);

        upsert attach;
    }
}