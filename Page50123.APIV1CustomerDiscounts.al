page 50123 "Customer Discount Extension"
{
    PageType = API;
    Caption = 'Customer Discount Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'customerDiscount';
    EntitySetName = 'customerDiscounts';
    DelayedInsert = true;

    SourceTable = "Cust. Invoice Disc.";
    //SourceTable = 19;

    layout
    {
        area(Content)
        {
            field("invoiceDiscountCode"; Code)
            {
                ApplicationArea = All;
            }
            field("minimumAmount"; "Minimum Amount")
            {
                ApplicationArea = All;
            }
            field("discountPercent"; "Discount %")
            {
                ApplicationArea = All;
            }
            field(id; SystemId) { }
            field(lastModifiedDateTime; SystemModifiedAt) { }
        }
    }
}