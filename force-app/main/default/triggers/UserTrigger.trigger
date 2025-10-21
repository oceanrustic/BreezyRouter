trigger UserTrigger on User (before update, after update, before insert,
                                   after insert, after delete) {
    new UserHandler().run();
}