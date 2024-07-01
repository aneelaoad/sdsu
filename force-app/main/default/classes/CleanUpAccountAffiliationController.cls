public class CleanUpAccountAffiliationController {

    public Id pollDelAccAffBatchId;
    public Id pollDelRefBatchId;

    public Boolean poll {get; set;}

    public AsyncApexJob asynApexjob {get; set;}
    public Integer step {get; set;}
    public Boolean renderBatchResults {get; set;}
    public List<AsyncApexJob> jobs {get; set;}
    public Set<Id> jobIds {get; set;}

    public CleanUpAccountAffiliationController() {
        poll = false;
        renderBatchResults = false;
        jobIds = new Set<Id>();
    }

    public PageReference exeDeleteAccAffBatch() {
        pollDelAccAffBatchId = Database.executeBatch(new DeleteAccountAffiliationBatch(), 200);
        step = 1;
        getBatchJob(pollDelAccAffBatchId);
        jobIds.add(pollDelAccAffBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    public PageReference exeDeleteReferenceBatch() {
        pollDelRefBatchId = Database.executeBatch(new DeleteReferrenceBatch(), 200);
        step = 2;
        getBatchJob(pollDelRefBatchId);
        jobIds.add(pollDelRefBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    public PageReference pollResults() {
        Id jobId = null;
        if(step == 1)
            jobId = pollDelAccAffBatchId;
        else if(step == 2)
            jobId = pollDelRefBatchId;

        getBatchJob(jobId);
        getBatchJobs();
        if(asynApexjob.Status == 'Completed') {
            poll = false;
        }
        return null;
    }

    private void getBatchJob(Id jobId) {
        asynApexjob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                              CreatedBy.Email, ExtendedStatus, ApexClass.Name
                       FROM AsyncApexJob
                        WHERE Id = :jobId
                        limit 1];
    }

    private void getBatchJobs() {
        jobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
                       CreatedBy.Email, ExtendedStatus, ApexClass.Name
                FROM AsyncApexJob
                WHERE Id IN :jobIds];
    }

    private void toggleResultsFlag() {
        renderBatchResults = true;
    }
}