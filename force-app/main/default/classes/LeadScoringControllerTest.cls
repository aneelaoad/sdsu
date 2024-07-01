@isTest
public class LeadScoringControllerTest {
    @testSetup static void Setup()
    {
        Lead l=new Lead();
        l.LastName='Test';
        l.Company='Test';
        l.Landing_Page_Program_of_Interest__c='Professional Certificate in Civil Sitework Construction';
        l.Applying_for_Term__c='22SU';
        l.X60_Units_Completed__c=true;
        l.Golden_4__c=true; 
        l.Lower_Division_Prep__c=true;
        l.Status='Open – Provisionally Admitted';
        l.HasOptedOutOfEmail=false;
        l.LeadSource='Web - Paid Digital';
        l.Microsite_Webinar_RSVP__c='abc'; 
        l.Microsite_Program_Interest__c='American Indian Studies'; 
        l.Microsite_Community_College__c='San Diego Mesa College';
        l.Microsite_Desired_Term__c='22SU'; 
        l.HTM_Mem_Industry__c='Aerospace';
        l.Degree_Completion_Program__c='Online American Indian Studies';
        insert l;
    }
    
    @isTest static void calculateLeadScoreTest(){
        Lead l=[select id,Landing_Page_Program_of_Interest__c,Applying_for_Term__c,X60_Units_Completed__c,
                                              Golden_4__c,Lower_Division_Prep__c,Status, LeadSource, Microsite_Webinar_RSVP__c, 
                                              Microsite_Program_Interest__c,Microsite_Community_College__c,Microsite_Desired_Term__c, 
                                              HTM_Mem_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c,Inbound_Call__c,HasOptedOutOfEmail,Email_Open__c from lead Order By CreatedDate DESC limit 1];
           Test.startTest();
       LeadScoringController lsc=new LeadScoringController();
        lsc.calculateLeadScore(l);
        test.stopTest(); 
    }
    @isTest static void calculateLeadScoreTest2(){
         Lead l=new Lead();
        l.LastName='Test';
        l.Company='Test';
        l.Landing_Page_Program_of_Interest__c='Professional Certificate in Civil Sitework Construction';
        l.Applying_for_Term__c='22SU';
        l.X60_Units_Completed__c=false;
        l.Golden_4__c=false; 
        l.Lower_Division_Prep__c=false;
        l.Status='Preapplication';
        l.LeadSource='Web – Organic';
        l.Microsite_Webinar_RSVP__c='abc';
        l.HasOptedOutOfEmail=false;
        l.Microsite_Program_Interest__c='American Indian Studies'; 
        l.Microsite_Community_College__c='San Diego Mesa College';
        l.Microsite_Desired_Term__c='22SU'; 
        l.HTM_Mem_Industry__c='Aerospace';
        l.Degree_Completion_Program__c='Online American Indian Studies';
        insert l;
        Lead lead=[select id,Landing_Page_Program_of_Interest__c,Applying_for_Term__c,X60_Units_Completed__c,
                                              Golden_4__c,Lower_Division_Prep__c,Status, LeadSource, Microsite_Webinar_RSVP__c, 
                                              Microsite_Program_Interest__c,Microsite_Community_College__c,Microsite_Desired_Term__c, 
                                              HTM_Mem_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c,Inbound_Call__c,HasOptedOutOfEmail,Email_Open__c from lead Order By CreatedDate DESC limit 1];
         List<Lead> leadList=[select id,Landing_Page_Program_of_Interest__c,Applying_for_Term__c,X60_Units_Completed__c,
                                              Golden_4__c,Lower_Division_Prep__c,Status, LeadSource, Microsite_Webinar_RSVP__c, 
                                              Microsite_Program_Interest__c,Microsite_Community_College__c,Microsite_Desired_Term__c, 
                                              HTM_Mem_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c,Inbound_Call__c,HasOptedOutOfEmail,Email_Open__c from lead Order By CreatedDate desc limit 2];
           Test.startTest();
       LeadScoringController lsc=new LeadScoringController();
        lsc.calculateLeadScore(lead);
        lsc.deleteExistingScores(leadList);
        test.stopTest(); 
    } 
    
