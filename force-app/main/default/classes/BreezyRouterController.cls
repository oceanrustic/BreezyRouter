/**
 * @description Controller class for BreezyRouter Lightning Web Components
 * Provides methods for router CRUD operations, user assignment, and status management
 * @author BreezyRouter Team
 * @date 2025
 */
public with sharing class BreezyRouterController {
    
    /**
     * @description Get all routers with member count
     * @return List of routers with metadata
     */
    @AuraEnabled(cacheable=true)
    public static List<RouterWrapper> getRouters() {
        try {
            List<RouterWrapper> wrappers = new List<RouterWrapper>();
            
            // Query all routers with member counts
            List<BreezyRouter__c> routers = [
                SELECT Id, Name, Description__c, CreatedDate, LastModifiedDate,
                       (SELECT Id, Status__c FROM BreezyRouter_Members__r)
                FROM BreezyRouter__c
                ORDER BY Name ASC
                LIMIT 2000
            ];
            
            for (BreezyRouter__c router : routers) {
                RouterWrapper wrapper = new RouterWrapper();
                wrapper.id = router.Id;
                wrapper.name = router.Name;
                wrapper.description = router.Description__c;
                wrapper.createdDate = router.CreatedDate;
                wrapper.lastModifiedDate = router.LastModifiedDate;
                
                // Count members by status
                Integer totalMembers = 0;
                Integer activeMembers = 0;
                
                for (BreezyRouter_Member__c member : router.BreezyRouter_Members__r) {
                    totalMembers++;
                    if (member.Status__c == 'Active') {
                        activeMembers++;
                    }
                }
                
                wrapper.totalMembers = totalMembers;
                wrapper.activeMembers = activeMembers;
                wrappers.add(wrapper);
            }
            
            return wrappers;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving routers: ' + e.getMessage());
        }
    }
    
    /**
     * @description Search routers by name or description
     * @param searchTerm The search term
     * @return List of matching routers
     */
    @AuraEnabled(cacheable=true)
    public static List<RouterWrapper> searchRouters(String searchTerm) {
        try {
            if (String.isBlank(searchTerm)) {
                return getRouters();
            }
            
            String searchPattern = '%' + searchTerm + '%';
            List<RouterWrapper> wrappers = new List<RouterWrapper>();
            
            List<BreezyRouter__c> routers = [
                SELECT Id, Name, Description__c, CreatedDate, LastModifiedDate,
                       (SELECT Id, Status__c FROM BreezyRouter_Members__r)
                FROM BreezyRouter__c
                WHERE Name LIKE :searchPattern 
                   OR Description__c LIKE :searchPattern
                ORDER BY Name ASC
                LIMIT 2000
            ];
            
            for (BreezyRouter__c router : routers) {
                RouterWrapper wrapper = new RouterWrapper();
                wrapper.id = router.Id;
                wrapper.name = router.Name;
                wrapper.description = router.Description__c;
                wrapper.createdDate = router.CreatedDate;
                wrapper.lastModifiedDate = router.LastModifiedDate;
                
                Integer totalMembers = 0;
                Integer activeMembers = 0;
                
                for (BreezyRouter_Member__c member : router.BreezyRouter_Members__r) {
                    totalMembers++;
                    if (member.Status__c == 'Active') {
                        activeMembers++;
                    }
                }
                
                wrapper.totalMembers = totalMembers;
                wrapper.activeMembers = activeMembers;
                wrappers.add(wrapper);
            }
            
            return wrappers;
        } catch (Exception e) {
            throw new AuraHandledException('Error searching routers: ' + e.getMessage());
        }
    }
    
    /**
     * @description Create a new router
     * @param name Router name
     * @param description Router description
     * @return Id of created router
     */
    @AuraEnabled
    public static String createRouter(String name, String description) {
        try {
            if (String.isBlank(name)) {
                throw new AuraHandledException('Router name is required');
            }
            
            // Check for duplicate names
            List<BreezyRouter__c> existing = [
                SELECT Id FROM BreezyRouter__c 
                WHERE Name = :name 
                LIMIT 1
            ];
            
            if (!existing.isEmpty()) {
                throw new AuraHandledException('A router with this name already exists');
            }
            
            BreezyRouter__c router = new BreezyRouter__c(
                Name = name,
                Description__c = description
            );
            
            insert router;
            return router.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating router: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error creating router: ' + e.getMessage());
        }
    }
    
    /**
     * @description Update an existing router
     * @param routerId Router Id
     * @param name Router name
     * @param description Router description
     */
    @AuraEnabled
    public static void updateRouter(String routerId, String name, String description) {
        try {
            if (String.isBlank(routerId) || String.isBlank(name)) {
                throw new AuraHandledException('Router ID and name are required');
            }
            
            // Check for duplicate names (excluding current router)
            List<BreezyRouter__c> existing = [
                SELECT Id FROM BreezyRouter__c 
                WHERE Name = :name 
                AND Id != :routerId
                LIMIT 1
            ];
            
            if (!existing.isEmpty()) {
                throw new AuraHandledException('A router with this name already exists');
            }
            
            BreezyRouter__c router = new BreezyRouter__c(
                Id = routerId,
                Name = name,
                Description__c = description
            );
            
            update router;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating router: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error updating router: ' + e.getMessage());
        }
    }
    
    /**
     * @description Delete a router and optionally its members
     * @param routerId Router Id
     * @param deleteMembers Whether to delete associated members
     */
    @AuraEnabled
    public static void deleteRouter(String routerId, Boolean deleteMembers) {
        try {
            if (String.isBlank(routerId)) {
                throw new AuraHandledException('Router ID is required');
            }
            
            if (deleteMembers) {
                // Delete associated members first
                List<BreezyRouter_Member__c> members = [
                    SELECT Id FROM BreezyRouter_Member__c 
                    WHERE BreezyRouter__c = :routerId
                ];
                
                if (!members.isEmpty()) {
                    delete members;
                }
            }
            
            BreezyRouter__c router = new BreezyRouter__c(Id = routerId);
            delete router;
        } catch (DmlException e) {
            throw new AuraHandledException('Error deleting router: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting router: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get router details with member information
     * @param routerId Router Id
     * @return Router details with members
     */
    @AuraEnabled(cacheable=false)
    public static RouterDetailWrapper getRouterDetails(String routerId) {
        try {
            if (String.isBlank(routerId)) {
                throw new AuraHandledException('Router ID is required');
            }
            
            List<BreezyRouter__c> routers = [
                SELECT Id, Name, Description__c, CreatedDate, LastModifiedDate
                FROM BreezyRouter__c
                WHERE Id = :routerId
                LIMIT 1
            ];
            
            if (routers.isEmpty()) {
                throw new AuraHandledException('Router not found');
            }
            
            BreezyRouter__c router = routers[0];
            
            // Query members with user details
            List<BreezyRouter_Member__c> members = [
                SELECT Id, UserId__c, Status__c, Routed_Date__c, Routed_Time__c,
                       CreatedDate, LastModifiedDate
                FROM BreezyRouter_Member__c
                WHERE BreezyRouter__c = :routerId
                ORDER BY CreatedDate ASC
            ];
            
            // Get user details
            Set<String> userIds = new Set<String>();
            for (BreezyRouter_Member__c member : members) {
                if (String.isNotBlank(member.UserId__c)) {
                    userIds.add(member.UserId__c);
                }
            }
            
            Map<String, User> userMap = new Map<String, User>();
            if (!userIds.isEmpty()) {
                for (User u : [
                    SELECT Id, Name, Email, Username, IsActive
                    FROM User
                    WHERE Id IN :userIds
                ]) {
                    userMap.put(u.Id, u);
                }
            }
            
            // Build wrapper
            RouterDetailWrapper wrapper = new RouterDetailWrapper();
            wrapper.id = router.Id;
            wrapper.name = router.Name;
            wrapper.description = router.Description__c;
            wrapper.createdDate = router.CreatedDate;
            wrapper.lastModifiedDate = router.LastModifiedDate;
            wrapper.members = new List<MemberWrapper>();
            
            for (BreezyRouter_Member__c member : members) {
                MemberWrapper memberWrapper = new MemberWrapper();
                memberWrapper.id = member.Id;
                memberWrapper.userId = member.UserId__c;
                memberWrapper.status = member.Status__c;
                memberWrapper.routedDate = member.Routed_Date__c;
                memberWrapper.routedTime = member.Routed_Time__c;
                memberWrapper.createdDate = member.CreatedDate;
                
                if (userMap.containsKey(member.UserId__c)) {
                    User u = userMap.get(member.UserId__c);
                    memberWrapper.userName = u.Name;
                    memberWrapper.userEmail = u.Email;
                    memberWrapper.userActive = u.IsActive;
                }
                
                wrapper.members.add(memberWrapper);
            }
            
            return wrapper;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving router details: ' + e.getMessage());
        }
    }
    
    // Wrapper classes for data transfer
    
    /**
     * @description Wrapper class for router summary data
     */
    public class RouterWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public Integer totalMembers;
        @AuraEnabled public Integer activeMembers;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public DateTime lastModifiedDate;
    }
    
    /**
     * @description Wrapper class for router detail data
     */
    public class RouterDetailWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public DateTime createdDate;
        @AuraEnabled public DateTime lastModifiedDate;
        @AuraEnabled public List<MemberWrapper> members;
    }
    
    /**
     * @description Wrapper class for member data
     */
    public class MemberWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String userId;
        @AuraEnabled public String userName;
        @AuraEnabled public String userEmail;
        @AuraEnabled public Boolean userActive;
        @AuraEnabled public String status;
        @AuraEnabled public DateTime routedDate;
        @AuraEnabled public Time routedTime;
        @AuraEnabled public DateTime createdDate;
    }
    
    // ==================== USER ASSIGNMENT METHODS ====================
    
    /**
     * @description Search for users to assign to routers
     * @param searchTerm Search term for name, email, or username
     * @param roleId Filter by Role ID
     * @param profileId Filter by Profile ID
     * @param department Filter by Department
     * @return List of users matching criteria
     */
    @AuraEnabled(cacheable=false)
    public static List<UserWrapper> searchUsers(String searchTerm, String roleId, String profileId, String department) {
        try {
            List<UserWrapper> userWrappers = new List<UserWrapper>();
            
            // Build dynamic SOQL
            String query = 'SELECT Id, Name, Email, Username, IsActive, Department, Profile.Name, UserRole.Name ' +
                          'FROM User WHERE IsActive = true';
            
            // Add search term filter
            if (String.isNotBlank(searchTerm)) {
                String searchPattern = '%' + searchTerm + '%';
                query += ' AND (Name LIKE :searchPattern OR Email LIKE :searchPattern OR Username LIKE :searchPattern)';
            }
            
            // Add role filter
            if (String.isNotBlank(roleId)) {
                query += ' AND UserRoleId = :roleId';
            }
            
            // Add profile filter
            if (String.isNotBlank(profileId)) {
                query += ' AND ProfileId = :profileId';
            }
            
            // Add department filter
            if (String.isNotBlank(department)) {
                query += ' AND Department = :department';
            }
            
            query += ' ORDER BY Name ASC LIMIT 200';
            
            List<User> users = Database.query(query);
            
            for (User u : users) {
                UserWrapper wrapper = new UserWrapper();
                wrapper.id = u.Id;
                wrapper.name = u.Name;
                wrapper.email = u.Email;
                wrapper.username = u.Username;
                wrapper.isActive = u.IsActive;
                wrapper.department = u.Department;
                wrapper.profileName = u.Profile.Name;
                wrapper.roleName = u.UserRole != null ? u.UserRole.Name : '';
                userWrappers.add(wrapper);
            }
            
            return userWrappers;
        } catch (Exception e) {
            throw new AuraHandledException('Error searching users: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get users already assigned to a router
     * @param routerId Router ID
     * @return List of user IDs in the router
     */
    @AuraEnabled(cacheable=false)
    public static List<String> getRouterMemberUserIds(String routerId) {
        try {
            if (String.isBlank(routerId)) {
                return new List<String>();
            }
            
            List<String> userIds = new List<String>();
            List<BreezyRouter_Member__c> members = [
                SELECT UserId__c 
                FROM BreezyRouter_Member__c 
                WHERE BreezyRouter__c = :routerId
            ];
            
            for (BreezyRouter_Member__c member : members) {
                if (String.isNotBlank(member.UserId__c)) {
                    userIds.add(member.UserId__c);
                }
            }
            
            return userIds;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving router members: ' + e.getMessage());
        }
    }
    
    /**
     * @description Add users to a router
     * @param routerId Router ID
     * @param userIds List of User IDs to add
     * @return Number of users added
     */
    @AuraEnabled
    public static Integer addUsersToRouter(String routerId, List<String> userIds) {
        try {
            if (String.isBlank(routerId) || userIds == null || userIds.isEmpty()) {
                throw new AuraHandledException('Router ID and user IDs are required');
            }
            
            // Get existing members to avoid duplicates
            Set<String> existingUserIds = new Set<String>();
            List<BreezyRouter_Member__c> existingMembers = [
                SELECT UserId__c 
                FROM BreezyRouter_Member__c 
                WHERE BreezyRouter__c = :routerId
            ];
            
            for (BreezyRouter_Member__c member : existingMembers) {
                existingUserIds.add(member.UserId__c);
            }
            
            // Create new members for users not already in router
            List<BreezyRouter_Member__c> newMembers = new List<BreezyRouter_Member__c>();
            
            for (String userId : userIds) {
                if (!existingUserIds.contains(userId)) {
                    newMembers.add(new BreezyRouter_Member__c(
                        BreezyRouter__c = routerId,
                        UserId__c = userId,
                        Status__c = 'Active'
                    ));
                }
            }
            
            if (!newMembers.isEmpty()) {
                insert newMembers;
            }
            
            return newMembers.size();
        } catch (DmlException e) {
            throw new AuraHandledException('Error adding users to router: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error adding users to router: ' + e.getMessage());
        }
    }
    
    /**
     * @description Remove users from a router
     * @param routerId Router ID
     * @param userIds List of User IDs to remove
     * @return Number of users removed
     */
    @AuraEnabled
    public static Integer removeUsersFromRouter(String routerId, List<String> userIds) {
        try {
            if (String.isBlank(routerId) || userIds == null || userIds.isEmpty()) {
                throw new AuraHandledException('Router ID and user IDs are required');
            }
            
            List<BreezyRouter_Member__c> membersToDelete = [
                SELECT Id 
                FROM BreezyRouter_Member__c 
                WHERE BreezyRouter__c = :routerId 
                AND UserId__c IN :userIds
            ];
            
            if (!membersToDelete.isEmpty()) {
                delete membersToDelete;
            }
            
            return membersToDelete.size();
        } catch (DmlException e) {
            throw new AuraHandledException('Error removing users from router: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error removing users from router: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get all active Roles for filtering
     * @return List of Roles
     */
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getUserRoles() {
        try {
            List<PicklistOption> options = new List<PicklistOption>();
            
            List<UserRole> roles = [
                SELECT Id, Name 
                FROM UserRole 
                ORDER BY Name ASC
            ];
            
            for (UserRole role : roles) {
                options.add(new PicklistOption(role.Name, role.Id));
            }
            
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving user roles: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get all Profiles for filtering
     * @return List of Profiles
     */
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getUserProfiles() {
        try {
            List<PicklistOption> options = new List<PicklistOption>();
            
            List<Profile> profiles = [
                SELECT Id, Name 
                FROM Profile 
                WHERE UserType = 'Standard'
                ORDER BY Name ASC
            ];
            
            for (Profile profile : profiles) {
                options.add(new PicklistOption(profile.Name, profile.Id));
            }
            
            return options;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving user profiles: ' + e.getMessage());
        }
    }
    
    /**
     * @description Wrapper class for user data
     */
    public class UserWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String username;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public String department;
        @AuraEnabled public String profileName;
        @AuraEnabled public String roleName;
    }
    
    /**
     * @description Wrapper class for picklist options
     */
    public class PicklistOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}

