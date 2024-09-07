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
public class RestrictContactByRecordTypeTest {
  @isTest
  static void testRestrictContactInsertion() {
    // Create a test Account
    Account acc = new Account(
      Name = 'Test Account',
      RecordTypeId = '012bm000002IdwDAAS'
    );
    insert acc;

    // Insert the first Contact with the restricted record type (this should succeed)
    Contact con1 = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Email = 'john.doe@example.com',
      AccountId = acc.Id
    );
    insert con1;

    // Try to insert a second Contact with the same restricted record type (this should fail)
    Contact con2 = new Contact(
      FirstName = 'Jane',
      LastName = 'Smith',
      Email = 'jane.smith@example.com',
      AccountId = acc.Id
    );

    // Test that the second insertion fails
    try {
      insert con2;
      System.assert(false, 'The trigger should have thrown an exception.');
    } catch (DmlException e) {
      System.assert(
        e.getMessage()
          .contains('Only one contact is allowed for Personal Record Type')
      );
    }
  }
}
