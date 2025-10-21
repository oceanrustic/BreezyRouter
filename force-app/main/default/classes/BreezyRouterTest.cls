@isTest
private class BreezyRouterTest {
    @isTest static void testGetNextUserInBreezyRouter() {
        BreezyRouter__c routerRecord = new BreezyRouter__c(Name = 'TestQueue');
        insert routerRecord;

        BreezyRouter_Member__c routerMember = new BreezyRouter_Member__c(
            UserId__c = UserInfo.getUserId(),
            Status__c = 'Active',
            BreezyRouter__c = routerRecord.Id
        );
        insert routerMember;

        List<Id> nextUserIds = BreezyRouter.getNextUserInBreezyRouter(new List<String>{ 'TestQueue' });

        System.assertEquals(1, nextUserIds.size(), 'Found User in Router');
    }
}