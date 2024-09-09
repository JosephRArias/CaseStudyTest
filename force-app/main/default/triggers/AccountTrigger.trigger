trigger AccountTrigger on Account(after update) {
  if (TriggerHelper.isAccountTriggerRunning) {
    return;
  }
  TriggerHelper.isAccountTriggerRunning = true;
  Map<Id, Account> updatedAccounts = new Map<Id, Account>();
  for (Account acc : Trigger.new) {
    updatedAccounts.put(acc.Id, acc);
  }

  List<Contact> contactsToUpdate = new List<Contact>();
  contactsToUpdate = [
    SELECT
      Id,
      Name,
      Phone,
      MailingStreet,
      MailingCity,
      MailingState,
      MailingCountry,
      MailingPostalCode,
      Birthdate,
      Salutation,
      AccountId
    FROM Contact
    WHERE AccountId IN :updatedAccounts.keySet()
  ];
  for (Contact con : contactsToUpdate) {
    Account updatedAcc = updatedAccounts.get(con.AccountId);
    con.FirstName = updatedAcc.Name;
    con.Phone = updatedAcc.Phone;
    con.Email = updatedAcc.Email__c;
    con.Birthdate = updatedAcc.Birthdate__c;
    con.Salutation = updatedAcc.Salutation__c;
    con.Client_Score__c = updatedAcc.Client_Score__c;
    con.MailingStreet = updatedAcc.ShippingStreet;
    con.MailingCity = updatedAcc.ShippingCity;
    con.MailingState = updatedAcc.ShippingState;
    con.MailingCountry = updatedAcc.ShippingCountry;
    con.MailingPostalCode = updatedAcc.ShippingPostalCode;
  }
  if (!contactsToUpdate.isEmpty()) {
    update contactsToUpdate;
  }
  TriggerHelper.isAccountTriggerRunning = false;
}
