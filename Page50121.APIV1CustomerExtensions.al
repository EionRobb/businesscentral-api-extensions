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
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            field("ID"; Rec.SystemId)
            {
                ApplicationArea = All;
            }
            field("customerNumber"; Rec."No.")
            {
                ApplicationArea = All;
            }
            field("customerDiscountGroup"; Rec."Customer Disc. Group")
            {
                ApplicationArea = All;
            }
            field("customerPriceGroup"; Rec."Customer Price Group")
            {
                ApplicationArea = All;
            }
            field("creditLimit"; Rec."Credit Limit (LCY)")
            {
                ApplicationArea = All;
            }
            field("salespersonCode"; Rec."Salesperson Code")
            {
                ApplicationArea = All;
            }
            field("allowLineDiscount"; Rec."Allow Line Disc.")
            {
                ApplicationArea = All;
            }
            field("invoiceDiscountCode"; Rec."Invoice Disc. Code")
            {
                ApplicationArea = All;
            }
            field(lastModifiedDateTime; Rec.SystemModifiedAt)
            {
                ApplicationArea = All;
            }
        }
    }
}