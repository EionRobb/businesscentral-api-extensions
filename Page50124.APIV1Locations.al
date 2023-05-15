
page 50124 Locations
{
    PageType = API;
    Caption = 'Locations API';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'location';
    EntitySetName = 'locations';
    DelayedInsert = true;

    //SourceTable = 14;
    SourceTable = "Location";

    layout
    {
        area(Content)
        {
            field(code; Rec.Code)
            {
                ApplicationArea = All;
            }
            field(name; Rec.Name)
            {
                ApplicationArea = All;
            }
            field(name2; Rec."Name 2")
            {
                ApplicationArea = All;
            }
            field(address; Rec.Address)
            {
                ApplicationArea = All;
            }
            field(address2; Rec."Address 2")
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