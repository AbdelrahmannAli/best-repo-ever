/*************************************************************************   
@description Reusable http client class for all callouts. It can recieves two parameters, the named credentials api name, or object authentication credential type.*/
@namespaceAccessible
public with sharing virtual class HttpClient {
    
    @NamespaceAccessible public ICredentialsProvider credentials { get; set; }
    @NamespaceAccessible public String salesforceNamedCredentialsApiUrl  { get; set; }
    
    /*************************************************************************   
@description A constructor for the HttpClient class with empty params*/
@NamespaceAccessible
    public HttpClient(){
        this(null, null);
    }
    /*************************************************************************   
@description A constructor for the HttpClient class with the api name that should be saved in salesforce named credentials*/
    @NamespaceAccessible
    public HttpClient( String  salesforceNamedCredentialsApiName){
        this(null, salesforceNamedCredentialsApiName);
    }
    
    @NamespaceAccessible
    public HttpClient(ICredentialsProvider credentials) {
        this(credentials, null);
    }
    
    /*************************************************************************   
@description A method that sets the credentials and salesforceNamedCredentialsApiName to be able to authenticate any callout made further*/
    @NamespaceAccessible
    public HttpClient(ICredentialsProvider credentials, String  salesforceNamedCredentialsApiName) {
        this.credentials = credentials;
       	this.salesforceNamedCredentialsApiUrl = salesforceNamedCredentialsApiName != null? CheckEnvironmentType.checkCustomMetadata(salesforceNamedCredentialsApiName) : '';
    }
    
    /*************************************************************************   
@description A method that initiates a get callout and returns the http response
-> It can recieves three parameters, rest of endpoint url, queryParameters and headers if available*/
    @NamespaceAccessible
    public HttpResponse get(String endpoint, String queryParameters, Map<String, String> headers) {
        return callout(endpoint, queryParameters,'GET', headers);
    }
    
    /*************************************************************************   
@description A method that initiates a post callout and returns the http response
-> It can recieves three parameters, rest of endpoint url, payload and extra headers if available*/
    @NamespaceAccessible
    public HttpResponse post(String endpoint, String payload, Map<String, String> headers) {
        return callout(endpoint, payload, 'POST', headers);
    }
    
    /*************************************************************************   
@description A method that initiates a put callout and returns the http response
-> It can recieves three parameters, rest of endpoint url, payload and extra headers if available*/
    @NamespaceAccessible
    public HttpResponse put(String endpoint, String payload, Map<String, String> headers) {
        return callout(endpoint, payload, 'PUT', headers);
    }
    
    /*************************************************************************   
@description A method that initiates a patch callout and returns the http response
-> It can recieves three parameters, rest of endpoint url, payload and extra headers if available*/
    @NamespaceAccessible
    public HttpResponse patch(String endpoint, String payload, Map<String, String> headers) {
        return callout(endpoint, payload, 'PATCH', headers);
    }
    
    /*************************************************************************   
@description A method that initiates a del callout and returns the http response
-> It can recieves two parameters, rest of endpoint url and headers if available*/
    @NamespaceAccessible
    public HttpResponse del(String endpoint, String payload, Map<String, String> headers) {
        return callout(endpoint, payload, 'DELETE', headers);
    }
    
    /*************************************************************************   
@description A method that initiates a head callout and returns the http response
-> It can recieves two parameters, rest of endpoint url and headers if available*/
    @NamespaceAccessible
    public HttpResponse head(String endpoint, String payload, Map<String, String> headers) {
        return callout(endpoint, payload, 'HEAD', headers);
    }
    
    /*************************************************************************   
@description A method initiates the callout itself setting the payload, method type, headers, and endpoint then send it as a http request and returns the http response
-> It can recieves four parameters, rest of endpoint url, payload, method type and headers if available*/
    @NamespaceAccessible
    public HttpResponse callout(String endpoint, String payload, String method, Map<String, String> headers) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setTimeout(60000);
        if(headers != null && !headers.values().isEmpty()){
            for (String key : headers.keySet()){
                request.setHeader(key, headers.get(key));
            }
        }
        
        if(!String.isBlank(salesforceNamedCredentialsApiUrl))
            endpoint = salesforceNamedCredentialsApiUrl + endpoint;
        
        if(!String.isBlank(payload)){
            if(method  == 'GET'){
                endpoint += payload;
            } else {
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setBody(payload);
            }
        }
        
        request.setEndpoint(endpoint);
                
        if(credentials != null) {
            request.setHeader('Authorization', credentials.getHeader());
        }

        return http.send(request);
    }
}