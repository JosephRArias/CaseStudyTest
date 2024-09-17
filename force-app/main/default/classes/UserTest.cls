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
private class UserTest {
  @isTest
  static void userChangeTracking() {
    // TO DO: implement unit test
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User us = new User(
      FirstName = 'Jose',
      LastName = 'Test',
      MobilePhone = '8097630031',
      Department = 'Finance',
      CompanyName = 'Consulting Firm Name',
      Username = 'josetest@test.com',
      Alias = 'testus',
      Email = 'testemail@test.com',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      ProfileId = p.Id,
      LanguageLocaleKey = 'en_US'
    );
    insert us;

    us.MobilePhone = '8885554444';
    update us;
    List<Field_Change_History__c> histories = [
      SELECT Field_Name__c, Old_Value__c, New_Value__c, Object_Name__c
      FROM Field_Change_History__c
      WHERE Name = :us.Id
    ];
    // Assertions to verify correct tracking
    System.assertEquals(
      1,
      histories.size(),
      'There should be one field change tracked.'
    );
    Field_Change_History__c history = histories[0];
    System.assertEquals(
      'MobilePhone',
      history.Field_Name__c,
      'The field name should be MobilePhone.'
    );
    System.assertEquals(
      '8097630031',
      history.Old_Value__c,
      'The old value should be 8097630031.'
    );
    System.assertEquals(
      '8885554444',
      history.New_Value__c,
      'The new value should be 8885554444.'
    );
    System.assertEquals(
      'User',
      history.Object_Name__c,
      'The object name should be User.'
    );
  }
}
