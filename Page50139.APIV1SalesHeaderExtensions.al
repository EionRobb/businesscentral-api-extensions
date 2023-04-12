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
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            field("id"; Rec."SystemId") { ApplicationArea = All; }
            field("number"; Rec."No.") { ApplicationArea = All; }

            field(externalDocumentNumber; Rec."External Document No.") { ApplicationArea = All; }

            field(yourReference; Rec."Your Reference") { ApplicationArea = All; }
            field(postingDescription; Rec."Posting Description") { ApplicationArea = All; }
            field(status; Rec."Status")
            {
                ApplicationArea = All;
                Editable = False;
            }
            field(lastModifiedDateTime; Rec.SystemModifiedAt)
            {
                ApplicationArea = All;
                Editable = False;
            }
            /*part(salesOrder; "APIV1 - Sales Orders")
            {
                EntityName = 'salesOrder';
                EntitySetName = 'salesOrders';
                SubPageLink = "Document Id" = FIELD(SystemId);
            }*/
            /*part(salesOrder; "APIV1 - Sales Order Lines")
            {
                EntityName = 'salesOrderLine';
                EntitySetName = 'salesOrderLines';
                SubPageLink = "Document Id" = FIELD(SystemId);
            }*/
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        IF xRec.SystemId <> Rec.SystemId THEN
            ERROR('The id cannot be changed.');
        IF xRec."No." <> Rec."No." THEN
            ERROR('The number cannot be changed.');

    end;

    [ServiceEnabled]
    procedure Release(var actionContext: WebServiceActionContext)
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        ReleaseSalesDocument.PerformManualRelease(Rec);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Sales Header Extension");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    procedure CheckAndRelease(var actionContext: WebServiceActionContext)
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        ReleaseSalesDocument.PerformManualCheckAndRelease(Rec);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Sales Header Extension");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    procedure Reopen(var actionContext: WebServiceActionContext)
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin
        ReleaseSalesDocument.PerformManualReopen(Rec);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Sales Header Extension");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

}