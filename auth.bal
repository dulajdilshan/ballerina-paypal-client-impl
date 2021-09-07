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

    AuthResp authResponse = check clientEp->post(
        "/v1/oauth2/token",
        "grant_type=client_credentials",
        mediaType = "application/x-www-form-urlencoded"
    );

    io:println("New Token: ", authResponse.access_token);
    return authResponse.access_token;
}

public function isConfigToml(string key = "abc", string value = "abc-value") returns error? {
    string currentDir = file:getCurrentDir();
    boolean fileExists = check file:test("Config.toml", file:WRITABLE);

    check file:create("bar.txt");
    io:println(fileExists);
}

