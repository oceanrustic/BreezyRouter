# BreezyRouter - Installation Guide

Step-by-step guide for installing BreezyRouter in your Salesforce org.

## Prerequisites

- Salesforce org (Production, Sandbox, or Developer Edition)
- Lightning Experience enabled
- System Administrator access
- Appropriate licenses for Lightning Web Components

---

## Installation Methods

### Method 1: AppExchange Installation (Recommended)

1. **Visit AppExchange**
   - Go to https://appexchange.salesforce.com
   - Search for "BreezyRouter"
   - Click on the listing

2. **Get It Now**
   - Click **"Get It Now"** button
   - Log in with your Salesforce credentials

3. **Choose Installation Target**
   - Select **Production** or **Sandbox**
   - Review installation requirements
   - Click **"Continue"**

4. **Installation Options**
   - Choose installation for **All Users** or **Admins Only**
   - Review security settings
   - Accept terms and conditions
   - Click **"Confirm and Install"**

5. **Wait for Installation**
   - Installation typically takes 2-5 minutes
   - You'll receive email notification when complete

6. **Verify Installation**
   - Go to Setup → Installed Packages
   - Verify "BreezyRouter" is listed
   - Check for any installation errors

---

### Method 2: Manual Installation via CLI

#### Step 1: Install Salesforce CLI
```bash
# Install Salesforce CLI
# Visit: https://developer.salesforce.com/tools/salesforcecli

# Verify installation
sfdx --version
```

#### Step 2: Clone Repository
```bash
# Clone the repository
git clone <repository-url>
cd BreezyRouter
```

#### Step 3: Authenticate to Org
```bash
# Authenticate to your org
sfdx force:auth:web:login -a myorg
```

#### Step 4: Deploy Source
```bash
# Deploy all source
sfdx force:source:deploy -p force-app -u myorg

# Or deploy specific components
sfdx force:source:deploy -p force-app/main/default/classes -u myorg
sfdx force:source:deploy -p force-app/main/default/lwc -u myorg
sfdx force:source:deploy -p force-app/main/default/objects -u myorg
sfdx force:source:deploy -p force-app/main/default/permissionsets -u myorg
```

#### Step 5: Verify Deployment
```bash
# Check deployment status
sfdx force:source:status -u myorg

# Verify classes are deployed
sfdx force:apex:class:list -u myorg
```

---

## Post-Installation Steps

### Step 1: Assign Permission Sets

1. **Navigate to Permission Sets**
   - Setup → Users → Permission Sets
   - Find: **BreezyRouter Admin**, **BreezyRouter Manager**, **BreezyRouter User**

2. **Assign to Users**
   - Click **"Manage Assignments"**
   - Click **"Add Users"**
   - Select users → **Assign**

See [Admin Setup Guide](ADMIN_SETUP_GUIDE.md) for detailed permission set assignment.

### Step 2: Verify Components

1. **Check Custom Objects**
   - Setup → Object Manager
   - Verify **BreezyRouter__c** exists
   - Verify **BreezyRouter_Member__c** exists

2. **Check Lightning Components**
   - Setup → Lightning App Builder
   - Verify components are available:
     - `breezyRouterManagement`
     - `breezyUserAssignment`
     - `breezyStatusManager`
     - `breezyRouterDashboard`

3. **Check Tabs**
   - Setup → Tabs
   - Verify **BreezyRouter** tab exists

### Step 3: Create Lightning Page (Optional)

1. **Create App Page**
   - Setup → Lightning App Builder → New → App Page
   - Name: "BreezyRouter Home"
   - Drag `breezyRouterManagement` component
   - Save → Activate

2. **Assign to App**
   - Edit your Salesforce app
   - Add "BreezyRouter Home" to navigation
   - Save

### Step 4: Test Installation

1. **Create Test Router**
   - Navigate to BreezyRouter Management
   - Click "Create Router"
   - Name: "Test Router"
   - Save

2. **Add Test Members**
   - Click "Manage Users"
   - Add yourself or test users
   - Verify members appear

3. **Test Routing**
   - Create a Flow with `BreezyRouter.getNextUserInBreezyRouter`
   - Run Flow
   - Verify routing works

See [Testing Guide](TESTING_ROUTER_USAGE.md) for detailed testing.

---

## Verification Checklist

After installation, verify:

- [ ] Permission sets are visible in Setup
- [ ] Custom objects are created
- [ ] Lightning components are available
- [ ] Tabs are visible
- [ ] Can access BreezyRouter Management
- [ ] Can create a router
- [ ] Can add members
- [ ] Dashboard loads correctly
- [ ] Flow integration works (test with simple Flow)

---

## Troubleshooting Installation

### Installation Failed

**Check:**
- ✅ User has System Administrator permissions
- ✅ Org has sufficient storage
- ✅ Lightning Experience is enabled
- ✅ Required API version is available

**Resolve:**
- Try installing in smaller batches
- Check installation logs
- Contact support if issues persist

### Components Not Visible

**Check:**
- ✅ Lightning components are deployed
- ✅ User has permission set assigned
- ✅ Lightning Experience is enabled

**Resolve:**
- Refresh browser cache
- Log out and log back in
- Verify permission set assignment

### Permission Errors

**Check:**
- ✅ Permission sets are installed
- ✅ User has correct permission set assigned
- ✅ Object-level permissions are set

**Resolve:**
- Reassign permission set
- Check object sharing settings
- Verify FLS (Field-Level Security)

### API Errors

**Check:**
- ✅ API version compatibility
- ✅ Governor limits not exceeded
- ✅ Org has necessary features enabled

**Resolve:**
- Update to latest API version
- Reduce batch sizes
- Enable required features in Setup

---

## Uninstallation

### If You Need to Uninstall

1. **Remove Permission Set Assignments**
   - Setup → Users → Permission Sets
   - Remove all assignments

2. **Delete Custom Data** (Optional)
   - Delete all routers via Data Loader or UI
   - Delete all members

3. **Uninstall Package**
   - Setup → Installed Packages
   - Find "BreezyRouter"
   - Click **"Uninstall"**
   - Confirm deletion

⚠️ **Warning**: Uninstalling will delete all BreezyRouter data!

---

## Next Steps

After successful installation:

1. ✅ **Assign Permission Sets** - See [Admin Setup Guide](ADMIN_SETUP_GUIDE.md)
2. ✅ **Create First Router** - See [User Guide](USER_GUIDE.md)
3. ✅ **Test Routing** - See [Testing Guide](TESTING_ROUTER_USAGE.md)
4. ✅ **Configure Flows** - See [API Documentation](API_DOCUMENTATION.md)

---

## Support

If you encounter issues during installation:

- **Check Documentation**: Review guides in this repository
- **Review Logs**: Check installation logs in Setup
- **Contact Support**: Reach out via your Salesforce account manager

---

**Installation Complete!** 🎉

Ready to start routing? See [User Guide](USER_GUIDE.md)!

