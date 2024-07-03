public class LeadScoringHandler {
    
    public static void handleLeadUpdate(Set<Id> leadIdsToProcess) {
        if (!leadIdsToProcess.isEmpty()) {
            // Query Lead_Scoring__c records related to the Leads to be processed
            List<Lead_Scoring__c> leadScoringsToDelete = [
                SELECT Id 
                FROM Lead_Scoring__c 
                WHERE Lead__c IN :leadIdsToProcess
            ];

            // Delete the related Lead_Scoring__c records
            delete leadScoringsToDelete;

            // Prepare Leads to update the Weighted_Score__c field to null
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Lead lead : [SELECT Id, Weighted_Score__c FROM Lead WHERE Id IN :leadIdsToProcess]) {
                lead.Weighted_Score__c = null;
                leadsToUpdate.add(lead);
            }

            // Update the Leads
            update leadsToUpdate;
        }
    }
}
