import ballerina/http;
import ballerina/io;

type InvoiceDetail record {|
    string invoice_number;
    string reference = "default-ref";
    string invoice_date;
    string currency_code = "USD";
    string note = "Thank you for your business.";
    string term = "No refunds after 30 days.";
    string memo = "This is a long contract";
    record {|string term_type?; string due_date;|} payment_term;
|};

type Invoice record {|
    InvoiceDetail detail;
    Person invoicer;
    Item[] items;
|};

function getNewInvoiceNumber(http:Client payPalClient) returns string|error {
    json resp = check payPalClient->post("/v2/invoicing/generate-next-invoice-number", {});
    string invoicenumber = check resp.invoice_number;

    io:println("Next Invoice Number: ", invoicenumber);
    return invoicenumber;
}

function createSampledraftInvoice(http:Client payPalClient) returns error? {
    string nextInvoiceNumber = check getNewInvoiceNumber(payPalClient);

    Person invoicer = check createPersonRandom();

    var toInvoiceDetail = function(string nextInvoiceNumber, string invoiceDate, string dueDate) returns InvoiceDetail => {
        invoice_number: nextInvoiceNumber,
        invoice_date: invoiceDate,
        payment_term: {
            due_date: dueDate
        }
    };

    InvoiceDetail invoDetail = toInvoiceDetail(nextInvoiceNumber, "2021-08-12", "2021-08-13");

    Item item1 = {
        name: "Yoga Mat",
        description: "Elastic mat to practice yoga.",
        quantity: 1,
        unit_amount: {
            currency_code: "USD",
            value: 50.00
        }
    };

    Item item2 = {
        name: "T-shirt",
        description: "XL T-shirt",
        quantity: 1,
        unit_amount: {
            currency_code: "USD",
            value: 25.00
        }
    };

    Invoice invoice = {
        detail: invoDetail,
        invoicer: invoicer,
        items: [item1, item2]
    };

    check createDraftInvoice(payPalClient, invoice);
}

function createDraftInvoice(http:Client payPalClient, Invoice invoice) returns error? {
    json resp = check payPalClient->post("/v2/invoicing/invoices", invoice);
    io:println("Response: ", resp);
}

function getInvoices(http:Client payPalClient) returns json|error? {
    json resp = check payPalClient->get("/v2/invoicing/invoices");
    io:println("Invoices: ", resp.items);
    return resp.items;
}

function getInvoice(http:Client payPalClient, string invoiceID) returns json|error? {
    string url = "/v2/invoicing/invoices/" + invoiceID;
    json resp = check payPalClient->get(url);
    io:println("Invoice: ", resp);
    return resp;
}

function deleteInvoice(http:Client payPalClient, string invoiceID) returns error? {
    string url = "/v2/invoicing/invoices/" + invoiceID;
    http:Response resp = check payPalClient->delete(url);
}
