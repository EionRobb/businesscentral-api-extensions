page 50134 "Salesperson Entity"
{
    PageType = API;
    Caption = 'Salesperson Entity';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'salesperson';
    EntitySetName = 'salespersons';
    DelayedInsert = true;

    SourceTable = "Salesperson/Purchaser";
    //SourceTable = 13;
    ODataKeyFields = Code;

    layout
    {
        area(Content)
        {
            field("code"; Code)
            {
                ApplicationArea = All;
            }
            field("name"; Name)
            {
                ApplicationArea = All;
            }
            field("commissionPercent"; "Commission %")
            {
                ApplicationArea = All;
            }
            field("email"; "E-Mail")
            {
                ApplicationArea = All;
            }

        }
    }
}