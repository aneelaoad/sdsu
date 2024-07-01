public with sharing class ExternalIDMigrationPageController {
    public Id currentJobId;
    public Integer step {get; set;}
    public Boolean poll {get; set;}
    public AsyncApexJob currentasyncJob {get; set;}
    public JobDetail job {get; set;}
    public List<JobDetail> listJobs {get; set;}
    public Set<Id> setJobIds {get; set;}
    public Boolean renderBatchResults {get; set;}
    public Integer RecordsNotProcessed {get; set;}
    public Integer failedExternalRecords {get; set;}
    /**** Lists required to maintain error records after migration */
    public static final Set<String> uniDirectionalSObjectNameSet = new Set<String>{'JIHIRCRM__Beneficiary__c', 'JIHIRCRM__Reference__c', 'JIHIRCRM__Product__c', 'JIHIRCRM__Membership__c', 'JIHIRCRM__MarketingCode__c', 'JIHIRCRM__HiRWaitList__c'};
    public static final Set<String> biDirectionalSObjectNameSet = new Set<String>{'Account', 'Contact', 'JIACAF__Account_Affiliation__c', 'JIACAF__Affiliation_Role_Type__c'};
    public static final Integer QUERY_LIMIT = 100;
    public static final Integer QUERY_MAX_LIMIT = 50000;
    public Set<String> sObjectVsErrorRecordsKeySet {get; set;}
    public Map<String, List<sObject>> sObjectVsErrorRecordsMap {get; set;}
    public Map<String, String> sObjectNameVsExternalFieldMap {get; set;}
    public Map<String, String> sObjectNameVsSourceSysFieldMap {get; set;}
    public Map<String, String> sObjectNameVsLocalSysFieldMap {get; set;}
    public Map<String, Boolean> internalIdVsHasExternalRecordMap {get; set;}
    public Map<String, Map<String, String>> sObjectVsBoundaryIdMap;
    public String sObjectRendered {get; set;}
    public Map<String, Boolean> hasNextMap {get; set;}
    public Map<String, Boolean> hasPreMap {get; set;}

    public Map<String, Integer> sizeMap {get; set;}
    public Map<String, Integer> fromMap {get; set;}
    public Map<String, Integer> toMap {get; set;}

    public class JobDetail {
        public AsyncApexJob asyncJob {get; set;}
        public String timeTaken {get; set;}
    }

    public ExternalIDMigrationPageController() {
        setJobIds  = new Set<Id>();
        listJobs = new List<JobDetail>();
        job = new JobDetail();
        RecordsNotProcessed = 0;
        failedExternalRecords = 0;
        sObjectRendered = '';
        sObjectVsErrorRecordsKeySet = new Set<String>();
        internalIdVsHasExternalRecordMap = new Map<String, Boolean>();
        sObjectVsErrorRecordsMap = new Map<String, List<sObject>>();
        sObjectVsBoundaryIdMap = new Map<String, Map<String, String>>();
        hasPreMap = new Map<String, Boolean>();
        hasNextMap = new Map<String, Boolean>();
        sObjectNameVsExternalFieldMap = new Map<String, String>();
        sObjectNameVsSourceSysFieldMap = new Map<String, String>();
        sObjectNameVsLocalSysFieldMap = new Map<String, String>();
        sizeMap = new Map<String, Integer>();
        fromMap = new Map<String, Integer>();
        toMap = new Map<String, Integer>();
    }

    public PageReference exeMigrationBatch() {
        currentJobId = Database.executeBatch(new MigrationBatch(), Integer.valueOf(Label.ExternalRecordMigrationBatchScope));
        step = 1;
        setJobIds.add(currentJobId);
        getBatchJobs(false);
        poll = true;
        renderBatchResults = true;
        return null;
    }

    /**** Method to get error records after migration */
    public PageReference getErrorRecords() {
        for(sObject_ExternalID_Mapping__mdt ObjectExternalIDMappingInstance : [ SELECT ExternalD_Field_Name__c
                                                                                     , ObjectName__c
                                                                                     , Source_System__c
                                                                                     , Local_System__c
                                                                                 FROM sObject_ExternalID_Mapping__mdt ]) {
            sObjectNameVsExternalFieldMap.put(ObjectExternalIDMappingInstance.ObjectName__c, ObjectExternalIDMappingInstance.ExternalD_Field_Name__c);
            sObjectNameVsLocalSysFieldMap.put(ObjectExternalIDMappingInstance.ObjectName__c, ObjectExternalIDMappingInstance.Local_System__c);
            sObjectNameVsSourceSysFieldMap.put(ObjectExternalIDMappingInstance.ObjectName__c, ObjectExternalIDMappingInstance.Source_System__c);
        }

        for(String sObjectName : uniDirectionalSObjectNameSet) {
            if(setUniDirectionalErrorRecords(sObjectName, 'first')) {
                sObjectVsErrorRecordsKeySet.add(sObjectName);
            }
        }

        for(String sObjectName : biDirectionalSObjectNameSet) {
            if(setBiDirectionalErrorRecords(sObjectName, 'first')) {
                sObjectVsErrorRecordsKeySet.add(sObjectName);
            }
        }

        for(String sObjectName : sObjectVsErrorRecordsKeySet) {
            sObjectRendered = sObjectName;
            break;
        }

        setErrorRecordCount();

        return null;
    }

    public void setErrorRecordCount() {
        for(String sObjectName : sObjectVsErrorRecordsKeySet) {
            List<String> idList = new List<String>();
            List<sObject> errList = fetchErrorRecords(sObjectName, sObjectNameVsExternalFieldMap.get(sObjectName), sObjectNameVsLocalSysFieldMap.get(sObjectName), sObjectNameVsSourceSysFieldMap.get(sObjectName), 'first', false);
            for(sObject errorRecord : errList) {
                idList.add('\'' + errorRecord.Id + '\'');
            }
            if(uniDirectionalSObjectNameSet.contains(sObjectName)) {
                RecordsNotProcessed += errList.size();
                sizeMap.put(sObjectName, errList.size());
            }
            errList.clear();
            if(!idList.isEmpty()) {
                Integer cnt = getRecordCount('SELECT count() FROM JIENS__External_Record__c WHERE JIENS__InternalType__c = \'' + sObjectName + '\' AND JIENS__InternalID__c IN (' + String.join(idList, ',') + ') LIMIT 50000');
                failedExternalRecords += cnt;
                if(biDirectionalSObjectNameSet.contains(sObjectName)) {
                    sizeMap.put(sObjectName, cnt);
                }
            }
        }
        
    }

    /**** Method to query error records after migration */
    public List<sObject> fetchErrorRecords(String sObjectName, String externalIdFieldName, String localSysFieldName, String sourceSysName, String op, Boolean isUnidirectional) {
        List<sObject> errorRecordList = new List<sObject>();

        if( String.isBlank(sObjectName) || String.isBlank(externalIdFieldName) || String.isBlank(op) || String.isBlank(sourceSysName) || String.isBlank(localSysFieldName)) {
            return errorRecordList;
        }

        String queryString = ' SELECT Id ' +
                                  ' , Name ' +
                                  ' , ' + sourceSysName +
                                  ' , ' + localSysFieldName +
                                  ' , ' + externalIdFieldName +
                               ' FROM ' + sObjectName +
                              ' WHERE ( ' + externalIdFieldName + ' = null ' +
                                 ' OR ' + localSysFieldName + ' = null ' +
                                 ' OR ' + sourceSysName + ' = null )';


        if(isUnidirectional) {
            if(op == 'first') {
                queryString += ' ORDER BY Id ';
            } else if(op == 'pre') {
                queryString += ' AND ( Id < \'' + Id.valueOf(sObjectVsBoundaryIdMap.get(sObjectName).get('first')) + '\' ) ' +
                ' ORDER BY Id DESC';
            } else if(op == 'next') {
                queryString += ' AND ( Id > \'' + Id.valueOf(sObjectVsBoundaryIdMap.get(sObjectName).get('last')) + '\' ) ' +
                ' ORDER BY Id ';
            } else if(op == 'last') {
                queryString += ' ORDER BY Id DESC';
            }
            queryString += ' LIMIT ' + QUERY_LIMIT;
        } else {
            if(op == 'first') {
                queryString += ' ORDER BY Id ';
            } else if(op == 'pre') {
                queryString += ' AND ( Id <= \'' + Id.valueOf(sObjectVsBoundaryIdMap.get(sObjectName).get('first')) + '\' ) ' +
                ' ORDER BY Id DESC';
            } else if(op == 'next') {
                queryString += ' AND ( Id >= \'' + Id.valueOf(sObjectVsBoundaryIdMap.get(sObjectName).get('last')) + '\' ) ' +
                ' ORDER BY Id ';
            } else if(op == 'last') {
                queryString += ' ORDER BY Id DESC';
            }
            // if(op == 'first' || op == 'next') {
            //  queryString += ' ORDER BY Id ';
            // } else if(op == 'pre' || op == 'last') {
            //  queryString += ' ORDER BY Id DESC';
            // }
            queryString += ' LIMIT ' + QUERY_MAX_LIMIT;
        }
        
        System.debug('queryString---'+ queryString);

        errorRecordList = Database.query(queryString);

        System.debug('errorRecordList---'+ errorRecordList );
        
        return errorRecordList;
    }

    /**** Method to call batch for deletion of external records */
    public PageReference deleteExternalRecords() {
        currentJobId = Database.executeBatch(new ExternalRecordsDeleteBatch(), Integer.valueOf(Label.DeleteExternalRecordsScope));
        step = 2;
        RecordsNotProcessed = 0;
        setJobIds.add(currentJobId);
        getBatchJobs(false);
        poll = true;
        renderBatchResults = true;
        return null;
    }

    public PageReference deleteFailedExternalRecords() {
        RecordsNotProcessed = getRecordCount('SELECT count() FROM JIENS__External_Record__c');
        return null;
    }

    /* Created wrapper object for Job */
    public JobDetail createJobDetail(AsyncApexJob job) {
        JobDetail jd = new JobDetail();
        jd.asyncJob = job;
        if(job.Status == 'Completed') {
            jd.timeTaken = calcTimeTaken(job);
        } else {
            jd.timeTaken = '';
        }
        return jd;
    }

    /* Calculates time taken for a batch execution */
    private String calcTimeTaken(AsyncApexJob job) {
        Long timeInMillis = job.CompletedDate.getTime() - job.CreatedDate.getTime();
        return '' + Integer.valueOf(timeInMillis) + ' ms';
    }

    /* Polls batch results */
    public PageReference pollBatchResult() {
        listJobs.clear();
        getBatchJobs(true);
        if(currentasyncJob.Status == 'Completed') {
            poll = false;
        }
        return null;
    }

    /* Returns list of batch jobs to be shown in history */
    private void getBatchJobs(Boolean isHistory) {
        for(AsyncApexJob thisJob : [ SELECT Id
                                          , Status
                                          , NumberOfErrors
                                          , JobItemsProcessed
                                          , TotalJobItems
                                          , CreatedBy.Email
                                          , ExtendedStatus
                                          , ApexClass.Name
                                          , CompletedDate
                                          , CreatedDate
                                       FROM AsyncApexJob
                                      WHERE Id IN :setJobIds
                                   ORDER BY CreatedDate DESC ]) {
            if(isHistory) {
                listJobs.add(createJobDetail(thisJob));
            }
            if(thisJob.Id == currentJobId) {
                currentasyncJob = thisJob;
                job = createJobDetail(currentasyncJob);
            }
        }
    }

    public PageReference getErrornousRecords() {
        String sObjectName = Apexpages.currentPage().getParameters().get('sObjectName');
        String op = Apexpages.currentPage().getParameters().get('op');

        sObjectRendered = sObjectName;

        if(uniDirectionalSObjectNameSet.contains(sObjectName)) {
            setUniDirectionalErrorRecords(sObjectName, op);
        } else if (biDirectionalSObjectNameSet.contains(sObjectName)) {
            setBiDirectionalErrorRecords(sObjectName, op);
        }

        setErrorRecordCount();

        return null;
    }

    public Boolean setUniDirectionalErrorRecords(String sObjectName, String op) {
        if(String.isBlank(sObjectName) || String.isBlank(op)) {
            return false;
        }

        Set<String> idSet = new Set<String>();

        List<sObject> errorRecordList = fetchErrorRecords(sObjectName, sObjectNameVsExternalFieldMap.get(sObjectName), sObjectNameVsLocalSysFieldMap.get(sObjectName), sObjectNameVsSourceSysFieldMap.get(sObjectName), op, true);

        if(!errorRecordList.isEmpty()) {
            if(op == 'last' || op == 'pre') {
                errorRecordList = reverseList(errorRecordList);
            }

            sObjectVsErrorRecordsMap.put(sObjectName, errorRecordList);
            sObjectVsBoundaryIdMap.put(sObjectName, new Map<String, String>{ 'first' => errorRecordList[0].Id ,
                                                                             'last'  => errorRecordList[errorRecordList.size()-1].Id });

            if(op == 'first') {
                fromMap.put(sObjectName, 1);
                toMap.put(sObjectName, errorRecordList.size());
            } else if(op == 'pre') {
                fromMap.put(sObjectName, fromMap.get(sObjectName) - errorRecordList.size() );
                toMap.put(sObjectName, fromMap.get(sObjectName) + errorRecordList.size() - 1);
            } else if(op == 'next') {
                fromMap.put(sObjectName, toMap.get(sObjectName)+1);
                toMap.put(sObjectName, fromMap.get(sObjectName) + errorRecordList.size() - 1);
            } else if(op == 'last') {
                fromMap.put(sObjectName, sizeMap.get(sObjectName) - errorRecordList.size() +1);
                toMap.put(sObjectName, sizeMap.get(sObjectName));
            }
            Boolean hasPre = getRecordCount(' SELECT count() ' +
                                              ' FROM ' + sObjectName +
                                             ' WHERE ( Id < \'' + errorRecordList[0].Id + '\') ' +
                                               ' AND ( ' + sObjectNameVsSourceSysFieldMap.get(sObjectName) + ' = null ' +
                                                ' OR ' + sObjectNameVsLocalSysFieldMap.get(sObjectName) + ' = null ' +
                                                ' OR ' + sObjectNameVsExternalFieldMap.get(sObjectName) + ' = null) ' +
                                             ' LIMIT 1 ') > 0 ? true : false ;
            hasPreMap.put(sObjectName, hasPre);

            Boolean hasNext = getRecordCount(' SELECT count() ' +
                                              ' FROM ' + sObjectName +
                                             ' WHERE ( Id > \'' + errorRecordList[errorRecordList.size()-1].Id + '\') ' +
                                               ' AND ( ' + sObjectNameVsSourceSysFieldMap.get(sObjectName) + ' = null ' +
                                                ' OR ' + sObjectNameVsLocalSysFieldMap.get(sObjectName) + ' = null ' +
                                                ' OR ' + sObjectNameVsExternalFieldMap.get(sObjectName) + ' = null) ' +
                                             ' LIMIT 1 ') > 0 ? true : false ;
            hasNextMap.put(sObjectName, hasNext);

            for(sObject sObj : errorRecordList) {
                idSet.add(sObj.Id);
                internalIdVsHasExternalRecordMap.put(sObj.Id, false);
            }

            for(JIENS__External_Record__c externalRecord : [ SELECT JIENS__InternalID__c
                                                        FROM JIENS__External_Record__c
                                                       WHERE JIENS__InternalID__c IN :idSet ]) {
                internalIdVsHasExternalRecordMap.put(Id.valueOf(externalRecord.JIENS__InternalID__c), true);
            }

            return true;
        }

        return false;
    }

    public Boolean setBiDirectionalErrorRecords(String sObjectName, String op) {
        if(String.isBlank(sObjectName) || String.isBlank(op)) {
            return false;
        }

        List<Id> idSet = new List<Id>();

        List<sObject> errorRecordList = fetchErrorRecords(sObjectName, sObjectNameVsExternalFieldMap.get(sObjectName), sObjectNameVsLocalSysFieldMap.get(sObjectName), sObjectNameVsSourceSysFieldMap.get(sObjectName), op, false);

        if(!errorRecordList.isEmpty()) {
            if(op == 'last' || op == 'pre') {
                errorRecordList = reverseList(errorRecordList);
            }

            Map<Id, sObject> errorRecordMap = new Map<Id, sObject>();
            errorRecordMap.putAll(errorRecordList);

            for(Id recordId : errorRecordMap.keySet()) {
                idSet.add(recordId);
            }

            String queryString = 'SELECT JIENS__InternalID__c FROM JIENS__External_Record__c WHERE JIENS__InternalID__c IN :idSet AND JIENS__InternalType__c = :sObjectName ';

            if(op == 'first') {
                queryString += ' ORDER BY JIENS__InternalID__c ';
            } else if(op == 'pre') {
                queryString += ' AND ( JIENS__InternalID__c < \'' + Id.valueOf(sObjectVsBoundaryIdMap.get(sObjectName).get('first')) + '\' ) ' +
                ' ORDER BY JIENS__InternalID__c DESC';
            } else if(op == 'next') {
                queryString += ' AND ( JIENS__InternalID__c > \'' + Id.valueOf(sObjectVsBoundaryIdMap.get(sObjectName).get('last')) + '\' ) ' +
                ' ORDER BY JIENS__InternalID__c ';
            } else if(op == 'last') {
                queryString += ' ORDER BY JIENS__InternalID__c DESC';
            }

            queryString += ' LIMIT :QUERY_LIMIT';

            List<JIENS__External_Record__c> externalRecordList =(List<JIENS__External_Record__c>) Database.query(queryString);

            if(op == 'last' || op == 'pre') {
                externalRecordList = reverseList(externalRecordList);
            }

            if(!externalRecordList.isEmpty()) {
                sObjectVsErrorRecordsKeySet.add(sObjectName);

                List<sObject> failedRecords = new List<sObject>();
                List<String> tempGreaterList = new List<String>();
                List<String> tempLesserList = new List<String>();

                for(JIENS__External_Record__c externalRecord : externalRecordList) {
                    failedRecords.add(errorRecordMap.get(externalRecord.JIENS__InternalID__c));
                    internalIdVsHasExternalRecordMap.put(Id.valueOf(externalRecord.JIENS__InternalID__c), true);
                }

                for(String str : idSet) {
                    if(Id.valueOf(str).getSobjectType() == Id.valueOf(externalRecordList[externalRecordList.size()-1].JIENS__InternalID__c).getSobjectType() && str > externalRecordList[externalRecordList.size()-1].JIENS__InternalID__c) {
                        tempGreaterList.add('\'' + str + '\'');
                    } else if (Id.valueOf(str).getSobjectType() == Id.valueOf(externalRecordList[0].JIENS__InternalID__c).getSobjectType() && str < externalRecordList[0].JIENS__InternalID__c ) {
                        tempLesserList.add('\'' + str + '\'');
                    }
                }

                sObjectVsErrorRecordsMap.put(sObjectName, failedRecords);
                sObjectVsBoundaryIdMap.put(sObjectName, new Map<String, String>{ 'first' => externalRecordList[0].JIENS__InternalID__c ,
                                                                                 'last'  => externalRecordList[externalRecordList.size()-1].JIENS__InternalID__c });

                if(op == 'first') {
                    fromMap.put(sObjectName, 1);
                    toMap.put(sObjectName, externalRecordList.size());
                } else if(op == 'pre') {
                    fromMap.put(sObjectName, fromMap.get(sObjectName) - externalRecordList.size() );
                    toMap.put(sObjectName, fromMap.get(sObjectName) + externalRecordList.size() - 1);
                } else if(op == 'next') {
                    fromMap.put(sObjectName, toMap.get(sObjectName)+1);
                    toMap.put(sObjectName, fromMap.get(sObjectName) + externalRecordList.size() - 1);
                } else if(op == 'last') {
                    fromMap.put(sObjectName, sizeMap.get(sObjectName) - externalRecordList.size() +1);
                    toMap.put(sObjectName, sizeMap.get(sObjectName));
                }

                Boolean hasPre;
                if(!tempLesserList.isEmpty()){
                    hasPre = getRecordCount(' SELECT count() ' +
                                              ' FROM JIENS__External_Record__c ' +
                                             ' WHERE JIENS__InternalType__c = \'' + sObjectName + '\' AND JIENS__InternalID__c IN ( ' + String.join(tempLesserList, ',') + ' ) ' +
                                             ' LIMIT 1 ') > 0 ? true : false ;
                } else {
                    hasPre = false;
                }

                Boolean hasNext;
                if(!tempGreaterList.isEmpty()){
                    hasNext = getRecordCount(' SELECT count() ' +
                                               ' FROM JIENS__External_Record__c ' +
                                              ' WHERE JIENS__InternalType__c = \'' + sObjectName + '\' AND JIENS__InternalID__c IN ( ' + String.join(tempGreaterList, ',') + ' ) ' +
                                              ' LIMIT 1 ') > 0 ? true : false ;
                } else {
                    hasNext = false;
                }

                hasPreMap.put(sObjectName, hasPre);
                hasNextMap.put(sObjectName, hasNext);

                return true;
            }
        }

        return false;
    }

    public List<sObject> reverseList(List<sObject> sObjectList) {
        List<sObject> sObjectReverseList = new List<sObject>();

        if(sObjectList == null || sObjectList.isEmpty()) {
            return sObjectReverseList;
        }

        for(Integer i = sObjectList.size() - 1 ;i >= 0 ;i--) {
            sObjectReverseList.add(sObjectList[i]);
        }

        return sObjectReverseList;
    }

    public Integer getRecordCount(String query) {
        if(String.isBlank(query)) {
            return 0;
        }

        return Database.countQuery(query);
    }



}