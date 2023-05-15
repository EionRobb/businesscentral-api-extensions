#pragma implicitwith disable
page 50120 SpecialPrices
{
    PageType = API;
    Caption = 'Special Pricing API';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'salesPrice';
    EntitySetName = 'salesPrices';
    //SourceTable = 7002;
    DelayedInsert = true;

    SourceTable = "Sales Price";

    layout
    {
        area(Content)
        {
            field(itemNumber; Rec."Item No.")
            {
                Caption = 'Item Number';
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
#if BUILD_REGION_AUNZ
            field(publishedPrice; Rec."Published Price")
            {
                ApplicationArea = All;
            }
#endif
            field(unitPrice; Rec."Unit Price")
            {
                ApplicationArea = All;
            }
#if BUILD_REGION_AUNZ
            field(costPrice; Rec.Cost)
            {
                ApplicationArea = All;
            }
#endif
            field(unitofMeasureCode; Rec."Unit of Measure Code")
            {
                ApplicationArea = All;
            }
            field(priceIncludesTax; Rec."Price Includes VAT")
            {
                ApplicationArea = All;
            }
            field(allowInvoiceDiscount; Rec."Allow Invoice Disc.")
            {
                ApplicationArea = All;
            }
            field(allowLineDiscount; Rec."Allow Line Disc.")
            {
                ApplicationArea = All;
            }
            field(minimumQuantity; Rec."Minimum Quantity")
            {
                ApplicationArea = All;
            }
#if BUILD_REGION_AUNZ
            field(discountAmount; Rec."Discount Amount")
            {
                ApplicationArea = All;
            }
            field(costPlusPercentage; Rec."Cost-plus %")
            {
                ApplicationArea = All;
            }
#endif
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
