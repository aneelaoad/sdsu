/* Controller class for Account Type Migration page
 *
 * Revision History:
 *
 * Version     Author           Date         Description
 * 1.0         Mujjammil khan   16/08/2016   Initial Draft
 */
public with sharing class RelationshipMigrationController{

    public Id pollAccTypeBatchId;
    public Id pollAccTypeExtRecBatchId;
    public Id pollAccBatchId;
    public Id pollAccAffBatchId;
    
    public string eventsInfo{get;set;}
    public Boolean poll {get; set;}
    public JobDetail job {get; set;}
    public AsyncApexJob asyncJob {get; set;}
    public Integer step {get; set;}
    public Boolean renderBatchResults {get; set;}
    public List<JobDetail> jobs {get; set;}
    public Set<Id> jobIds {get; set;}
  
    public static final String COMPLETED = 'Completed';
    public static final String MIGRATE_REF_BATCH = 'MigrateAccountTypeBatch';
    public static final String UPDATE_EXTERNAL_AFF_ROLE_BATCH = 'UpdateExternalRecordsForReference';
    public static final String ACCOUNT_DATA_MIGRATION = 'DataMigrationForAccountChanges';
    public static final String ACCOUNT_AFF_DATA_MIGRATION = 'DataMigrationBatchAccountAffiliation';
    public static final String AFF_ROLE_TYPE_OBJ = 'JIACAF__Affiliation_Role_Type__c';
    public static final String EXTERNAL_RECORD_OBJ = 'JIENS__External_Record__c';
  public static final String ACCOUNT_OBJ = 'Account';
  public static final String ACCOUNT_AFF_OBJ = 'JIACAF__Account_Affiliation__c';
  public static final String CREATED_DATE = 'CreatedDate';
  public static final String LASTMODIFIED_DATE = 'LastModifiedDate';
  
    public RelationshipMigrationController() {
        eventsInfo= 'Please click the above button to raise events.';
        poll = false;
        renderBatchResults = false;
        jobIds = new Set<Id>();
        job = new JobDetail();
    }

    public PageReference exeAccTypeBatch() {
        pollAccTypeBatchId = Database.executeBatch(new MigrateAccountTypeBatch(), 200);
        step = 1;
        getBatchJob(pollAccTypeBatchId);
        jobIds.add(pollAccTypeBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }
    
    public PageReference executeEventGenerationScript(){
        List<JIENS__Event__c> eventsList = eventGenerationScript();
        if(eventsList.isEmpty() == false){
            eventsInfo = eventsList.size()+' events for Pull & Stub got created successfully.';
        }
        else{
            eventsInfo = 'Some problem occurred while creating events';
        }
        return null;
    }
    private List<JIENS__Event__c> eventGenerationScript(){
    
        List<JIENS__Event__c> eventsList = new List<JIENS__Event__c>();
        List<JIACAF__Affiliation_Role_Type__c> listAffiliationRoleTYpe = new List<JIACAF__Affiliation_Role_Type__c>();
        List<JIENS__External_Record__c> listExternalRec = new List<JIENS__External_Record__c>();
        List<String> listExternalId = new List<String>{'9','10'}; 
        
        List<JIENS__Topic__c> pullRequestTopic = [SELECT Id,
                                                   JIENS__IsActive__c,
                                                   JIENS__LocalSystemID__c,
                                                   JIENS__Name__c,
                                                   JIENS__ObjectName__c,
                                                   JIENS__RecordType__c,
                                                   JIENS__SourceSystemID__c,
                                                   JIENS__TopicArea__c,
                                                   JIENS__LocalSystemID__r.JIENS__SystemExternalId__c,
                                                   JIENS__TopicId__c 
                                            FROM JIENS__Topic__c 
                                            WHERE JIENS__TopicArea__r.name = 'Pull Request'];
                                            
        List<JIENS__External_Record__c> extrnlRecordList = [SELECT JIENS__ExternalID__c,
                                                                    JIENS__InternalID__c,
                                                                    JIENS__InternalType__c,
                                                                    JIENS__LocalSystemID__c,
                                                                    JIENS__RecordType__c,
                                                                    JIENS__SystemID__c,
                                                                    JIENS__SystemUniqueKey__c,
                                                                    JIENS__UniqueKey__c
                                                            FROM JIENS__External_Record__c
                                                            WHERE JIENS__InternalType__c = 'JIACAF__Affiliation_Role_Type__c' AND
                                                                    JIENS__RecordType__c = 'ref_affiliationroletype'];
        
        
        if(pullRequestTopic.isEmpty() == false && extrnlRecordList.isEmpty() == false){
            for(JIENS__External_Record__c extrnlRcrd : extrnlRecordList){
                String contentJson = '{"InternalId":"'+extrnlRcrd.JIENS__InternalID__c+'","ExternalId":"'+extrnlRcrd.JIENS__ExternalID__c+'"}';
                system.debug('==contentJson=='+contentJson);
                JIENS__Event__c eventRecord = new JIENS__Event__c(JIENS__ContentJSON__c = contentJson,
                                                                  JIENS__EventStateID__c = 'Ready',
                                                                  JIENS__LocalSystem__c = pullRequestTopic[0].JIENS__LocalSystemID__c,                                   
                                                                  JIENS__OriginatingSourceSystemID__c = pullRequestTopic[0].JIENS__LocalSystemID__r.JIENS__SystemExternalId__c,
                                                                  JIENS__SourceSystem__c = pullRequestTopic[0].JIENS__SourceSystemID__c,
                                                                  JIENS__Topic__c = pullRequestTopic[0].Id,
                                                                  JIENS__TopicID__c = pullRequestTopic[0].JIENS__TopicId__c
                                                                  );
                eventsList.add(eventRecord);
            }
        }
        List<JIENS__Topic__c> stubTopic = [SELECT Id,
                                            JIENS__IsActive__c,
                                            JIENS__LocalSystemID__c,
                                            JIENS__Name__c,
                                            JIENS__ObjectName__c,
                                            JIENS__RecordType__c,
                                            JIENS__SourceSystemID__c,
                                            JIENS__TopicArea__c,
                                            JIENS__LocalSystemID__r.JIENS__SystemExternalId__c,
                                            JIENS__TopicId__c 
                                     FROM JIENS__Topic__c 
                                     WHERE JIENS__TopicArea__r.name = 'Stub'
                                     AND JIENS__TopicId__c = '120'
                                     AND JIENS__ObjectName__c = 'JIACAF__Affiliation_Role_Type__c'];
                                     
        List<RecordType> RecordTypeIdForAffRoleTypeRecord = [SELECT Id 
                                                             FROM RecordType 
                                                             WHERE SobjectType = 'JIACAF__Affiliation_Role_Type__c' AND 
                                                             DeveloperName = 'ref_affiliationroletype'];
        
        if(RecordTypeIdForAffRoleTypeRecord.isEmpty() == false){
            for(integer i = 0; i < 2; i++){
                JIACAF__Affiliation_Role_Type__c affRoleTypeObj = new JIACAF__Affiliation_Role_Type__c(name = 'stub-'+i,
                                                                                                       JIACAF__IsActive__c = true,
                                                                                                       recordTypeId = RecordTypeIdForAffRoleTypeRecord[0].id);
                listAffiliationRoleTYpe.add(affRoleTypeObj);
            }
            
            DataBase.SaveResult[] reslt = DataBase.insert(listAffiliationRoleTYpe,false);
            
            if(stubTopic.isEmpty() == false){
                for(Integer i  = 0; i < reslt.size(); i++){
                    if(reslt[i].isSuccess()){
                        JIENS__External_Record__c externalRec = new  JIENS__External_Record__c();
                        externalRec.JIENS__ExternalID__c = listExternalId[i];
                        externalRec.JIENS__InternalID__c = reslt[i].getId();
                        externalRec.JIENS__InternalType__c = 'JIACAF__Affiliation_Role_Type__c';
                        externalRec.JIENS__RecordType__c = 'ref_affiliationroletype';
                        externalRec.JIENS__SystemID__c = stubTopic[0].JIENS__SourceSystemID__c;
                        externalRec.JIENS__LocalSystemID__c = stubTopic[0].JIENS__LocalSystemID__c;
                        
                        listExternalRec.add(externalRec);
                    }
                }
            
                if(listExternalRec.isEmpty() == false) {
                    DataBase.SaveResult[] res = DataBase.insert(listExternalRec,false);
                    for(Integer i  = 0; i < res.size(); i++){
                        if(res[i].isSuccess()){
                          String contentJson = '{"Id":"'+res[i].getId()+'"}';
                          JIENS__Event__c eventRecord = new JIENS__Event__c(JIENS__ContentJSON__c = contentJson,
                                                                            JIENS__EventStateID__c = 'Ready',
                                                                            JIENS__LocalSystem__c = stubTopic[0].JIENS__LocalSystemID__c,                                    
                                                                            JIENS__OriginatingSourceSystemID__c = stubTopic[0].JIENS__LocalSystemID__r.JIENS__SystemExternalId__c,
                                                                            JIENS__SourceSystem__c = stubTopic[0].JIENS__SourceSystemID__c,
                                                                            JIENS__Topic__c = stubTopic[0].Id,
                                                                            JIENS__TopicID__c = stubTopic[0].JIENS__TopicId__c
                                                                            );                  
                           eventsList.add(eventRecord);
                        }
                    }
                }
            
            }
        }
        
        if(eventsList.isEmpty() == false){   
            insert eventsList;
        }
        system.debug('====eventsList To Insert====='+eventsList);
        return eventsList;
    }
    
    public PageReference exeAccTypeExternalRecBatch() {
        pollAccTypeExtRecBatchId = Database.executeBatch(new UpdateExternalRecordsForReference(), 200);
        step = 2;
        getBatchJob(pollAccTypeExtRecBatchId);
        jobIds.add(pollAccTypeExtRecBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }
    
    public PageReference executeAccMigrationBatch() {
        pollAccBatchId = Database.executeBatch(new DataMigrationForAccountChanges(), 200);
        step = 3;
        getBatchJob(pollAccBatchId);
        jobIds.add(pollAccBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }
    
    public PageReference executeAccAffMigrationBatch() {
        pollAccAffBatchId = Database.executeBatch(new DataMigrationBatchAccountAffiliation(), 200);
        step = 4;
        getBatchJob(pollAccAffBatchId);
        jobIds.add(pollAccAffBatchId);
        getBatchJobs();
        poll = true;
        toggleResultsFlag();
        return null;
    }

    /* Polls batch results */
    public PageReference pollAccTypeAction() {
        Id jobId = null;
        if(step == 1)
            jobId = pollAccTypeBatchId;
        else if(step == 2)
            jobId = pollAccTypeExtRecBatchId;
        else if(step == 3)
            jobId = pollAccBatchId;
        else if(step == 4)
            jobId = pollAccAffBatchId;
        
        getBatchJob(jobId);
        //Issue 0009741 changes : Avoid creating job details for processed job
        // getBatchJobs();
        if(asyncJob.Status == COMPLETED) {
            poll = false;
        }
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
            if(job.ApexClass.Name == MIGRATE_REF_BATCH) {
                jd.noOfRecords = getNoOfRecords(job, AFF_ROLE_TYPE_OBJ, CREATED_DATE);
            }
            else if(job.ApexClass.Name == UPDATE_EXTERNAL_AFF_ROLE_BATCH) {
                jd.noOfRecords = getNoOfRecords(job, EXTERNAL_RECORD_OBJ, LASTMODIFIED_DATE);
            }
            else if(job.ApexClass.Name == ACCOUNT_DATA_MIGRATION) {
                jd.noOfRecords = getNoOfRecords(job, ACCOUNT_OBJ, LASTMODIFIED_DATE);
            }
            else if(job.ApexClass.Name == ACCOUNT_AFF_DATA_MIGRATION) {
                jd.noOfRecords = getNoOfRecords(job, ACCOUNT_AFF_OBJ, LASTMODIFIED_DATE);
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
}