/*
* Batch for processing the csv file for account migration
*
* Revision History:
*
* Version     Author           Date         Description
* 1.0                        03/07/2018    Initial Draft
*/
global with sharing class AccountMigrationBatch implements Database.batchable<string>, Database.Stateful {
    public string strCsvFile;
    public string strHeader;
    public Integer count;
    public Integer deleteIndex;
    public Integer replaceIndex;
    public Blob csvBlob;

    public static final string CR_LF = '\r\n';
    public static final string COMMA = ',';
    public static final Integer STARTING_INDEX = 0;
    public static final Integer MAXFILESIZE = 6291456;

    global AccountMigrationBatch(Blob csvBlob) {
        this.csvBlob = csvBlob;
        count = 1;
    }

    //start() of Batch
    global Iterable<string> start(Database.batchableContext batchableContext) {
        String csvFile = csvBlob.toString();
        csvBlob = null;
        strHeader = csvFile.substring(STARTING_INDEX, csvFile.indexOf(CR_LF));
        deleteIndex = strHeader.split(COMMA).indexOf(System.Label.Acc_Migration_Deleted_Id_Col_Header);
        replaceIndex = strHeader.split(COMMA).indexOf(System.Label.Acc_Migration_Survive_Id_Col_Header);
        System.debug('strHeader '+ strHeader);
        System.debug('deleteIndex '+ deleteIndex);
        System.debug('System.Label.Acc_Migration_Deleted_Id_Col_Header '+ System.Label.Acc_Migration_Deleted_Id_Col_Header);
        System.debug('System.Label.Acc_Migration_Survive_Id_Col_Header '+ System.Label.Acc_Migration_Survive_Id_Col_Header);
        System.debug('replaceIndex '+ replaceIndex);
        strHeader += COMMA + 'Error Reason';
        strCsvFile = csvFile.substring(csvFile.indexOf(CR_LF) + CR_LF.length(), csvFile.length());
        return new CSVIteratorClass(strCsvFile, CR_LF);
    }

    //execute() of batch
    global void execute(Database.BatchableContext batchableContext, List<String> scope) {
        System.debug('scope '+ scope);
        System.debug('deleteIndex '+ deleteIndex);
        System.debug('replaceIndex '+ replaceIndex);
        if(deleteIndex != -1 && replaceIndex != -1) {
            for(String externalIdPairString : scope) {
                String returnString = AccountMigrationBatchHandler.execute(externalIdPairString, deleteIndex, replaceIndex, COMMA);
                System.debug('returnString-------------'+ returnString);
                if(!String.isBlank(returnString)) {
                    AccountMigrationBatchHandler.generateErrorLogs(batchableContext.getJobId(), returnString, count, strHeader, MAXFILESIZE);
                }
            }
        } else {
            AccountMigrationBatchHandler.generateErrorLogs(batchableContext.getJobId(), String.join(scope,CR_LF)+ COMMA + System.Label.Acc_Migration_Header_Not_Found_Err_Msg, count, strHeader, MAXFILESIZE);
        }
    }

    //finish of batch()
    global void finish(Database.BatchableContext batchableContext) {

    }

}