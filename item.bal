type Item record {|
    string name;
    string description;
    int quantity;
    Amount unit_amount;
    Tax tax?;
    Discount discount?;
    string unit_of_measure = "QUANTITY";
|};

