trigger LeadScoringTrigger on Lead (after update) {
  // List to hold Lead IDs for processing
  Set<Id> leadIdsToProcess = new Set<Id>();

  // Iterate through each Lead to check for Qualified, Unqualified, or Converted status
  for (Lead lead : Trigger.new) {
      if ((lead.Status == 'Qualified' || lead.Status == 'Unqualified' || lead.Status == 'Converted' || lead.Status == 'Applied') && 
          (Trigger.oldMap.get(lead.Id).Status != lead.Status)) {
          leadIdsToProcess.add(lead.Id);
      }
  }

  // Delegate processing to the handler class
  LeadScoringHandler.handleLeadUpdate(leadIdsToProcess);
}