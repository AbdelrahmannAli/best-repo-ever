/*************************************************************************   
@description An interface for defining Credentials Provider like OAuth2, Basic Auth, etc..*/
@namespaceAccessible
public interface ICredentialsProvider {
    String getHeader();
}