page 50129 "CustomerPayments"
{
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    Caption = 'customerPayments', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'customerPayment';
    EntitySetName = 'customerPayment';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Gen. Journal Line";
    //Extensible = false;
    //InsertAllowed = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
            }
        }
    }

    [ServiceEnabled]
    procedure post(var ActionContext: WebServiceActionContext)
    begin
        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", Rec);
        //CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", Rec);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::CustomerPayments);
        ActionContext.AddEntityKey(FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;
}


