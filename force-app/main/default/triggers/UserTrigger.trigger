trigger UserTrigger on User(after update) {
  List<Field_Tracking_Configuration__mdt> mdtConfig = [
    SELECT Object_Name__c, Field_Name__c
    FROM Field_Tracking_Configuration__mdt
    WHERE Object_Name__c = 'User'
  ];
  List<Field_Change_History__c> changeHistory = new List<Field_Change_History__c>();
  Set<String> trackedFields = new Set<String>();
  for (Field_Tracking_Configuration__mdt config : mdtConfig) {
    trackedFields.add(config.Field_Name__c);
  }
  for (User us : Trigger.new) {
    User oldUser = Trigger.oldMap.get(us.Id);
    for (String fieldName : trackedFields) {
      Object oldValue = oldUser.get(fieldName);
      Object newValue = us.get(fieldName);
      if (oldValue != newValue) {
        Field_Change_History__c changes = new Field_Change_History__c(
          Object_Name__c = 'User',
          Old_Value__c = String.valueOf(oldValue),
          New_Value__c = String.valueOf(newValue),
          User_ID__c = UserInfo.getUserId(),
          Change_Date__c = System.now(),
          Field_Name__c = fieldName,
          Name = us.Id
        );
        changeHistory.add(changes);
      }
    }
  }
  if (!changeHistory.isEmpty()) {
    insert changeHistory;
  }
}
