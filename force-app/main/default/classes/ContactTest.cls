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
private class ContactTest {
  @isTest
  static void testRestrictContactInsertion() {
    Account acc = new Account(
      Name = 'Test Account',
      RecordTypeId = '012bm000002IdwDAAS'
    );
    insert acc;

    Contact con1 = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john.doe@example.com',
      AccountId = acc.Id
    );
    insert con1;

    Contact con2 = new Contact(
      FirstName = 'Jane',
      LastName = 'Smith',
      Email = 'jane.smith@example.com',
      AccountId = acc.Id
    );

    try {
      insert con2;
      System.assert(false, 'The trigger should have thrown an exception.');
    } catch (DmlException e) {
      System.assert(
        e.getMessage()
          .contains('Only one contact is allowed on Personal Accounts')
      );
    }
  }

  @isTest
  static void testRestrictContactUpdateToAccount() {
    Account acc1 = new Account(
      Name = 'Test Account',
      RecordTypeId = '012bm000002IdwDAAS'
    );
    insert acc1;

    Contact con1 = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john.doe@example.com',
      AccountId = acc1.Id
    );
    insert con1;
    Account acc2 = new Account(
      Name = 'Test Account 2',
      RecordTypeId = '012bm000002IdwDAAS'
    );
    insert acc2;
    Contact con2 = new Contact(
      FirstName = 'Jane',
      LastName = 'Doe',
      Email = 'jane.doe@example.com',
      AccountId = acc2.Id
    );
    insert con2;
    try {
      Contact c = [
        SELECT Id, AccountId
        FROM Contact
        WHERE Email = 'jane.doe@example.com'
      ];
      c.AccountId = acc1.Id;
      update c;
      System.assert(false, 'The trigger should have thrown an exception.');
    } catch (DmlException e) {
      System.assert(
        e.getMessage()
          .contains('Only one contact is allowed on Personal Accounts')
      );
    }
  }
  @isTest
  static void testAccountUpdateOnContactUpdateOrInsert() {
    Account acc = new Account(
      Name = 'Test Account',
      RecordTypeId = '012bm000002IdwDAAS'
    );
    insert acc;
    Contact con = new Contact(
      FirstName = 'Jose',
      LastName = 'Arias',
      Phone = '8005554040',
      Email = 'jariasm@test.com',
      AccountId = acc.Id
    );
    insert con;
    Account updatedAccount = [
      SELECT Id, Email__c, Phone, Name
      FROM Account
      WHERE Id = :acc.Id
    ];
    System.assertEquals('jariasm@test.com', updatedAccount.Email__c);
    System.assertEquals('8005554040', updatedAccount.Phone);
    System.assertEquals('Jose Arias', updatedAccount.Name);
  }
}
