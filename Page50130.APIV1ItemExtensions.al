#pragma implicitwith disable
page 50130 "Item Entity Extension"
{
    PageType = API;
    Caption = 'Item Entity Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'item';
    EntitySetName = 'items';
    DelayedInsert = true;

    SourceTable = "Item";
    //SourceTable = 27;
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            field("ID"; Rec.SystemId)
            {
                ApplicationArea = All;
            }
            field("itemNumber"; Rec."No.")
            {
                ApplicationArea = All;
            }
            field("generalProductPostingGroupCode"; Rec."Gen. Prod. Posting Group")
            {
                ApplicationArea = All;
            }
            field("taxProductPostingGroupCode"; Rec."VAT Prod. Posting Group")
            {
                ApplicationArea = All;
            }
            field("discountGroup"; Rec."Item Disc. Group")
            {
                ApplicationArea = All;
            }
            field("allowInvoiceDiscount"; Rec."Allow Invoice Disc.")
            {
                ApplicationArea = All;
            }
            field("salesUnitOfMeasureCode"; Rec."Sales Unit of Measure")
            {
                ApplicationArea = All;
            }
            field("purchaseUnitOfMeasureCode"; Rec."Purch. Unit of Measure")
            {
                ApplicationArea = All;
            }
            field("salesBlocked"; Rec."Sales Blocked")
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
#pragma implicitwith restore
