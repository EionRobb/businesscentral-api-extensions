page 50137 "Sales Invoice Extension"
{
    PageType = API;
    Caption = 'Sales Invoice Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'salesInvoice';
    EntitySetName = 'salesInvoices';
    DelayedInsert = true;

    SourceTable = "Sales Invoice Entity Aggregate";
    //SourceTable = 5475;
    ODataKeyFields = "Id";

    layout
    {
        area(Content)
        {
            field("id"; "Id") { ApplicationArea = All; }
            field("number"; "No.") { ApplicationArea = All; }
            part(salesInvoiceLines; "Sales Invoice Line Extension")
            {
                Caption = 'Lines', Locked = true;
                EntityName = 'salesInvoiceLine';
                EntitySetName = 'salesInvoiceLines';
                SubPageLink = "Document Id" = FIELD(Id);
            }
            field(lastModifiedDateTime; SystemModifiedAt)
            {
                ApplicationArea = All;
            }
        }
    }
}