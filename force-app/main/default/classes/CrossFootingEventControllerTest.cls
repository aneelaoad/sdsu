@isTest
Public class CrossFootingEventControllerTest
{

    static testMethod void testCrossFootedAccount()
    {
        PageReference pgRef = Page.CrossFootingEventGenerator;
        Test.setCurrentPageReference (pgRef);
        CrossFootingEventController ctrl = new CrossFootingEventController();
        Test.startTest();
            ctrl.exeCrossFootAccountBatch();
            ctrl.pollCrossFootAction();
        Test.stopTest(); 
           // Called again to check functionality after job is completed
        ctrl.pollCrossFootAction(); 
        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollcrossFootAccountBatchId
                            limit 1];
        System.assertEquals(0, job.NumberOfErrors);
    }
    static testMethod void testCrossFootedContact()
    {
        PageReference pgRef = Page.CrossFootingEventGenerator;
        Test.setCurrentPageReference (pgRef);
        CrossFootingEventController ctrl = new CrossFootingEventController();
        Test.startTest();
            ctrl.exeCrossFootContactBatch();
            ctrl.pollCrossFootAction();
        Test.stopTest(); 
           // Called again to check functionality after job is completed
        ctrl.pollCrossFootAction(); 
        AsyncApexJob job = [select Id, NumberOfErrors
                            from AsyncApexJob
                            where Id = :ctrl.pollcrossFootContactBatchId
                            limit 1];
        System.assertEquals(0, job.NumberOfErrors);
    }
}