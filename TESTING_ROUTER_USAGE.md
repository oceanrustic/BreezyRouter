# Testing Router Usage with Salesforce Flows

This guide shows you how to test the BreezyRouter routing functionality using a Salesforce Flow that calls the invocable Apex method.

## Overview

The BreezyRouter has an **Invocable Apex Method** called `getNextUserInBreezyRouter` that:
- Takes a router name as input
- Returns the next user ID based on round-robin routing
- Updates the `Routed_Date__c` and `Routed_Time__c` fields
- These updates are tracked in the Dashboard's "Last Routed" metrics

---

## Step 1: Create Test Data

### A. Create a Router
1. Go to **BreezyRouter Management** component
2. Click **"Create Router"**
3. Name: `Test Router`
4. Description: `Testing router functionality`
5. Click **Save**

### B. Add Members to the Router
1. In the Routers table, find your "Test Router"
2. Click the dropdown menu → **"Manage Users"**
3. Add **3-5 users** to the router
4. Ensure all members have **Status = "Active"**
5. Click **Done**

---

## Step 2: Create a Salesforce Flow to Test Routing

### Option A: Create an Autolaunched Flow (Recommended for Testing)

1. **Go to Setup** → **Flows** → **New Flow**
2. Select **Autolaunched Flow** → Click **Create**

3. **Add an Action Element:**
   - Drag **"Action"** from the palette onto the canvas
   - Click the action element
   - Click **"New Resource"** in the Action property panel
   - Resource Type: **Apex**
   - Action: **BreezyRouter.getNextUserInBreezyRouter**
   - API Name: `getNextUserInBreezyRouter`
   - Click **Done**

4. **Configure the Apex Action:**
   - **Input**: `routerNames` → Add a value: `Test Router` (or your router name)
   - The output will be stored in `getNextUserInBreezyRouter.outputVariable`

5. **Add a Debug/Apex Action Element (Optional):**
   - Add another action or debug element to display the returned user ID
   - You can add an **Assignment** element to store the result in a variable

6. **Save the Flow:**
   - Flow Label: `Test BreezyRouter Routing`
   - Flow API Name: `Test_BreezyRouter_Routing`
   - Click **Save**

### Option B: Create a Screen Flow (Interactive Testing)

1. **Go to Setup** → **Flows** → **New Flow**
2. Select **Screen Flow** → Click **Create**

3. **Add a Screen Element:**
   - Drag **"Screen"** onto the canvas
   - Add an input field: **Text** → Label: `Router Name`
   - Variable Name: `routerName`
   - Make it Required

4. **Add an Action Element:**
   - Drag **"Action"** onto the canvas
   - Click **"New Resource"** → **Apex**
   - Action: **BreezyRouter.getNextUserInBreezyRouter**
   - Input: `routerNames` → Reference: `{!routerName}`
   - Output Variable: `routedUserIds`

5. **Add Another Screen to Display Results:**
   - Drag **"Screen"** onto the canvas
   - Add a Display Text field to show the returned user ID(s)

6. **Add Navigation:**
   - Connect all elements with arrows

7. **Save and Activate the Flow**

---

## Step 3: Test the Flow

### For Autolaunched Flow:
1. Go to **Setup** → **Flows**
2. Find your flow → Click **"Run"** (or use the URL builder/button)
3. Execute the flow
4. Check the debug logs or variables for the returned user ID

### For Screen Flow:
1. Create a **Button** or **Quick Action** to launch the flow
2. Or go to the Flow's detail page and click **"Run"**
3. Enter the router name: `Test Router`
4. Click **Next**
5. View the returned user ID

---

## Step 4: Verify Routing Behavior

### A. Check Member Records:
1. Go to **Setup** → **Object Manager** → **BreezyRouter Member**
2. Go to **Records**
3. Filter to show members of your "Test Router"
4. **Verify:**
   - One member should have `Routed_Date__c` and `Routed_Time__c` populated (the one that was routed)
   - The others should be NULL (or older dates)

