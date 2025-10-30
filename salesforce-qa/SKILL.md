---
name: salesforce-qa
description: Quality assurance and code review for Salesforce development. Use when reviewing Apex code, Lightning Web Components, flows, validating against best practices, checking for security issues, governor limit concerns, test coverage, or ensuring code quality standards.
---

# Salesforce Quality Assurance

This skill provides comprehensive QA and code review guidance for Salesforce development.

## QA Workflow

When reviewing Salesforce code, follow this systematic approach:

1. **Initial Assessment** - Understand code purpose and scope
2. **Standards Check** - Verify naming conventions and formatting
3. **Functionality Review** - Validate business logic correctness
4. **Performance Analysis** - Check bulkification and governor limits
5. **Security Review** - Verify CRUD/FLS and sharing rules
6. **Test Coverage** - Validate test quality and coverage
7. **Documentation Check** - Ensure adequate comments
8. **Generate Report** - Provide actionable feedback

## Code Review Checklist

### 1. Bulkification & Governor Limits

**CRITICAL ISSUES (Must Fix):**
- [ ] No SOQL queries inside loops
- [ ] No DML statements inside loops
- [ ] No nested loops with SOQL/DML
- [ ] Queries use WHERE IN with collections, not individual WHERE clauses
- [ ] Batch size considerations for large data volumes

**Example violations:**
```apex
// CRITICAL: SOQL in loop
for (Account acc : accountList) {
    List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id]; // WRONG
}

// CRITICAL: DML in loop
for (Account acc : accountList) {
    update acc; // WRONG
}
```

**Correct pattern:**
```apex
// Collect IDs first
Set<Id> accountIds = new Set<Id>();
for (Account acc : accountList) {
    accountIds.add(acc.Id);
}

// Single SOQL query
Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds]) {
    if (!contactsByAccount.containsKey(con.AccountId)) {
        contactsByAccount.put(con.AccountId, new List<Contact>());
    }
    contactsByAccount.get(con.AccountId).add(con);
}

// Process all accounts
List<Account> toUpdate = new List<Account>();
for (Account acc : accountList) {
    // Use the map
    List<Contact> relatedContacts = contactsByAccount.get(acc.Id);
    if (relatedContacts != null && relatedContacts.size() > 0) {
        toUpdate.add(acc);
    }
}

// Single DML
if (!toUpdate.isEmpty()) {
    update toUpdate;
}
```

### 2. Security Review

**Check these security aspects:**
- [ ] CRUD permissions checked (isAccessible, isCreateable, isUpdateable, isDeletable)
- [ ] FLS (Field-Level Security) verified for sensitive fields
- [ ] Sharing rules appropriate (with sharing, without sharing, inherited sharing)
- [ ] No hardcoded credentials or sensitive data
- [ ] User input sanitized for SOQL injection
- [ ] External callouts use named credentials

**Security patterns:**
```apex
// GOOD: Check object access
if (!Schema.sObjectType.Account.isAccessible()) {
    throw new AuraHandledException('Insufficient permissions to read Account');
}

// GOOD: Use WITH SECURITY_ENFORCED
List<Account> accounts = [
    SELECT Id, Name 
    FROM Account 
    WITH SECURITY_ENFORCED
];

// GOOD: Strip inaccessible fields
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.READABLE,
    accountList
);

// BAD: Potential SOQL injection
String accountName = UserInput; // Could be: "Test' OR '1'='1"
String query = 'SELECT Id FROM Account WHERE Name = \'' + accountName + '\''; // WRONG
List<Account> accounts = Database.query(query);

// GOOD: Use bind variables
List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
```

### 3. Error Handling

**Required error handling:**
- [ ] Try-catch blocks for DML operations
- [ ] Specific exception types caught when possible
- [ ] Errors logged to custom object or Platform Events
- [ ] User-friendly error messages
- [ ] Rollback strategy using savepoints
- [ ] Partial success scenarios handled (Database.insert(records, false))

