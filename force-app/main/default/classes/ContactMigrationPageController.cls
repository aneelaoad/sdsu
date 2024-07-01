public with sharing class ContactMigrationPageController {
    public Id currentJobId;
    public Integer step {get; set;}
    public Boolean poll {get; set;}
    public AsyncApexJob currentasyncJob {get; set;}
    public JobDetail job {get; set;}
    public List<JobDetail> listJobs {get; set;}
    public Set<Id> setJobIds {get; set;}
    public Boolean renderBatchResults {get; set;}
    public static final String CREATED_DATE = 'CreatedDate';
    public static final String LASTMODIFIED_DATE = 'LastModifiedDate';
    public static final String COMPLETED = 'Completed';
    public static final String CONTACT_OBJ = 'Contact';
    
    
    public ContactMigrationPageController() {
        setJobIds  = new Set<Id>();
        listJobs = new List<JobDetail>();
        job = new JobDetail();
    }
    public PageReference exeContactMigrationBatch() {

        currentJobId = Database.executeBatch(new HIRCRMContactMigrationBatch(), 200);
        step = 1;
        setJobIds.add(currentJobId);
        getBatchJobs(false);
        poll = true;
        toggleResultsFlag();
        return null;
    }
    
    
    public PageReference exeExternalRecMigrationBatch() {
        currentJobId = Database.executeBatch(new ContactExternalRecMigrationBatch(), 200);
        step = 2;
        setJobIds.add(currentJobId);
        getBatchJobs(false);
        poll = true;
        toggleResultsFlag();
        return null;
    }
    
    /* Toggle renderBatchResults */
    private void toggleResultsFlag() {
        renderBatchResults = true;
    }
    
    
    /* Created wrapper object for Job */
    public JobDetail createJobDetail(AsyncApexJob job) {
        JobDetail jd = new JobDetail();
        jd.asyncJob = job;
        if(job.Status == COMPLETED) {
            jd.timeTaken = calcTimeTaken(job);
            if(job.ApexClass.Name == Label.ContactMigrationBatch) {
                jd.noOfRecords = getNoOfRecords(job, CONTACT_OBJ, LASTMODIFIED_DATE);
            }
            else if(job.ApexClass.Name == Label.ContactExternalRecMigrationBatch) {
                jd.noOfRecords = getNoOfRecords(job, Label.ExternalRec_Custom_Object, LASTMODIFIED_DATE);
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
        return Database.countQuery('SELECT count() FROM ' +
                         strObjectName +
                              ' WHERE ' + strFilterField + ' >= :dtStartTime' +
                              ' AND ' + strFilterField + ' <= :dtEndTime');
    }
    
     /* Polls batch results */
    public PageReference pollBatchResult() {
        listJobs.clear();
        getBatchJobs(true);
         
        if(currentasyncJob.Status == COMPLETED) {
            poll = false;
        }
        return null;
    }
    
    
    /* Returns list of batch jobs to be shown in history */
    private void getBatchJobs(Boolean isHistory) {
        for(AsyncApexJob thisJob : [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                                           CreatedBy.Email, ExtendedStatus, ApexClass.Name,
                                           CompletedDate, CreatedDate
                                    FROM AsyncApexJob
                                    WHERE Id IN :setJobIds
                                    ORDER BY CreatedDate DESC]) {
            if(isHistory) {
                listJobs.add(createJobDetail(thisJob));
            }
            if(thisJob.Id == currentJobId) {
                currentasyncJob = thisJob;
                job = createJobDetail(currentasyncJob);
            }
        }
    }
    
}