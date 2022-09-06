page 50121 "Customer Entity Extension"
{
    PageType = API;
    Caption = 'Customer Entity Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    DelayedInsert = true;

    SourceTable = "Customer";
    //SourceTable = 18;
    ODataKeyFields = Id;

    layout
    {
        area(Content)
        {
            field("ID"; ID)
            {
                ApplicationArea = All;
            }
            field("customerNumber"; "No.")
            {
                ApplicationArea = All;
            }
            field("customerDiscountGroup"; "Customer Disc. Group")
            {
                ApplicationArea = All;
            }
            field("customerPriceGroup"; "Customer Price Group")
            {
                ApplicationArea = All;
            }
            field("creditLimit"; "Credit Limit (LCY)")
            {
                ApplicationArea = All;
            }
            field("salespersonCode"; "Salesperson Code")
            {
                ApplicationArea = All;
            }
            field("allowLineDiscount"; "Allow Line Disc.")
            {
                ApplicationArea = All;
            }
            field("invoiceDiscountCode"; "Invoice Disc. Code")
            {
                ApplicationArea = All;
            }
        }
    }
}