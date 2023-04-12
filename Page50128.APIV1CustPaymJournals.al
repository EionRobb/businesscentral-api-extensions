#pragma implicitwith disable
page 50128 "APIV1 - Cust. Paym. Journals"
{
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    Caption = 'customerPaymentJournals', Locked = true;
    DelayedInsert = true;
    EntityName = 'customerPaymentJournal';
    EntitySetName = 'customerPaymentJournals';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Gen. Journal Batch";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("code"; Rec.Name)
                {
                    Caption = 'code', Locked = true;
                    ShowMandatory = true;
                    ApplicationArea = All;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'displayName', Locked = true;
                    ApplicationArea = All;
                }
                field(lastModifiedDateTime; Rec."Last Modified DateTime")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    ApplicationArea = All;
                }
                field(balancingAccountId; Rec.BalAccountId)
                {
                    Caption = 'balancingAccountId', Locked = true;
                    ApplicationArea = All;
                }
                field(balancingAccountNumber; Rec."Bal. Account No.")
                {
                    Caption = 'balancingAccountNumber', Locked = true;
                    Editable = false;
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Journal Template Name" := GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName();
    end;

    trigger OnOpenPage()
    begin
        Rec.SETRANGE("Journal Template Name", GraphMgtJournal.GetDefaultCustomerPaymentsTemplateName());
    end;

    [ServiceEnabled]
    procedure post(var ActionContext: WebServiceActionContext)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GetBatch(GenJournalBatch);
        PostBatch(GenJournalBatch);
        SetActionResponse(ActionContext, Rec.SystemId);
    end;

    local procedure PostBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch.Name);
        IF NOT GenJournalLine.FINDFIRST() THEN
            ERROR(ThereIsNothingToPostErr);

        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
    end;

    local procedure GetBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        //if not GenJournalBatch.GetBySystemId(SystemId) then //TODO needs newer API version
        GenJournalBatch.SETRANGE(SystemId, Rec.SystemId);
        IF NOT GenJournalBatch.FINDFIRST() THEN
            Error(CannotFindBatchErr, Rec.SystemId);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; GenJournalBatchId: Guid)
    var
    begin

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Cust. Paym. Journals");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), GenJournalBatchId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    var
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        ThereIsNothingToPostErr: Label 'There is nothing to post.';
        CannotFindBatchErr: Label 'The General Journal Batch with ID %1 cannot be found.', Comment = '%1 - the System ID of the general journal batch';
}

#pragma implicitwith restore


