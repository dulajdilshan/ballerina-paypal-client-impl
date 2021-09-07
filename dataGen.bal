import ballerina/http;
import ballerina/io;

function genRandomPerson() returns json|error {
    http:Client randomNameGenClient = check new ("https://randomuser.me");

    json resp = check randomNameGenClient->get("/api?nat=us");
    io:println("Person: ", resp);
    
    return resp.results;
}

function genRandomPerson1() returns Person|error {
    http:Client randomNameGenClient = check new ("https://randomuser.me");

    http:Response resp = check randomNameGenClient->get("/api?nat=us");
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();

    io:println("User", jsonPayload.toString());

    return check jsonToPerson(check jsonPayload.results.ensureType());
}

