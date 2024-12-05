@NamespaceAccessible
public with sharing class SyntilioException extends Exception {
    
    @NamespaceAccessible
    public static void throwError(String message) {
        throw new SyntilioException(message);
    }
}