**Error handling pattern:**
```apex
// GOOD: Comprehensive error handling
Savepoint sp = Database.setSavepoint();
try {
    update accounts;
} catch (DmlException e) {
    Database.rollback(sp);
    
    // Log specific DML errors
    for (Integer i = 0; i < e.getNumDml(); i++) {
        ErrorLogger.log(
            'AccountProcessor',
            'updateAccounts',
            'Record: ' + e.getDmlId(i) + ', Error: ' + e.getDmlMessage(i)
        );
    }
    
    throw new AuraHandledException('Failed to update accounts. Please contact administrator.');
    
} catch (Exception e) {
    Database.rollback(sp);
    ErrorLogger.log('AccountProcessor', 'updateAccounts', e);
    throw new AuraHandledException('An unexpected error occurred.');
}
```

### 4. Test Coverage & Quality

**Test class requirements:**
- [ ] Test class exists for every Apex class
- [ ] Minimum 90% code coverage (target 100%)
- [ ] Bulk testing with 200+ records
- [ ] Positive test scenarios covered
- [ ] Negative test scenarios covered
- [ ] @TestSetup used for efficient data creation
- [ ] Test.startTest() and Test.stopTest() properly used
- [ ] Meaningful assertions (not just coverage)
- [ ] System.assertEquals with failure messages
- [ ] Test data doesn't rely on existing org data

**Test quality assessment:**
```apex
// BAD: Just coverage, no assertions
@isTest
static void testMethod1() {
    Account acc = new Account(Name = 'Test');
    insert acc;
    AccountService.processAccount(acc.Id);
    // No assertions! Just getting coverage
}

// GOOD: Meaningful test with assertions
@isTest
static void testAccountProcessing() {
    // Arrange
    Account acc = new Account(Name = 'Test', Status__c = 'New');
    insert acc;
    
    // Act
    Test.startTest();
    AccountService.processAccount(acc.Id);
    Test.stopTest();
    
    // Assert
    Account result = [SELECT Id, Status__c FROM Account WHERE Id = :acc.Id];
    System.assertEquals('Processed', result.Status__c, 'Account status should be updated to Processed');
}

// GOOD: Bulk testing
@isTest
static void testBulkProcessing() {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < 200; i++) {
        accounts.add(new Account(Name = 'Test ' + i));
    }
    insert accounts;
    
    Test.startTest();
    AccountService.processAccounts(accounts);
    Test.stopTest();
    
    List<Account> results = [SELECT Id, Status__c FROM Account WHERE Id IN :accounts];
    System.assertEquals(200, results.size(), 'All 200 accounts should be processed');
}
```

### 5. Code Organization & Patterns

**Architecture review:**
- [ ] Trigger handler pattern used (no logic in triggers)
- [ ] Service layer pattern for business logic
- [ ] Selector pattern for SOQL queries
- [ ] Single Responsibility Principle followed
- [ ] Methods under 50 lines (ideally under 30)
- [ ] Classes focused on single purpose
- [ ] Utility classes for reusable logic

**Anti-patterns to flag:**
```apex
// BAD: Logic in trigger
trigger AccountTrigger on Account (before insert) {
    for (Account acc : Trigger.new) {
        // Complex logic directly in trigger - WRONG
        if (acc.Type == 'Customer') {
            acc.Status__c = 'Active';
        }
    }
}

// GOOD: Trigger handler pattern
trigger AccountTrigger on Account (before insert) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    handler.run();
}

// BAD: God class (does everything)
public class AccountManager {
    public void createAccount() { }
    public void updateAccount() { }
    public void deleteAccount() { }
    public void sendEmail() { }
    public void callExternalAPI() { }
    public void generateReport() { }
    // Too many responsibilities - WRONG
}

// GOOD: Separation of concerns
public class AccountService { } // Business logic
public class AccountSelector { } // SOQL queries
public class AccountEmailService { } // Email functionality
public class AccountIntegrationService { } // External calls
```

### 6. Performance & Optimization

**Check for performance issues:**
- [ ] Queries use selective filters (indexed fields)
- [ ] Query results limited appropriately
- [ ] Unnecessary queries eliminated
- [ ] Map-based lookups instead of nested loops
- [ ] Appropriate use of asynchronous patterns
- [ ] Large data processing uses Batch Apex
- [ ] Recursive trigger prevention implemented

