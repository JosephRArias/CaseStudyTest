trigger LimitDiscountOnOpportunityLineItem on OpportunityLineItem(
  before insert,
  before update
) {
  /*List<OpportunityLineItem> oliWithPricebook = [
    SELECT
      Id,
      UnitPrice,
      Quantity,
      TotalPrice,
      PricebookEntry.UnitPrice,
      PricebookEntry.Product2.Name,
      Discount
    FROM OpportunityLineItem
    WHERE Id IN :Trigger.newMap.keySet()
  ];*/

  for (OpportunityLineItem oli : Trigger.new) {
    Decimal maxAllowedDiscount = 0.30;
    Decimal appliedDiscount = oli.Discount;
    if (appliedDiscount > maxAllowedDiscount) {
      oli.AddError('The discount exceeds the limit of 30%.');
    }
  }

}