### B. Run the Flow Multiple Times:
1. **Run the flow 3-5 times** with the same router name
2. After each run, check which member was routed
3. **Verify Round-Robin:**
   - Each run should route to a **different member**
   - It should cycle through all active members
   - The member with the **oldest Routed_Date__c** should be selected next

### C. Check Dashboard Metrics:
1. Go to **BreezyRouter Management** → **Dashboard** tab
2. **Verify:**
   - **Total Routings** count should increase
   - **Router Performance** section should show:
     - Routing count for "Test Router"
     - **Last Routed** date/time should update
   - Progress bars should reflect routing activity

---

## Step 5: Test Edge Cases

### A. Test with No Active Members:
1. Set all members in "Test Router" to **"On Leave"** or **"Other"**
2. Run the flow
3. Verify it returns **null/no user ID**
4. Dashboard should show "Never routed"

### B. Test with Multiple Routers:
1. Create another router: `Test Router 2`
2. Add different members to it
3. Run the flow with `Test Router 2`
4. Verify only that router's members get routed

### C. Test Time Range Filtering:
1. Go to Dashboard → Change time range to **"Last 7 Days"**
2. Verify routing counts and dates filter correctly

---

## Step 6: Integration Testing (Optional - Advanced)

### Use Flow in a Real Scenario:

You can integrate the BreezyRouter into existing automation:

**Example: Auto-assign Leads/Cases**
1. Create a Flow triggered on **Lead/Case creation**
2. Add the **BreezyRouter.getNextUserInBreezyRouter** action
3. Assign the returned user ID to the Lead/Case Owner
4. Test by creating a new Lead/Case
5. Verify it gets assigned to a router member

**Flow Elements:**
```
Trigger → (Record Created)
    ↓
Action → BreezyRouter.getNextUserInBreezyRouter
    Input: routerNames = ['Sales Router']
    ↓
Assignment → Lead.OwnerId = {!getNextUserInBreezyRouter.outputVariable[0]}
```

---

## Troubleshooting

### Flow Can't Find the Apex Action:
- **Check**: Ensure `BreezyRouter.cls` is deployed
- **Check**: The method has `@InvocableMethod` annotation
- **Solution**: Redeploy the Apex class

### Flow Returns No User:
- **Check**: Router name matches exactly (case-sensitive)
- **Check**: Members are "Active" status
- **Check**: Router has at least one active member

### Dashboard Not Updating:
- **Check**: Refresh the Dashboard tab
- **Check**: Time range includes current date
- **Check**: `Routed_Date__c` field is being updated correctly

### Routing Not Round-Robin:
- **Check**: Multiple members exist with different Routed_Date__c values
- **Verify**: Apex method orders by `Routed_Date__c ASC, Routed_Time__c ASC`

---

## Quick Test Checklist

- [ ] Router created with 3+ active members
- [ ] Flow created that calls `getNextUserInBreezyRouter`
- [ ] Flow executes successfully
- [ ] User ID is returned
- [ ] Member's `Routed_Date__c` updates
- [ ] Multiple runs route to different members (round-robin)
- [ ] Dashboard shows routing count
- [ ] Dashboard shows "Last Routed" date/time
- [ ] Time range filter works correctly

---

## Summary

**Flow Input:**
- `routerNames` (List<String>) - Example: `['Test Router']`

**Flow Output:**
- `List<Id>` - Returns user ID(s) of the next member(s) to route to

**Dashboard Tracking:**
- `Routed_Date__c` and `Routed_Time__c` fields are updated automatically
- Dashboard aggregates this data for analytics
- "Last Routed" shows the most recent routing time per router

**Success Criteria:**
✅ Flow can call the invocable method
✅ Round-robin routing works correctly
✅ Dashboard metrics update in real-time
✅ Last routed date/time displays accurately

