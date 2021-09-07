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
    json resp = check payPalClient->post("/v2/checkout/orders", 'order);
    io:println(resp);
    return resp;
}

function getOrders(http:Client payPalClient) returns error? {
    json resp = check payPalClient->get("/v2/checkout/orders");    
    io:println("Order: ", resp);
}

function getOrder(http:Client payPalClient, string orderID) returns error? {
    string url = "/v2/checkout/orders/" + orderID;
    json resp = check payPalClient->get(url);
    io:println("Order: ", resp);
}
