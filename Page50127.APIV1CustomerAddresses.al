#pragma implicitwith disable
page 50127 "Customer Addresses"
{
    PageType = API;
    Caption = 'Customer Addresses Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'customerAddress';
    EntitySetName = 'customerAddresses';
    DelayedInsert = true;

    SourceTable = "Ship-to Address";
    //SourceTable = 222;

    layout
    {
        area(Content)
        {

            field("customerNumber"; Rec."Customer No.")
            {
                ApplicationArea = All;
            }
            field("code"; Rec.Code)
            {
                ApplicationArea = All;
            }
            field("name"; Rec.Name)
            {
                ApplicationArea = All;
            }
            field("address"; Rec.Address)
            {
                ApplicationArea = All;
            }
            field("name2"; Rec."Name 2")
            {
                ApplicationArea = All;
            }
            field("address2"; Rec."Address 2")
            {
                ApplicationArea = All;
            }
            field("city"; Rec.City)
            {
                ApplicationArea = All;
            }
            field("postcode"; Rec."Post Code")
            {
                ApplicationArea = All;
            }
            field("county"; Rec."County")
            {
                ApplicationArea = All;
            }
            field("regionCode"; Rec."Country/Region Code")
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
