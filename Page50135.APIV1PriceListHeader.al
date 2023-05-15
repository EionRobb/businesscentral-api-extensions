#pragma implicitwith disable
page 50135 "Price List Header Entity"
{
    PageType = API;
    Caption = 'Price List Headers';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'priceListHeader';
    EntitySetName = 'priceListHeaders';
    DelayedInsert = true;

    SourceTable = "Price List Header";
    //SourceTable = 7000;
    ODataKeyFields = Code;

    layout
    {
        area(Content)
        {
            field("Code"; Rec."Code") { ApplicationArea = All; }
            field("Description"; Rec."Description") { ApplicationArea = All; }
            field("SourceGroup"; Rec."Source Group") { ApplicationArea = All; }
            field("SourceType"; Rec."Source Type") { ApplicationArea = All; }
            field("SourceNo"; Rec."Source No.") { ApplicationArea = All; }
            field("ParentSourceNo"; Rec."Parent Source No.") { ApplicationArea = All; }
            field("SourceID"; Rec."Source ID") { ApplicationArea = All; }
            field("PriceType"; Rec."Price Type") { ApplicationArea = All; }
            field("AmountType"; Rec."Amount Type") { ApplicationArea = All; }
            field("CurrencyCode"; Rec."Currency Code") { ApplicationArea = All; }
            field("StartingDate"; Rec."Starting Date") { ApplicationArea = All; }
            field("EndingDate"; Rec."Ending Date") { ApplicationArea = All; }
            field("PriceIncludesVAT"; Rec."Price Includes VAT") { ApplicationArea = All; }
            //field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)") { ApplicationArea = All; }
            field("AllowLineDiscount"; Rec."Allow Line Disc.") { ApplicationArea = All; }
            field("AllowInvoiceDisccount"; Rec."Allow Invoice Disc.") { ApplicationArea = All; }
            //field("No. Series"; "No. Series") { ApplicationArea = All; }
            field("Status"; Rec."Status") { ApplicationArea = All; }
            //field("Filter Source No."; "Filter Source No.") { ApplicationArea = All; }
            //field("Allow Updating Defaults"; "Allow Updating Defaults") { ApplicationArea = All; }
            field("AssignToNo"; Rec."Assign-to No.") { ApplicationArea = All; }
            field("AssignToParentNo"; Rec."Assign-to Parent No.") { ApplicationArea = All; }
            field(id; Rec."SystemId") { ApplicationArea = All; }
            //field("SystemCreatedAt"; "SystemCreatedAt") { ApplicationArea = All; }
            //field("SystemCreatedBy"; "SystemCreatedBy") { ApplicationArea = All; }
            //field("SystemModifiedAt"; "SystemModifiedAt") { ApplicationArea = All; }
            //field("SystemModifiedBy"; "SystemModifiedBy") { ApplicationArea = All; }
            //field("SystemRowVersion"; "SystemRowVersion") { ApplicationArea = All; }
            field(lastModifiedDateTime; Rec.SystemModifiedAt)
            {
                ApplicationArea = All;
            }

            part(lines; 50136)
            {
                EntityName = 'priceListLine';
                EntitySetName = 'priceListLines';
                SubPageLink = "Price List Code" = FIELD("Code");
            }
        }
    }
}
#pragma implicitwith restore
