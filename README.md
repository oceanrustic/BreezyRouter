# BreezyRouter - AppExchange App

**BreezyRouter** is a powerful Salesforce-native round-robin routing solution that automatically distributes workload evenly across team members. Built with Lightning Web Components (LWC) and designed for the Salesforce AppExchange.

## 🚀 Features

### Core Functionality
- **Round-Robin Routing**: Automatically route assignments to the next available team member
- **Router Management**: Create, update, and delete routing groups with ease
- **User Assignment**: Bulk add/remove users from routers with advanced search and filtering
- **Status Management**: Track member availability (Active, PTO, On Leave, Other) with audit trail
- **Dashboard & Analytics**: Comprehensive insights into routing performance and patterns

### Key Benefits
- ✅ **Fair Distribution**: Ensures equal workload distribution across team members
- ✅ **Visual Interface**: Intuitive Lightning Web Component interface
- ✅ **Bulk Operations**: Manage hundreds of users efficiently
- ✅ **Real-Time Analytics**: Track routing patterns and performance metrics
- ✅ **Audit Trail**: Complete history of status changes and routing activity
- ✅ **Flow Integration**: Invocable Apex method for easy Flow automation

## 📋 Requirements

- Salesforce org (Production, Sandbox, or Developer Edition)
- Lightning Experience enabled
- System Administrator permissions for installation

## 📦 Installation

### Install from AppExchange
1. Visit the [BreezyRouter listing](link-to-appexchange) on AppExchange
2. Click "Get It Now"
3. Follow the installation wizard
4. Assign permission sets to users (see [Admin Setup Guide](ADMIN_SETUP_GUIDE.md))

### Manual Installation (Developer)
1. Clone this repository
2. Deploy to your org using Salesforce CLI:
   ```bash
   sfdx force:source:deploy -p force-app
   ```
3. Assign permission sets to users

## 🎯 Quick Start

### 1. Create Your First Router
1. Navigate to **BreezyRouter Management** (from App Launcher or Utility Bar)
2. Click **"Create Router"**
3. Enter a name (e.g., "Sales Queue", "Support Team")
4. Add optional description
5. Click **"Save"**

### 2. Add Members to Router
1. In the router list, click the dropdown menu next to your router
2. Select **"Manage Users"**
3. Search and select users to add
4. Use filters to narrow down users (Role, Profile, Department)
5. Click **"Add Selected Users"**

### 3. Use Router in Flow
Create a Flow that calls the invocable method:
- **Action**: `BreezyRouter.getNextUserInBreezyRouter`
- **Input**: `routerNames` = `['Your Router Name']`
- **Output**: Returns User ID(s) for assignment

See [Testing Guide](TESTING_ROUTER_USAGE.md) for detailed Flow examples.

## 📚 Documentation

- **[User Guide](USER_GUIDE.md)** - Complete guide for end users
- **[Admin Setup Guide](ADMIN_SETUP_GUIDE.md)** - Configuration and setup instructions
- **[Installation Guide](INSTALLATION_GUIDE.md)** - Detailed installation steps
- **[Testing Guide](TESTING_ROUTER_USAGE.md)** - How to test router functionality
- **[API Documentation](API_DOCUMENTATION.md)** - Invocable method reference

## 🔧 Configuration

### Permission Sets
Three permission sets are included:
- **BreezyRouter Admin**: Full access (create, edit, delete routers)
- **BreezyRouter Manager**: Manage routers and members (no deletion)
- **BreezyRouter User**: Read-only access

See [Admin Setup Guide](ADMIN_SETUP_GUIDE.md) for detailed permission set configuration.

## 🎨 Components

### Lightning Web Components
- **breezyRouterManagement**: Main router management interface with tabs
- **breezyUserAssignment**: User search and assignment interface
- **breezyStatusManager**: Status management and bulk updates
- **breezyRouterDashboard**: Analytics and insights dashboard

### Apex Classes
- **BreezyRouterController**: Main controller for all LWC components
- **BreezyRouter**: Invocable method for Flow integration

## 🔒 Security

- All Apex classes use `with sharing` for proper access control
- SOQL queries use bind variables to prevent injection attacks
- Field-Level Security (FLS) respected through permission sets
- No hardcoded credentials or sensitive data

## 🧪 Testing

Comprehensive test coverage (75%+):
- 55+ test methods covering all functionality
- Dashboard, status management, and router operations
- Edge cases and error handling
- All tests passing ✅

## 📊 AppExchange Compliance

- ✅ 75%+ code coverage
- ✅ Security best practices implemented
- ✅ Comprehensive documentation
- ✅ Proper error handling
- ✅ Access control and sharing rules

## 🐛 Known Issues

None at this time.

## 📝 Version History

### Version 1.0 (Current)
- Initial AppExchange release
- Round-robin routing functionality
- Status management with audit trail
- Dashboard and analytics
- Flow integration via invocable method

## 🤝 Support

For issues, questions, or feature requests:
- **Email**: support@breezyrouter.com
- **Documentation**: See documentation files in this repository
- **Issues**: Submit via your Salesforce account manager

## 📄 License

This is a commercial AppExchange app. See license agreement upon installation.

## 🙏 Acknowledgments

Built with:
- Salesforce Lightning Web Components
- Lightning Design System
- Salesforce Apex

---

**BreezyRouter** - Making workload distribution fair and easy! 🎯
