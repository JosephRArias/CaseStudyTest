trigger ContactTrigger on Contact(
  after update,
  after insert,
  before insert,
  before update
) {
  Set<Id> accountIds = new Set<Id>();
  String personalRecordTypeId = '012bm000002IdwDAAS';

  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      for (Contact con : Trigger.new) {
        if (con.AccountId != null) {
          accountIds.add(con.AccountId);
        }
      }
      if (!accountIds.isEmpty()) {
        Map<Id, Account> accountMap = new Map<Id, Account>(
          [
            SELECT Id, RecordType.Id, (SELECT Id FROM Contacts)
            FROM Account
            WHERE Id IN :accountIds
          ]
        );
        for (Contact con : Trigger.new) {
          Account acc = accountMap.get(con.AccountId);
          if (acc != null) {
            if (
              acc.Contacts.size() > 0 &&
              acc.RecordType.Id == personalRecordTypeId
            ) {
              con.AddError('Only one contact is allowed on Personal Accounts');
            }
          }
        }
      }
    }
  } else if (Trigger.isAfter) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
      for (Contact con : Trigger.new) {
        if (con.AccountId != null) {
          Account acc = accountsToUpdate.get(con.AccountId);
          if (acc == null) {
            acc = [
              SELECT
                Id,
                Name,
                ShippingStreet,
                ShippingCity,
                ShippingState,
                ShippingCountry,
                ShippingPostalCode,
                Phone,
                Email__c,
                Birthdate__c,
                Salutation__c,
                Client_Score__c
              FROM Account
              WHERE Id = :con.AccountId
              LIMIT 1
            ];
            accountsToUpdate.put(acc.Id, acc);
          }
          acc.Name = con.FirstName + ' ' + con.LastName;
          acc.Phone = con.Phone;
          acc.Email__c = con.Email;
          acc.Birthdate__c = con.Birthdate;
          acc.Salutation__c = con.Salutation;
          acc.Client_Score__c = con.Client_Score__c;
          acc.ShippingStreet = con.MailingStreet;
          acc.ShippingCity = con.MailingCity;
          acc.ShippingState = con.MailingState;
          acc.ShippingCountry = con.MailingCountry;
          acc.ShippingPostalCode = con.MailingPostalCode;
        }
      }
      if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate.values();
      }
    }
  }
}
