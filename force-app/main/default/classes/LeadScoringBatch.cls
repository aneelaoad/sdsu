public class LeadScoringBatch implements Database.Batchable<sObject> {
    Date dateToday = System.today();
    public Database.QueryLocator start(Database.BatchableContext info){ 
        return Database.getQueryLocator([SELECT Id, Name, Landing_Page_Program_of_Interest__c, Applying_for_Term__c, X60_Units_Completed__c, 
                                         American_Institution__c, Golden_4__c, Lower_Division_Prep__c, LeadSource,Microsite_Webinar_RSVP__c, Status, 
                                         Microsite_Community_College__c, Microsite_Desired_Term__c, Microsite_Program_Interest__c, 
                                         HTM_MEM_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c,Weighted_Score__c,HasOptedOutOfEmail,
                                         Email_Open__c,Inbound_Call__c
                                         FROM Lead 
                                         where (Status != 'Denied'
                                         AND   Status != 'Unqualified'
                                         AND   Status != 'Withdrawn'
                                         AND   Status != 'Closed'
                                         AND   Status != 'Aged - Closed'
                                         AND   Status != 'Enrolled' 
                                         AND   IsConverted = false
                                         AND   LeadSource != null)
                                         /*WHERE LastModifiedDate >= :dateToday*/]);
    }
    
    public void execute(Database.BatchableContext info, List<Lead> scope){
        LeadScoringController lsc=new LeadScoringController();
        system.debug('Current Lead scope'+scope);
        //Delete the existing lead scores so that new ones can be stored as per requirements
        Integer deletedScoresCount = lsc.deleteExistingScores(scope);
        system.debug('Scores deleted in this batch: ' + deletedScoresCount);
        List<Lead_Scoring__c> scoresToCreate=new  List<Lead_Scoring__c>();
        system.debug('Before Creation of score'+scoresToCreate);
        
        for(Lead lead : scope){
            scoresToCreate.addAll(lsc.calculateLeadScore(lead));
        }
        insert scoresToCreate;
        system.debug('Score After creation : '+scoresToCreate);
        
    }
    
    
    
    public void finish(Database.BatchableContext info){     
    } 
    
}