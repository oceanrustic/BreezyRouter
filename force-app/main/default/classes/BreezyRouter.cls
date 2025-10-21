public class BreezyRouter {

    @InvocableMethod(label='Get Next User in BreezyRouter')
    public static List<Id> getNextUserInBreezyRouter(List<String> routerNames) {
        List<Id> nextUserIds = new List<Id>();

        if (routerNames != null && !routerNames.isEmpty()) {
            for (String routerName : routerNames) {
                Id nextUserId = getNextUserByRouterName(routerName);
                if (nextUserId != null) {
                    nextUserIds.add(nextUserId);
                }
            }
        }

        return nextUserIds;
    }

    private static Id getNextUserByRouterName(String routerName) {
        Id userId = null;
        
        List<BreezyRouter_Member__c> routerMembers = [SELECT UserId__c, Routed_Date__c, Routed_Time__c
                                            FROM BreezyRouter_Member__c
                                            WHERE Status__c = 'Active'
                                            AND BreezyRouter__r.Name = :routerName
                                            ORDER BY Routed_Date__c ASC, Routed_Time__c ASC
                                            LIMIT 1];
        
        if (!routerMembers.isEmpty()) {
            userId = routerMembers[0].UserId__c;
            
            Datetime now = Datetime.now();
            Time currentTime = now.time();
            routerMembers[0].Routed_Date__c = now ;
            routerMembers[0].Routed_Time__c = currentTime ;
            update routerMembers;
        }
        
        return userId;
    }
}