
page 50122 SpecialDiscounts
{
    PageType = API;
    Caption = 'Special Discounts API';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'salesDiscount';
    EntitySetName = 'salesDiscounts';
    //SourceTable = 7004;
    DelayedInsert = true;

    SourceTable = "Sales Line Discount";

    layout
    {
        area(Content)
        {
            field(code; Code)
            {
                ApplicationArea = All;
            }
            field(salesType; "Sales Type")
            {
                Caption = 'Sales Type';
                ApplicationArea = All;
            }
            field(salesCode; "Sales Code")
            {
                Caption = 'Sales Code';
                ApplicationArea = All;
            }
            field(startingDate; "Starting Date")
            {
                ApplicationArea = All;
            }
            field(endingDate; "Ending Date")
            {
                ApplicationArea = All;
            }
            field(currencyCode; "Currency Code")
            {
                ApplicationArea = All;
            }
            field(unitofMeasureCode; "Unit of Measure Code")
            {
                ApplicationArea = All;
            }
            field(minimumQuantity; "Minimum Quantity")
            {
                ApplicationArea = All;
            }
            field(lineDiscountPercentage; "Line Discount %")
            {
                ApplicationArea = All;
            }
            field(type; Type)
            {
                ApplicationArea = All;
            }
            field(variantCode; "Variant Code")
            {
                ApplicationArea = All;
            }

            field(id; SystemId) { }
            field(lastModifiedDateTime; SystemModifiedAt) { }
        }
    }
}