**Performance patterns:**
```apex
// BAD: Nested loops (O(n²))
for (Account acc : accountList) {
    for (Contact con : contactList) {
        if (con.AccountId == acc.Id) {
            // Process - INEFFICIENT
        }
    }
}

// GOOD: Map-based lookup (O(n))
Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
for (Contact con : contactList) {
    if (!contactsByAccount.containsKey(con.AccountId)) {
        contactsByAccount.put(con.AccountId, new List<Contact>());
    }
    contactsByAccount.get(con.AccountId).add(con);
}

for (Account acc : accountList) {
    List<Contact> relatedContacts = contactsByAccount.get(acc.Id);
    // Process efficiently
}
```

### 7. Naming Conventions

**Verify naming standards:**
- [ ] Classes: PascalCase (AccountTriggerHandler)
- [ ] Methods: camelCase (processAccounts)
- [ ] Variables: camelCase (accountList)
- [ ] Constants: UPPER_SNAKE_CASE (MAX_RECORDS)
- [ ] Descriptive names (not x, temp, data)
- [ ] Boolean methods start with is/has/should
- [ ] Collection names pluralized

### 8. Documentation

**Required documentation:**
- [ ] Class-level comments explaining purpose
- [ ] Method-level comments for public methods
- [ ] Complex logic has inline comments
- [ ] Parameter descriptions provided
- [ ] Return value documented
- [ ] Exceptions documented

## Review Report Format

When providing QA feedback, structure the report as follows:

```markdown
## QA Review Summary

**Status:** [APPROVED / APPROVED WITH CHANGES / REJECTED]
**Overall Score:** [X/10]
**Review Date:** [Date]

### Critical Issues (Must Fix) 🔴
1. [Issue description with file/line reference]
   - **Impact:** [Explain the risk]
   - **Fix:** [Suggested solution]

### Major Issues (Should Fix) 🟡
1. [Issue description]
   - **Recommendation:** [How to improve]

### Minor Issues (Nice to Have) 🟢
1. [Issue description]
   - **Suggestion:** [Optional improvement]

### Positive Observations ✅
- [What was done well]

### Code Coverage
- **Overall Coverage:** [X%]
- **Classes Below 75%:** [List if any]

### Performance Considerations
- [Any performance concerns or optimizations]

### Security Review
- [Security assessment]

### Next Steps
1. [Action items prioritized]
```

## Lightning Web Component (LWC) Review

When reviewing LWC code, check:

**JavaScript:**
- [ ] No DOM manipulation outside render()
- [ ] @api, @track, @wire used correctly
- [ ] Proper lifecycle hooks usage
- [ ] Error handling in async operations
- [ ] Apex calls use imperative or wire service appropriately
- [ ] No business logic in components (should be in Apex)

**HTML:**
- [ ] Accessibility attributes (aria-label, role)
- [ ] Conditional rendering uses if:true/if:false
- [ ] Iterators use key attribute
- [ ] Lightning Design System (SLDS) classes used

**Security:**
- [ ] User input sanitized
- [ ] No eval() or innerHTML usage
- [ ] CRUD/FLS enforced in Apex controllers

## Flow Review

When reviewing Flows, verify:
- [ ] Bulk-safe (handles collections)
- [ ] Uses Get Records efficiently (not in loops)
- [ ] Error handling configured
- [ ] Debug mode tested
- [ ] No hardcoded IDs
- [ ] Interview limits considered (2000 elements)

## Salesforce Vibe Integration

When code is developed with Salesforce Vibe assistance:
- [ ] Verify all Salesforce best practices still apply
- [ ] Check for any auto-generated code that needs optimization
- [ ] Ensure governor limits are respected
- [ ] Validate test coverage meets standards
- [ ] Confirm security practices are followed

## Additional Considerations

### Platform Events
- Asynchronous processing checked
- Retry logic implemented
- Error handling configured

### Custom Metadata
- Used for configuration (not hardcoded values)
- Proper deployment strategy

### Change Sets / Deployment
- All dependencies included
- Test classes deployed
- No hardcoded org-specific values

## Final Approval Criteria

Code must meet ALL of these to be approved:
1. ✅ No critical issues (SOQL/DML in loops, security)
2. ✅ Test coverage ≥ 90%
3. ✅ All tests pass with meaningful assertions
4. ✅ Security review passed
5. ✅ Error handling implemented
6. ✅ Documentation adequate
7. ✅ Code follows org standards
