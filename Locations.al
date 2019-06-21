
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
            field(code; Code)
            {
                ApplicationArea = All;
            }
            field(name; Name)
            {
                ApplicationArea = All;
            }
            field(name2; "Name 2")
            {
                ApplicationArea = All;
            }
            field(address; Address)
            {
                ApplicationArea = All;
            }
            field(address2; "Address 2")
            {
                ApplicationArea = All;
            }

        }
    }
}