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
            field("number"; "No.")
            {
                ApplicationArea = All;
            }
            field(type; Type)
            {
                ApplicationArea = All;
            }
            field("customerNumber"; "Company No.")
            {
                ApplicationArea = All;
            }
            field("name"; Name)
            {
                ApplicationArea = All;
            }
            field("firstName"; "First Name")
            {
                ApplicationArea = All;
            }
            field("surname"; Surname)
            {
                ApplicationArea = All;
            }
            field("email"; "E-Mail")
            {
                ApplicationArea = All;
            }
            field("lastDateModified"; "Last Date Modified")
            {
                ApplicationArea = All;
            }
            field("lastTimeModified"; "Last Time Modified")
            {
                ApplicationArea = All;
            }
            field("salespersonCode"; "Salesperson Code")
            {
                ApplicationArea = All;
            }
            field("phoneNumber"; "Phone No.")
            {
                ApplicationArea = All;
            }
            field("mobilePhoneNumber"; "Mobile Phone No.")
            {
                ApplicationArea = All;
            }
            field("faxNumber"; "Fax No.")
            {
                ApplicationArea = All;
            }
            field("jobTitle"; "Job Title")
            {
                ApplicationArea = All;
            }
            field("territoryCode"; "Territory Code")
            {
                ApplicationArea = All;
            }
        }
    }
}