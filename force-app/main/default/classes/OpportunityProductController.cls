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
    /*Map<Id, PricebookEntry> pricebookEntryMap= new Map<Id, PricebookEntry>(
      [SELECT Id, Product2Id FROM Product2 WHERE Product2Id IN :productIds AND Pricebook2Id = '01sbm000004JhLWAA0']
    );*/
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

    // Insert OpportunityLineItem records
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
      SELECT Quantity, UnitPrice, TotalPrice, PricebookEntry.Name, Discount
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
