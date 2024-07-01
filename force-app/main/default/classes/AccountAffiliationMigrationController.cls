public with sharing class AccountAffiliationMigrationController {

    public Id pollAffRoleTypeBatchId;
    public Id pollAccAffBatchId;
    public Id pollAffRoleTypeExtRecBatchId;
    public Id pollAccAffExtRecBatchId;

    public Boolean poll {get; set;}

    public JobDetail job {get; set;}
    public AsyncApexJob asyncJob {get; set;}
    public Integer step {get; set;}
    public Boolean renderBatchResults {get; set;}
    public List<JobDetail> jobs {get; set;}
    public Set<Id> jobIds {get; set;}

    public static final String COMPLETED = 'Completed';
    public static final String MIGRATE_REF_BATCH = 'MigrateAffiliationRoleTypeBatch';
    public static final String MIGRATE_ACAF_BATCH = 'MigrateAccountAffiliationBatch';
    public static final String UPDATE_EXTERNAL_AFF_ROLE_BATCH = 'UpdateExternalRecordsForReference';
    public static final String UPDATE_EXTERNAL_ACAF_BATCH = 'UpdateExternalRecordsForAffiliation';
    public static final String AFF_ROLE_TYPE_OBJ = 'JIACAF__Affiliation_Role_Type__c';
    public static final String ACC_AFF_OBJ = 'JIACAF__Account_Affiliation__c';
    public static final String EXTERNAL_RECORD_OBJ = 'JIENS__External_Record__c';

    public AccountAffiliationMigrationController() {
        poll = false;
        renderBatchResults = false;
        jobIds = new Set<Id>();
        job = new JobDetail();
    }

    public PageReference exeAffRoleTypeBatch() {
        pollAffRoleTypeBatchId = Database.executeBatch(new MigrateAffiliationRoleTypeBatch(), 200);
        step = 1;
        getBatchJob(pollAffRoleTypeBatchId);
        jobIds.add(pollAffRoleTypeBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    public PageReference exeAccAffBatch() {
        pollAccAffBatchId = Database.executeBatch(new MigrateAccountAffiliationBatch(), 200);
        step = 2;
        getBatchJob(pollAccAffBatchId);
        jobIds.add(pollAccAffBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    public PageReference exeAffRoleTypeExternalRecBatch() {
        pollAffRoleTypeExtRecBatchId = Database.executeBatch(new UpdateExternalRecordsForReference(), 200);
        step = 3;
        getBatchJob(pollAffRoleTypeExtRecBatchId);
        jobIds.add(pollAffRoleTypeExtRecBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    public PageReference exeAccAffTypeExternalRecBatch() {
        pollAccAffExtRecBatchId = Database.executeBatch(new UpdateExternalRecordsForAffiliation(), 200);
        step = 4;
        getBatchJob(pollAccAffExtRecBatchId);
        jobIds.add(pollAccAffExtRecBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    /* Polls batch results */
    public PageReference pollAffRoleTypeAction() {
        Id jobId = null;
        if(step == 1)
            jobId = pollAffRoleTypeBatchId;
        else if(step == 2)
            jobId = pollAccAffBatchId;
        else if(step == 3)
            jobId = pollAffRoleTypeExtRecBatchId;
        else if(step == 4)
            jobId = pollAccAffExtRecBatchId;

        getBatchJob(jobId);
        getBatchJobs();
        if(asyncJob.Status == COMPLETED) {
            poll = false;
        }
        return null;
    }

    /* Returns current batch job based on jobId parameter */
    private void getBatchJob(Id jobId) {
        Set<String> classNames = new Set<String>{'MigrateAffiliationRoleTypeBatch',
                                                 'MigrateAccountAffiliationBatch'};
        asyncJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                           CreatedBy.Email, ExtendedStatus, ApexClass.Name,
                           CompletedDate, CreatedDate
                    FROM AsyncApexJob
                    WHERE Id = :jobId
                    limit 1];
        job = createJobDetail(asyncJob);
    }

    /* Returns list of batch jobs to be shown in history */
    private void getBatchJobs() {
        jobs = new List<JobDetail>();
        for(AsyncApexJob thisJob : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                                           CreatedBy.Email, ExtendedStatus, ApexClass.Name,
                                           CompletedDate, CreatedDate
                                    FROM AsyncApexJob
                                    WHERE Id IN :jobIds]) {
            jobs.add(createJobDetail(thisJob));
        }
    }

    /* Toggle renderBatchResults */
    private void toggleResultsFlag() {
        renderBatchResults = true;
    }

    /* Created wrapper object for Job */
    private JobDetail createJobDetail(AsyncApexJob job) {
        JobDetail jd = new JobDetail();
        jd.asyncJob = job;
        if(job.Status == COMPLETED) {
            jd.timeTaken = calcTimeTaken(job);
            if(job.ApexClass.Name == MIGRATE_REF_BATCH) {
                jd.noOfRecords = getNoOfRecordsInserted(AFF_ROLE_TYPE_OBJ);
            }
            else if(job.ApexClass.Name == MIGRATE_ACAF_BATCH) {
                jd.noOfRecords = getNoOfRecordsInserted(ACC_AFF_OBJ);
            }
            else if(job.ApexClass.Name == UPDATE_EXTERNAL_AFF_ROLE_BATCH) {
                //jd.noOfRecords = Database.getUpdated(EXTERNAL_RECORD_OBJ, job.CreatedDate, job.CompletedDate).getIds().size();
                jd.noOfRecords = getNoOfExternalRecordsUpdated(job);
            }
            else if(job.ApexClass.Name == UPDATE_EXTERNAL_ACAF_BATCH) {
                //jd.noOfRecords = Database.getUpdated(EXTERNAL_RECORD_OBJ, job.CreatedDate, job.CompletedDate).getIds().size();
                jd.noOfRecords = getNoOfExternalRecordsUpdated(job);
            }
            else {
                jd.noOfRecords = null;
            }
        }
        else {
            jd.timeTaken = '';
        }
        return jd;
    }

    /* Calculates time taken for a batch execution */
    private String calcTimeTaken(AsyncApexJob job) {
        Long timeInMillis = job.CompletedDate.getTime() - job.CreatedDate.getTime();
        Integer hh = Integer.valueOf((timeInMillis / (1000.0*60.0*60.0)).round(System.RoundingMode.DOWN));
        Integer mm = Integer.valueOf((timeInMillis / (1000.0*60.0)).round(System.RoundingMode.DOWN));
        Integer ss = Integer.valueOf((timeInMillis / 1000.0).round(System.RoundingMode.DOWN));
        return ''
                + ((hh < 10) ? '0'+String.valueOf(hh) : ''+hh) + ':'
                + ((mm < 10) ? '0'+String.valueOf(mm) : ''+mm) + ':'
                + ((ss < 10) ? '0'+String.valueOf(ss) : ''+ss);
    }

    /* Returns no of records of an object */
    private Integer getNoOfRecordsInserted(String objName) {
        return Database.query('select Id from '+objName).size();
    }

    /* Returns no of records of an object */
    private Integer getNoOfExternalRecordsUpdated(AsyncApexJob job) {
        return [select Id
                from JIENS__External_Record__c
                where LastModifiedDate >= :job.CreatedDate
                  AND LastModifiedDate <= :job.CompletedDate].size();
    }

}