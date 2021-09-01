import ballerina/http;
import ballerina/io;

type InvoiceDetail record {|
    string invoice_number;
    string reference;
    string invoice_date;
    string currency_code;
    string note;
    string term;
    string memo;
    record {|string term_type?; string due_date;|} payment_term;
|};

type Invoice record {|
    InvoiceDetail detail;
    Person invoicer;
    Item[] items;
|};

InvoiceDetail defaultInvoiceDetails = {
    invoice_number: "<INVOICE-NUMBER>",
    reference: "default-ref",
    invoice_date: "<INVOICE-DATE>",
    currency_code: "USD",
    note: "Thank you for your business.",
    term: "No refunds after 30 days.",
    memo: "This is a long contract",
    payment_term: {
        due_date: "<DUE-DATE>"
    }
};

function getNewInvoiceNumber(http:Client payPalClient) returns string|error {
    http:Request req = new ();
    req.setHeader("content-type", "application/json");
    req.setHeader("Accept", "application/json");

    http:Response resp = check payPalClient->post("/v2/invoicing/generate-next-invoice-number", req);
    json payload = check resp.getJsonPayload().clone();

    string invoicenumber = check payload.invoice_number;

    io:println("Next Invoice Number: ", invoicenumber);
    return invoicenumber;
}

function createInvoiceDetail(string nextInvoiceNumber, string invoiceDate, string dueDate) returns InvoiceDetail {
    InvoiceDetail invoiceDetail = defaultInvoiceDetails;

    invoiceDetail.invoice_number = nextInvoiceNumber;
    invoiceDetail.invoice_date = invoiceDate;
    invoiceDetail.payment_term.due_date = dueDate;

    return invoiceDetail;
}

function createSampledraftInvoice(http:Client payPalClient) returns error? {
    string nextInvoiceNumber = check getNewInvoiceNumber(payPalClient);

    Person invoicer = check createPersonRandom().ensureType();

    InvoiceDetail invoDetail = createInvoiceDetail(nextInvoiceNumber, "2021-08-12", "2021-08-13");

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

}

function createDraftInvoice(http:Client payPalClient, Invoice invoice) returns error? {
    http:Request req = new ();
    req.setHeader("content-type", "application/json");
    req.setHeader("Accept", "application/json");

    req.setJsonPayload(invoice);

    http:Response resp = check payPalClient->post("/v2/invoicing/invoices", req);
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();
    io:println(jsonPayload.toString());
}

function getInvoices(http:Client payPalClient) returns json|error? {
    http:Response resp = check payPalClient->get("/v2/invoicing/invoices");
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();
    io:println(jsonPayload.toString());
    return jsonPayload;
}

function getInvoice(http:Client payPalClient, string invoiceID) returns json|error? {
    string url = "/v2/invoicing/invoices/" + invoiceID;
    http:Response resp = check payPalClient->get(url);
    json jsonPayload = check resp.getJsonPayload().cloneReadOnly();
    io:println(jsonPayload.toString());
    return jsonPayload;
}

function deleteInvoice(http:Client payPalClient, string invoiceID) returns error? {
    http:Request req = new ();
    req.setHeader("content-type", "application/json");
    req.setHeader("Accept", "application/json");

    string url = "/v2/invoicing/invoices/" + invoiceID;
    http:Response resp = check payPalClient->delete(url);
}

