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
        } catch (AuraHandledException e) {
            throw e;
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
        } catch (AuraHandledException e) {
            throw e;
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
                AuraHandledException e = new AuraHandledException('Router name is required');
                e.setMessage('Router name is required');
                throw e;
            }
            
            // Check for duplicate names
            List<BreezyRouter__c> existing = [
                SELECT Id FROM BreezyRouter__c 
                WHERE Name = :name 
                LIMIT 1
            ];
            
            if (!existing.isEmpty()) {
                AuraHandledException e = new AuraHandledException('A router with this name already exists');
                e.setMessage('A router with this name already exists');
                throw e;
            }
            
            BreezyRouter__c router = new BreezyRouter__c(
                Name = name,
                Description__c = description
            );
            
            insert router;
            return router.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating router: ' + e.getDmlMessage(0));
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
                AuraHandledException e = new AuraHandledException('Router ID and name are required');
                e.setMessage('Router ID and name are required');
                throw e;
            }
            
            // Check for duplicate names (excluding current router)
            List<BreezyRouter__c> existing = [
                SELECT Id FROM BreezyRouter__c 
                WHERE Name = :name 
                AND Id != :routerId
                LIMIT 1
            ];
            
            if (!existing.isEmpty()) {
                AuraHandledException e = new AuraHandledException('A router with this name already exists');
                e.setMessage('A router with this name already exists');
                throw e;
            }
            
            BreezyRouter__c router = new BreezyRouter__c(
                Id = routerId,
                Name = name,
                Description__c = description
            );
            
            update router;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating router: ' + e.getDmlMessage(0));
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
                AuraHandledException e = new AuraHandledException('Router ID is required');
                e.setMessage('Router ID is required');
                throw e;
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
                AuraHandledException e = new AuraHandledException('Router ID is required');
                e.setMessage('Router ID is required');
                throw e;
            }
            
            List<BreezyRouter__c> routers = [
                SELECT Id, Name, Description__c, CreatedDate, LastModifiedDate
                FROM BreezyRouter__c
                WHERE Id = :routerId
                LIMIT 1
            ];
            
            if (routers.isEmpty()) {
                AuraHandledException e = new AuraHandledException('Router not found');
                e.setMessage('Router not found');
                throw e;
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
        } catch (AuraHandledException e) {
            throw e;  // Re-throw validation errors without wrapping
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
     * @description Wrapper class for member data (includes routing and status information)
     */
    public class MemberWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String userId;
        @AuraEnabled public String userName;
        @AuraEnabled public String userEmail;
        @AuraEnabled public Boolean userActive;
        @AuraEnabled public String userUsername;
        @AuraEnabled public String department;
        @AuraEnabled public String profileName;
        @AuraEnabled public String status;
        @AuraEnabled public String previousStatus;
        @AuraEnabled public Datetime statusChangedDate;
        @AuraEnabled public String statusChangedBy;
        @AuraEnabled public String statusChangeReason;
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
        } catch (AuraHandledException e) {
            throw e;
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
        if (String.isBlank(routerId)) {
            return new List<String>();
        }
        try {
            
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
        } catch (AuraHandledException e) {
            throw e;
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
                AuraHandledException e = new AuraHandledException('Router ID and user IDs are required');
                e.setMessage('Router ID and user IDs are required');
                throw e;
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
        } catch (AuraHandledException e) {
            throw e;
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
                AuraHandledException e = new AuraHandledException('Router ID and user IDs are required');
                e.setMessage('Router ID and user IDs are required');
                throw e;
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
        } catch (AuraHandledException e) {
            throw e;
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
        } catch (AuraHandledException e) {
            throw e;
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
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving user profiles: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get all members for a specific router with their status
     * @param routerId The router ID
     * @return List of router members
     */
    @AuraEnabled(cacheable=true)
    public static List<MemberWrapper> getRouterMembers(String routerId) {
        try {
            if (String.isBlank(routerId)) {
                AuraHandledException e = new AuraHandledException('Router ID is required');
                e.setMessage('Router ID is required');
                throw e;
            }
            
            List<MemberWrapper> wrappers = new List<MemberWrapper>();
            
            List<BreezyRouter_Member__c> members = [
                SELECT Id, UserId__c, Status__c, Previous_Status__c, 
                       Status_Changed_Date__c, Status_Changed_By__c, Status_Changed_By__r.Name,
                       Status_Change_Reason__c, UserId__r.Name, UserId__r.Email,
                       UserId__r.Username, UserId__r.Department, UserId__r.Profile.Name
                FROM BreezyRouter_Member__c
                WHERE BreezyRouter__c = :routerId
                ORDER BY UserId__r.Name ASC
            ];
            
            for (BreezyRouter_Member__c member : members) {
                MemberWrapper wrapper = new MemberWrapper();
                wrapper.id = member.Id;
                wrapper.userId = member.UserId__c;
                wrapper.userName = member.UserId__r.Name;
                wrapper.userEmail = member.UserId__r.Email;
                wrapper.userUsername = member.UserId__r.Username;
                wrapper.department = member.UserId__r.Department;
                wrapper.profileName = member.UserId__r.Profile.Name;
                wrapper.status = member.Status__c;
                wrapper.previousStatus = member.Previous_Status__c;
                wrapper.statusChangedDate = member.Status_Changed_Date__c;
                wrapper.statusChangedBy = member.Status_Changed_By__r != null ? member.Status_Changed_By__r.Name : null;
                wrapper.statusChangeReason = member.Status_Change_Reason__c;
                wrappers.add(wrapper);
            }
            
            return wrappers;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving router members: ' + e.getMessage());
        }
    }
    
    /**
     * @description Update status for a single member with audit trail
     * @param memberId The member ID
     * @param newStatus The new status value
     * @param reason Optional reason for the status change
     * @return Success message
     */
    @AuraEnabled
    public static String updateMemberStatus(String memberId, String newStatus, String reason) {
        try {
            if (String.isBlank(memberId) || String.isBlank(newStatus)) {
                AuraHandledException e = new AuraHandledException('Member ID and status are required');
                e.setMessage('Member ID and status are required');
                throw e;
            }
            
            BreezyRouter_Member__c member = [
                SELECT Id, Status__c, Previous_Status__c
                FROM BreezyRouter_Member__c
                WHERE Id = :memberId
                LIMIT 1
            ];
            
            // Update audit trail fields
            member.Previous_Status__c = member.Status__c;
            member.Status__c = newStatus;
            member.Status_Changed_Date__c = System.now();
            member.Status_Changed_By__c = UserInfo.getUserId();
            member.Status_Change_Reason__c = reason;
            
            update member;
            
            return 'Status updated successfully';
        } catch (AuraHandledException e) {
            throw e;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating member status: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error updating member status: ' + e.getMessage());
        }
    }
    
    /**
     * @description Bulk update status for multiple members
     * @param memberIds List of member IDs
     * @param newStatus The new status value
     * @param reason Optional reason for the status change
     * @return Number of members updated
     */
    @AuraEnabled
    public static Integer bulkUpdateMemberStatus(List<String> memberIds, String newStatus, String reason) {
        try {
            if (memberIds == null || memberIds.isEmpty() || String.isBlank(newStatus)) {
                AuraHandledException e = new AuraHandledException('Member IDs and status are required');
                e.setMessage('Member IDs and status are required');
                throw e;
            }
            
            List<BreezyRouter_Member__c> members = [
                SELECT Id, Status__c, Previous_Status__c
                FROM BreezyRouter_Member__c
                WHERE Id IN :memberIds
            ];
            
            if (members.isEmpty()) {
                AuraHandledException e = new AuraHandledException('No members found with provided IDs');
                e.setMessage('No members found with provided IDs');
                throw e;
            }
            
            // Update all members with audit trail
            Datetime now = System.now();
            String userId = UserInfo.getUserId();
            
            for (BreezyRouter_Member__c member : members) {
                member.Previous_Status__c = member.Status__c;
                member.Status__c = newStatus;
                member.Status_Changed_Date__c = now;
                member.Status_Changed_By__c = userId;
                member.Status_Change_Reason__c = reason;
            }
            
            update members;
            
            return members.size();
        } catch (AuraHandledException e) {
            throw e;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating member statuses: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error updating member statuses: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get status history for members in a router
     * @param routerId The router ID
     * @return List of history records
     */
    @AuraEnabled(cacheable=true)
    public static List<StatusHistoryWrapper> getStatusHistory(String routerId) {
        try {
            if (String.isBlank(routerId)) {
                AuraHandledException e = new AuraHandledException('Router ID is required');
                e.setMessage('Router ID is required');
                throw e;
            }
            
            List<StatusHistoryWrapper> historyList = new List<StatusHistoryWrapper>();
            
            // First, get history from our custom audit fields
            List<BreezyRouter_Member__c> members = [
                SELECT Id, UserId__r.Name, Status__c, Previous_Status__c,
                       Status_Changed_Date__c, Status_Changed_By__r.Name,
                       Status_Change_Reason__c
                FROM BreezyRouter_Member__c
                WHERE BreezyRouter__c = :routerId
                AND Status_Changed_Date__c != null
                ORDER BY Status_Changed_Date__c DESC
                LIMIT 50
            ];
            
            for (BreezyRouter_Member__c member : members) {
                StatusHistoryWrapper history = new StatusHistoryWrapper();
                history.memberName = member.UserId__r.Name;
                history.oldStatus = member.Previous_Status__c;
                history.newStatus = member.Status__c;
                history.changedDate = member.Status_Changed_Date__c;
                history.changedBy = member.Status_Changed_By__r != null ? member.Status_Changed_By__r.Name : '';
                history.reason = member.Status_Change_Reason__c;
                historyList.add(history);
            }
            
            // Also get history from standard field history tracking
            List<BreezyRouter_Member__History> fieldHistory = [
                SELECT ParentId, Field, OldValue, NewValue, CreatedDate, CreatedBy.Name
                FROM BreezyRouter_Member__History
                WHERE Parent.BreezyRouter__c = :routerId
                AND Field = 'Status__c'
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
            
            for (BreezyRouter_Member__History history : fieldHistory) {
                // Check if we already have this record from custom fields
                Boolean alreadyExists = false;
                for (StatusHistoryWrapper existing : historyList) {
                    if (existing.memberName == history.CreatedBy.Name && 
                        existing.changedDate == history.CreatedDate) {
                        alreadyExists = true;
                        break;
                    }
                }
                
                if (!alreadyExists) {
                    StatusHistoryWrapper historyWrapper = new StatusHistoryWrapper();
                    historyWrapper.memberName = history.CreatedBy.Name;
                    historyWrapper.oldStatus = String.valueOf(history.OldValue);
                    historyWrapper.newStatus = String.valueOf(history.NewValue);
                    historyWrapper.changedDate = history.CreatedDate;
                    historyWrapper.changedBy = history.CreatedBy.Name;
                    historyWrapper.reason = 'Status changed via field history';
                    historyList.add(historyWrapper);
                }
            }
            
            // Sort by date descending
            historyList.sort(new StatusHistoryComparator());
            
            return historyList;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving status history: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get status breakdown counts for a router
     * @param routerId The router ID
     * @return Map of status to count
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getMemberStatusCounts(String routerId) {
        try {
            if (String.isBlank(routerId)) {
                AuraHandledException e = new AuraHandledException('Router ID is required');
                e.setMessage('Router ID is required');
                throw e;
            }
            
            Map<String, Integer> statusCounts = new Map<String, Integer>{
                'Active' => 0,
                'PTO' => 0,
                'On Leave' => 0,
                'Other' => 0
            };
            
            List<BreezyRouter_Member__c> members = [
                SELECT Status__c
                FROM BreezyRouter_Member__c
                WHERE BreezyRouter__c = :routerId
            ];
            
            for (BreezyRouter_Member__c member : members) {
                if (statusCounts.containsKey(member.Status__c)) {
                    statusCounts.put(member.Status__c, statusCounts.get(member.Status__c) + 1);
                }
            }
            
            return statusCounts;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving status counts: ' + e.getMessage());
        }
    }
    
    /**
     * @description Wrapper class for status history data
     */
    public class StatusHistoryWrapper {
        @AuraEnabled public String memberName;
        @AuraEnabled public String oldStatus;
        @AuraEnabled public String newStatus;
        @AuraEnabled public Datetime changedDate;
        @AuraEnabled public String changedBy;
        @AuraEnabled public String reason;
    }
    
    /**
     * @description Get comprehensive dashboard statistics
     * @return DashboardStatsWrapper with key metrics
     */
    @AuraEnabled(cacheable=true)
    public static DashboardStatsWrapper getDashboardStats() {
        try {
            DashboardStatsWrapper stats = new DashboardStatsWrapper();
            
            // Total routers count
            stats.totalRouters = [SELECT COUNT() FROM BreezyRouter__c];
            
            // Total members count
            stats.totalMembers = [SELECT COUNT() FROM BreezyRouter_Member__c];
            
            // Active members count
            stats.activeMembers = [SELECT COUNT() FROM BreezyRouter_Member__c WHERE Status__c = 'Active'];
            
            // Inactive members count (PTO, On Leave, Other)
            stats.inactiveMembers = [SELECT COUNT() FROM BreezyRouter_Member__c WHERE Status__c != 'Active'];
            
            // Total routings count (based on Routed_Date__c)
            stats.totalRoutings = [SELECT COUNT() FROM BreezyRouter_Member__c WHERE Routed_Date__c != null];
            
            // Calculate average routings per day (last 30 days)
            Date thirtyDaysAgo = Date.today().addDays(-30);
            Integer routingsLast30Days = [SELECT COUNT() FROM BreezyRouter_Member__c 
                                        WHERE Routed_Date__c >= :thirtyDaysAgo];
            stats.averageRoutingsPerDay = Math.round(routingsLast30Days / 30.0);
            
            return stats;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving dashboard stats: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get router analytics data
     * @param timeRange Number of days to analyze
     * @return List of RouterAnalyticsWrapper
     */
    @AuraEnabled(cacheable=true)
    public static List<RouterAnalyticsWrapper> getRouterAnalytics(String timeRange) {
        try {
            Integer days = Integer.valueOf(timeRange);
            Date startDate = Date.today().addDays(-days);
            
            List<RouterAnalyticsWrapper> analytics = new List<RouterAnalyticsWrapper>();
            
            // Get all routers with their analytics
            List<BreezyRouter__c> routers = [
                SELECT Id, Name, CreatedDate
                FROM BreezyRouter__c
                ORDER BY Name
            ];
            
            for (BreezyRouter__c router : routers) {
                RouterAnalyticsWrapper analyticsItem = new RouterAnalyticsWrapper();
                analyticsItem.routerId = router.Id;
                analyticsItem.routerName = router.Name;
                
                // Count routings in the time range
                analyticsItem.routingCount = [SELECT COUNT() FROM BreezyRouter_Member__c 
                                            WHERE BreezyRouter__c = :router.Id 
                                            AND Routed_Date__c >= :startDate];
                
                // Get last routed date
                List<BreezyRouter_Member__c> lastRoutedMembers = [
                    SELECT Routed_Date__c
                    FROM BreezyRouter_Member__c
                    WHERE BreezyRouter__c = :router.Id
                    AND Routed_Date__c != null
                    ORDER BY Routed_Date__c DESC
                    LIMIT 1
                ];
                
                if (!lastRoutedMembers.isEmpty()) {
                    analyticsItem.lastRoutedDate = lastRoutedMembers[0].Routed_Date__c;
                }
                
                analytics.add(analyticsItem);
            }
            
            // Calculate progress percentages
            Integer maxRoutings = 0;
            for (RouterAnalyticsWrapper item : analytics) {
                if (item.routingCount > maxRoutings) {
                    maxRoutings = item.routingCount;
                }
            }
            
            for (RouterAnalyticsWrapper item : analytics) {
                if (maxRoutings > 0) {
                    Decimal percentage = (item.routingCount * 100.0) / maxRoutings;
                    item.progressStyle = 'width: ' + percentage + '%;';
                } else {
                    item.progressStyle = 'width: 0%;';
                }
            }
            
            return analytics;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving router analytics: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get routing frequency data by day of week
     * @param timeRange Number of days to analyze
     * @return List of RoutingFrequencyWrapper
     */
    @AuraEnabled(cacheable=true)
    public static List<RoutingFrequencyWrapper> getRoutingFrequency(String timeRange) {
        try {
            Integer days = Integer.valueOf(timeRange);
            Date startDate = Date.today().addDays(-days);
            
            List<RoutingFrequencyWrapper> frequency = new List<RoutingFrequencyWrapper>();
            
            // Initialize days of week
            String[] dayNames = new String[]{'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'};
            
            for (Integer i = 0; i < 7; i++) {
                RoutingFrequencyWrapper dayData = new RoutingFrequencyWrapper();
                dayData.dayName = dayNames[i];
                dayData.dayOfWeek = i;
                
                // Count routings for this day of week in the time range
                List<AggregateResult> results = [
                    SELECT COUNT(Id) routingCount
                    FROM BreezyRouter_Member__c
                    WHERE Routed_Date__c >= :startDate
                    AND DAY_IN_WEEK(Routed_Date__c) = :i
                ];
                
                dayData.routingCount = Integer.valueOf(results[0].get('routingCount'));
                frequency.add(dayData);
            }
            
            // Calculate bar styles
            Integer maxCount = 0;
            for (RoutingFrequencyWrapper day : frequency) {
                if (day.routingCount > maxCount) {
                    maxCount = day.routingCount;
                }
            }
            
            for (RoutingFrequencyWrapper day : frequency) {
                if (maxCount > 0) {
                    Decimal percentage = (day.routingCount * 100.0) / maxCount;
                    day.barStyle = 'width: ' + percentage + '%;';
                } else {
                    day.barStyle = 'width: 0%;';
                }
            }
            
            return frequency;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving routing frequency: ' + e.getMessage());
        }
    }
    
    /**
     * @description Comparator for sorting status history by date
     */
    public class StatusHistoryComparator implements Comparator<StatusHistoryWrapper> {
        public Integer compare(StatusHistoryWrapper a, StatusHistoryWrapper b) {
            if (a.changedDate == null && b.changedDate == null) return 0;
            if (a.changedDate == null) return 1;
            if (b.changedDate == null) return -1;
            // Compare dates - newer dates first (descending order)
            if (a.changedDate > b.changedDate) return -1;
            if (a.changedDate < b.changedDate) return 1;
            return 0;
        }
    }
    
    /**
     * @description Wrapper class for dashboard statistics
     */
    public class DashboardStatsWrapper {
        @AuraEnabled public Integer totalRouters;
        @AuraEnabled public Integer totalMembers;
        @AuraEnabled public Integer activeMembers;
        @AuraEnabled public Integer inactiveMembers;
        @AuraEnabled public Integer totalRoutings;
        @AuraEnabled public Integer averageRoutingsPerDay;
    }
    
    /**
     * @description Wrapper class for router analytics
     */
    public class RouterAnalyticsWrapper {
        @AuraEnabled public String routerId;
        @AuraEnabled public String routerName;
        @AuraEnabled public Integer routingCount;
        @AuraEnabled public Datetime lastRoutedDate;
        @AuraEnabled public String progressStyle;
    }
    
    /**
     * @description Wrapper class for routing frequency data
     */
    public class RoutingFrequencyWrapper {
        @AuraEnabled public String dayName;
        @AuraEnabled public Integer dayOfWeek;
        @AuraEnabled public Integer routingCount;
        @AuraEnabled public String barStyle;
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

