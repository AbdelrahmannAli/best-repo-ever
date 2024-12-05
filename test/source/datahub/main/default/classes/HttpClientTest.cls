/*************************************************************************   
    @description This is a test class for HttpClient*/

    @IsTest
    public with sharing class HttpClientTest {
    
        public static final String PAYLOAD_REQUEST = '{"payload": true}';
        public static final String PAYLOAD_RESPONSE = '{"payload": false}';
        public static final String ENDPOINT = '/doSomething';
    
        /*************************************************************************   
        @description This tests sending a post request without jwt authentication*/
        @IsTest
        static void postMethod_NoAuth_NoJwtCredentials_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('POST'));
            Syntilio.HttpClient client = new Syntilio.HttpClient();
            // Act
            HttpResponse res = client.post(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>() );
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
        
            /*************************************************************************   
        @description This tests sending a post request without jwt authentication*/
        @IsTest
        public static void postMethod_JwtNamedCredentials_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('POST', 'test'));
            Syntilio.HttpClient client = new Syntilio.HttpClient(null, 'test');
            // Act
            HttpResponse res = client.post(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>());
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a put request without jwt authentication*/
        @IsTest
        public static void putMethod_NoAuth_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('PUT','test'));
            Syntilio.HttpClient client = new Syntilio.HttpClient(null, 'test');
    
            // Act
            HttpResponse res = client.put(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a post request with jwt authentication*/
        @IsTest
        public static void putMethod_JwtNamedCredentials_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('PUT', 'test'));
    
            Syntilio.HttpClient client = new Syntilio.HttpClient('test');
    
            // Act
            HttpResponse res = client.put(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a patch request without jwt authentication*/
        @IsTest
        public static void patchMethod_NoAuth_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('PATCH','test'));
            Syntilio.HttpClient client = new Syntilio.HttpClient(null, 'test');
    
            // Act
            HttpResponse res = client.patch(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a post request with jwt authentication*/
        @IsTest
        public static void patchMethod_JwtNamedCredentials_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('PATCH', 'test'));
    
            Syntilio.HttpClient client = new Syntilio.HttpClient('test');
    
            // Act
            HttpResponse res = client.patch(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a get request without jwt authentication*/
        @IsTest
        public static void getMethod_NoAuth_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('GET','test'));
            Syntilio.HttpClient client = new Syntilio.HttpClient(null, 'test');
    
            // Act
            HttpResponse res = client.get(ENDPOINT, '', new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a get request with jwt authentication*/
        @IsTest
        public static void getMethod_JwtNamedCredentials_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('GET', 'test'));
    
            Syntilio.HttpClient client = new Syntilio.HttpClient('test');
    
            // Act
            HttpResponse res = client.get(ENDPOINT, '', new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a delete request without jwt authentication*/
        @IsTest
        public static void deleteMethod_NoAuth_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('DELETE','test'));
            Syntilio.HttpClient client = new Syntilio.HttpClient(null, 'test');
    
            // Act
            HttpResponse res = client.del(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                /*************************************************************************   
        @description This tests sending a delete request with jwt authentication*/
        @IsTest
        public static void deleteMethod_JwtNamedCredentials_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('DELETE', 'test'));
    
            Syntilio.HttpClient client = new Syntilio.HttpClient('test');
    
            // Act
            HttpResponse res = client.del(ENDPOINT, PAYLOAD_REQUEST, new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                    /*************************************************************************   
        @description This tests sending a head request without jwt authentication*/
        @IsTest
        public static void headMethod_NoAuth_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('HEAD','test'));
            Syntilio.HttpClient client = new Syntilio.HttpClient(null, 'test');
    
            // Act
            HttpResponse res = client.head(ENDPOINT, '', new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    
                    /*************************************************************************   
        @description This tests sending a head request with jwt authentication*/
        @IsTest
        public static void headMethod_JwtNamedCredentials_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('HEAD', 'test'));
    
            Syntilio.HttpClient client = new Syntilio.HttpClient('test');
    
            // Act
            HttpResponse res = client.head(ENDPOINT, '' ,new Map<String, String>());
    
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
        
        /*************************************************************************   
        @description This tests sending a get request with headers*/
        @IsTest
        static void getMethod_NoAuth_with_Headers_Test() {
            // Arrange
            Test.setMock(HttpCalloutMock.class, new Syntilio.HttpClientMock('GET'));
            Syntilio.HttpClient client = new Syntilio.HttpClient();
            // Act
            Map<String, String> destinationsHeaders = new Map<String, String>{'Destinations' => 'Ons'};
    
            HttpResponse res = client.get(ENDPOINT, '', destinationsHeaders );
            // Assert
            System.assertEquals(null, client.credentials);
            System.assertEquals(PAYLOAD_RESPONSE, res.getBody());
            System.assertEquals(200, res.getStatusCode());
        }
    }