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
            field(businessPostingGroup; "VAT Bus. Posting Group")
            {
                ApplicationArea = All;
            }
            field(productPostingGroup; "VAT Prod. Posting Group")
            {
                ApplicationArea = All;
            }
            field(calculationType; "VAT Calculation Type")
            {
                ApplicationArea = All;
            }
            field(percentage; "VAT %")
            {
                ApplicationArea = All;
            }
            field(ID; "VAT Identifier")
            {
                ApplicationArea = All;
            }


        }
    }
}