/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OpportunityLineItemTest {
  @IsTest
  static void testDiscountLimit() {
    Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
    insert prod;

    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = '01sbm000004JhLWAA0',
      Product2Id = prod.Id,
      UnitPrice = 100,
      IsActive = true
    );
    insert pbe;

    // Create an Opportunity
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Prospecting',
      CloseDate = Date.today()
    );
    insert opp;
    OpportunityLineItem oli = new OpportunityLineItem(
      OpportunityId = opp.Id,
      PricebookEntryId = pbe.Id,
      UnitPrice = 50,
      Quantity = 1,
      TotalPrice = 50,
      Discount = 0.50
    );

    try {
      insert oli;
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('The discount exceeds the limit of 30%.'),
        'Expected discount limit error'
      );
    }
  }
  @isTest
  static void opportunityStageUpdateTest() {
    Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
    insert prod;
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = '01sbm000004JhLWAA0',
      Product2Id = prod.Id,
      UnitPrice = 100,
      IsActive = true
    );
    insert pbe;

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Qualification',
      CloseDate = Date.today().addDays(30),
      Pricebook2Id = '01sbm000004JhLWAA0'
    );
    insert opp;
    OpportunityLineItem oli = new OpportunityLineItem(
      OpportunityId = opp.Id,
      PricebookEntryId = pbe.Id,
      Quantity = 2,
      UnitPrice = 100
    );

    insert oli;

    Opportunity updatedOpp = [
      SELECT StageName
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    System.assertEquals(
      'Value Proposition',
      updatedOpp.StageName,
      'The Opportunity stage should have been updated to "Value Proposition"'
    );
  }
}
