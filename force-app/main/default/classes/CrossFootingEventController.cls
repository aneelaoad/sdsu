Public class CrossFootingEventController
{

    public Id pollcrossFootAccountBatchId;
    public Id pollcrossFootContactBatchId;
    public Boolean poll {get; set;}

    public JobDetail job {get; set;}
    public AsyncApexJob asyncJob {get; set;}
    public Integer step {get; set;}
    public Boolean renderBatchResults {get; set;}
    public List<JobDetail> jobs {get; set;}
    public Set<Id> jobIds {get; set;}

    public static final String COMPLETED = 'Completed';
    public static final String CROSS_FOOT_BATCH= 'CreatecrossfootBatch';
    public static final String EVENT_OBJ= 'JIENS__Event__c';
    public CrossFootingEventController() {
        poll = false;
        renderBatchResults = false;
        jobIds = new Set<Id>();
        job = new JobDetail();
    }

    public PageReference exeCrossFootAccountBatch() {
        pollcrossFootAccountBatchId= Database.executeBatch(new CreatecrossfootBatch('Account'), 200);
        step = 1;
        getBatchJob(pollcrossFootAccountBatchId);
        jobIds.add(pollcrossFootAccountBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    public PageReference exeCrossFootContactBatch() {
        pollcrossFootContactBatchId= Database.executeBatch(new CreatecrossfootBatch('Contact'), 200);
        step = 2;
        getBatchJob(pollcrossFootContactBatchId);
        jobIds.add(pollcrossFootContactBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

   
    /* Polls batch results */
    public PageReference pollCrossFootAction() {
        Id jobId = null;
        if(step == 1)
            jobId = pollcrossFootAccountBatchId;
        else if(step == 2)
            jobId = pollcrossFootContactBatchId;
        getBatchJob(jobId);
        getBatchJobs();
        if(asyncJob.Status == COMPLETED) {
            poll = false;
        }
        return null;
    }

    /* Returns current batch job based on jobId parameter */
    private void getBatchJob(Id jobId) {
        Set<String> classNames = new Set<String>{'CreatecrossfootBatch'};
                                               
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
            if(job.ApexClass.Name == CROSS_FOOT_BATCH) {
                jd.noOfRecords = getNoOfRecordsInserted(EVENT_OBJ,job);
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
    private Integer getNoOfRecordsInserted(String objName,AsyncApexJob job) {
         return [select Id from JIENS__External_Record__c 
         where CreatedDate >= :job.CreatedDate AND CreatedDate <= :job.CompletedDate].size();
    }

    /* Returns no of records of an object */
   /* private Integer getNoOfExternalRecordsUpdated(AsyncApexJob job) {
        return [select Id
                from JIENS__External_Record__c
                where LastModifiedDate >= :job.CreatedDate
                  AND LastModifiedDate <= :job.CompletedDate].size();
    }*/





}