# BreezyRouter - Admin Setup Guide

Complete guide for Salesforce Administrators to set up and configure BreezyRouter.

## Table of Contents
1. [Installation](#installation)
2. [Permission Sets](#permission-sets)
3. [Initial Configuration](#initial-configuration)
4. [Security Settings](#security-settings)
5. [Troubleshooting](#troubleshooting)

---

## Installation

### From AppExchange
1. Visit AppExchange listing
2. Click **"Get It Now"**
3. Log in with your Salesforce credentials
4. Choose installation target (Production or Sandbox)
5. Review security settings
6. Click **"Confirm and Install"**
7. Wait for installation to complete

### Manual Installation
See [Installation Guide](INSTALLATION_GUIDE.md) for detailed steps.

---

## Permission Sets

BreezyRouter includes three permission sets for different user roles:

### 1. BreezyRouter Admin
**Full administrative access**
- Create, edit, delete routers
- Manage all users
- Manage all statuses
- View dashboard
- Access to all features

**Assign to:**
- System Administrators
- Router managers who need full control

### 2. BreezyRouter Manager
**Management access (no deletion)**
- Create and edit routers
- Manage users and members
- Manage statuses
- View dashboard
- Cannot delete routers

**Assign to:**
- Team leads
- Department managers
- Supervisors

### 3. BreezyRouter User
**Read-only access**
- View routers and members
- View dashboard
- Cannot modify data

**Assign to:**
- End users who need visibility only
- Auditors
- Report viewers

### Assigning Permission Sets

#### To Individual Users
1. Setup → Users → Users
2. Find user → Click user name
3. Scroll to **Permission Set Assignments**
4. Click **Edit Assignments**
5. Select permission set → **Assign**
6. Click **Save**

#### In Bulk (Permission Set Assignment)
1. Setup → Users → Permission Sets
2. Find **"BreezyRouter Admin"** (or Manager/User)
3. Click **Manage Assignments**
4. Click **Add Users**
5. Select users → **Assign**
6. Repeat for other permission sets

---

## Initial Configuration

### Step 1: Create Your First Router
1. Navigate to **BreezyRouter Management**
2. Click **"Create Router"**
3. Name it (e.g., "Sales Team", "Support Queue")
4. Add description
5. Save

### Step 2: Add Members
1. Click **"Manage Users"** on your router
2. Search and select users
3. Use filters if needed
4. Add selected users

### Step 3: Verify Status
1. Click **"Manage Status"** on your router
2. Ensure all members have **Status = "Active"**
3. Change status as needed

### Step 4: Test Routing
Create a simple Flow to test:
1. Setup → Flows → New Flow
2. Add Apex action: `BreezyRouter.getNextUserInBreezyRouter`
3. Input: `routerNames = ['Your Router Name']`
4. Test the Flow
5. Verify routing works

See [Testing Guide](TESTING_ROUTER_USAGE.md) for details.

---

## Security Settings

### Field-Level Security (FLS)
All custom fields respect FLS:
- Permission sets control access
- Users without access won't see fields
- Validation rules apply

### Sharing Rules
BreezyRouter uses **private sharing model**:
- Users only see routers they're members of
- Admins see all routers
- Sharing rules can be customized if needed

### Object Security
**BreezyRouter__c** (Router object):
- Read: Users with permission set
- Create/Edit: Admin or Manager permission set
- Delete: Admin permission set only

**BreezyRouter_Member__c** (Member object):
- Read: Users with permission set
- Create/Edit: Admin or Manager permission set
- Delete: Admin permission set only

### Access Control Review
1. Setup → Security → Sharing Settings
2. Review sharing rules
3. Verify organization-wide defaults
4. Adjust as needed for your org

---

## Customization Options

### Custom Fields
You can add custom fields to:
- **BreezyRouter__c**: Additional router metadata
- **BreezyRouter_Member__c**: Additional member information

**Important**: Custom fields won't break existing functionality.

### Validation Rules
You can create validation rules on:
- Router name format
- Member status transitions
- Other business rules

### Automation
BreezyRouter works with:
- **Flows**: Use invocable method (see [API Documentation](API_DOCUMENTATION.md))
- **Process Builder**: Call Flow with routing logic
- **Apex Triggers**: Direct Apex method calls

---

## Maintenance

### Regular Tasks
- **Weekly**: Review dashboard for routing patterns
- **Monthly**: Audit status changes via history
- **Quarterly**: Review and update permission set assignments
- **As needed**: Add/remove members from routers

### Data Backup
- BreezyRouter data is stored in standard Salesforce objects
- Included in regular Salesforce backups
- Can export via Data Loader if needed

### Performance Monitoring
- Monitor dashboard load times
- Check for large router member lists (100+ members)
- Optimize Flow calls if processing many records

---

## Troubleshooting

### Permission Issues

**User can't see routers:**
- ✅ Check permission set is assigned
- ✅ Verify permission set includes object access
- ✅ Check user has active status

**User can't create routers:**
- ✅ Assign **BreezyRouter Admin** or **Manager** permission set
- ✅ Verify object-level permissions

**User can't manage status:**
- ✅ Check permission set includes **BreezyRouter_Member__c** edit access
- ✅ Verify sharing rules

### Routing Issues

**Flow not routing correctly:**
- ✅ Verify router name matches exactly (case-sensitive)
- ✅ Check router has active members
- ✅ Verify Flow has correct Apex action
- ✅ Check error logs in Flow debug

**Round-robin not working:**
- ✅ Verify multiple active members exist
- ✅ Check `Routed_Date__c` is being updated
- ✅ Review dashboard for routing activity

### Data Issues

**Dashboard showing incorrect counts:**
- ✅ Refresh dashboard data
- ✅ Check time range filter
- ✅ Verify data exists in org

**Status history missing:**
- ✅ Ensure field history tracking is enabled
- ✅ Check user has permission to view history
- ✅ Verify status changes were saved

---

## Best Practices

### Router Management
- ✅ Use descriptive names (include team/department)
- ✅ Add descriptions to document purpose
- ✅ Keep router list organized (delete unused routers)
- ✅ Regular cleanup of inactive members

### User Management
- ✅ Add users in bulk during initial setup
- ✅ Remove users when they leave team
- ✅ Update statuses proactively (before PTO, etc.)
- ✅ Use status reasons for audit trail

### Security
- ✅ Assign minimum required permission set
- ✅ Regular review of permission set assignments
- ✅ Document any customizations
- ✅ Review audit logs quarterly

### Performance
- ✅ Limit router member count to reasonable numbers (< 200 per router)
- ✅ Use filters when searching users
- ✅ Monitor dashboard load times
- ✅ Optimize Flow calls

---

## Support & Resources

### Documentation
- **[User Guide](USER_GUIDE.md)**: End-user documentation
- **[API Documentation](API_DOCUMENTATION.md)**: Technical reference
- **[Testing Guide](TESTING_ROUTER_USAGE.md)**: How to test routing
- **[Installation Guide](INSTALLATION_GUIDE.md)**: Installation steps

### Getting Help
- **Salesforce Support**: For platform issues
- **AppExchange Support**: For app-specific issues
- **Documentation**: Check guides first
- **Salesforce Community**: Ask questions in forums

---

## Appendix

### Permission Set Details

#### BreezyRouter Admin
```
Objects:
- BreezyRouter__c: Read, Create, Edit, Delete
- BreezyRouter_Member__c: Read, Create, Edit, Delete

Fields:
- All fields: Read, Edit
```

#### BreezyRouter Manager
```
Objects:
- BreezyRouter__c: Read, Create, Edit
- BreezyRouter_Member__c: Read, Create, Edit

Fields:
- All fields: Read, Edit
```

#### BreezyRouter User
```
Objects:
- BreezyRouter__c: Read
- BreezyRouter_Member__c: Read

Fields:
- All fields: Read
```

---

**Setup Complete!** 🎉

Your BreezyRouter is ready to use. See [User Guide](USER_GUIDE.md) to start routing!

