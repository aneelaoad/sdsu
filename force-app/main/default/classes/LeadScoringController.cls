public class LeadScoringController {
    //It will delete duplicate records from Leads
      public Integer deleteExistingScores(List<Lead> leads){
        List<Lead_Scoring__c> existingScores = [SELECT Id FROM Lead_Scoring__c
                                                     WHERE Lead__c  IN: leads];
        if(existingScores.size() > 0){
            delete existingScores;
        }
        system.debug('Existing Lead Scores: ' + existingScores);
        return existingScores.size();
      }
    
    //It will calculate All categories of Lead Score and will return lead scoring 
    public List<Lead_Scoring__c> calculateLeadScore(Lead lead)
    {
        
        double finalScore=0,demographicScore=0, activitiesScore=0,timelineScore=0,preQualStudentTrackerScore=0;
        demographicScore=calculateDemographic(lead.Landing_Page_Program_of_Interest__c, lead.Applying_for_Term__c, lead.X60_Units_Completed__c,
                                              lead.Golden_4__c, lead.Lower_Division_Prep__c, lead.Status, lead.LeadSource, lead.Microsite_Webinar_RSVP__c, 
                                              lead.Microsite_Program_Interest__c, lead.Microsite_Community_College__c, lead.Microsite_Desired_Term__c, 
                                              lead.HTM_Mem_Industry__c, lead.Degree_Completion_Program__c);
        TextLane__TextMessage__c textMessage;
        try{
            textMessage=[SELECT Id, TextLane__DeliveryResponseCode__c FROM TextLane__TextMessage__c where TextLane__Lead__c=:lead.id limit 1];
        }catch(System.QueryException e){
            textMessage=new TextLane__TextMessage__c();
                System.debug('The following exception has occurred: ' + e.getMessage());

        }
        system.debug('TextMessage :  '+textMessage);
        string testmsg = textMessage == Null ? '0' : textMessage.TextLane__DeliveryResponseCode__c;
        
        activitiesScore=calculateActivities(lead.LandingPageSubmissionDate__c,testmsg,lead.HasOptedOutOfEmail,lead.Microsite_Webinar_RSVP__c,
                                            lead.Email_Open__c,lead.Inbound_Call__c);
        Lead l=[SELECT id, createdDate, Days_in_Status__c FROM Lead where id=:lead.id];
        
        system.debug('Created Date :'+l.createdDate);
        //timelineScore=calculateTimeline(l.createdDate);
        timelineScore=calculateTimeline(l.Days_in_Status__c);
        
        
        
        PreQual_Student_Tracker__c PrequalRecord;
        try{
            PrequalRecord=[SELECT Id, Name, X60_Units__c, CSU_GPA__c, CSU_A1__c, CSU_A2__c, CSU_A3__c, CSU_B4__c, 	Missing_Prep_Courses__c,
                          Outcome__c,Program_GPA__c, SDSU_GPA__c, Semester__c FROM PreQual_Student_Tracker__c where Lead__c=:lead.id];
        }
        catch(System.QueryException e){
            PrequalRecord=new PreQual_Student_Tracker__c();
                System.debug('The following exception has occurred: ' + e.getMessage());

        }
        preQualStudentTrackerScore=calculatePreQualStudentTrackerScore(PrequalRecord.Name,PrequalRecord.X60_Units__c,PrequalRecord.CSU_GPA__c,
                                                                       PrequalRecord.CSU_A1__c,PrequalRecord.CSU_A2__c,PrequalRecord.CSU_A3__c,PrequalRecord.CSU_B4__c,
                                                                      PrequalRecord.Missing_Prep_Courses__c,PrequalRecord.Outcome__c,PrequalRecord.Program_GPA__c,
                                                                      PrequalRecord.SDSU_GPA__c,PrequalRecord.Semester__c);
        
        finalScore=demographicScore+activitiesScore+timelineScore+preQualStudentTrackerScore;
        
        system.debug('Demographic score :'+demographicScore);
        system.debug('Activities score :'+activitiesScore);
        system.debug('Timeline score :'+timelineScore);
        system.debug('Prequal Student Tracker Score :'+preQualStudentTrackerScore);
        system.debug('Final Score :'+finalScore);
        String [] leadCategories = new String[]{'Demographic', 'Activities','Timeline','PreQual Student Tracker'};
                Double [] leadScores = new Double[]{demographicScore, activitiesScore,timelineScore,preQualStudentTrackerScore};
                   // double[] percentage=new Double[]{(demographicScore*0.5),(activitiesScore*0.3),(timelineScore*0.2)};
                   double[] percentage=new Double[]{(20),(30),(20),(30)};
                    List<Lead_Scoring__c> scoresToCreate=new  List<Lead_Scoring__c>();
        for(integer i = 0; i < 4; i++){
            Lead_Scoring__c leadscore = new Lead_Scoring__c();
            leadscore.Lead__c = lead.id;
            leadscore.Category__c = leadCategories[i]; 
            leadscore.Category_Weight__c =percentage[i];
            leadscore.Score__c = leadScores[i];
            
            scoresToCreate.add(leadscore);
        }
        
        //Final Percentage according to weightage and sum of all percentages of all categories
        //Ask about it
        Double weightedScore = (demographicScore*0.2)+(activitiesScore*0.3)+(timelineScore*0.2)+(preQualStudentTrackerScore*0.3);
        lead.Weighted_Score__c = weightedScore;
        update lead;
        system.debug('Scores for this Publisher: ' + scoresToCreate);
        return scoresToCreate;      
    } 
    
    //Method calling in calculateLeadScore method and will Calculate and return Demographic Score 
    public Double calculateDemographic(string Landing_Page_Program_of_Interest,string Applying_for_Term,boolean isUnits_Complete60,
                                       boolean isGolden_4,boolean Lower_DivsionPrep,string Lead_Status,string Lead_Source,
                                       string Microsite_WebinarRSVP,string Microsite_ProgramOfInterest,string Microsite_CommunityCollege,
                                       string Microsite_DesiredTerm,string HTM_MemIndustry,string Degree_CompletionProgram) 
    {
        Demographic__mdt demographic=[SELECT Id,LandingPage_AnyValue__c, ApplyingForTerm_CurrentTerm__c, ApplyingForTerm_FutureTerm__c, 
                                      ApplyingForTerm_PastTerm__c, x60UnitsComplete_Checked__c, Golden4_Checked__c, LowerDivisionPrep_Checked__c,
                                      LeadStatus_ProvisionallyAdmitted__c, LeadStatus_Preapplication__c, LeadStatus_OpenProvisionally__c,
                                      LeadStatus_Admitted__c, LeadStatus_Denied__c, LeadStatus_PreapplicationToProspect__c, LeadSource_Referral__c,
                                      LeadSource_Affiliate__c, LeadSource_TransferFromMainCampus__c, LeadSource_Web_Organic__c, 
                                      LeadSource_DeniedFromMainCampus__c, LeadSource_CalState__c, MicrositeWebinarRSVP__c, 
                                      MicrositeProgramOfInterest_Anyvalue__c, MicrositeCommunityCollege_Anyvalue__c, 
                                      MicrositeDesiredTerm_FutureTerms__c, MicrositeDesiredTerm_PastAndCurrentTerms__c,
                                      HTM_MEMIndustry_Anyvalue__c, DegreeCompletionProgram_Anyvalue__c,ApplyForTermCurrent__c,
                                      ApplyForTermFuture__c,MicrositeDesiredTermCurrent__c,LeadStatus_Open__c,
                                      LeadStatus_AttemptedContact__c,LeadStatus_Prospect__c,Lead_Status_Closed__c,Lead_Status_Aged_closed__c,
                                      Lead_Status_Suspected_Bot__c,Lead_Status_Unqualified__c,	Lead_Status_Prequalified__c,LeadSource_Web_Paid_Digital__c,
                                      LeadSource_Imported_list__c,LeadSource_Cal_State_Apply_Feeds__c,LeadSource_Chat__c,LeadSource_Email__c,
                                      LeadSource_Event__c,LeadSource_Phone__c,LeadSource_Print__c,
                                      MicrositeDesiredTermFuture__c,LeadStatus_Applied__c FROM Demographic__mdt limit 1];
        
        double totalDemographic=0,landingPageProgramOfInterest=0,applyingForTerm=0,unitsComplete60Value=0,
            golden4Value=0,lowerDivsionPrepValue=0,leadStatus=0,leadSourceValue=0,micrositeWebinarRSVP=0,
            micrositeProgramOfInterest=0,micrositeCommunityCollege=0,micrositeDesiredTerm=0,htmMemIndustry=0,degreeCompletionProg=0;
        if(Landing_Page_Program_of_Interest!=null){
            landingPageProgramOfInterest=demographic.LandingPage_AnyValue__c;
        }
        else{
            landingPageProgramOfInterest=0;
        }
        
        if(Applying_for_Term == demographic.ApplyForTermFuture__c)
        {
            applyingForTerm=20;
        }
       	else if(Applying_for_Term == demographic.ApplyForTermCurrent__c)
        {
            applyingForTerm=40;
        }
        else
        {
         applyingForTerm=20;   
        }
        
        /*
        switch on Applying_for_Term{
        when 'Current Term'{
        applyingForTerm=40;
        }
        when 'Future Term'{
        applyingForTerm=20;
        }
        when 'Past Terms'{
        applyingForTerm=20;
        }
        when 'Null'{
        applyingForTerm=0;
        }
        }
        */
        
        if(Microsite_DesiredTerm == demographic.MicrositeDesiredTermCurrent__c)
        {
            micrositeDesiredTerm=-20;
        }
        else if(Microsite_DesiredTerm == demographic.MicrositeDesiredTermFuture__c)
        {
            micrositeDesiredTerm=40;
        }
        else
        {
         micrositeDesiredTerm=-20;   
        }
        
        /*
        switch on Microsite_DesiredTerm{
        when 'Future Terms'{
        micrositeDesiredTerm=40;
        }
        when 'Past and Current Term'{
        micrositeDesiredTerm=-20;
        }
        }
        */
        switch on Lead_Status{
            when 'Applied'{
                leadStatus=demographic.LeadStatus_Applied__c;
            }
            when 'Admitted'{
                leadStatus=demographic.LeadStatus_Admitted__c;
            }
            when 'Preapplication'{
                leadStatus=demographic.LeadStatus_Preapplication__c;
            }
            when 'Open – Provisionally Admitted'{
                leadStatus=demographic.LeadStatus_OpenProvisionally__c;
            }
            when 'Provisional Admission'{
                leadStatus=demographic.LeadStatus_OpenProvisionally__c;
            }
            when 'Denied'{
                leadStatus=demographic.LeadStatus_Denied__c;
            }
            when 'Open'{
                leadStatus=demographic.LeadStatus_Open__c;
            }
            when 'Attempted Contact'{
                leadStatus=demographic.LeadStatus_AttemptedContact__c;
            }
            when 'Prospect'{
                leadStatus=demographic.LeadStatus_Prospect__c;
            }
            when 'Preapplication to Prospect'{
                leadStatus=demographic.LeadStatus_PreapplicationToProspect__c;
            }
            when 'Closed'{
                leadStatus=demographic.Lead_Status_Closed__c;
            }
            when 'Aged - Closed'{
                leadStatus=demographic.Lead_Status_Aged_closed__c;
            }
            when 'Suspected Bot'{
                leadStatus=demographic.Lead_Status_Suspected_Bot__c;
            }
            when 'Unqualified'{
                leadStatus=demographic.Lead_Status_Unqualified__c;
            }
            when 'Prequalified'{
                leadStatus=demographic.Lead_Status_Prequalified__c;
            }
            
            when else{
                leadStatus=0;
            }
        }
        if(isUnits_Complete60 == true){
            unitsComplete60Value=demographic.x60UnitsComplete_Checked__c;
        }
        else{
            unitsComplete60Value=0;
        }
        if(isGolden_4 == true){
            golden4Value = demographic.Golden4_Checked__c;
        }
        else{
            golden4Value =0;
        }
        if(Lower_DivsionPrep==true)
        {
            lowerDivsionPrepValue=demographic.LowerDivisionPrep_Checked__c;
        }
        else{
            lowerDivsionPrepValue=0;
        }
        
        switch on Lead_Source{
            when 'Referral'{
                leadSourceValue=demographic.LeadSource_Referral__c;
            }
            when 'Affiliate'{
                leadSourceValue=demographic.LeadSource_Affiliate__c;
            }
            when 'Transfer from Main Campus'{
                leadSourceValue=demographic.LeadSource_TransferFromMainCampus__c;
            }
            when 'Web - Organic'{
                leadSourceValue=demographic.LeadSource_Web_Organic__c;
            }
            when 'Denied from Main Campus'{
                leadSourceValue=demographic.LeadSource_DeniedFromMainCampus__c;
            }
            when 'Cal State Apply Feeds'{
                leadSourceValue=demographic.LeadSource_Cal_State_Apply_Feeds__c;
            }
            when 'Chat'{
                leadSourceValue=demographic.LeadSource_Chat__c;
            }
            when 'Email'{
                leadSourceValue=demographic.LeadSource_Email__c;
            }
            when 'Event'{
                leadSourceValue=demographic.LeadSource_Event__c;
            }
            when 'Imported List'{
                leadSourceValue=demographic.LeadSource_Imported_list__c;
            }
            when 'Phone'{
                leadSourceValue=demographic.LeadSource_Phone__c;
            }
            when 'Print'{
                leadSourceValue=demographic.LeadSource_Print__c;
            }
            when 'Web - Paid Digital'{
                leadSourceValue=demographic.LeadSource_Web_Paid_Digital__c;
            }
            when else{
                leadSourceValue=0;
            }
        }
        if(Microsite_WebinarRSVP!=NULL )
        {
            micrositeWebinarRSVP=demographic.MicrositeWebinarRSVP__c;
        }
        else{
            micrositeWebinarRSVP=0;
        }
        
        if(Microsite_ProgramOfInterest!=NULL)
        {
            micrositeProgramOfInterest=demographic.MicrositeProgramOfInterest_Anyvalue__c;
        }
        else{
            micrositeProgramOfInterest=0;
        }
        if(Microsite_CommunityCollege!=NULL )
        {
            micrositeCommunityCollege=demographic.MicrositeCommunityCollege_Anyvalue__c;
        }
        else{
            micrositeCommunityCollege=0;
        }
        if(HTM_MemIndustry!=NULL )
        {
            htmMemIndustry=demographic.HTM_MEMIndustry_Anyvalue__c;
        }
        else{
            htmMemIndustry=0;
        }
        if(Degree_CompletionProgram!=NULL )
        {
            degreeCompletionProg=demographic.DegreeCompletionProgram_Anyvalue__c;
        }
        else{
            degreeCompletionProg=0;
        }
        
        
        /*totalDemographic=(landingPageProgramOfInterest+applyingForTerm+unitsComplete60Value+
                          golden4Value+lowerDivsionPrepValue+leadStatus+leadSourceValue+micrositeWebinarRSVP+
                          micrositeProgramOfInterest+micrositeCommunityCollege+micrositeDesiredTerm+htmMemIndustry+degreeCompletionProg);*/
        totalDemographic=(leadStatus+leadSourceValue);
        return totalDemographic;
    } 
    
    //Method calling in calculateLeadScore method and will Calculate and return Activities Score 
    public Double calculateActivities(date landingPageSubmission,string TextLaneDeliveryResponseCode, boolean emailOptOut,
                                      string ActivityInfoSessionApplicationWorkshopRSVP, boolean emailOpen, boolean inboundCall){
        double landingPageSubmissionValue,textMessageReplyValue,emailOptOutValue,ActivityInfoSessionApplicationWorkshopRSVPValue,emailOpenValue,inboundCallValue;
        Activities__mdt activities=  [SELECT Id, Activities_LandingPageSubmission__c, Activities_TextMessageReply__c,Act_InfoSessionApplicationWorkshopRSVP__c,
                                     Activities_EmailOpen__c, Activities_EmailOptOut__c, Activities_EmailReply__c, Activities_InboundCall__c FROM Activities__mdt];
        if(landingPageSubmission!=Null){
            landingPageSubmissionValue=activities.Activities_LandingPageSubmission__c;
        }
        else{
            landingPageSubmissionValue=0;
        }
        if(TextLaneDeliveryResponseCode!=NULL)
        {
            textMessageReplyValue=activities.Activities_TextMessageReply__c;
        }
        else
        {
            textMessageReplyValue=0;
        }
        if(emailOptOut == true)
        {
            emailOptOutValue=activities.Activities_EmailOptOut__c;
        }
        else
        {
            emailOptOutValue=0;
        }
        if(ActivityInfoSessionApplicationWorkshopRSVP != NULL)
        {
            ActivityInfoSessionApplicationWorkshopRSVPValue=activities.Act_InfoSessionApplicationWorkshopRSVP__c;
        }
        else
        {
            ActivityInfoSessionApplicationWorkshopRSVPValue=0;
        }
        if(emailOpen == true)
        {
            emailOpenValue=activities.Activities_EmailOpen__c;
        }
        else
        {
            emailOpenValue=0;
        }
        if(inboundCall == true)
        {
            inboundCallValue=activities.Activities_InboundCall__c;
        }
        else
        {
            inboundCallValue=0;
        }
           
        double totalActivities=(landingPageSubmissionValue+textMessageReplyValue+emailOptOutValue+ActivityInfoSessionApplicationWorkshopRSVPValue+emailOpenValue+
                                inboundCallValue);
        return totalActivities;
    }
    //Method calling in calculateLeadScore method and will Calculate and return Timeline Score 
	public Double calculateTimeline(Decimal Days_in_Status) {
    Timeline__mdt timeline = [SELECT Id, Timeline_LeadCreatedToday__c, Timeline_LeadCreated150daysAgo__c, 
                              Timeline_LeadCreated30daysAgo__c, Timeline_LeadCreated60daysAgo__c,
                              Timeline_LeadCreated90daysAgo__c,Timeline_LeadCreated120daysAgo__c FROM Timeline__mdt LIMIT 1];
    
    double totalTimeline = 0;
    datetime dT = Datetime.now();
    Date myDate = Date.newInstance(dT.year(), dT.month(), dT.day());
    //Date createdDate = Date.newInstance(CreateDate.year(), CreateDate.month(), CreateDate.day());

	if (Days_in_Status >= 0 && Days_in_Status <= 29) {
    totalTimeline = timeline.Timeline_LeadCreatedToday__c;
	} 
    else if (Days_in_Status >= 30 && Days_in_Status <= 59) {
    totalTimeline = timeline.Timeline_LeadCreated30daysAgo__c;
	} 
    else if (Days_in_Status >= 60 && Days_in_Status <= 89) {
    totalTimeline = timeline.Timeline_LeadCreated60daysAgo__c;
	} 
    else if (Days_in_Status >= 90 && Days_in_Status <= 119) {
    totalTimeline = timeline.Timeline_LeadCreated90daysAgo__c;
	}
    else if (Days_in_Status >= 120 && Days_in_Status <= 149) {
    totalTimeline = timeline.Timeline_LeadCreated120daysAgo__c;
	}
    else {
    totalTimeline = timeline.Timeline_LeadCreated150daysAgo__c;
	}    
	return totalTimeline; 
	}




    
		public Double calculatePreQualStudentTrackerScore(string Name, boolean X60Units, boolean CSU_GPA, boolean CSU_A1, boolean CSU_A2, boolean CSU_A3,
                                                          boolean CSU_B4, boolean MissingPrepCourses, string Outcome, boolean Program_GPA, boolean SDSU_GPA, string Semester){
        
                                                              
        double totalPreQualStudentTracker=0,nameValue=0, X60UnitsValue=0, CSU_GPA_Value=0, CSU_A1_Value=0, CSU_A2_Value=0, CSU_A3_Value=0, CSU_B4_Value=0, MissingPrepCoursesValue=0, OutcomeValue=0,
            	Program_GPA_Value=0, SDSU_GPA_Value=0, SemesterValue=0;
        PreQual_Student_Trackers__mdt preQualStudentTracker=  [SELECT PreQual_Student_Tracker__c,PreQual_60_Units__c,PreQual_CSU_A1__c,PreQual_CSU_A2__c,
                                                               PreQual_CSU_A3__c,PreQual_CSU_B4__c,	PreQual_CSU_GPA__c,PreQual_Missing_Prep_Courses__c,
                                                               PreQual_Outcome_Conditionally_Eligible__c,PreQual_Outcome_Eligible__c,PreQual_Outcome_Ineligible__c,
                                                               PreQual_Program_GPA__c,PreQual_SDSU_GPA__c,	PreQual_Semester_FA23__c,PreQual_Semester_FA24__c,
                                                               PreQual_Semester_FA25__c,PreQual_Semester_SP23__c,PreQual_Semester_SP24__c,
                                                               PreQual_Semester_SP25__c FROM PreQual_Student_Trackers__mdt ];
            
            if(Name != Null){
                nameValue = preQualStudentTracker.PreQual_Student_Tracker__c;
            }
            else{
                nameValue=0;
            }
             System.debug('Name ' + nameValue);                                                 
            if(X60Units == true){
                X60UnitsValue = preQualStudentTracker.PreQual_60_Units__c;
            }
            else{
                X60UnitsValue=0;
            }
            System.debug('X60 ' + X60UnitsValue);
                                                              
            if(CSU_GPA == true){
                CSU_GPA_Value = preQualStudentTracker.PreQual_CSU_GPA__c;
            }
            else{
                CSU_GPA_Value=0;
            }
            System.debug('GPA VALUE ' + CSU_GPA_Value);
                                                              
            if(CSU_A1 == true){
                CSU_A1_Value = preQualStudentTracker.PreQual_CSU_A1__c;
            }
            else{
                CSU_A1_Value=0;
            }
            System.debug('A1 ' + CSU_A1_Value);
                                                              
            if(CSU_A2 == true){
                CSU_A2_Value = preQualStudentTracker.PreQual_CSU_A2__c;
            }
            else{
                CSU_A2_Value=0;
            }
            System.debug('A2 ' + CSU_A2_Value);                 
            if(CSU_A3 == true){
                CSU_A3_Value = preQualStudentTracker.PreQual_CSU_A3__c;
            }
            else{
                CSU_A3_Value=0;
            }
            System.debug('A3 ' + CSU_A3_Value);                                  
            if(CSU_B4 == true){
                CSU_B4_Value = preQualStudentTracker.PreQual_CSU_B4__c;
            }
            else{
                CSU_B4_Value=0;
            }
            System.debug('b4 ' + CSU_B4_Value);                                  
            
                                                              
            if(MissingPrepCourses == true){
                MissingPrepCoursesValue = preQualStudentTracker.PreQual_Missing_Prep_Courses__c;
            }
            else{
                MissingPrepCoursesValue=0;
            }
            System.debug('Miss ' + MissingPrepCoursesValue);                                  
            
                                                              
            switch on Outcome{
                
                when 'Eligible'{
                    OutcomeValue = preQualStudentTracker.PreQual_Outcome_Eligible__c;
                }
                
                when 'Conditionally Eligible'{
                    OutcomeValue = preQualStudentTracker.PreQual_Outcome_Conditionally_Eligible__c;
                }
                
                when 'Ineligible'{
                    OutcomeValue = preQualStudentTracker.PreQual_Outcome_Ineligible__c;
                }
                when else{
                	OutcomeValue=0;
            }
            }
            System.debug('outcome ' + OutcomeValue);                                  
            
                                                              
            if(Program_GPA == true){
                Program_GPA_Value = preQualStudentTracker.PreQual_Program_GPA__c;
            }
            else{
                Program_GPA_Value=0;
            }
            System.debug('Prog GPA ' + Program_GPA_Value);                                  
            
                                                              
           	if(SDSU_GPA == true){
                SDSU_GPA_Value = preQualStudentTracker.PreQual_SDSU_GPA__c;
            }
            else{
                SDSU_GPA_Value=0;
            }
            System.debug('SDSU GPA ' + SDSU_GPA_Value);                                  
            
                                                              
            switch on Semester{
                when 'FA23'{
                    SemesterValue = preQualStudentTracker.PreQual_Semester_FA23__c;
                }
                when 'SP24'{
                    SemesterValue = preQualStudentTracker.PreQual_Semester_SP24__c;
                }
                when 'FA24'{
                    SemesterValue = preQualStudentTracker.PreQual_Semester_FA24__c;
                }
                when 'SP25'{
                    SemesterValue = preQualStudentTracker.PreQual_Semester_SP25__c;
                }
                when 'FA25'{
                    SemesterValue = preQualStudentTracker.PreQual_Semester_FA25__c;
                }
                when 'SP23'{
                    SemesterValue = preQualStudentTracker.PreQual_Semester_SP23__c;
                }
                
                when else{
                	SemesterValue=0;
            	}
            }                                                 
            
            System.debug('Sem Value ' + SemesterValue);                                  
                                                              
            totalPreQualStudentTracker=(nameValue+X60UnitsValue+CSU_GPA_Value+CSU_A1_Value+CSU_A2_Value+CSU_A3_Value+CSU_B4_Value+
             MissingPrepCoursesValue+OutcomeValue+Program_GPA_Value+SDSU_GPA_Value+SemesterValue);
             System.debug('Total' + totalPreQualStudentTracker);
        return (totalPreQualStudentTracker);  
          
        }
}