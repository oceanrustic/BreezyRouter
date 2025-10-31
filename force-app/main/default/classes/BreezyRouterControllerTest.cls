/**
 * @description Test class for BreezyRouterController
 * Provides comprehensive test coverage for router CRUD operations
 * @author BreezyRouter Team
 * @date 2025
 */
@isTest
private class BreezyRouterControllerTest {
    
    /**
     * @description Test data setup
     */
    @testSetup
    static void setupTestData() {
        // Create test routers
        List<BreezyRouter__c> routers = new List<BreezyRouter__c>();
        
        for (Integer i = 1; i <= 5; i++) {
            routers.add(new BreezyRouter__c(
                Name = 'Test Router ' + i,
                Description__c = 'Description for test router ' + i
            ));
        }
        
        insert routers;
        
        // Create test users (use existing users from org)
        List<User> testUsers = [SELECT Id FROM User WHERE IsActive = true LIMIT 3];
        
        // Create members for first router
        if (!testUsers.isEmpty() && !routers.isEmpty()) {
            List<BreezyRouter_Member__c> members = new List<BreezyRouter_Member__c>();
            
            for (User u : testUsers) {
                members.add(new BreezyRouter_Member__c(
                    BreezyRouter__c = routers[0].Id,
                    UserId__c = u.Id,
                    Status__c = 'Active',
                    Routed_Date__c = System.now(),
                    Routed_Time__c = Time.newInstance(12, 0, 0, 0)
                ));
            }
            
            insert members;
        }
    }
    
    /**
     * @description Test getRouters method
     */
    @isTest
    static void testGetRouters() {
        Test.startTest();
        List<BreezyRouterController.RouterWrapper> routers = BreezyRouterController.getRouters();
        Test.stopTest();
        
        System.assertNotEquals(null, routers, 'Routers should not be null');
        System.assertEquals(5, routers.size(), 'Should return 5 routers');
        
        // Verify first router has members
        BreezyRouterController.RouterWrapper firstRouter = routers[0];
        System.assertEquals('Test Router 1', firstRouter.name, 'Router name should match');
        System.assertEquals(3, firstRouter.totalMembers, 'Should have 3 members');
        System.assertEquals(3, firstRouter.activeMembers, 'Should have 3 active members');
    }
    
    /**
     * @description Test searchRouters method with results
     */
    @isTest
    static void testSearchRoutersWithResults() {
        Test.startTest();
        List<BreezyRouterController.RouterWrapper> routers = 
            BreezyRouterController.searchRouters('Test Router 1');
        Test.stopTest();
        
        System.assertNotEquals(null, routers, 'Search results should not be null');
        System.assertEquals(1, routers.size(), 'Should return 1 matching router');
        System.assertEquals('Test Router 1', routers[0].name, 'Router name should match search');
    }
    
    /**
     * @description Test searchRouters method with no results
     */
    @isTest
    static void testSearchRoutersNoResults() {
        Test.startTest();
        List<BreezyRouterController.RouterWrapper> routers = 
            BreezyRouterController.searchRouters('NonExistent Router');
        Test.stopTest();
        
        System.assertNotEquals(null, routers, 'Search results should not be null');
        System.assertEquals(0, routers.size(), 'Should return no matching routers');
    }
    
    /**
     * @description Test searchRouters with blank term
     */
    @isTest
    static void testSearchRoutersBlankTerm() {
        Test.startTest();
        List<BreezyRouterController.RouterWrapper> routers = 
            BreezyRouterController.searchRouters('');
        Test.stopTest();
        
        System.assertNotEquals(null, routers, 'Should return all routers for blank search');
        System.assertEquals(5, routers.size(), 'Should return all 5 routers');
    }
    
    /**
     * @description Test createRouter method success
     */
    @isTest
    static void testCreateRouterSuccess() {
        Test.startTest();
        String routerId = BreezyRouterController.createRouter('New Test Router', 'New Description');
        Test.stopTest();
        
        System.assertNotEquals(null, routerId, 'Router ID should not be null');
        
        BreezyRouter__c router = [SELECT Id, Name, Description__c FROM BreezyRouter__c WHERE Id = :routerId];
        System.assertEquals('New Test Router', router.Name, 'Router name should match');
        System.assertEquals('New Description', router.Description__c, 'Description should match');
    }
    
