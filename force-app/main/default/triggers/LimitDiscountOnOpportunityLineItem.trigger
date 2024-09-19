trigger LimitDiscountOnOpportunityLineItem on OpportunityLineItem(
  before insert,
  before update
) {
  for (OpportunityLineItem oli : Trigger.new) {
    Decimal maxAllowedDiscount = 0.30;
    Decimal appliedDiscount = oli.Discount;
    if (appliedDiscount > maxAllowedDiscount) {
      oli.AddError('The discount exceeds the limit of 30%.');
    }
  }

}
