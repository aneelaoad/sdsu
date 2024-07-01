/* This class is for CSV upload functionality of Account Migration
*
* Revision History:
*
* Version     Author           Date         Description
* 1.0                        03/07/2018    Initial Draft
*/
public with sharing class AccountMigrationCsvUploadController {
    public Blob blobCsvFileBody {get; set;}
    public string strCsv {get; set;}
    public Integer intFileSizeVal {get; set;}
    public Id batchId;
    public String strBatchStatus {get; set;}
    public Boolean blnIsPollar {get; set;}
    public Integer intPercentVal {get; set;}
    public List<JIENS__ErrorLogs__c> errorLogList {get; set;}

    public static final Integer FILESIZE = 3145728;
    public static final Integer BATCHSCOPE = Integer.valueOf(label.Acc_Migration_Batch_Scope);
    public static final String STRABORTED = 'Aborted';
    public static final String STRFAILED = 'Failed';
    public static final String STRCOMPLETED = 'Completed';
    public static final String STREXTENSION = '.csv';

    public AccountMigrationCsvUploadController() {
        intPercentVal = 0;
    }

    //This method is for checking batch status to show loading image.
    public PageReference checkBatchStatus() {
        AsyncApexJob job = [
            SELECT Id
                 , Status
                 , TotalJobItems
                 , JobItemsProcessed
                 , ExtendedStatus
                 , NumberOfErrors
             FROM AsyncApexJob
            WHERE Id =: batchId
        ];

        strBatchStatus = job.Status;
        if( job.TotalJobItems > 0  && (job.Status != STRABORTED || job.Status != STRFAILED) &&job.NumberOfErrors == 0 ) {
            intPercentVal = Integer.valueOf((Double.valueOf(job.JobItemsProcessed)/Double.valueOf(job.TotalJobItems))*100);
            if(strBatchStatus == STRCOMPLETED) {
                blnIsPollar = false;
            } else {
                blnIsPollar = true;
            }
        } else if(job.Status == STRABORTED) {
            blnIsPollar = false;
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.Column_Size_Exceed_Error));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'label.Column_Size_Exceed_Error'));
        } else if(job.Status == STRFAILED) {
            blnIsPollar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, job.ExtendedStatus));
        } else if(job.NumberOfErrors > 0) {
            blnIsPollar = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, job.ExtendedStatus));
        }

        errorLogList = [
            SELECT Id
              FROM JIENS__ErrorLogs__c
             WHERE JIENS__RecordID__c = :batchId
             LIMIT 1
        ];

        return null;
    }

    public void processCsv() {
        if(strCsv != null) {
            if(intFileSizeVal > FILESIZE) {
                //maximum attachment size is 3MB.  Show an error
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.File_Size_Error));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'label.File_Size_Error'));
            } else if(!strCsv.endsWithIgnoreCase(STREXTENSION)) {
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,label.File_Format_Error));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'label.File_Format_Error'));
            } else {
                try {
                    AccountMigrationBatch batchObj = new AccountMigrationBatch(blobCsvFileBody);
                    blobCsvFileBody = null;
                    Id batchInstanceId = Database.executeBatch(batchObj, BATCHSCOPE);
                    batchId = batchInstanceId;
                    blnIsPollar = true;
                }
                catch(Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, e.getMessage()));
                }
            }
        } else {
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,label.File_Attach_Error));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'label.File_Attach_Error'));
        }
    }

    public void showFileSizeError() {
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, label.File_Size_Error));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'label.File_Size_Error'));
    }

}