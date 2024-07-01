/* Wrapper class to hold more details associated with an async apex job */
public class JobDetail {
    public AsyncApexJob asyncJob {get; set;}
    public String timeTaken {get; set;}
    public Integer noOfRecords {get; set;}
}