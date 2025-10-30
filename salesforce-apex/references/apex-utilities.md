# Apex Utility Methods

Common utility methods for Salesforce development.

## String Utilities

```apex
public class StringUtils {
    
    public static Boolean isBlankOrNull(String value) {
        return value == null || String.isBlank(value);
    }
    
    public static String truncate(String value, Integer maxLength) {
        if (isBlankOrNull(value) || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }
    
    public static String joinList(List<String> values, String separator) {
        if (values == null || values.isEmpty()) {
            return '';
        }
        return String.join(values, separator);
    }
}
```

## Collection Utilities

```apex
public class CollectionUtils {
    
    public static Set<Id> getIdSet(List<SObject> records) {
        Set<Id> ids = new Set<Id>();
        for (SObject record : records) {
            if (record.Id != null) {
                ids.add(record.Id);
            }
        }
        return ids;
    }
    
    public static Map<Id, SObject> getMapById(List<SObject> records) {
        Map<Id, SObject> recordMap = new Map<Id, SObject>();
        for (SObject record : records) {
            if (record.Id != null) {
                recordMap.put(record.Id, record);
            }
        }
        return recordMap;
    }
    
    public static List<List<SObject>> partition(List<SObject> records, Integer batchSize) {
        List<List<SObject>> batches = new List<List<SObject>>();
        
        for (Integer i = 0; i < records.size(); i += batchSize) {
            Integer endIndex = Math.min(i + batchSize, records.size());
            batches.add(records.subList(i, endIndex));
        }
        
        return batches;
    }
}
```

## Date Utilities

```apex
public class DateUtils {
    
    public static Date getFirstDayOfMonth(Date inputDate) {
        return Date.newInstance(inputDate.year(), inputDate.month(), 1);
    }
    
    public static Date getLastDayOfMonth(Date inputDate) {
        Date firstDay = getFirstDayOfMonth(inputDate);
        Date nextMonth = firstDay.addMonths(1);
        return nextMonth.addDays(-1);
    }
    
    public static Integer getBusinessDays(Date startDate, Date endDate) {
        Integer businessDays = 0;
        Date currentDate = startDate;
        
        while (currentDate <= endDate) {
            String dayOfWeek = Datetime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0))
                .format('EEEE');
            
            if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                businessDays++;
            }
            
            currentDate = currentDate.addDays(1);
        }
        
        return businessDays;
    }
}
```

## Error Logger

```apex
public class ErrorLogger {
    
    public static void log(String className, String methodName, Exception e) {
        Error_Log__c errorLog = new Error_Log__c(
            Class_Name__c = className,
            Method_Name__c = methodName,
            Error_Message__c = e.getMessage(),
            Stack_Trace__c = e.getStackTraceString(),
            Error_Type__c = e.getTypeName(),
            Timestamp__c = System.now()
        );
        
        try {
            insert errorLog;
        } catch (Exception logException) {
            // Fail silently or use Platform Events for logging
            System.debug('Failed to log error: ' + logException.getMessage());
        }
    }
    
    public static void logBulk(List<Database.SaveResult> saveResults, List<SObject> records) {
        List<Error_Log__c> errorLogs = new List<Error_Log__c>();
        
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                String errors = '';
                for (Database.Error err : saveResults[i].getErrors()) {
                    errors += err.getMessage() + '\n';
                }
                
                errorLogs.add(new Error_Log__c(
                    Record_Id__c = records[i].Id,
                    Error_Message__c = errors,
                    Timestamp__c = System.now()
                ));
            }
        }
        
        if (!errorLogs.isEmpty()) {
            insert errorLogs;
        }
    }
}
```

## Custom Exception

```apex
public class CustomException extends Exception {
    private String errorCode;
    
    public CustomException(String message, String errorCode) {
        this(message);
        this.errorCode = errorCode;
    }
    
    public String getErrorCode() {
        return this.errorCode;
    }
}
```

## Test Data Factory

```apex
@isTest
public class TestDataFactory {
    
    public static Account createAccount(String name, Boolean doInsert) {
        Account acc = new Account(
            Name = name,
            Type = 'Customer',
            Industry = 'Technology'
        );
        
        if (doInsert) {
            insert acc;
        }
        
        return acc;
    }
    
    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 0; i < count; i++) {
            accounts.add(createAccount('Test Account ' + i, false));
        }
        
        if (doInsert) {
            insert accounts;
        }
        
        return accounts;
    }
    
    public static Contact createContact(Id accountId, Boolean doInsert) {
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = accountId,
            Email = 'test@example.com'
        );
        
        if (doInsert) {
            insert con;
        }
        
        return con;
    }
}
```

## Security Utils

```apex
public class SecurityUtils {
    
    public static Boolean checkObjectAccess(Schema.SObjectType objectType, System.AccessType accessType) {
        switch on accessType {
            when CREATABLE {
                return objectType.getDescribe().isCreateable();
            }
            when READABLE {
                return objectType.getDescribe().isAccessible();
            }
            when UPDATABLE {
                return objectType.getDescribe().isUpdateable();
            }
            when DELETABLE {
                return objectType.getDescribe().isDeletable();
            }
            when else {
                return false;
            }
        }
    }
    
    public static Boolean checkFieldAccess(Schema.SObjectField field, System.AccessType accessType) {
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        
        switch on accessType {
            when CREATABLE {
                return fieldDescribe.isCreateable();
            }
            when READABLE {
                return fieldDescribe.isAccessible();
            }
            when UPDATABLE {
                return fieldDescribe.isUpdateable();
            }
            when else {
                return false;
            }
        }
    }
    
    public static void stripInaccessibleFields(List<SObject> records, System.AccessType accessType) {
        if (records == null || records.isEmpty()) {
            return;
        }
        
        SObjectAccessDecision decision = Security.stripInaccessible(accessType, records);
        records.clear();
        records.addAll(decision.getRecords());
    }
}
```
