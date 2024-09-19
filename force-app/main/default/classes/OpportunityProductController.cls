public with sharing class OpportunityProductController {
  @AuraEnabled(cacheable=false)
  public static void addOpportunityProduct(
    Id opportunityId,
    List<Id> productIds
  ) {
    List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
    Opportunity opp = [
      SELECT Id, Pricebook2Id
      FROM Opportunity
      WHERE Id = :opportunityId
    ];
    Pricebook2 pricebook = [
      SELECT Id
      FROM Pricebook2
      WHERE Id = '01sbm000004JhLWAA0'
      LIMIT 1
    ];
    if (opp.Pricebook2Id == null) {
      opp.Pricebook2Id = pricebook.Id;
      update opp;
    }
    List<PricebookEntry> entries = [
      SELECT Id, Name, Product2Id, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :pricebook.Id AND Product2Id IN :productIds
    ];
    for (PricebookEntry ent : entries) {
      OpportunityLineItem lineItem = new OpportunityLineItem(
        OpportunityId = opportunityId,
        Product2Id = ent.Product2Id,
        Quantity = 1,
        UnitPrice = ent.UnitPrice
      );
      lineItems.add(lineItem);
    }

    if (!lineItems.isEmpty()) {
      insert lineItems;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<PricebookEntry> getProductEntries(Id pricebookId) {
    return [
      SELECT Id, Name, Product2Id, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :pricebookId
    ];
  }
  @AuraEnabled(cacheable=true)
  public static List<OpportunityLineItem> populateDataTable(Id opportunityId) {
    return [
      SELECT Quantity, UnitPrice, TotalPrice, PricebookEntry.Name, Discount, Id
      FROM OpportunityLineItem
      WHERE OpportunityId = :opportunityId
    ];
  }
  @AuraEnabled
  public static void updateRecords(
    List<OpportunityLineItem> opportunityLineData
  ) {
    try {
      if (!opportunityLineData.isEmpty()) {
        update opportunityLineData;
      }
    } catch (DmlException e) {
      String errorMessage = e.getDmlMessage(0);
      throw new AuraHandledException(errorMessage);
    }
  }
  public OpportunityProductController() {
  }
}
