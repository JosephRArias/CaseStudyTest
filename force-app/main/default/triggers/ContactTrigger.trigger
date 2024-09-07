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
      List<AggregateResult> contactCount = [
        SELECT COUNT(Id), AccountId
        FROM Contact
        WHERE AccountId IN :accountIds AND RecordTypeId = :personalRecordTypeId
        GROUP BY AccountId
      ];
      Map<Id, Integer> accountToContactNumber = new Map<Id, Integer>();
      for (AggregateResult ar : contactCount) {
        accountToContactNumber.put(ar.get('AccountId'), ar.get(expr0));
      }
      for (Contact con : Trigger.new) {
        if (con.AccountId != null && con.RecordTypeId == personalRecordTypeId) {
          Integer contactCount = accountToContactNumber.get(con.AccountId);
          if (contactCount != null && contactCount >= 1) {
            con.addError(
              'Only one contact is allowed for Personal Record Type'
            );
          }
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

  if (!accountIds.isEmpty()) {
    List<Account> accounts = new List<Account>();
    accounts = [
      SELECT Id, ShippingAddress, Name, Phone, Email
      FROM Account
      WHERE Id IN :accountIds
    ];
  }
}
