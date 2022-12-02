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
            field("Code"; "Code") { ApplicationArea = All; }
            field("Description"; "Description") { ApplicationArea = All; }
            field("SourceGroup"; "Source Group") { ApplicationArea = All; }
            field("SourceType"; "Source Type") { ApplicationArea = All; }
            field("SourceNo"; "Source No.") { ApplicationArea = All; }
            field("ParentSourceNo"; "Parent Source No.") { ApplicationArea = All; }
            field("SourceID"; "Source ID") { ApplicationArea = All; }
            field("PriceType"; "Price Type") { ApplicationArea = All; }
            field("AmountType"; "Amount Type") { ApplicationArea = All; }
            field("CurrencyCode"; "Currency Code") { ApplicationArea = All; }
            field("StartingDate"; "Starting Date") { ApplicationArea = All; }
            field("EndingDate"; "Ending Date") { ApplicationArea = All; }
            field("PriceIncludesVAT"; "Price Includes VAT") { ApplicationArea = All; }
            //field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)") { ApplicationArea = All; }
            field("AllowLineDiscount"; "Allow Line Disc.") { ApplicationArea = All; }
            field("AllowInvoiceDisccount"; "Allow Invoice Disc.") { ApplicationArea = All; }
            //field("No. Series"; "No. Series") { ApplicationArea = All; }
            field("Status"; "Status") { ApplicationArea = All; }
            //field("Filter Source No."; "Filter Source No.") { ApplicationArea = All; }
            //field("Allow Updating Defaults"; "Allow Updating Defaults") { ApplicationArea = All; }
            field("AssignToNo"; "Assign-to No.") { ApplicationArea = All; }
            field("AssignToParentNo"; "Assign-to Parent No.") { ApplicationArea = All; }
            field("SystemId"; "SystemId") { ApplicationArea = All; }
            //field("SystemCreatedAt"; "SystemCreatedAt") { ApplicationArea = All; }
            //field("SystemCreatedBy"; "SystemCreatedBy") { ApplicationArea = All; }
            //field("SystemModifiedAt"; "SystemModifiedAt") { ApplicationArea = All; }
            //field("SystemModifiedBy"; "SystemModifiedBy") { ApplicationArea = All; }
            //field("SystemRowVersion"; "SystemRowVersion") { ApplicationArea = All; }
            field(lastModifiedDateTime; SystemModifiedAt) { }

            part(lines; 50136)
            {
                EntityName = 'priceListLine';
                EntitySetName = 'priceListLines';
                SubPageLink = "Price List Code" = FIELD("Code");
            }
        }
    }
}