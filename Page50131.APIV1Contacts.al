#pragma implicitwith disable
page 50131 "Contacts"
{
    PageType = API;
    Caption = 'Contacts';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'contact';
    EntitySetName = 'contacts';
    DelayedInsert = true;

    SourceTable = "Contact";
    //SourceTable = 5050;

    layout
    {
        area(Content)
        {
            field("number"; Rec."No.")
            {
                ApplicationArea = All;
            }
            field(type; Rec.Type)
            {
                ApplicationArea = All;
            }
            field("customerNumber"; Rec."Company No.")
            {
                ApplicationArea = All;
            }
            field("name"; Rec.Name)
            {
                ApplicationArea = All;
            }
            field("firstName"; Rec."First Name")
            {
                ApplicationArea = All;
            }
            field("surname"; Rec.Surname)
            {
                ApplicationArea = All;
            }
            field("email"; Rec."E-Mail")
            {
                ApplicationArea = All;
            }
            field("lastDateModified"; Rec."Last Date Modified")
            {
                ApplicationArea = All;
            }
            field("lastTimeModified"; Rec."Last Time Modified")
            {
                ApplicationArea = All;
            }
            field("salespersonCode"; Rec."Salesperson Code")
            {
                ApplicationArea = All;
            }
            field("phoneNumber"; Rec."Phone No.")
            {
                ApplicationArea = All;
            }
            field("mobilePhoneNumber"; Rec."Mobile Phone No.")
            {
                ApplicationArea = All;
            }
            field("faxNumber"; Rec."Fax No.")
            {
                ApplicationArea = All;
            }
            field("jobTitle"; Rec."Job Title")
            {
                ApplicationArea = All;
            }
            field("territoryCode"; Rec."Territory Code")
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
