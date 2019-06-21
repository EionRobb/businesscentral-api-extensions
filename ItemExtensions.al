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
    ODataKeyFields = Id;

    layout
    {
        area(Content)
        {
            field("ID"; ID)
            {
                ApplicationArea = All;
            }
            field("itemNumber"; "No.")
            {
                ApplicationArea = All;
            }
            field("generalProductPostingGroupCode"; "Gen. Prod. Posting Group")
            {
                ApplicationArea = All;
            }
            field("taxProductPostingGroupCode"; "VAT Prod. Posting Group")
            {
                ApplicationArea = All;
            }
            field("discountGroup"; "Item Disc. Group")
            {
                ApplicationArea = All;
            }
            field("allowInvoiceDiscount"; "Allow Invoice Disc.")
            {
                ApplicationArea = All;
            }
            field("salesUnitOfMeasure"; "Sales Unit of Measure")
            {
                ApplicationArea = All;
                ODataEDMType = 'ITEM-UOM';
            }
        }
    }
}