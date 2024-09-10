public with sharing class OpportunityProductController {
  @AuraEnabled(cacheable=true)
  public static void addOpportunityProduct(
    Id opportunityId,
    List<OpportunityLineItem> products
  ) {
    for (OpportunityLineItem op : products) {
      op.OpportunityId = opportunityId;
    }
    insert products;
  }

  @AuraEnabled
  public static List<PricebookEntry> getProductEntries(Id pricebookId) {
    return [
      SELECT Id, Name, Product2Id, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :pricebookId
    ];
  }
  public OpportunityProductController() {
  }
}