    @isTest static void calculateLeadScoreTest3(){
         Lead l=new Lead();
        l.LastName='Test';
        l.Company='Test';
        l.Landing_Page_Program_of_Interest__c='Professional Certificate in Civil Sitework Construction';
        l.Applying_for_Term__c='22SU';
        l.X60_Units_Completed__c=false;
        l.Golden_4__c=false; 
        l.Lower_Division_Prep__c=false;
        l.Status='Admitted';
        l.LeadSource='Cal State Apply Feeds';
        l.Email_Open__c=true;
        l.HasOptedOutOfEmail=true;
        l.Inbound_Call__c=true;
        l.Microsite_Webinar_RSVP__c='abc'; 
        l.Microsite_Program_Interest__c='American Indian Studies'; 
        l.Microsite_Community_College__c='San Diego Mesa College';
        l.Microsite_Desired_Term__c='22SU'; 
        l.HTM_Mem_Industry__c='Aerospace';
        l.Degree_Completion_Program__c='Online American Indian Studies';
        l.Email_Open__c=true;
        l.HasOptedOutOfEmail=true;
        l.Inbound_Call__c=true;
        insert l;
        Lead lead=[select id,Landing_Page_Program_of_Interest__c,Applying_for_Term__c,X60_Units_Completed__c,
                                              Golden_4__c,Lower_Division_Prep__c,Status, LeadSource, Microsite_Webinar_RSVP__c, 
                                              Microsite_Program_Interest__c,Microsite_Community_College__c,Microsite_Desired_Term__c, 
                                              HTM_Mem_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c,Inbound_Call__c,HasOptedOutOfEmail,Email_Open__c from lead Order By CreatedDate DESC limit 1];
        // List<Lead> leadList=[select id,Landing_Page_Program_of_Interest__c,Applying_for_Term__c,X60_Units_Completed__c,
        //                                      Golden_4__c,Lower_Division_Prep__c,Status, LeadSource, Microsite_Webinar_RSVP__c, 
        //                                      Microsite_Program_Interest__c,Microsite_Community_College__c,Microsite_Desired_Term__c, 
        //                                      HTM_Mem_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c from lead Order By CreatedDate];
           Test.startTest();
       LeadScoringController lsc=new LeadScoringController();
        lsc.calculateLeadScore(lead);
      //  lsc.deleteExistingScores(leadList);
        test.stopTest(); 
    } 

    @isTest static void calculateLeadScoreTest4(){
         Lead l=new Lead();        
        l.LastName='Test4';
        l.Company='Test4';
        l.Landing_Page_Program_of_Interest__c='';
        l.Applying_for_Term__c='';
        l.X60_Units_Completed__c=false;
        l.Golden_4__c=false; 
        l.Lower_Division_Prep__c=false;
        l.Status='Suspected Bot';
        l.LeadSource='Transfer from Main Campus';
        l.Microsite_Webinar_RSVP__c='bbc'; 
        l.Microsite_Program_Interest__c=''; 
        l.Microsite_Community_College__c='';
        l.Microsite_Desired_Term__c=''; 
        l.HTM_Mem_Industry__c='Aerospace';
        l.Degree_Completion_Program__c='Online American Indian Studies';
        l.Email_Open__c=false;
        l.HasOptedOutOfEmail=false;
        l.Inbound_Call__c=false;
        insert l;
        PreQual_Student_Tracker__c p=new PreQual_Student_Tracker__c();
        p.Lead__c=l.id;
        p.CSU_A1__c=true;
        insert p;
        Lead lead=[select id,Landing_Page_Program_of_Interest__c,Applying_for_Term__c,X60_Units_Completed__c,
                                              Golden_4__c,Lower_Division_Prep__c,Status, LeadSource, Microsite_Webinar_RSVP__c, 
                                              Microsite_Program_Interest__c,Microsite_Community_College__c,Microsite_Desired_Term__c, 
                                              HTM_Mem_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c, Inbound_Call__c,HasOptedOutOfEmail,Email_Open__c from lead Order By CreatedDate DESC limit 1];

        PreQual_Student_Tracker__c PrequalRecord=[SELECT Id, Name, X60_Units__c, CSU_GPA__c, CSU_A1__c, CSU_A2__c, CSU_A3__c, CSU_B4__c, 	Missing_Prep_Courses__c,
                          Outcome__c,Program_GPA__c, SDSU_GPA__c, Semester__c FROM PreQual_Student_Tracker__c];
    //     List<Lead> leadList=[select id,Landing_Page_Program_of_Interest__c,Applying_for_Term__c,X60_Units_Completed__c,
      //                                        Golden_4__c,Lower_Division_Prep__c,Status, LeadSource, Microsite_Webinar_RSVP__c, 
        //                                      Microsite_Program_Interest__c,Microsite_Community_College__c,Microsite_Desired_Term__c, 
          //                                    HTM_Mem_Industry__c,Degree_Completion_Program__c,LandingPageSubmissionDate__c from lead Order By CreatedDate desc limit 2];
           Test.startTest();
       LeadScoringController lsc=new LeadScoringController();
        lsc.calculateLeadScore(lead);
        //lsc.deleteExistingScores(leadList);
        test.stopTest(); 
    } 
    @isTest static void LeadScoringBatchTest()
    {
         Test.startTest();
          LeadScoringBatch lsb=new LeadScoringBatch();
        Database.executeBatch(lsb);
        test.stopTest(); 
    }
    @isTest static void LeadScoringBatchScheduleTest()
    {
          Test.startTest();
          LeadScoringBatchSchedule lsbs=new LeadScoringBatchSchedule();
      String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, lsbs );
        Test.stopTest();
    }
}