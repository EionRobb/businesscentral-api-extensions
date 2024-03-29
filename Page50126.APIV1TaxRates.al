page 50126 TaxRates
{
    PageType = API;
    Caption = 'Tax Rates API';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'taxRate';
    EntitySetName = 'taxRates';
    DelayedInsert = true;

    //SourceTable = 325
    SourceTable = "VAT Posting Setup";

    layout
    {
        area(Content)
        {
            field(businessPostingGroup; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = All;
            }
            field(productPostingGroup; Rec."VAT Prod. Posting Group")
            {
                ApplicationArea = All;
            }
            field(calculationType; Rec."VAT Calculation Type")
            {
                ApplicationArea = All;
            }
            field(percentage; Rec."VAT %")
            {
                ApplicationArea = All;
            }
            field(ID; Rec."VAT Identifier")
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