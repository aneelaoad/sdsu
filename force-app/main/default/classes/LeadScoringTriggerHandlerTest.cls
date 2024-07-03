@isTest
public class LeadScoringTriggerHandlerTest {
    @isTest
    static void testHandleLeadUpdate() {
        // Create test Leads
        Lead lead1 = new Lead(LastName = 'Test1', Company = 'TestCompany1', Status = 'New');
        insert lead1;

        // Create related Lead_Scoring__c records
        Lead_Scoring__c leadScoring1 = new Lead_Scoring__c(Lead__c = lead1.Id);
        insert leadScoring1;

        // Update Lead to add a weighted score
        lead1.Weighted_Score__c = 100;
        update lead1;

        // Update Lead status to Unqualified
        lead1.Status = 'Unqualified';
        update lead1;

        // Verify that related Lead_Scoring__c records are deleted
        List<Lead_Scoring__c> leadScorings = [SELECT Id FROM Lead_Scoring__c WHERE Lead__c = :lead1.Id];
        System.assertEquals(0, leadScorings.size(), 'Related Lead_Scoring__c records should be deleted');

        // Verify that the Weighted_Score__c field is cleared
        Lead updatedLead1 = [SELECT Id, Weighted_Score__c FROM Lead WHERE Id = :lead1.Id];
        System.assertEquals(null, updatedLead1.Weighted_Score__c, 'Weighted_Score__c should be null for unqualified lead');
    }
}
