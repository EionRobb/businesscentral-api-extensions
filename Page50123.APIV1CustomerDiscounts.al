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
            field("invoiceDiscountCode"; Rec.Code)
            {
                ApplicationArea = All;
            }
            field("minimumAmount"; Rec."Minimum Amount")
            {
                ApplicationArea = All;
            }
            field("discountPercent"; Rec."Discount %")
            {
                ApplicationArea = All;
            }
            field(id; Rec.SystemId)
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