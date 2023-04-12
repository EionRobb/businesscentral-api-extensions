#pragma implicitwith disable
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
            field("code"; Rec.Code)
            {
                ApplicationArea = All;
            }
            field("name"; Rec.Name)
            {
                ApplicationArea = All;
            }
            field("commissionPercent"; Rec."Commission %")
            {
                ApplicationArea = All;
            }
            field("email"; Rec."E-Mail")
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
