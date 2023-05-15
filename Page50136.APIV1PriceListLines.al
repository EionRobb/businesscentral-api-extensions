#pragma implicitwith disable
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
            field("PriceListCode"; Rec."Price List Code") { ApplicationArea = All; }
            field("LineNo"; Rec."Line No.") { ApplicationArea = All; }
            field("SourceType"; Rec."Source Type") { ApplicationArea = All; }
            field("SourceNo"; Rec."Source No.") { ApplicationArea = All; }
            field("ParentSourceNo"; Rec."Parent Source No.") { ApplicationArea = All; }
            field("SourceID"; Rec."Source ID") { ApplicationArea = All; }
            field("AssetType"; Rec."Asset Type") { ApplicationArea = All; }
            field("AssetNo"; Rec."Asset No.") { ApplicationArea = All; }
            field("VariantCode"; Rec."Variant Code") { ApplicationArea = All; }
            field("CurrencyCode"; Rec."Currency Code") { ApplicationArea = All; }
            field("WorkTypeCode"; Rec."Work Type Code") { ApplicationArea = All; }
            field("StartingDate"; Rec."Starting Date") { ApplicationArea = All; }
            field("EndingDate"; Rec."Ending Date") { ApplicationArea = All; }
            field("MinimumQuantity"; Rec."Minimum Quantity") { ApplicationArea = All; }
            field("UnitofMeasureCode"; Rec."Unit of Measure Code") { ApplicationArea = All; }
            field("AmountType"; Rec."Amount Type") { ApplicationArea = All; }
            field("UnitPrice"; Rec."Unit Price") { ApplicationArea = All; }
            field("CostFactor"; Rec."Cost Factor") { ApplicationArea = All; }
            field("UnitCost"; Rec."Unit Cost") { ApplicationArea = All; }
            field("LineDiscountPercent"; Rec."Line Discount %") { ApplicationArea = All; }
            field("AllowLineDiscount"; Rec."Allow Line Disc.") { ApplicationArea = All; }
            field("AllowInvoiceDiscount"; Rec."Allow Invoice Disc.") { ApplicationArea = All; }
            field("PriceIncludesVAT"; Rec."Price Includes VAT") { ApplicationArea = All; }
            //field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)"){ApplicationArea = All;}
            //field("VAT Prod. Posting Group"; "VAT Prod. Posting Group"){ApplicationArea = All;}
            field("AssetID"; Rec."Asset ID") { ApplicationArea = All; }
            field("LineAmount"; Rec."Line Amount") { ApplicationArea = All; }
            field("PriceType"; Rec."Price Type") { ApplicationArea = All; }
            field("Description"; Rec."Description") { ApplicationArea = All; }
            field("Status"; Rec."Status") { ApplicationArea = All; }
            field("DirectUnitCost"; Rec."Direct Unit Cost") { ApplicationArea = All; }
            field("SourceGroup"; Rec."Source Group") { ApplicationArea = All; }
            field("ProductNo"; Rec."Product No.") { ApplicationArea = All; }
            field("AssignToNo"; Rec."Assign-to No.") { ApplicationArea = All; }
            field("AssignToParentNo"; Rec."Assign-to Parent No.") { ApplicationArea = All; }
            //field("Variant Code Lookup"; "Variant Code Lookup"){ApplicationArea = All;}
            //field("Unit of Measure Code Lookup"; "Unit of Measure Code Lookup"){ApplicationArea = All;}
#if BUILD_REGION_AUNZ
            field("PublishedPrice"; Rec."Published Price") { ApplicationArea = All; }
            field("Cost"; Rec."Cost") { ApplicationArea = All; }
            field("CostPlusPercent"; Rec."Cost-plus %") { ApplicationArea = All; }
            field("DiscountAmount"; Rec."Discount Amount") { ApplicationArea = All; }
#endif
            field(id; Rec."SystemId") { ApplicationArea = All; }
            //field("SystemCreatedAt"; "SystemCreatedAt"){ApplicationArea = All;}
            //field("SystemCreatedBy"; "SystemCreatedBy"){ApplicationArea = All;}
            //field("SystemModifiedAt"; "SystemModifiedAt"){ApplicationArea = All;}
            //field("SystemModifiedBy"; "SystemModifiedBy"){ApplicationArea = All;}
            //field("SystemRowVersion"; "SystemRowVersion"){ApplicationArea = All;}
            field(lastModifiedDateTime; Rec.SystemModifiedAt)
            {
                ApplicationArea = All;
            }
        }
    }
}
#pragma implicitwith restore
