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
            field(itemNumber; "Item No.")
            {
                Caption = 'Item Number';
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
            field(publishedPrice; "Published Price")
            {
                ApplicationArea = All;
            }
            field(unitPrice; "Unit Price")
            {
                ApplicationArea = All;
            }
            field(costPrice; Cost)
            {
                ApplicationArea = All;
            }
            field(unitofMeasureCode; "Unit of Measure Code")
            {
                ApplicationArea = All;
            }
            field(priceIncludesTax; "Price Includes VAT")
            {
                ApplicationArea = All;
            }
            field(allowInvoiceDiscount; "Allow Invoice Disc.")
            {
                ApplicationArea = All;
            }
            field(allowLineDiscount; "Allow Line Disc.")
            {
                ApplicationArea = All;
            }
            field(minimumQuantity; "Minimum Quantity")
            {
                ApplicationArea = All;
            }
            field(discountAmount; "Discount Amount")
            {
                ApplicationArea = All;
            }
            field(costPlusPercentage; "Cost-plus %")
            {
                ApplicationArea = All;
            }
            field(variantCode; "Variant Code")
            {
                ApplicationArea = All;
            }


        }
    }
}