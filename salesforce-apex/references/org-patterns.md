# Org-Specific Patterns

This file should be customized with your organization's specific Salesforce development patterns and standards.

## Naming Conventions

### Classes
- Trigger handlers: `[Object]TriggerHandler` (e.g., `AccountTriggerHandler`)
- Service classes: `[Object]Service` (e.g., `AccountService`)
- Selector classes: `[Object]Selector` (e.g., `AccountSelector`)
- Test classes: `[ClassName]Test` (e.g., `AccountServiceTest`)
- Batch classes: `[Purpose]Batch` (e.g., `AccountUpdateBatch`)

### Custom Objects
- Custom objects: `[Name]__c` (e.g., `Custom_Setting__c`)
- Junction objects: `[Object1]_[Object2]__c` (e.g., `Account_Contact__c`)

### Custom Fields
- Custom fields: `[Name]__c` (e.g., `Custom_Field__c`)
- Boolean fields: `Is_[State]__c` or `Has_[Attribute]__c`
- Date fields: `[Event]_Date__c` (e.g., `Last_Contact_Date__c`)

## Architecture Patterns

### Data Model
Add documentation of your org's key objects and relationships:

```
Account
├── Contacts (standard relationship)
├── Opportunities (standard relationship)
└── Custom_Object__c (custom relationship)
    └── Related_Object__c
```

### Integration Architecture
Document your integration patterns:

- **External System 1**: REST API via Named Credential
- **External System 2**: Middleware via Platform Events
- **Data Warehouse**: Batch nightly sync

## Custom Metadata Types

Document custom metadata used for configuration:

- `API_Configuration__mdt`: External API endpoints and credentials
- `Business_Rule__mdt`: Configurable business rules
- `Error_Notification__mdt`: Error notification recipients

## Logging & Error Handling

### Error Logging
Use the `ErrorLogger` utility for all error logging:

```apex
try {
    // business logic
} catch (Exception e) {
    ErrorLogger.log('ClassName', 'methodName', e);
    throw new AuraHandledException('User-friendly message');
}
```

### Platform Events
Document if you use Platform Events for error handling:

- `Error_Event__e`: Real-time error notifications
- `Integration_Log__e`: External system call logging

## Testing Standards

### Test Data
- Use `@TestSetup` for efficient test data creation
- Test data factory class: `TestDataFactory`
- Minimum bulk test size: 200 records

### Coverage Requirements
- Minimum class coverage: 90%
- Minimum org coverage: 75%
- All test methods must have meaningful assertions

### Test Naming
- Test methods: `test[MethodName][Scenario]`
- Example: `testProcessAccountsWithBulkData()`
- Example: `testValidationRuleWithInvalidData()`

## Security Patterns

### Sharing Rules
- Default: `with sharing` for all classes
- Exceptions documented in class comments
- `without sharing` only when necessary and approved

### CRUD/FLS
- Always check permissions before DML
- Use `WITH SECURITY_ENFORCED` in SOQL
- Use `Security.stripInaccessible()` when needed

## Deployment Process

### Environments
1. Developer Sandboxes (individual development)
2. Integration Sandbox (integration testing)
3. UAT Sandbox (user acceptance testing)
4. Production (live environment)

### Deployment Method
- Change Sets for small changes
- SFDX for large changes or full deployments
- Continuous Integration: [Tool name if applicable]

## Code Review Requirements

All code must pass review before deployment:
- [ ] Peer review completed
- [ ] Security review passed
- [ ] Test coverage ≥ 90%
- [ ] QA validation completed
- [ ] Documentation updated

## Common Utilities

Document commonly used utility classes:

- `StringUtils`: String manipulation helpers
- `CollectionUtils`: Collection operations
- `DateUtils`: Date calculations
- `ErrorLogger`: Error logging framework
- `TestDataFactory`: Test data creation

## Governor Limit Strategies

Document how your org handles governor limits:

### Batch Processing
- Default batch size: 200
- Used for processing > 10,000 records
- Scheduled via custom UI or CRON

### Queueable Chains
- Max chain depth: 3 levels
- Used for complex async operations
- Monitor via System Jobs

### Platform Events
- Used for decoupling triggers
- Async processing of non-critical logic
- Error handling via separate subscriber

## Prohibited Patterns

Document patterns NOT to use in your org:

- ❌ Process Builder (migrating to Flows)
- ❌ Workflow Rules (migrating to Flows)
- ❌ Direct SOQL in triggers (use selector pattern)
- ❌ Hardcoded IDs anywhere
- ❌ `@future` methods (prefer Queueable)

## Additional Notes

Add any other org-specific information:
- Release schedule
- Hotfix procedures
- Emergency contacts
- Documentation links
