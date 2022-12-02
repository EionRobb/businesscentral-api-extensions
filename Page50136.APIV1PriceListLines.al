page 50136 "Price List Lines Entity"
{
    PageType = API;
    Caption = 'Price List Lines';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'priceListLine';
    EntitySetName = 'priceListLines';
    DelayedInsert = true;

    SourceTable = "Price List Line";
    //SourceTable = 7001;
    ODataKeyFields = "Price List Code", "Line No.";

    layout
    {
        area(Content)
        {
            field("PriceListCode"; "Price List Code") { ApplicationArea = All; }
            field("LineNo"; "Line No.") { ApplicationArea = All; }
            field("SourceType"; "Source Type") { ApplicationArea = All; }
            field("SourceNo"; "Source No.") { ApplicationArea = All; }
            field("ParentSourceNo"; "Parent Source No.") { ApplicationArea = All; }
            field("SourceID"; "Source ID") { ApplicationArea = All; }
            field("AssetType"; "Asset Type") { ApplicationArea = All; }
            field("AssetNo"; "Asset No.") { ApplicationArea = All; }
            field("VariantCode"; "Variant Code") { ApplicationArea = All; }
            field("CurrencyCode"; "Currency Code") { ApplicationArea = All; }
            field("WorkTypeCode"; "Work Type Code") { ApplicationArea = All; }
            field("StartingDate"; "Starting Date") { ApplicationArea = All; }
            field("EndingDate"; "Ending Date") { ApplicationArea = All; }
            field("MinimumQuantity"; "Minimum Quantity") { ApplicationArea = All; }
            field("UnitofMeasureCode"; "Unit of Measure Code") { ApplicationArea = All; }
            field("AmountType"; "Amount Type") { ApplicationArea = All; }
            field("UnitPrice"; "Unit Price") { ApplicationArea = All; }
            field("CostFactor"; "Cost Factor") { ApplicationArea = All; }
            field("UnitCost"; "Unit Cost") { ApplicationArea = All; }
            field("LineDiscountPercent"; "Line Discount %") { ApplicationArea = All; }
            field("AllowLineDiscount"; "Allow Line Disc.") { ApplicationArea = All; }
            field("AllowInvoiceDiscount"; "Allow Invoice Disc.") { ApplicationArea = All; }
            field("PriceIncludesVAT"; "Price Includes VAT") { ApplicationArea = All; }
            //field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)"){ApplicationArea = All;}
            //field("VAT Prod. Posting Group"; "VAT Prod. Posting Group"){ApplicationArea = All;}
            field("AssetID"; "Asset ID") { ApplicationArea = All; }
            field("LineAmount"; "Line Amount") { ApplicationArea = All; }
            field("PriceType"; "Price Type") { ApplicationArea = All; }
            field("Description"; "Description") { ApplicationArea = All; }
            field("Status"; "Status") { ApplicationArea = All; }
            field("DirectUnitCost"; "Direct Unit Cost") { ApplicationArea = All; }
            field("SourceGroup"; "Source Group") { ApplicationArea = All; }
            field("ProductNo"; "Product No.") { ApplicationArea = All; }
            field("AssignToNo"; "Assign-to No.") { ApplicationArea = All; }
            field("AssignToParentNo"; "Assign-to Parent No.") { ApplicationArea = All; }
            //field("Variant Code Lookup"; "Variant Code Lookup"){ApplicationArea = All;}
            //field("Unit of Measure Code Lookup"; "Unit of Measure Code Lookup"){ApplicationArea = All;}
            field("PublishedPrice"; "Published Price") { ApplicationArea = All; }
            field("Cost"; "Cost") { ApplicationArea = All; }
            field("CostPlusPercent"; "Cost-plus %") { ApplicationArea = All; }
            field("DiscountAmount"; "Discount Amount") { ApplicationArea = All; }
            field("SystemId"; "SystemId") { ApplicationArea = All; }
            //field("SystemCreatedAt"; "SystemCreatedAt"){ApplicationArea = All;}
            //field("SystemCreatedBy"; "SystemCreatedBy"){ApplicationArea = All;}
            //field("SystemModifiedAt"; "SystemModifiedAt"){ApplicationArea = All;}
            //field("SystemModifiedBy"; "SystemModifiedBy"){ApplicationArea = All;}
            //field("SystemRowVersion"; "SystemRowVersion"){ApplicationArea = All;}
            field(lastModifiedDateTime; SystemModifiedAt) { }
        }
    }
}