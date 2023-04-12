#pragma implicitwith disable
page 50125 "Prepayments"
{
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    Caption = 'prepayments', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'prepayments';
    EntitySetName = 'prepayments';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Sales Header";
    //Extensible = false;
    //InsertAllowed = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(SalesOrderId; Rec.SystemId)
                {
                    Caption = 'SalesOrderId', Locked = true;
                    Editable = false;
                    ApplicationArea = All;
                }
                field(SalesOrderNumber; Rec."No.")
                {
                    Caption = 'SalesOrderNumber', Locked = true;
                    Editable = false;
                    ApplicationArea = All;
                }
                field(PrepaymentInvoiceNumber; Rec."Last Prepayment No.")
                {
                    Caption = 'PrepaymentInvoiceNumber', Locked = true;
                    Editable = false;
                    ApplicationArea = All;
                }
                field(CustomerNumber; Rec."Bill-to Customer No.")
                {
                    Caption = 'CustomerNumber', Locked = true;
                    Editable = false;
                    ApplicationArea = All;
                }
                field(ExternalDocumentNumber; Rec."External Document No.")
                {
                    Caption = 'ExternalDocumentNumber', Locked = true;
                    Editable = false;
                    ApplicationArea = All;
                }
                field(AmountIncludingVAT; Rec."Amount Including VAT")
                {
                    Caption = 'AmountIncludingVAT', Locked = true;
                    Editable = false;
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

    [ServiceEnabled]
    procedure CreatePrepayment(var actionContext: WebServiceActionContext)
    begin
        // Create Prepayment Invoice
        CreatePrepaymentInvoice(Rec);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::Prepayments);
        //actionContext.AddEntityKey(Rec.FieldNo("Last Prepayment No."), Rec."Last Prepayment No.");  // Already set as part of the Rec update
        //actionContext.AddEntityKey(Rec.FieldNo("No."), Rec."No.");
        actionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        actionContext.SetResultCode(WebServiceActionResultCode::Created);
    end;

    local procedure CreatePrepaymentInvoice(var SalesHeader: Record "Sales Header")
    //https://github.com/YevgenKarpinka/Sprut_API_v16/blob/62cd5e33de49f797f94ddfe56e7f7a01eb7649aa/Page/Page50003.APIV2SalesInvoice.al
    var
        PostPrepayments: Codeunit "Post Prepayments";
    begin
        // Validate Mandatory Fields/Values
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.TestField(Status, SalesHeader.Status::Open);
        SalesHeader.TestField("Sell-to Customer No.");
        SalesHeader.TestField("Bill-to Customer No.");
        SalesHeader.TestField("Posting Date");
        SalesHeader.TestField("Due Date");
        //SalesHeader.TestField("Prices Including VAT", true);

        // Update Sales Order Prepayment Fields
        UpdateSalesOrderPrepaymentFields(SalesHeader);

        // Post Prepayment Invoice
        PostPrepayments.PostPrepaymentInvoice(SalesHeader);
    end;

    local procedure UpdateSalesOrderPrepaymentFields(var SalesHeader: Record "Sales Header")
    var
        orderModified: Boolean;
        salesOrderLines: Record "Sales Line";
        salesOrderLineSums: Record "Sales Line";
        totalOrderAmount: Decimal;
        diffLineAmount: Decimal;
        diffAmounts: Decimal;
        errTotalPrepaymentAmountInvoiced: Label 'Total prepayment amount invoiced greater than 0.';
    begin
        // Update Sales Order Header Fields
        orderModified := false;
        if SalesHeader."Prepayment %" <> 100.00 then begin
            SalesHeader."Prepayment %" := 100.00;
            orderModified := true;
        end;
        if SalesHeader."Document Date" <> SalesHeader."Posting Date" then begin
            SalesHeader."Document Date" := SalesHeader."Posting Date";
            orderModified := true;
        end;
        if SalesHeader."Prepayment Due Date" <> SalesHeader."Due Date" then begin
            SalesHeader."Prepayment Due Date" := SalesHeader."Due Date";
            orderModified := true;
        end;
        if orderModified then
            SalesHeader.Modify();

        // Update Sales Order Line Fields
        salesOrderLines.SetRange("Document Type", salesOrderLines."Document Type"::Order);
        salesOrderLines.SetRange("Document No.", SalesHeader."No.");
        salesOrderLines.SetFilter(Quantity, '<>%1', 0);

        // Calculate Total Order Amount
        salesOrderLineSums.CopyFilters(salesOrderLines);
        salesOrderLineSums.CalcSums("Line Amount", "Prepmt. Line Amount", "Prepmt. Amt. Inv.");
        if salesOrderLineSums."Prepmt. Amt. Inv." > 0 then
            Error(errTotalPrepaymentAmountInvoiced, salesOrderLineSums."Prepmt. Amt. Inv.");
        totalOrderAmount := salesOrderLineSums."Line Amount";

        // Update Sales Line Prepayment Amount
        salesOrderLines.SetCurrentKey("Line No.", Quantity);
        salesOrderLines.FindSet(true, false);
        repeat
            salesOrderLines.Validate("Prepmt. Line Amount", salesOrderLines."Prepmt. Amt. Inv.");
            if salesOrderLines."Line Amount" > salesOrderLines."Prepmt. Amt. Inv." then begin
                diffLineAmount := salesOrderLines."Line Amount" - salesOrderLines."Prepmt. Amt. Inv.";
                if diffLineAmount >= totalOrderAmount then begin
                    diffAmounts := totalOrderAmount;
                end else begin
                    diffAmounts := diffLineAmount;
                end;
                salesOrderLines.Validate("Prepmt. Line Amount", salesOrderLines."Prepmt. Amt. Inv." + diffAmounts);
                totalOrderAmount -= diffAmounts;
            end;
            salesOrderLines.Modify(true);
        until salesOrderLines.Next() = 0;
    end;
}
#pragma implicitwith restore
