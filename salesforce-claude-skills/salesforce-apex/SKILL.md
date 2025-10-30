---
name: salesforce-apex
description: Apex code development including triggers, classes, batch jobs, scheduled jobs, queueable jobs, and test classes. Use when writing, reviewing, debugging Apex code, implementing business logic, handling governor limits, or creating unit tests with proper coverage.
---

# Salesforce Apex Development

This skill provides guidance for professional Apex development following Salesforce best practices.

## Development Workflow

When writing Apex code, follow this sequence:

1. **Understand requirements** - Clarify business logic and data model
2. **Design solution** - Consider governor limits, bulkification, and architecture
3. **Implement code** - Follow patterns below
4. **Write tests** - Achieve 100% coverage with meaningful assertions
5. **Review & refine** - Check against best practices checklist

## Core Principles

### Bulkification
ALWAYS write bulk-safe code. Every trigger, class, and method must handle collections.

**Bad:**
```apex
trigger AccountTrigger on Account (before insert) {
    for (Account acc : Trigger.new) {
        // WRONG: SOQL in loop
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
    }
}
```

**Good:**
```apex
trigger AccountTrigger on Account (before insert) {
    Set<Id> accountIds = new Set<Id>();
    for (Account acc : Trigger.new) {
        accountIds.add(acc.Id);
    }
    // CORRECT: SOQL outside loop
    Map<Id, Contact> contactsByAccountId = new Map<Id, Contact>(
        [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds]
    );
}
```

### Governor Limits
Keep these limits in mind:
- 100 SOQL queries per transaction
- 50,000 records retrieved via SOQL
- 150 DML statements per transaction
- 10,000 records processed via DML
- 6 MB heap size (synchronous), 12 MB (asynchronous)
- 10 seconds CPU time (synchronous), 60 seconds (asynchronous)

**Solution patterns:**
- Use collections and bulk operations
- Aggregate SOQL with WHERE IN clauses
- Consider asynchronous patterns for large operations (Batch, Queueable)
- Use Platform Events for decoupling

### Trigger Framework
ALWAYS use a trigger handler pattern. Never put logic directly in triggers.

**Trigger structure:**
```apex
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    handler.run();
}
```

**Handler structure:**
```apex
public class AccountTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        for (Account acc : (List<Account>) Trigger.new) {
            // Before insert logic
        }
    }
    
    public override void afterUpdate() {
        // After update logic
        processAccountUpdates((Map<Id, Account>) Trigger.oldMap, (List<Account>) Trigger.new);
    }
    
    private void processAccountUpdates(Map<Id, Account> oldMap, List<Account> newList) {
        // Separate business logic into private methods
    }
}
```

For TriggerHandler base class, see `references/trigger-handler-base.md`.

## Code Patterns

### Service Layer Pattern
Separate business logic from triggers into service classes:

```apex
public class AccountService {
    
    public static void updateRelatedContacts(List<Account> accounts) {
        // Bulkified business logic
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        
        List<Contact> contactsToUpdate = [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE AccountId IN :accountIds
        ];
        
        // Process contacts
        update contactsToUpdate;
    }
}
```

### Selector Pattern
Encapsulate SOQL queries in selector classes:

```apex
public class AccountSelector {
    
    public static List<Account> getAccountsWithContacts(Set<Id> accountIds) {
        return [
            SELECT Id, Name, 
                   (SELECT Id, FirstName, LastName FROM Contacts)
            FROM Account
            WHERE Id IN :accountIds
        ];
    }
    
    public static List<Account> getActiveAccountsByType(String type) {
        return [
            SELECT Id, Name, Type
            FROM Account
            WHERE Type = :type
            AND Active__c = true
        ];
    }
}
```

### Test Class Pattern
Write comprehensive test classes with proper setup and assertions:

```apex
@isTest
private class AccountServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data once for all test methods
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                Type = 'Customer'
            ));
        }
        insert accounts;
    }
    
    @isTest
    static void testBulkUpdate() {
        // Arrange
        List<Account> accounts = [SELECT Id, Name FROM Account];
        
        // Act
        Test.startTest();
        AccountService.updateRelatedContacts(accounts);
        Test.stopTest();
        
        // Assert
        List<Contact> updatedContacts = [SELECT Id FROM Contact WHERE AccountId IN :accounts];
        System.assertEquals(200, updatedContacts.size(), 'Should process all contacts');
    }
    
    @isTest
    static void testNegativeScenario() {
        // Test error handling
        try {
            AccountService.updateRelatedContacts(null);
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assert(true, 'Expected exception caught');
        }
    }
}
```

