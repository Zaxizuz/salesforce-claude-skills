# Trigger Handler Base Class

This base class provides a framework for trigger handlers to follow a consistent pattern.

## Implementation

```apex
public virtual class TriggerHandler {
    
    // Bypass mechanisms
    private static Set<String> bypassedHandlers = new Set<String>();
    
    // Context tracking
    @TestVisible
    private Boolean isTriggerExecuting;
    
    @TestVisible
    private Integer triggerSize;
    
    public TriggerHandler() {
        this.isTriggerExecuting = Trigger.isExecuting;
        this.triggerSize = Trigger.size;
    }
    
    // Main entry point
    public void run() {
        
        if (!validateRun()) {
            return;
        }
        
        // Before triggers
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                beforeInsert();
            } else if (Trigger.isUpdate) {
                beforeUpdate();
            } else if (Trigger.isDelete) {
                beforeDelete();
            }
        }
        
        // After triggers
        if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                afterInsert();
            } else if (Trigger.isUpdate) {
                afterUpdate();
            } else if (Trigger.isDelete) {
                afterDelete();
            } else if (Trigger.isUndelete) {
                afterUndelete();
            }
        }
    }
    
    // Context methods - override in subclasses
    @TestVisible
    protected virtual void beforeInsert() {}
    
    @TestVisible
    protected virtual void beforeUpdate() {}
    
    @TestVisible
    protected virtual void beforeDelete() {}
    
    @TestVisible
    protected virtual void afterInsert() {}
    
    @TestVisible
    protected virtual void afterUpdate() {}
    
    @TestVisible
    protected virtual void afterDelete() {}
    
    @TestVisible
    protected virtual void afterUndelete() {}
    
    // Validation
    @TestVisible
    private Boolean validateRun() {
        if (!this.isTriggerExecuting) {
            throw new TriggerHandlerException('Trigger handler called outside of trigger execution');
        }
        
        if (isBypassed()) {
            return false;
        }
        
        return true;
    }
    
    // Bypass mechanism
    public static void bypass(String handlerName) {
        bypassedHandlers.add(handlerName.toLowerCase());
    }
    
    public static void clearBypass(String handlerName) {
        bypassedHandlers.remove(handlerName.toLowerCase());
    }
    
    public static void clearAllBypasses() {
        bypassedHandlers.clear();
    }
    
    @TestVisible
    private Boolean isBypassed() {
        return bypassedHandlers.contains(getHandlerName().toLowerCase());
    }
    
    @TestVisible
    private String getHandlerName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }
    
    // Exception class
    public class TriggerHandlerException extends Exception {}
}
```

## Usage Example

```apex
public class AccountTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        for (Account acc : (List<Account>) Trigger.new) {
            if (String.isBlank(acc.Name)) {
                acc.addError('Account name is required');
            }
        }
    }
    
    public override void afterUpdate() {
        Set<Id> accountIds = new Set<Id>();
        
        for (Account acc : (List<Account>) Trigger.new) {
            Account oldAcc = (Account) Trigger.oldMap.get(acc.Id);
            
            if (acc.Name != oldAcc.Name) {
                accountIds.add(acc.Id);
            }
        }
        
        if (!accountIds.isEmpty()) {
            AccountService.updateRelatedContacts(accountIds);
        }
    }
}
```

## Test Example with Bypass

```apex
@isTest
private class AccountTriggerHandlerTest {
    
    @isTest
    static void testBypassMechanism() {
        // Bypass the handler
        TriggerHandler.bypass('AccountTriggerHandler');
        
        Account acc = new Account(Name = ''); // Would normally fail validation
        insert acc; // Succeeds because handler is bypassed
        
        // Clear bypass
        TriggerHandler.clearBypass('AccountTriggerHandler');
        
        try {
            Account acc2 = new Account(Name = '');
            insert acc2; // Now fails validation
            System.assert(false, 'Should have failed');
        } catch (DmlException e) {
            System.assert(true);
        }
    }
}
```

## Benefits

1. **Consistency** - All triggers follow the same pattern
2. **Bypass mechanism** - Can disable triggers for data loads or testing
3. **Clear context** - Each trigger context has its own method
4. **Testability** - Easy to test individual contexts
5. **Error prevention** - Validates execution context
