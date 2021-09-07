import ballerina/http;
import ballerina/io;

type Amount record {|
    string currency_code;
    float value;
|};

type Tax record {|
    string name;
    float percent;
|};

type Discount record {|
    float percent;
|};

type CustomAmount record {|
    string label;
    Amount amount;
|};

type AmountBreakdown record {|
    CustomAmount custom?;
    record {Amount amount; Tax tax?;} shipping;
    record {Discount invoice_discount;} discount?;
|};

type Transaction record {|
    record {|
        float total;
        string currency = "USD";
    |} amount;
    string invoice_number?;
|};

type Payment record {|
    string intent = "sale";
    record {string payment_method;} payer = {
        payment_method: "paypal"
    };
    Transaction[] transactions;
    record {|string return_url; string cancel_url;|} redirect_urls;
|};

function createSamplePayment(http:Client payPalClient) returns error? {
    Payment payment = {
        transactions: [
            {
                amount: {
                    total: 30.11
                }
            }
        ],
        redirect_urls: {
            return_url: "https://example.com",
            cancel_url: "https://example.com"
        }
    };
    string paymentID = check createPayment(payPalClient, payment);
    io:println("PaymentId: ", paymentID);
}

function createPayment(http:Client payPalClient, Payment payment) returns string|error {
    json resp = check payPalClient->post("/v1/payments/payment", payment);
    string paymentID = check resp.id;
    return paymentID;
}
