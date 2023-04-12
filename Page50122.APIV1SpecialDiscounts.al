
#pragma implicitwith disable
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
            field(code; Rec.Code)
            {
                ApplicationArea = All;
            }
            field(salesType; Rec."Sales Type")
            {
                Caption = 'Sales Type';
                ApplicationArea = All;
            }
            field(salesCode; Rec."Sales Code")
            {
                Caption = 'Sales Code';
                ApplicationArea = All;
            }
            field(startingDate; Rec."Starting Date")
            {
                ApplicationArea = All;
            }
            field(endingDate; Rec."Ending Date")
            {
                ApplicationArea = All;
            }
            field(currencyCode; Rec."Currency Code")
            {
                ApplicationArea = All;
            }
            field(unitofMeasureCode; Rec."Unit of Measure Code")
            {
                ApplicationArea = All;
            }
            field(minimumQuantity; Rec."Minimum Quantity")
            {
                ApplicationArea = All;
            }
            field(lineDiscountPercentage; Rec."Line Discount %")
            {
                ApplicationArea = All;
            }
            field(type; Rec.Type)
            {
                ApplicationArea = All;
            }
            field(variantCode; Rec."Variant Code")
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
#pragma implicitwith restore
