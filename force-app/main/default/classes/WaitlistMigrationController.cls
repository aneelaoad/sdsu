public with sharing class WaitlistMigrationController {
    
    public Id waitlistBatchId;
    public Boolean poll {get; set;}
    public JobDetail job {get; set;}
    public AsyncApexJob asyncJob {get; set;}
    public Integer step {get; set;}
    public Boolean renderBatchResults {get; set;}
    public List<JobDetail> jobs {get; set;}
    public Set<Id> jobIds {get; set;}
    public static final String COMPLETED = 'Completed';
    public static final String MIGRATE_WAITLIST_BATCH = 'WaitlistMigrationBatch';
    public static final String WAITLIST_OBJ = 'JIHIRCRM__HiRWaitList__c';
    public static final String CREATED_DATE = 'LastModifiedDate';

    public WaitlistMigrationController(){
        poll = false;
        renderBatchResults = false;
        jobIds = new Set<Id>();
        job = new JobDetail();
    }

    public pageReference migrateWaitlist(){
        waitlistBatchId = Database.executebatch(new WaitlistMigrationBatch(), 200);
        step = 1;
        getBatchJob(waitlistBatchId);
        jobIds.add(waitlistBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    /* Returns current batch job based on jobId parameter */
    private void getBatchJob(Id jobId) {
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
                                    WHERE Id IN :jobIds
                                    ORDER BY CreatedDate DESC]) {
           // if(thisJob.Id <> job.asyncJob.id || step == 4)
            {
              jobs.add(createJobDetail(thisJob));
            }
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
            if(job.ApexClass.Name == MIGRATE_WAITLIST_BATCH) {
                jd.noOfRecords = getNoOfRecords(job, WAITLIST_OBJ, CREATED_DATE);
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
    private Integer getNoOfRecords(AsyncApexJob job, String strObjectName, String strFilterField) {
        DateTime dtStartTime = job.CreatedDate;
        DateTime dtEndTime = job.CompletedDate;
        return Database.query('SELECT Id FROM ' +
                        strObjectName +
                            ' WHERE ' + strFilterField + ' >= :dtStartTime' +
                            ' AND ' + strFilterField + ' <= :dtEndTime').size();
    }

    /* Polls batch results */
    public PageReference pollAccTypeAction() {
        Id jobId = null;
        if(step == 1){
            jobId = waitlistBatchId;
        }
        getBatchJob(jobId);
        getBatchJobs();
        if(asyncJob.Status == COMPLETED) {
            poll = false;
        }
        return null;
    }

}