    /**
     * @description Test createRouter with duplicate name
     */
    @isTest
    static void testCreateRouterDuplicateName() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.createRouter('Test Router 1', 'Duplicate');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('already exists'), 
                         'Should throw error for duplicate name');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for duplicate name');
    }
    
    /**
     * @description Test createRouter with blank name
     */
    @isTest
    static void testCreateRouterBlankName() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.createRouter('', 'Description');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('required'), 
                         'Should throw error for blank name');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for blank name');
    }
    
    /**
     * @description Test updateRouter method success
     */
    @isTest
    static void testUpdateRouterSuccess() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        
        Test.startTest();
        BreezyRouterController.updateRouter(router.Id, 'Updated Router Name', 'Updated Description');
        Test.stopTest();
        
        BreezyRouter__c updatedRouter = [SELECT Name, Description__c FROM BreezyRouter__c WHERE Id = :router.Id];
        System.assertEquals('Updated Router Name', updatedRouter.Name, 'Name should be updated');
        System.assertEquals('Updated Description', updatedRouter.Description__c, 'Description should be updated');
    }
    
    /**
     * @description Test updateRouter with duplicate name
     */
    @isTest
    static void testUpdateRouterDuplicateName() {
        List<BreezyRouter__c> routers = [SELECT Id FROM BreezyRouter__c LIMIT 2];
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.updateRouter(routers[1].Id, 'Test Router 1', 'Description');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('already exists'), 
                         'Should throw error for duplicate name');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for duplicate name');
    }
    
    /**
     * @description Test updateRouter with blank name
     */
    @isTest
    static void testUpdateRouterBlankName() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c LIMIT 1];
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.updateRouter(router.Id, '', 'Description');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('required'), 
                         'Should throw error for blank name');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for blank name');
    }
    
    /**
     * @description Test deleteRouter without deleting members
     */
    @isTest
    static void testDeleteRouterWithoutMembers() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 2' LIMIT 1];
        
        Test.startTest();
        BreezyRouterController.deleteRouter(router.Id, false);
        Test.stopTest();
        
        List<BreezyRouter__c> deletedRouters = [SELECT Id FROM BreezyRouter__c WHERE Id = :router.Id];
        System.assertEquals(0, deletedRouters.size(), 'Router should be deleted');
    }
    
    /**
     * @description Test deleteRouter with deleting members
     */
    @isTest
    static void testDeleteRouterWithMembers() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        Integer memberCountBefore = [SELECT COUNT() FROM BreezyRouter_Member__c WHERE BreezyRouter__c = :router.Id];
        
        System.assertEquals(3, memberCountBefore, 'Should have 3 members before deletion');
        
        Test.startTest();
        BreezyRouterController.deleteRouter(router.Id, true);
        Test.stopTest();
        
        List<BreezyRouter__c> deletedRouters = [SELECT Id FROM BreezyRouter__c WHERE Id = :router.Id];
        System.assertEquals(0, deletedRouters.size(), 'Router should be deleted');
        
        Integer memberCountAfter = [SELECT COUNT() FROM BreezyRouter_Member__c WHERE BreezyRouter__c = :router.Id];
        System.assertEquals(0, memberCountAfter, 'All members should be deleted');
    }
    
    /**
     * @description Test deleteRouter with blank ID
     */
    @isTest
    static void testDeleteRouterBlankId() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.deleteRouter('', false);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('required'), 
                         'Should throw error for blank ID');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for blank ID');
    }
    
    /**
     * @description Test getRouterDetails method
     */
    @isTest
    static void testGetRouterDetails() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        
        Test.startTest();
        BreezyRouterController.RouterDetailWrapper details = 
            BreezyRouterController.getRouterDetails(router.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, details, 'Details should not be null');
        System.assertEquals('Test Router 1', details.name, 'Router name should match');
        System.assertEquals(3, details.members.size(), 'Should have 3 members');
        
        // Verify member details
        BreezyRouterController.MemberWrapper member = details.members[0];
        System.assertNotEquals(null, member.userId, 'Member user ID should not be null');
        System.assertNotEquals(null, member.userName, 'Member user name should not be null');
        System.assertEquals('Active', member.status, 'Member status should be Active');
    }
    
    /**
     * @description Test getRouterDetails with invalid ID
     */
    @isTest
    static void testGetRouterDetailsInvalidId() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.getRouterDetails('001000000000000');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('not found') || e.getMessage().contains('Error'), 
                         'Should throw error for invalid ID');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for invalid ID');
    }
    
    /**
     * @description Test getRouterDetails with blank ID
     */
    @isTest
    static void testGetRouterDetailsBlankId() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.getRouterDetails('');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('required'), 
                         'Should throw error for blank ID');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown for blank ID');
    }
    
    /**
     * @description Test wrapper classes
     */
    @isTest
    static void testWrapperClasses() {
        // Test RouterWrapper
        BreezyRouterController.RouterWrapper routerWrapper = new BreezyRouterController.RouterWrapper();
        routerWrapper.id = 'testId';
        routerWrapper.name = 'Test Name';
        routerWrapper.description = 'Test Description';
        routerWrapper.totalMembers = 10;
        routerWrapper.activeMembers = 8;
        
        System.assertEquals('testId', routerWrapper.id, 'Wrapper ID should match');
        System.assertEquals('Test Name', routerWrapper.name, 'Wrapper name should match');
        System.assertEquals(10, routerWrapper.totalMembers, 'Total members should match');
        
        // Test RouterDetailWrapper
        BreezyRouterController.RouterDetailWrapper detailWrapper = new BreezyRouterController.RouterDetailWrapper();
        detailWrapper.id = 'testId';
        detailWrapper.name = 'Test Name';
        detailWrapper.members = new List<BreezyRouterController.MemberWrapper>();
        
        System.assertEquals('testId', detailWrapper.id, 'Detail wrapper ID should match');
        System.assertNotEquals(null, detailWrapper.members, 'Members list should be initialized');
        
        // Test MemberWrapper
        BreezyRouterController.MemberWrapper memberWrapper = new BreezyRouterController.MemberWrapper();
        memberWrapper.id = 'memberId';
        memberWrapper.userId = 'userId';
        memberWrapper.userName = 'Test User';
        memberWrapper.status = 'Active';
        
        System.assertEquals('memberId', memberWrapper.id, 'Member wrapper ID should match');
        System.assertEquals('Active', memberWrapper.status, 'Member status should match');
    }
    
    // ==================== USER ASSIGNMENT TESTS ====================
    
    /**
     * @description Test searchUsers method
     */
    @isTest
    static void testSearchUsers() {
        Test.startTest();
        List<BreezyRouterController.UserWrapper> users = 
            BreezyRouterController.searchUsers('', '', '', '');
        Test.stopTest();
        
        System.assertNotEquals(null, users, 'Users should not be null');
        System.assert(users.size() > 0, 'Should return at least one user');
    }
    
    /**
     * @description Test searchUsers with search term
     */
    @isTest
    static void testSearchUsersWithTerm() {
        User testUser = [SELECT Name FROM User WHERE IsActive = true LIMIT 1];
        
        Test.startTest();
        List<BreezyRouterController.UserWrapper> users = 
            BreezyRouterController.searchUsers(testUser.Name, '', '', '');
        Test.stopTest();
        
        System.assertNotEquals(null, users, 'Users should not be null');
        System.assert(users.size() > 0, 'Should find matching user');
    }
    
    /**
     * @description Test getRouterMemberUserIds method
     */
    @isTest
    static void testGetRouterMemberUserIds() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        
        Test.startTest();
        List<String> userIds = BreezyRouterController.getRouterMemberUserIds(router.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, userIds, 'User IDs should not be null');
        System.assertEquals(3, userIds.size(), 'Should return 3 user IDs');
    }
    
    /**
     * @description Test getRouterMemberUserIds with blank ID
     */
    @isTest
    static void testGetRouterMemberUserIdsBlankId() {
        Test.startTest();
        List<String> userIds = BreezyRouterController.getRouterMemberUserIds('');
        Test.stopTest();
        
        System.assertNotEquals(null, userIds, 'Should return empty list');
        System.assertEquals(0, userIds.size(), 'Should return empty list for blank ID');
    }
    
    /**
     * @description Test addUsersToRouter method
     */
    @isTest
    static void testAddUsersToRouter() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 2' LIMIT 1];
        List<User> testUsers = [SELECT Id FROM User WHERE IsActive = true LIMIT 2];
        List<String> userIds = new List<String>();
        for (User u : testUsers) {
            userIds.add(u.Id);
        }
        
        Test.startTest();
        Integer count = BreezyRouterController.addUsersToRouter(router.Id, userIds);
        Test.stopTest();
        
        System.assertEquals(2, count, 'Should add 2 users');
        
        List<BreezyRouter_Member__c> members = [
            SELECT Id FROM BreezyRouter_Member__c WHERE BreezyRouter__c = :router.Id
        ];
        System.assertEquals(2, members.size(), 'Router should have 2 members');
    }
    
    /**
     * @description Test addUsersToRouter prevents duplicates
     */
    @isTest
    static void testAddUsersToRouterDuplicates() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        List<BreezyRouter_Member__c> existingMembers = [
            SELECT UserId__c FROM BreezyRouter_Member__c WHERE BreezyRouter__c = :router.Id LIMIT 1
        ];
        
        List<String> userIds = new List<String>{ existingMembers[0].UserId__c };
        
        Test.startTest();
        Integer count = BreezyRouterController.addUsersToRouter(router.Id, userIds);
        Test.stopTest();
        
        System.assertEquals(0, count, 'Should not add duplicate user');
    }
    
    /**
     * @description Test addUsersToRouter with blank parameters
     */
    @isTest
    static void testAddUsersToRouterBlankParams() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.addUsersToRouter('', new List<String>());
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('required'), 'Should throw error for blank parameters');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown');
    }
    
    /**
     * @description Test removeUsersFromRouter method
     */
    @isTest
    static void testRemoveUsersFromRouter() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        List<BreezyRouter_Member__c> members = [
            SELECT UserId__c FROM BreezyRouter_Member__c WHERE BreezyRouter__c = :router.Id LIMIT 2
        ];
        
        List<String> userIds = new List<String>();
        for (BreezyRouter_Member__c member : members) {
            userIds.add(member.UserId__c);
        }
        
        Test.startTest();
        Integer count = BreezyRouterController.removeUsersFromRouter(router.Id, userIds);
        Test.stopTest();
        
        System.assertEquals(2, count, 'Should remove 2 users');
        
        List<BreezyRouter_Member__c> remainingMembers = [
            SELECT Id FROM BreezyRouter_Member__c WHERE BreezyRouter__c = :router.Id
        ];
        System.assertEquals(1, remainingMembers.size(), 'Router should have 1 member left');
    }
    
    /**
     * @description Test removeUsersFromRouter with blank parameters
     */
    @isTest
    static void testRemoveUsersFromRouterBlankParams() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            BreezyRouterController.removeUsersFromRouter('', new List<String>());
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('required'), 'Should throw error for blank parameters');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown');
    }
    
    /**
     * @description Test getUserRoles method
     */
    @isTest
    static void testGetUserRoles() {
        Test.startTest();
        List<BreezyRouterController.PicklistOption> roles = BreezyRouterController.getUserRoles();
        Test.stopTest();
        
        System.assertNotEquals(null, roles, 'Roles should not be null');
        // May be empty if no roles exist in org
    }
    
    /**
     * @description Test getUserProfiles method
     */
    @isTest
    static void testGetUserProfiles() {
        Test.startTest();
        List<BreezyRouterController.PicklistOption> profiles = BreezyRouterController.getUserProfiles();
        Test.stopTest();
        
        System.assertNotEquals(null, profiles, 'Profiles should not be null');
        System.assert(profiles.size() > 0, 'Should return at least one profile');
    }
    
    /**
     * @description Test UserWrapper class
     */
    @isTest
    static void testUserWrapper() {
        BreezyRouterController.UserWrapper wrapper = new BreezyRouterController.UserWrapper();
        wrapper.id = 'userId';
        wrapper.name = 'Test User';
        wrapper.email = 'test@test.com';
        wrapper.username = 'testuser@test.com';
        wrapper.isActive = true;
        wrapper.department = 'IT';
        wrapper.profileName = 'System Administrator';
        wrapper.roleName = 'CEO';
        
        System.assertEquals('userId', wrapper.id, 'User ID should match');
        System.assertEquals('Test User', wrapper.name, 'User name should match');
        System.assertEquals('test@test.com', wrapper.email, 'User email should match');
    }
    
    /**
     * @description Test PicklistOption class
     */
    @isTest
    static void testPicklistOption() {
        BreezyRouterController.PicklistOption option = 
            new BreezyRouterController.PicklistOption('Test Label', 'TestValue');
        
        System.assertEquals('Test Label', option.label, 'Label should match');
        System.assertEquals('TestValue', option.value, 'Value should match');
    }
    
    // ============================================
    // STATUS MANAGEMENT TESTS (Sprint 3 Week 5)
    // ============================================
    
    /**
     * @description Test getRouterMembers method
     */
    @isTest
    static void testGetRouterMembers() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        
        Test.startTest();
        List<BreezyRouterController.MemberWrapper> members = 
            BreezyRouterController.getRouterMembers(router.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, members, 'Members should not be null');
        System.assertEquals(3, members.size(), 'Should return 3 members');
        System.assertEquals('Active', members[0].status, 'Member status should be Active');
    }
    
    /**
     * @description Test getRouterMembers with blank router ID
     */
    @isTest
    static void testGetRouterMembersBlankId() {
        Test.startTest();
        try {
            BreezyRouterController.getRouterMembers('');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Router ID is required'), 'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateMemberStatus method
     */
    @isTest
    static void testUpdateMemberStatus() {
        BreezyRouter_Member__c member = [SELECT Id, Status__c FROM BreezyRouter_Member__c LIMIT 1];
        System.assertEquals('Active', member.Status__c, 'Initial status should be Active');
        
        Test.startTest();
        String result = BreezyRouterController.updateMemberStatus(
            member.Id, 
            'PTO', 
            'Going on vacation'
        );
        Test.stopTest();
        
        System.assertEquals('Status updated successfully', result, 'Should return success message');
        
        // Verify status was updated
        member = [SELECT Id, Status__c, Previous_Status__c, Status_Change_Reason__c 
                  FROM BreezyRouter_Member__c WHERE Id = :member.Id];
        System.assertEquals('PTO', member.Status__c, 'Status should be updated to PTO');
        System.assertEquals('Active', member.Previous_Status__c, 'Previous status should be Active');
        System.assertEquals('Going on vacation', member.Status_Change_Reason__c, 'Reason should be saved');
    }
    
    /**
     * @description Test updateMemberStatus with blank member ID
     */
    @isTest
    static void testUpdateMemberStatusBlankId() {
        Test.startTest();
        try {
            BreezyRouterController.updateMemberStatus('', 'PTO', 'Test');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Member ID and status are required'), 
                         'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test updateMemberStatus with blank status
     */
    @isTest
    static void testUpdateMemberStatusBlankStatus() {
        BreezyRouter_Member__c member = [SELECT Id FROM BreezyRouter_Member__c LIMIT 1];
        
        Test.startTest();
        try {
            BreezyRouterController.updateMemberStatus(member.Id, '', 'Test');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Member ID and status are required'), 
                         'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulkUpdateMemberStatus method
     */
    @isTest
    static void testBulkUpdateMemberStatus() {
        List<BreezyRouter_Member__c> members = [SELECT Id FROM BreezyRouter_Member__c];
        List<String> memberIds = new List<String>();
        for (BreezyRouter_Member__c member : members) {
            memberIds.add(member.Id);
        }
        
        Test.startTest();
        Integer count = BreezyRouterController.bulkUpdateMemberStatus(
            memberIds, 
            'On Leave', 
            'Team outing'
        );
        Test.stopTest();
        
        System.assertEquals(3, count, 'Should update 3 members');
        
        // Verify all members were updated
        List<BreezyRouter_Member__c> updatedMembers = 
            [SELECT Status__c, Previous_Status__c, Status_Change_Reason__c 
             FROM BreezyRouter_Member__c WHERE Id IN :memberIds];
        
        for (BreezyRouter_Member__c member : updatedMembers) {
            System.assertEquals('On Leave', member.Status__c, 'Status should be On Leave');
            System.assertEquals('Active', member.Previous_Status__c, 'Previous status should be Active');
            System.assertEquals('Team outing', member.Status_Change_Reason__c, 'Reason should be saved');
        }
    }
    
    /**
     * @description Test bulkUpdateMemberStatus with empty list
     */
    @isTest
    static void testBulkUpdateMemberStatusEmptyList() {
        Test.startTest();
        try {
            BreezyRouterController.bulkUpdateMemberStatus(new List<String>(), 'PTO', 'Test');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Member IDs and status are required'), 
                         'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulkUpdateMemberStatus with blank status
     */
    @isTest
    static void testBulkUpdateMemberStatusBlankStatus() {
        List<String> memberIds = new List<String>{'testId'};
        
        Test.startTest();
        try {
            BreezyRouterController.bulkUpdateMemberStatus(memberIds, '', 'Test');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Member IDs and status are required'), 
                         'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test bulkUpdateMemberStatus with invalid IDs
     */
    @isTest
    static void testBulkUpdateMemberStatusInvalidIds() {
        List<String> memberIds = new List<String>{'invalidId123'};
        
        Test.startTest();
        try {
            BreezyRouterController.bulkUpdateMemberStatus(memberIds, 'PTO', 'Test');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No members found'), 
                         'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getStatusHistory method
     */
    @isTest
    static void testGetStatusHistory() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        BreezyRouter_Member__c member = [SELECT Id FROM BreezyRouter_Member__c LIMIT 1];
        
        // Update a member status to create history
        BreezyRouterController.updateMemberStatus(member.Id, 'PTO', 'Test history');
        
        Test.startTest();
        List<BreezyRouterController.StatusHistoryWrapper> history = 
            BreezyRouterController.getStatusHistory(router.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, history, 'History should not be null');
        System.assertEquals(1, history.size(), 'Should return 1 history record');
        System.assertEquals('Active', history[0].oldStatus, 'Old status should be Active');
        System.assertEquals('PTO', history[0].newStatus, 'New status should be PTO');
        System.assertEquals('Test history', history[0].reason, 'Reason should match');
    }
    
    /**
     * @description Test getStatusHistory with blank router ID
     */
    @isTest
    static void testGetStatusHistoryBlankId() {
        Test.startTest();
        try {
            BreezyRouterController.getStatusHistory('');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Router ID is required'), 
                         'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getMemberStatusCounts method
     */
    @isTest
    static void testGetMemberStatusCounts() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        
        Test.startTest();
        Map<String, Integer> statusCounts = 
            BreezyRouterController.getMemberStatusCounts(router.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, statusCounts, 'Status counts should not be null');
        System.assertEquals(3, statusCounts.get('Active'), 'Should have 3 active members');
        System.assertEquals(0, statusCounts.get('PTO'), 'Should have 0 PTO members');
        System.assertEquals(0, statusCounts.get('On Leave'), 'Should have 0 On Leave members');
        System.assertEquals(0, statusCounts.get('Other'), 'Should have 0 Other members');
    }
    
    /**
     * @description Test getMemberStatusCounts with blank router ID
     */
    @isTest
    static void testGetMemberStatusCountsBlankId() {
        Test.startTest();
        try {
            BreezyRouterController.getMemberStatusCounts('');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Router ID is required'), 
                         'Should throw proper error');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getMemberStatusCounts with mixed statuses
     */
    @isTest
    static void testGetMemberStatusCountsMixed() {
        BreezyRouter__c router = [SELECT Id FROM BreezyRouter__c WHERE Name = 'Test Router 1' LIMIT 1];
        List<BreezyRouter_Member__c> members = [SELECT Id FROM BreezyRouter_Member__c LIMIT 3];
        
        // Update members to different statuses
        if (members.size() >= 3) {
            BreezyRouterController.updateMemberStatus(members[0].Id, 'PTO', 'Test');
            BreezyRouterController.updateMemberStatus(members[1].Id, 'On Leave', 'Test');
            // Keep members[2] as Active
        }
        
        Test.startTest();
        Map<String, Integer> statusCounts = 
            BreezyRouterController.getMemberStatusCounts(router.Id);
        Test.stopTest();
        
        System.assertEquals(1, statusCounts.get('Active'), 'Should have 1 active member');
        System.assertEquals(1, statusCounts.get('PTO'), 'Should have 1 PTO member');
        System.assertEquals(1, statusCounts.get('On Leave'), 'Should have 1 On Leave member');
    }
    
    /**
     * @description Test MemberWrapper class
     */
    @isTest
    static void testMemberWrapper() {
        BreezyRouterController.MemberWrapper wrapper = new BreezyRouterController.MemberWrapper();
        wrapper.id = 'memberId';
        wrapper.userId = 'userId';
        wrapper.userName = 'Test User';
        wrapper.userEmail = 'test@test.com';
        wrapper.userUsername = 'testuser@test.com';
        wrapper.department = 'IT';
        wrapper.profileName = 'System Administrator';
        wrapper.status = 'Active';
        wrapper.previousStatus = 'PTO';
        wrapper.statusChangedDate = System.now();
        wrapper.statusChangedBy = UserInfo.getUserId();
        wrapper.statusChangeReason = 'Back from vacation';
        
        System.assertEquals('memberId', wrapper.id, 'Member ID should match');
        System.assertEquals('Test User', wrapper.userName, 'User name should match');
        System.assertEquals('Active', wrapper.status, 'Status should match');
        System.assertEquals('PTO', wrapper.previousStatus, 'Previous status should match');
        System.assertEquals('Back from vacation', wrapper.statusChangeReason, 'Reason should match');
    }
    
    /**
     * @description Test StatusHistoryWrapper class
     */
    @isTest
    static void testStatusHistoryWrapper() {
        BreezyRouterController.StatusHistoryWrapper wrapper = 
            new BreezyRouterController.StatusHistoryWrapper();
        wrapper.memberName = 'Test User';
        wrapper.oldStatus = 'Active';
        wrapper.newStatus = 'PTO';
        wrapper.changedDate = System.now();
        wrapper.changedBy = 'Admin User';
        wrapper.reason = 'Going on vacation';
        
        System.assertEquals('Test User', wrapper.memberName, 'Member name should match');
        System.assertEquals('Active', wrapper.oldStatus, 'Old status should match');
        System.assertEquals('PTO', wrapper.newStatus, 'New status should match');
        System.assertEquals('Admin User', wrapper.changedBy, 'Changed by should match');
        System.assertEquals('Going on vacation', wrapper.reason, 'Reason should match');
    }
    
    // ==================== DASHBOARD TESTS ====================
    
    /**
     * @description Test getDashboardStats method
     */
    @isTest
    static void testGetDashboardStats() {
        Test.startTest();
        BreezyRouterController.DashboardStatsWrapper stats = 
            BreezyRouterController.getDashboardStats();
        Test.stopTest();
        
        System.assertNotEquals(null, stats, 'Stats should not be null');
        System.assert(stats.totalRouters >= 5, 'Should have at least 5 routers from test setup');
        System.assert(stats.totalMembers >= 3, 'Should have at least 3 members from test setup');
        System.assert(stats.activeMembers >= 0, 'Active members count should be valid');
        System.assert(stats.inactiveMembers >= 0, 'Inactive members count should be valid');
        System.assert(stats.totalRoutings >= 0, 'Total routings should be valid');
        System.assert(stats.averageRoutingsPerDay >= 0, 'Average routings per day should be valid');
    }
    
    /**
     * @description Test getRouterAnalytics method with different time ranges
     */
    @isTest
    static void testGetRouterAnalytics() {
        Test.startTest();
        List<BreezyRouterController.RouterAnalyticsWrapper> analytics30 = 
            BreezyRouterController.getRouterAnalytics('30');
        List<BreezyRouterController.RouterAnalyticsWrapper> analytics90 = 
            BreezyRouterController.getRouterAnalytics('90');
        List<BreezyRouterController.RouterAnalyticsWrapper> analytics365 = 
            BreezyRouterController.getRouterAnalytics('365');
        Test.stopTest();
        
        System.assertNotEquals(null, analytics30, 'Analytics for 30 days should not be null');
        System.assert(analytics30.size() >= 5, 'Should have analytics for all routers');
        
        // Verify each router has analytics
        for (BreezyRouterController.RouterAnalyticsWrapper router : analytics30) {
            System.assertNotEquals(null, router.routerId, 'Router ID should not be null');
            System.assertNotEquals(null, router.routerName, 'Router name should not be null');
            System.assert(router.routingCount >= 0, 'Routing count should be valid');
        }
        
        // Test different time ranges return data
        System.assertNotEquals(null, analytics90, 'Analytics for 90 days should not be null');
        System.assertNotEquals(null, analytics365, 'Analytics for 365 days should not be null');
    }
    
    /**
     * @description Test getRouterAnalytics with invalid time range
     */
    @isTest
    static void testGetRouterAnalyticsInvalidTimeRange() {
        Test.startTest();
        try {
            List<BreezyRouterController.RouterAnalyticsWrapper> analytics = 
                BreezyRouterController.getRouterAnalytics('invalid');
            System.assert(false, 'Should have thrown exception for invalid time range');
        } catch (Exception e) {
            System.assert(true, 'Expected exception for invalid time range');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test getRoutingFrequency method
     */
    @isTest
    static void testGetRoutingFrequency() {
        Test.startTest();
        List<BreezyRouterController.RoutingFrequencyWrapper> frequency7 = 
            BreezyRouterController.getRoutingFrequency('7');
        List<BreezyRouterController.RoutingFrequencyWrapper> frequency30 = 
            BreezyRouterController.getRoutingFrequency('30');
        Test.stopTest();
        
        System.assertNotEquals(null, frequency7, 'Frequency for 7 days should not be null');
        System.assertEquals(7, frequency7.size(), 'Should return 7 days of week');
        
        // Verify all days of week are present
        Set<String> dayNames = new Set<String>();
        for (BreezyRouterController.RoutingFrequencyWrapper day : frequency7) {
            System.assertNotEquals(null, day.dayName, 'Day name should not be null');
            System.assert(day.dayOfWeek >= 1 && day.dayOfWeek <= 7, 'Day of week should be 1-7');
            System.assert(day.routingCount >= 0, 'Routing count should be valid');
            System.assertNotEquals(null, day.barStyle, 'Bar style should not be null');
            dayNames.add(day.dayName);
        }
        
        // Verify all 7 days are present
        System.assertEquals(7, dayNames.size(), 'Should have all 7 days of the week');
        
        // Test 30 days range
        System.assertNotEquals(null, frequency30, 'Frequency for 30 days should not be null');
        System.assertEquals(7, frequency30.size(), 'Should still return 7 days of week');
    }
    
    /**
     * @description Test getRoutingFrequency with invalid time range
     */
    @isTest
    static void testGetRoutingFrequencyInvalidTimeRange() {
        Test.startTest();
        try {
            List<BreezyRouterController.RoutingFrequencyWrapper> frequency = 
                BreezyRouterController.getRoutingFrequency('invalid');
            System.assert(false, 'Should have thrown exception for invalid time range');
        } catch (Exception e) {
            System.assert(true, 'Expected exception for invalid time range');
        }
        Test.stopTest();
    }
    
    /**
     * @description Test DashboardStatsWrapper class
     */
    @isTest
    static void testDashboardStatsWrapper() {
        BreezyRouterController.DashboardStatsWrapper wrapper = 
            new BreezyRouterController.DashboardStatsWrapper();
        wrapper.totalRouters = 10;
        wrapper.totalMembers = 50;
        wrapper.activeMembers = 40;
        wrapper.inactiveMembers = 10;
        wrapper.totalRoutings = 100;
        wrapper.averageRoutingsPerDay = 5;
        
        System.assertEquals(10, wrapper.totalRouters, 'Total routers should match');
        System.assertEquals(50, wrapper.totalMembers, 'Total members should match');
        System.assertEquals(40, wrapper.activeMembers, 'Active members should match');
        System.assertEquals(10, wrapper.inactiveMembers, 'Inactive members should match');
        System.assertEquals(100, wrapper.totalRoutings, 'Total routings should match');
        System.assertEquals(5, wrapper.averageRoutingsPerDay, 'Average routings per day should match');
    }
    
    /**
     * @description Test RouterAnalyticsWrapper class
     */
    @isTest
    static void testRouterAnalyticsWrapper() {
        BreezyRouterController.RouterAnalyticsWrapper wrapper = 
            new BreezyRouterController.RouterAnalyticsWrapper();
        wrapper.routerId = 'router123';
        wrapper.routerName = 'Test Router';
        wrapper.routingCount = 25;
        wrapper.lastRoutedDate = System.now();
        wrapper.progressStyle = 'width: 50%;';
        
        System.assertEquals('router123', wrapper.routerId, 'Router ID should match');
        System.assertEquals('Test Router', wrapper.routerName, 'Router name should match');
        System.assertEquals(25, wrapper.routingCount, 'Routing count should match');
        System.assertNotEquals(null, wrapper.lastRoutedDate, 'Last routed date should not be null');
        System.assertEquals('width: 50%;', wrapper.progressStyle, 'Progress style should match');
    }
    
    /**
     * @description Test RoutingFrequencyWrapper class
     */
    @isTest
    static void testRoutingFrequencyWrapper() {
        BreezyRouterController.RoutingFrequencyWrapper wrapper = 
            new BreezyRouterController.RoutingFrequencyWrapper();
        wrapper.dayName = 'Wednesday';
        wrapper.dayOfWeek = 4;
        wrapper.routingCount = 10;
        wrapper.barStyle = 'width: 100%;';
        
        System.assertEquals('Wednesday', wrapper.dayName, 'Day name should match');
        System.assertEquals(4, wrapper.dayOfWeek, 'Day of week should match');
        System.assertEquals(10, wrapper.routingCount, 'Routing count should match');
        System.assertEquals('width: 100%;', wrapper.barStyle, 'Bar style should match');
    }
}

