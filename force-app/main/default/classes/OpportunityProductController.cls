public with sharing class OpportunityProductController {
  @AuraEnabled(cacheable=false)
  public static void addOpportunityProduct(
    Id opportunityId,
    List<OpportunityLineItem> products
  ) {
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
    opp.Pricebook2Id = pricebook.Id;
    update opp;
    for (OpportunityLineItem oli : products) {
      oli.OpportunityId = opportunityId;
    }
    insert products;
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
      SELECT
        Quantity,
        UnitPrice,
        TotalPrice,
        PricebookEntry.Name,
        PricebookEntry.Product2.Family
      FROM OpportunityLineItem
      WHERE OpportunityId = :opportunityId
    ];
  }
  @AuraEnabled(cacheable=true)
  public static Decimal getUnitPrice(Id Product2Id) {
    try {
      PricebookEntry result = [
        SELECT UnitPrice
        FROM PricebookEntry
        WHERE Product2Id = :Product2Id
        LIMIT 1
      ];
      return result.UnitPrice;
    } catch (Exception e) {
      // Handle error or return a default value
      throw new AuraHandledException(
        'Error fetching UnitPrice: ' + e.getMessage()
      );
    }
  }
  public OpportunityProductController() {
  }
}
