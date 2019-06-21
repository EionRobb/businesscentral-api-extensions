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

            field("customerNumber"; "Customer No.")
            {
                ApplicationArea = All;
            }
            field("code"; Code)
            {
                ApplicationArea = All;
            }
            field("name"; Name)
            {
                ApplicationArea = All;
            }
            field("address"; Address)
            {
                ApplicationArea = All;
            }
            field("name2"; "Name 2")
            {
                ApplicationArea = All;
            }
            field("address2"; "Address 2")
            {
                ApplicationArea = All;
            }
            field("city"; City)
            {
                ApplicationArea = All;
            }
            field("postcode"; "Post Code")
            {
                ApplicationArea = All;
            }
            field("county"; "County")
            {
                ApplicationArea = All;
            }
            field("regionCode"; "Country/Region Code")
            {
                ApplicationArea = All;
            }
        }
    }
}