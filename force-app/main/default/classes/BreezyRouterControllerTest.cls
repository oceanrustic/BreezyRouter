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
}

