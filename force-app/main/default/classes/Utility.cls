public class Utility {
    public static Boolean runningInASandbox {
        get {
            if (runningInASandbox == null) {
                System.Domain domain = System.DomainParser.parse(URL.getOrgDomainUrl());
                runningInASandbox = domain.getSandboxName() != null;
            }
            return runningInASandbox;
        }
        private set;
    }
}