## Asynchronous Patterns

### Batch Apex
For processing large data volumes (millions of records):

```apex
public class AccountUpdateBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name FROM Account WHERE Active__c = true
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // Process batch of records (default 200)
        for (Account acc : scope) {
            acc.LastProcessedDate__c = System.now();
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        // Send completion notification
    }
}

// Execute: Database.executeBatch(new AccountUpdateBatch(), 200);
```

### Queueable Apex
For complex logic with chaining capability:

```apex
public class AccountQueueable implements Queueable {
    private List<Account> accounts;
    
    public AccountQueueable(List<Account> accounts) {
        this.accounts = accounts;
    }
    
    public void execute(QueueableContext context) {
        // Process accounts
        update accounts;
        
        // Chain another job if needed
        if (needsMoreProcessing()) {
            System.enqueueJob(new ContactQueueable());
        }
    }
}

// Execute: System.enqueueJob(new AccountQueueable(accountList));
```

### Future Methods
For simple asynchronous callouts:

```apex
public class ExternalSystemCallout {
    
    @future(callout=true)
    public static void sendAccountData(Set<Id> accountIds) {
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN :accountIds];
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/accounts');
        req.setMethod('POST');
        req.setBody(JSON.serialize(accounts));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
    }
}
```

## Error Handling

### Try-Catch Blocks
Implement proper error handling:

```apex
public class AccountProcessor {
    
    public static void processAccounts(List<Account> accounts) {
        Savepoint sp = Database.setSavepoint();
        
        try {
            // Business logic
            update accounts;
            
        } catch (DmlException e) {
            Database.rollback(sp);
            
            // Log error
            ErrorLogger.log('AccountProcessor', 'processAccounts', e);
            
            // Handle specific errors
            for (Integer i = 0; i < e.getNumDml(); i++) {
                System.debug('Error on record: ' + e.getDmlId(i));
                System.debug('Error message: ' + e.getDmlMessage(i));
            }
            
            throw new AccountProcessorException('Failed to process accounts', e);
            
        } catch (Exception e) {
            Database.rollback(sp);
            ErrorLogger.log('AccountProcessor', 'processAccounts', e);
            throw e;
        }
    }
}
```

## Best Practices Checklist

Before finalizing code, verify:

- [ ] All code is bulkified (no SOQL/DML in loops)
- [ ] Governor limits considered and handled
- [ ] Error handling implemented with try-catch
- [ ] Test class written with 100% coverage
- [ ] Meaningful assertions in tests (not just coverage)
- [ ] Test data setup uses @TestSetup
- [ ] Bulk testing (200+ records) included
- [ ] Negative scenarios tested
- [ ] Security reviewed (CRUD/FLS, sharing rules)
- [ ] Code follows naming conventions
- [ ] Comments added for complex logic
- [ ] No hardcoded IDs or values

## Security Considerations

### CRUD/FLS Checks
```apex
// Check object permissions
if (!Schema.sObjectType.Account.isAccessible()) {
    throw new SecurityException('Insufficient permissions');
}

// Check field permissions
if (!Schema.sObjectType.Account.fields.Name.isAccessible()) {
    throw new SecurityException('Insufficient field permissions');
}

// Use WITH SECURITY_ENFORCED in SOQL (API 46.0+)
List<Account> accounts = [
    SELECT Id, Name 
    FROM Account 
    WITH SECURITY_ENFORCED
];
```

### Sharing Rules
```apex
// Respect sharing (default)
public class AccountController {
    // Sharing rules enforced
}

// Bypass sharing only when necessary
public without sharing class AccountDataLoader {
    // Use sparingly and document why
}

// Inherit sharing from caller
public inherited sharing class AccountHelper {
    // Flexible based on context
}
```

## Utilities

For running tests and checking coverage, see `scripts/run-tests.sh`.
For common utility methods, see `references/apex-utilities.md`.

## Naming Conventions

Follow Salesforce standard conventions:
- **Classes**: PascalCase (e.g., `AccountTriggerHandler`)
- **Methods**: camelCase (e.g., `processAccounts`)
- **Variables**: camelCase (e.g., `accountList`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RECORDS`)
- **Test classes**: ClassNameTest (e.g., `AccountServiceTest`)

## Additional Resources

- For trigger handler base class implementation: `references/trigger-handler-base.md`
- For common utility methods: `references/apex-utilities.md`
- For org-specific patterns: Add your patterns to `references/org-patterns.md`
