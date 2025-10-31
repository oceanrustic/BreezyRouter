# BreezyRouter - User Guide

Complete guide for using BreezyRouter in your Salesforce org.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Managing Routers](#managing-routers)
3. [Managing Users](#managing-users)
4. [Status Management](#status-management)
5. [Dashboard & Analytics](#dashboard--analytics)
6. [Using in Flows](#using-in-flows)

---

## Getting Started

### Accessing BreezyRouter
1. Open **App Launcher** (🔍 icon)
2. Search for **"BreezyRouter"**
3. Click on **BreezyRouter Management**

Or add to your Utility Bar for quick access!

### Understanding the Interface
The main screen has two tabs:
- **Routers**: Manage your routing groups
- **Dashboard**: View analytics and insights

---

## Managing Routers

### Creating a Router
1. Click **"Create Router"** button (top right)
2. Enter **Router Name** (required) - e.g., "Sales Team", "Support Queue"
3. Enter **Description** (optional) - Add details about the router's purpose
4. Click **"Save"**

### Editing a Router
1. Find your router in the list
2. Click the dropdown menu (⋮) on the row
3. Select **"Edit"**
4. Update name or description
5. Click **"Save"**

### Deleting a Router
1. Click dropdown menu (⋮) on the router row
2. Select **"Delete"**
3. **Optional**: Check "Also delete all members" if you want to remove all members
4. Click **"Delete"** to confirm

⚠️ **Warning**: This action cannot be undone!

### Searching Routers
Use the search box at the top to find routers by name or description.

---

## Managing Users

### Adding Users to a Router
1. Find your router in the list
2. Click dropdown menu (⋮) → **"Manage Users"**
3. The **"Available Users"** table shows all users in your org
4. Use **Search** to find specific users (by name, email, or username)
5. Use **Filters** (Role, Profile, Department) to narrow down the list
6. **Select users** using checkboxes
7. Click **"Add Selected Users"**
8. The selected users move to **"Current Router Members"** table

💡 **Tip**: You can add multiple users at once using the checkboxes!

### Removing Users from a Router
1. Open **"Manage Users"** for your router
2. In **"Current Router Members"** table, select users
3. Click **"Remove Selected Users"**
4. Confirm removal

### Viewing Current Members
The **"Current Router Members"** table shows:
- Member name, email, username
- Department
- Date added to router
- **Last Routed** date/time (when they were last assigned work)

---

## Status Management

### Understanding Statuses
Members can have four statuses:
- **Active**: Ready to receive assignments ✅
- **PTO**: On paid time off 🏖️
- **On Leave**: Extended leave (sick, personal, etc.) 🏥
- **Other**: Custom status (training, project work, etc.) 📋

**Important**: Only **Active** members are included in round-robin routing!

### Quick Status Changes (Bulk)
1. Click dropdown menu (⋮) → **"Manage Status"**
2. **Select members** using checkboxes
3. Click a status button:
   - **Set Active** (green)
   - **Set PTO** (gray)
   - **Set On Leave** (gray)
   - **Set Other** (gray)
4. Confirm the change

### Bulk Status Update
1. Open **"Manage Status"**
2. Select multiple members
3. Choose status from **"New Status"** dropdown
4. **Optional**: Add a reason for the change
5. Click **"Update Selected (X)"** button

### Viewing Status History
1. Open **"Manage Status"**
2. Click **"View History"** button (top right)
3. See complete audit trail:
   - Who changed the status
   - When it changed
   - Old status → New status
   - Reason (if provided)

### Status Summary Cards
The status management screen shows quick counts:
- **Active**: Number of active members
- **PTO**: Number on PTO
- **On Leave**: Number on leave
- **Other**: Number with other status

---

## Dashboard & Analytics

### Key Metrics
The dashboard shows six key metrics:
- **Total Routers**: Number of routing groups
- **Total Members**: Total users across all routers
- **Active Members**: Members ready for routing (with percentage)
- **Inactive Members**: Members not active (with percentage)
- **Total Routings**: Total number of routing events
- **Avg/Day**: Average routings per day

### Router Performance Chart
Shows routing activity per router:
- **Router Name**
- **Routing Count**: Number of routings in selected time range
- **Last Routed**: Most recent routing date/time
- **Progress Bar**: Visual representation of routing activity

### Routing Frequency Chart
Shows routing patterns by day of week:
- **Day Name**: Sunday through Saturday
- **Routing Count**: Number of routings for that day
- **Bar Chart**: Visual representation of activity

### Time Range Filter
Filter data by time period:
- **Last 7 Days**
- **Last 30 Days** (default)
- **Last 90 Days**
- **Last Year**

Click the dropdown and select your desired range.

### Refreshing Data
Click the **refresh icon** (🔄) to update all dashboard data in real-time.

---

## Using in Flows

BreezyRouter integrates with Salesforce Flows using an invocable Apex method.

### Creating a Flow with BreezyRouter

#### Step 1: Create Flow
1. Setup → Flows → New Flow
2. Choose **"Autolaunched Flow"** or **"Screen Flow"**

#### Step 2: Add Apex Action
1. Drag **"Action"** onto canvas
2. Click **"New Resource"** → **Apex**
3. Select: **BreezyRouter.getNextUserInBreezyRouter**

#### Step 3: Configure Input
- **Input Variable**: `routerNames`
- **Value**: `['Your Router Name']` (array with your router name)

#### Step 4: Use Output
- **Output Variable**: `getNextUserInBreezyRouter.outputVariable`
- Returns: List of User IDs (one per router name)
- Assign to your record's Owner field

### Example: Auto-Assign Leads
```
Trigger: Record Created (Lead)
    ↓
Action: BreezyRouter.getNextUserInBreezyRouter
    Input: routerNames = ['Sales Queue']
    ↓
Assignment: Lead.OwnerId = {!getNextUserInBreezyRouter.outputVariable[0]}
```

### Testing Your Flow
1. **Run Flow** manually or create a test record
2. Check that record gets assigned to a router member
3. **Run multiple times** to verify round-robin rotation
4. Check **Dashboard** to see routing activity

See [Testing Guide](TESTING_ROUTER_USAGE.md) for detailed examples.

---

## Tips & Best Practices

### ✅ Do's
- Use descriptive router names (e.g., "Sales Team - West Region")
- Add descriptions to document router purpose
- Keep members **Active** when ready for assignments
- Update status when members are unavailable
- Add reasons when changing status (for audit trail)
- Check dashboard regularly for routing patterns

### ❌ Don'ts
- Don't delete routers without removing members first (unless intentional)
- Don't leave inactive members in router (they won't be routed)
- Don't use special characters in router names
- Don't create duplicate router names

### 💡 Pro Tips
- **Create multiple routers** for different teams or regions
- **Use status management** to track team availability
- **Monitor dashboard** to identify routing patterns
- **View history** to audit status changes
- **Add all team members** to router for fair distribution

---

## Troubleshooting

### Router not routing users?
- ✅ Check members have **Status = "Active"**
- ✅ Verify router has at least one active member
- ✅ Check Flow configuration (router name must match exactly)
- ✅ Verify permission sets are assigned

### Can't see router in list?
- ✅ Check search filter isn't too restrictive
- ✅ Verify you have access via permission sets
- ✅ Refresh the page

### Status changes not showing in history?
- ✅ History shows changes from field history tracking
- ✅ Recent changes may take a moment to appear
- ✅ Refresh the page

### Dashboard showing zero counts?
- ✅ Check time range filter includes current date
- ✅ Verify routers have routing activity
- ✅ Click refresh button

---

## Keyboard Shortcuts

- **Tab**: Navigate between fields
- **Enter**: Submit forms
- **Escape**: Close modals
- **Ctrl/Cmd + F**: Browser search

---

## Need Help?

- **Admin Setup**: See [Admin Setup Guide](ADMIN_SETUP_GUIDE.md)
- **Testing**: See [Testing Guide](TESTING_ROUTER_USAGE.md)
- **API Reference**: See [API Documentation](API_DOCUMENTATION.md)
- **Support**: Contact your Salesforce administrator

---

**Happy Routing!** 🎯

