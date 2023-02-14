page 50139 "Sales Header Extension"
{
    PageType = API;
    Caption = 'Sales Header Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'salesHeader';
    EntitySetName = 'salesHeaders';
    DelayedInsert = true;

    SourceTable = "Sales Header";
    //SourceTable = 36;
    ODataKeyFields = "Id";

    layout
    {
        area(Content)
        {
            field("id"; "Id") { ApplicationArea = All; }
            field("number"; "No.") { ApplicationArea = All; }

            field(externalDocumentNumber; "External Document No.") { ApplicationArea = All; }

            field(yourReference; "Your Reference") { ApplicationArea = All; }
            field(postingDescription; "Posting Description") { ApplicationArea = All; }
            field(lastModifiedDateTime; SystemModifiedAt)
            {
                ApplicationArea = All;
            }
        }
    }

    [ServiceEnabled]
    procedure Release(var actionContext: WebServiceActionContext)
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        ReleaseSalesDocument.PerformManualRelease(Rec);
    end;

    [ServiceEnabled]
    procedure CheckAndRelease(var actionContext: WebServiceActionContext)
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        ReleaseSalesDocument.PerformManualCheckAndRelease(Rec);
    end;

    [ServiceEnabled]
    procedure Reopen(var actionContext: WebServiceActionContext)
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        ReleaseSalesDocument.PerformManualReopen(Rec);
    end;

}