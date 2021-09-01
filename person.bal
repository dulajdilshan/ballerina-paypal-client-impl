type Name record {|
    string given_name;
    string surname;
|};

type Address record {|
    string address_line_1;
    string address_line_2;
    string admin_area_2;
    string admin_area_1;
    string postal_code;
    string country_code;
|};

type Phone record {|
    string country_code;
    string national_number;
    string phone_type = "MOBILE";
|};

type Person record {|
    Name name?;
    Address address?;
    string email_address;
    Phone[] phones?;
|};

function createPersonRandom() returns Person|error {
    Person person =  check jsonToPerson(check genRandomPerson().ensureType());
    return person;
}

function createName(string givenName, string surname) returns Name {
    return {given_name: givenName, surname: surname};
}

function createPhoneUS(string no) returns Phone {
    return {country_code: "001", national_number: no};
}

function createPhone(string countryCode, string no) returns Phone {
    return {country_code: countryCode, national_number: no};
}

function createAddress(
    string addressLine,
    string adminArea,
    string postalCode,
    string countryCode
) returns Address {
    return {
        address_line_1: addressLine,
        address_line_2: "",
        admin_area_1: adminArea,
        admin_area_2: "",
        postal_code: postalCode,
        country_code: countryCode
    };
}

function jsonToPerson(json[] results) returns Person|error {

    json jsonUser = results[0];     // Since we get the result as an array, we take the first element

    map<json> mapUser = check jsonUser.ensureType();

    map<json> name = check mapUser.name.ensureType();
    string email = check mapUser.email;
    map<json> location = check mapUser.location.ensureType();
    map<json> street = check location.street.ensureType();

    int|string streetNo = check street.number;
    string streetName = check street.name;

    string|int postalCode = check location.postcode;

    Address address = {
        address_line_1: streetNo.toString(),
        address_line_2: streetName,
        admin_area_1: check location.city,
        admin_area_2: check location.state,
        country_code: "US",
        postal_code: postalCode.toString()
    };

    string phoneNo1 = check mapUser.phone;
    string phoneNo2 = check mapUser.cell;

    Phone[] phoneNos = [
        {country_code: "001", national_number: convertPhoneNumber(phoneNo1)},
        {country_code: "001", national_number: convertPhoneNumber(phoneNo2)}
    ];

    Person person = {
        name: {
            given_name: check name.first,
            surname: check name.last
        },
        address: address,
        email_address: email,
        phones: phoneNos
    };

    return person;
}

function convertPhoneNumber(string phoneNumber) returns string{
    string newPhoneNumber = "";

    foreach string i in phoneNumber{
        if i == "-" || i == "(" || i == ")" {
            continue;
        }
        newPhoneNumber = newPhoneNumber + i;
    }
    return newPhoneNumber;
}
