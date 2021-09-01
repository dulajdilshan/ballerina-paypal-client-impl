import ballerina/io;
import ballerina/http;

configurable string url = ?;
configurable string token = ?;
configurable string client_id = ?;
configurable string client_secret = ?;

http:Client payPalClient = check new (url,
    auth = {
        token: token
    }
);

public function main() returns error? {
    // your code goes here
}

function getUserInfo(http:Client payPalClient) returns error? {
    http:Response resp = check payPalClient->get("/v1/identity/oauth2/userinfo?schema=paypalv1.1");
    io:println("User Info: ", check resp.getJsonPayload());
}

// ************** 
//     Utils
// **************

function printConfigs(string url, string token, string client_id, string client_secret) {
    io:println("URL: ", url);
    io:println("Token: ", token);
    io:println("Client-ID: ", client_id);
    io:println("Client-Secret: ", client_secret);

    io:println("\n\n");
}
