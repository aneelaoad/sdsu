global class LeadScoringBatchSchedule implements schedulable {
    global void execute(SchedulableContext sc)
    {
    //PublisherScoringBatch  b= new PublisherScoringBatch(); //ur batch class
      //database.executebatch(b, 5);
       Database.executeBatch( new LeadScoringBatch(), 5);
    }
}