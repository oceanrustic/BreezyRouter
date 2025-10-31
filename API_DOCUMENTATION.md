# BreezyRouter - API Documentation

Technical documentation for developers integrating BreezyRouter into their Salesforce org.

## Table of Contents
1. [Invocable Methods](#invocable-methods)
2. [Apex Controller Methods](#apex-controller-methods)
3. [Integration Examples](#integration-examples)
4. [Error Handling](#error-handling)

---

## Invocable Methods

### `BreezyRouter.getNextUserInBreezyRouter`

**Purpose**: Returns the next user ID from a router using round-robin logic.

**Class**: `BreezyRouter`

**Signature**:
```apex
@InvocableMethod(label='Get Next User in BreezyRouter')
public static List<Id> getNextUserInBreezyRouter(List<String> routerNames)
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `routerNames` | `List<String>` | Yes | List of router names to get next user from |

#### Returns

| Type | Description |
|------|-------------|
| `List<Id>` | List of User IDs (one per router name provided) |

#### Behavior

- Selects the member with the **oldest `Routed_Date__c`** (or NULL)
- Only considers members with **`Status__c = 'Active'`**
- Updates `Routed_Date__c` and `Routed_Time__c` automatically
- Returns `null` in the list if no active members found for a router

#### Example Usage

**In Flow:**
```
Action: Apex
Class: BreezyRouter
Method: getNextUserInBreezyRouter

Input:
- routerNames: ['Sales Team']

Output Variable:
- getNextUserInBreezyRouter.outputVariable (List<Id>)

Usage:
Lead.OwnerId = {!getNextUserInBreezyRouter.outputVariable[0]}
```

**In Apex:**
```apex
List<String> routerNames = new List<String>{'Sales Team'};
List<Id> userIds = BreezyRouter.getNextUserInBreezyRouter(routerNames);
if (!userIds.isEmpty() && userIds[0] != null) {
    Lead lead = new Lead(Id = '00XXXXXXXXXXXXXXX');
    lead.OwnerId = userIds[0];
    update lead;
}
```

#### Notes

- Router name must **match exactly** (case-sensitive)
- If router doesn't exist or has no active members, returns `null`
- Updates member record automatically (triggers dashboard updates)
- Thread-safe for concurrent calls

---

## Apex Controller Methods

All methods in `BreezyRouterController` are `@AuraEnabled` for LWC components. Some useful methods for external integration:

### `getRouters()`

Returns all routers with member counts.

```apex
@AuraEnabled(cacheable=true)
public static List<RouterWrapper> getRouters()
```

**Returns**: List of routers with metadata

### `getRouterDetails(String routerId)`

Returns router details including all members.

```apex
@AuraEnabled(cacheable=true)
public static RouterDetailWrapper getRouterDetails(String routerId)
```

**Parameters**:
- `routerId`: Router record ID

**Returns**: Router details with member list

### `getRouterMembers(String routerId)`

Returns all members of a router with status information.

```apex
@AuraEnabled(cacheable=true)
public static List<MemberWrapper> getRouterMembers(String routerId)
```

**Parameters**:
- `routerId`: Router record ID

**Returns**: List of members with status and routing info

---

## Integration Examples

### Example 1: Auto-Assign Leads

**Flow Configuration:**
```
Trigger: Lead Created
    ↓
Decision: Is Lead.Product__c = 'Enterprise'?
    Yes → Action: BreezyRouter.getNextUserInBreezyRouter
                Input: routerNames = ['Enterprise Sales Team']
    ↓
Assignment: Lead.OwnerId = {!getNextUserInBreezyRouter.outputVariable[0]}
    ↓
Update: Lead
```

### Example 2: Round-Robin Case Assignment

**Flow Configuration:**
```
Trigger: Case Created
    ↓
Decision: Case.Origin = 'Email'?
    Yes → Action: BreezyRouter.getNextUserInBreezyRouter
                Input: routerNames = ['Support Queue']
    ↓
Assignment: Case.OwnerId = {!getNextUserInBreezyRouter.outputVariable[0]}
    ↓
Update: Case
```

### Example 3: Multiple Routers (Priority-Based)

**Flow Configuration:**
```
Trigger: Case Created
    ↓
Decision: Case.Priority = 'High'?
    Yes → Action: BreezyRouter.getNextUserInBreezyRouter
                Input: routerNames = ['Premium Support', 'Standard Support']
    No → Action: BreezyRouter.getNextUserInBreezyRouter
                Input: routerNames = ['Standard Support']
    ↓
Assignment: Case.OwnerId = {!getNextUserInBreezyRouter.outputVariable[0]}
```

**Note**: If first router has no active members, second router's user is used.

### Example 4: Apex Integration

```apex
public class LeadRoutingService {
    
    public static void routeLeads(List<Lead> leads) {
        // Get next user from router
        List<String> routerNames = new List<String>{'Sales Team'};
        List<Id> userIds = BreezyRouter.getNextUserInBreezyRouter(routerNames);
        
        if (!userIds.isEmpty() && userIds[0] != null) {
            // Assign leads
            for (Lead lead : leads) {
                lead.OwnerId = userIds[0];
            }
            update leads;
        }
    }
    
    // Use in trigger
    trigger LeadRouting on Lead (after insert) {
        if (Trigger.isAfter && Trigger.isInsert) {
            LeadRoutingService.routeLeads(Trigger.new);
        }
    }
}
```

### Example 5: Process Builder Integration

1. **Create Process Builder**
   - Object: Lead
   - Criteria: Lead.Status = 'New'
   - Action: Invoke Flow

2. **Flow Calls Router**
   - Flow: "Route Lead to Sales"
   - Flow calls: `BreezyRouter.getNextUserInBreezyRouter`
   - Assigns: Lead.OwnerId

---

## Error Handling

### Common Errors

#### Router Not Found
**Error**: Returns `null` in list
**Cause**: Router name doesn't exist
**Solution**: Verify router name matches exactly (case-sensitive)

#### No Active Members
**Error**: Returns `null` in list
**Cause**: Router has no members with `Status__c = 'Active'`
**Solution**: Add active members or update member statuses

#### Invalid Input
**Error**: `AuraHandledException` or Flow error
**Cause**: Empty list or null router names
**Solution**: Provide valid router name(s) in list

### Handling Null Returns

**In Flow:**
```
Action: BreezyRouter.getNextUserInBreezyRouter
    ↓
Decision: Is getNextUserInBreezyRouter.outputVariable[0] null?
    Yes → Assignment: Use default user or queue
    No → Assignment: Use router user
```

**In Apex:**
```apex
List<Id> userIds = BreezyRouter.getNextUserInBreezyRouter(routerNames);
Id assignedUserId = null;

if (!userIds.isEmpty() && userIds[0] != null) {
    assignedUserId = userIds[0];
} else {
    // Fallback logic
    assignedUserId = UserInfo.getUserId(); // or default queue
}
```

---

## Best Practices

### ✅ Do's
- **Validate router exists** before calling method
- **Handle null returns** gracefully
- **Use descriptive router names** (match exactly)
- **Monitor routing activity** via dashboard
- **Test flows** before deploying to production

### ❌ Don'ts
- Don't hardcode router names (use custom metadata or variables)
- Don't ignore null returns
- Don't create duplicate router names
- Don't call method too frequently (respect governor limits)

### 💡 Tips
- **Create router naming convention** for your org
- **Document router names** in process documentation
- **Test with multiple active members** to verify round-robin
- **Monitor dashboard** for routing patterns
- **Use status management** to control routing availability

---

## Technical Details

### Round-Robin Algorithm
1. Query members with `Status__c = 'Active'` and matching router
2. Order by `Routed_Date__c ASC, Routed_Time__c ASC`
3. Select first member (oldest routing date)
4. Update `Routed_Date__c` to `NOW()` and `Routed_Time__c` to current time
5. Return member's `UserId__c`

### Governor Limits
- **SOQL Queries**: 1 query per router
- **DML Operations**: 1 update per routing
- **CPU Time**: Minimal (< 100ms per call)
- **Heap Size**: Minimal (< 1KB per call)

### Thread Safety
- Method is thread-safe for concurrent calls
- Uses `SELECT FOR UPDATE` implicitly via DML
- No race conditions in round-robin selection

---

## Version History

### Version 1.0
- Initial invocable method
- Round-robin routing
- Automatic date/time tracking

---

## Support

For technical questions:
- Review [User Guide](USER_GUIDE.md) for general usage
- See [Testing Guide](TESTING_ROUTER_USAGE.md) for testing examples
- Contact support for integration assistance

---

**Happy Integrating!** 🚀

