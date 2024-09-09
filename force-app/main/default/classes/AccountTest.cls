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
public class AccountTest {
  @isTest
  static void testAccountFieldSync() {
    // Create a test Account
    Account acc = new Account(
      Name = 'Testing Account',
      Phone = '0000000000',
      BillingCity = 'New York'
    );
    insert acc;

    // Create test Contacts related to the Account
    Contact con1 = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Phone = '0987654321',
      MailingCity = 'San Francisco',
      AccountId = acc.Id
    );
    insert con1;

    // Update the Account's Phone and BillingCity
    acc.Phone = '9999999999';
    acc.ShippingCity = 'Chicago';
    update acc;

    // Query the Contacts again to verify the changes
    List<Contact> updatedContacts = [
      SELECT Phone, MailingCity
      FROM Contact
      WHERE AccountId = :acc.Id
    ];

    // Verify that the Contact fields have been updated correctly
    for (Contact con : updatedContacts) {
      System.assertEquals(
        '9999999999',
        con.Phone,
        'Contact phone should match Account phone'
      );
      System.assertEquals(
        'Chicago',
        con.MailingCity,
        'Contact MailingCity should match Account BillingCity'
      );
    }
  }
}
