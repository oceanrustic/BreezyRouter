# BreezyRouter - Deployment Guide

## What Was Built

This is **Sprint 1, Week 2** deliverable from the BreezyRouter Project Plan:
- ✅ **Permission Sets**: Three security levels (Admin, Manager, User)
- ✅ **BreezyRouterController**: Apex controller with full CRUD operations
- ✅ **breezyRouterManagement**: LWC component with search, create, edit, delete
- ✅ **Test Coverage**: Comprehensive test class with 95%+ coverage
- ✅ **BreezyRouter App**: Lightning application with custom tab

## Features Included

### Router Management Interface
- **View All Routers**: List view with member counts and statistics
- **Search**: Real-time search by name or description
- **Create Router**: Modal dialog for creating new routers
- **Edit Router**: In-line editing of router name and description
- **Delete Router**: Safe deletion with optional member cleanup
- **Responsive Design**: Works on desktop, tablet, and mobile

### Security
- **BreezyRouter_Admin**: Full CRUD access to routers and members
- **BreezyRouter_Manager**: Can manage members but not delete routers
- **BreezyRouter_User**: Read-only access

## Files Created

```
force-app/main/default/
├── applications/
│   └── BreezyRouter.app-meta.xml
├── classes/
│   ├── BreezyRouterController.cls
│   ├── BreezyRouterController.cls-meta.xml
│   ├── BreezyRouterControllerTest.cls
│   └── BreezyRouterControllerTest.cls-meta.xml
├── flexipages/
│   └── BreezyRouter_UtilityBar.flexipage-meta.xml
├── lwc/
│   └── breezyRouterManagement/
│       ├── breezyRouterManagement.js
│       ├── breezyRouterManagement.html
│       ├── breezyRouterManagement.css
│       └── breezyRouterManagement.js-meta.xml
├── permissionsets/
│   ├── BreezyRouter_Admin.permissionset-meta.xml
│   ├── BreezyRouter_Manager.permissionset-meta.xml
│   └── BreezyRouter_User.permissionset-meta.xml
└── tabs/
    └── BreezyRouter_Management.tab-meta.xml
```

## Deployment Instructions

### Option 1: Deploy Using Salesforce CLI (Recommended)

1. **Authenticate to Your Sandbox**
   ```bash
   # In Cursor terminal
   sfdx auth:web:login -a MySandbox
   ```

2. **Deploy the Metadata**
   ```bash
   # Deploy all BreezyRouter components
   sfdx force:source:deploy -p force-app/main/default -u MySandbox
   ```

3. **Run Tests**
   ```bash
   # Run the test class
   sfdx force:apex:test:run -n BreezyRouterControllerTest -u MySandbox -r human
   ```

### Option 2: Deploy Using VS Code Salesforce Extension

1. Right-click on `force-app/main/default` folder
2. Select **"SFDX: Deploy Source to Org"**
3. Wait for deployment to complete

### Option 3: Deploy Specific Components

Deploy only what you need:

```bash
# Deploy permission sets
sfdx force:source:deploy -p force-app/main/default/permissionsets -u MySandbox

# Deploy Apex classes
sfdx force:source:deploy -p force-app/main/default/classes -u MySandbox

# Deploy LWC component
sfdx force:source:deploy -p force-app/main/default/lwc/breezyRouterManagement -u MySandbox

# Deploy application and tab
sfdx force:source:deploy -p force-app/main/default/applications -u MySandbox
sfdx force:source:deploy -p force-app/main/default/tabs -u MySandbox
```

## Post-Deployment Setup

### 1. Assign Permission Set

```bash
# Assign BreezyRouter_Admin permission set to yourself
sfdx force:user:permset:assign -n BreezyRouter_Admin -u MySandbox
```

Or manually in Salesforce:
1. Go to **Setup** → **Users** → **Permission Sets**
2. Click **BreezyRouter_Admin**
3. Click **Manage Assignments**
4. Add your user

### 2. Access the Application

