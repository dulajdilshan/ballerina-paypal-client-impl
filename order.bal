import ballerina/http;
import ballerina/io;

enum ORDER_INTENT {
    CAPTURE = "CAPTURE",
    AUTHORIZE = "AUTHORIZE"
}

type Payee record {
    Name name?;
    string email;
};

type PurchaseUnit record {|
    Amount amount;
    Payee payee?;
|};

type Order record {|
    ORDER_INTENT intent;
    PurchaseUnit[] purchase_units;
|};

function createSampleOrder(http:Client payPalClient) returns error? {
    Order 'order = {
        intent: "CAPTURE",
        purchase_units: [
            {
                payee: {
                    email: "eggmaster@mail.com"
                },
                amount: {
                    currency_code: "USD",
                    value: 100.0
                }
            }
        ]
    };

    json jsonResult = check createOrder(payPalClient, 'order);
}

function createOrder(http:Client payPalClient, Order 'order) returns json|error {
    http:Request req = new ();
    req.setHeader("content-type", "application/json");
    req.setHeader("Accept", "application/json");

    req.setJsonPayload('order.toJson());

    http:Response resp = check payPalClient->post("/v2/checkout/orders", req);
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();
    return jsonPayload;
}

function getOrders(http:Client payPalClient) returns error? {
    http:Response resp = check payPalClient->get("/v2/checkout/orders");
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();
    io:println(jsonPayload.toString());
    string orderId = check jsonPayload.id;
}

function getOrder(http:Client payPalClient, string orderID) returns error? {
    string url = "/v2/checkout/orders/" + orderID;
    http:Response resp = check payPalClient->get(url);
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();
    io:println(jsonPayload.toString());
}
