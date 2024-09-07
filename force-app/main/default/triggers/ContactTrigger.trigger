trigger ContactTrigger on Contact(after update, before insert) {
  Set<Id> accountIds = new Set<Id>();
  String personalRecordTypeId = '012bm000002IdwDAAS';

  if (Trigger.isInsert) {
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

    if (Trigger.isUpdate) {
      for (Contact con : Trigger.new) {
        if (con.AccountId != null) {
          accountIds.add(con.AccountId);
        }
      }
    }

    /*if (!accountIds.isEmpty()) {
      List<Account> accounts = new List<Account>();
      accounts = [
        SELECT Id, ShippingAddress, Name, Phone, Email
        FROM Account
        WHERE Id IN :accountIds
      ];
    }*/
  }
}