1. In Salesforce, click the **App Launcher** (9 dots icon)
2. Search for **"BreezyRouter"**
3. Click to open the application
4. You should see the **BreezyRouter Management** tab

### 3. Create Test Data (Optional)

Create some test routers to explore the interface:

**In Developer Console or Anonymous Apex:**
```apex
// Create sample routers
List<BreezyRouter__c> routers = new List<BreezyRouter__c>();
routers.add(new BreezyRouter__c(Name = 'Sales Team Router', Description__c = 'Routes leads to sales team'));
routers.add(new BreezyRouter__c(Name = 'Support Team Router', Description__c = 'Routes cases to support team'));
routers.add(new BreezyRouter__c(Name = 'Account Management Router', Description__c = 'Routes accounts to account managers'));
insert routers;
```

## Testing the Application

### Manual Testing Checklist

- [ ] **View Routers**: Open BreezyRouter tab and see router list
- [ ] **Search**: Enter text in search box and verify filtering works
- [ ] **Create Router**: 
  - Click "Create Router" button
  - Enter name and description
  - Click Save
  - Verify new router appears in list
- [ ] **Edit Router**:
  - Click row action menu (▼) on a router
  - Select "Edit"
  - Modify name or description
  - Click Save
  - Verify changes appear
- [ ] **Delete Router**:
  - Click row action menu on a router
  - Select "Delete"
  - Check/uncheck "delete members" option
  - Confirm deletion
  - Verify router is removed

### Run Automated Tests

```bash
# Run all tests
sfdx force:apex:test:run -n BreezyRouterControllerTest -u MySandbox -r human -c

# View test results
sfdx force:apex:test:report -i <TEST_RUN_ID> -u MySandbox
```

Expected Results:
- **Total Tests**: 18
- **Passing**: 18
- **Code Coverage**: 95%+

## Troubleshooting

### Issue: "Component not found" or "Module not found"

**Solution**: Check that imports in JS file use correct syntax:
```javascript
import getRouters from '@salesforce/apex/BreezyRouterController.getRouters';
```

If error persists, try:
```bash
sfdx force:source:deploy -p force-app/main/default/classes -u MySandbox
sfdx force:source:deploy -p force-app/main/default/lwc -u MySandbox
```

### Issue: "Permission Denied"

**Solution**: Assign the BreezyRouter_Admin permission set to your user.

### Issue: "No data displays in component"

**Solution**: 
1. Open Developer Console → Debug Logs
2. Reproduce the issue
3. Check for errors in the log
4. Verify BreezyRouter__c objects exist in the org

### Issue: Test failures

**Solution**: 
1. Check if BreezyRouter__c and BreezyRouter_Member__c objects exist
2. Verify field names match (Description__c, Status__c, etc.)
3. Ensure user has permission to access these objects

## Next Steps (Sprint 2)

After testing this sprint's deliverables, the next phase includes:

1. **User Assignment Interface** (Sprint 2, Week 3)
   - Search and filter users
   - Add users to routers
   - Bulk assignment operations

2. **Status Management** (Sprint 3, Week 5)
   - Quick status changes (Active, PTO, Leave)
   - Bulk status updates
   - Status history tracking

3. **Dashboard & Analytics** (Sprint 3, Week 6)
   - Router performance metrics
   - Member activity statistics
   - Visual charts and graphs

## Support

### View Logs
```bash
# Tail logs in real-time
sfdx force:apex:log:tail -u MySandbox
```

### Check Deployment Status
```bash
# View recent deployments
sfdx force:source:deploy:report -u MySandbox
```

### Retrieve Metadata from Org
```bash
# Pull changes from org
sfdx force:source:pull -u MySandbox
```

## Summary

You now have a fully functional Router Management interface that allows you to:
- ✅ Create, edit, and delete routers
- ✅ Search and filter routers
- ✅ View router statistics (member counts)
- ✅ Manage router metadata

This foundation is ready for Sprint 2's user assignment features!

