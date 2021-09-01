import ballerina/http;
import ballerina/io;
import ballerina/file;

type AuthResp record {
    string app_id;
    string access_token;
};

public function generateToken(string url, string client_id, string client_secret) returns string|error? {
    http:Client clientEp = check new (url,
        auth = {
            username: client_id,
            password: client_secret
        }
    );

    http:Request req = new();
    req.setHeader("content-type", "application/x-www-form-urlencoded");
    req.setHeader("Accept", "application/json");
    req.setPayload("grant_type=client_credentials");

    http:Response resp = check clientEp->post("/v1/oauth2/token", req);
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();

    AuthResp authResp = <AuthResp> jsonPayload;

    string accessToken = authResp.access_token;

    io:println("New Token: ", accessToken);
    return accessToken;
}

public function isConfigToml(string key = "abc", string value = "abc-value") returns error?{
    string currentDir = file:getCurrentDir();
    boolean fileExists = check file:test("Config.toml", file:WRITABLE);

    check file:create("bar.txt");
    io:println(fileExists);
}

