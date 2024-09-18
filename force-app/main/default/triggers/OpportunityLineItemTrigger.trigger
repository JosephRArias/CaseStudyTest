trigger OpportunityLineItemTrigger on OpportunityLineItem(after insert) {
  Set<Id> opportunityIds = new Set<Id>();
  string targetStage = 'Value Proposition';

  for (OpportunityLineItem oli : Trigger.new) {
    opportunityIds.add(oli.OpportunityId);
  }
  List<OpportunityStage> opportunityStages = [
    SELECT MasterLabel, SortOrder
    FROM OpportunityStage
    WHERE IsActive = TRUE
  ];
  List<Opportunity> oppsToUpdate = [
    SELECT Id, StageName
    FROM Opportunity
    WHERE Id IN :opportunityIds
  ];
  Map<String, Integer> stageOrderMap = new Map<String, Integer>();
  for (OpportunityStage os : opportunityStages) {
    stageOrderMap.put(os.MasterLabel, os.SortOrder);
  }

  for (Opportunity op : oppsToUpdate) {
    Integer currentStageOrder = stageOrderMap.get(op.StageName);
    Integer targetStageOrder = stageOrderMap.get(targetStage);

    if (currentStageOrder < targetStageOrder) {
      op.StageName = targetStage;
    }
  }
  if (!oppsToUpdate.isEmpty()) {
    update oppsToUpdate;
  }

}
