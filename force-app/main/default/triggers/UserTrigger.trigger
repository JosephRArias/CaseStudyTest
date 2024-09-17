trigger UserTrigger on User(after update) {
  List<Field_Change_History__c> changeHistory = new List<Field_Change_History__c>();

  for (User us : Trigger.new) {
    User oldUser = Trigger.oldMap.get(us.Id);
    if (us.CompanyName != oldUser.CompanyName) {
      Field_Change_History__c changes = new Field_Change_History__c(
        Object_Name__c = 'User',
        Old_Value__c = oldUser.CompanyName,
        New_Value__c = us.CompanyName,
        User_ID__c = UserInfo.getUserId(),
        Change_Date__c = System.now(),
        Field_Name__c = 'CompanyName',
        Name = us.Id
      );
      changeHistory.add(changes);
    }
    if (us.Department != oldUser.Department) {
      Field_Change_History__c changes = new Field_Change_History__c(
        Object_Name__c = 'User',
        Old_Value__c = oldUser.Department,
        New_Value__c = us.Department,
        User_ID__c = UserInfo.getUserId(),
        Change_Date__c = System.now(),
        Name = us.Id,
        Field_Name__c = 'Department'
      );
      changeHistory.add(changes);
    }
    if (us.MobilePhone != oldUser.MobilePhone) {
      Field_Change_History__c changes = new Field_Change_History__c(
        Object_Name__c = 'User',
        Old_Value__c = oldUser.MobilePhone,
        New_Value__c = us.MobilePhone,
        User_ID__c = UserInfo.getUserId(),
        Change_Date__c = System.now(),
        Field_Name__c = 'MobilePhone',
        Name = us.Id
      );
      changeHistory.add(changes);
    }
  }
  if (!changeHistory.isEmpty()) {
    insert changeHistory;
  }
}
