//https://github.com/YevgenKarpinka/Sprut_API_v16/blob/62cd5e33de49f797f94ddfe56e7f7a01eb7649aa/Page/Page50003.APIV2SalesInvoice.al
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
    ODataKeyFields = "No.";
    PageType = API;
    SourceTable = "Sales Header";
    //Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(number; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'number', Locked = true;
                    Editable = false;
                }
            }
        }
    }

    var

        errTotalPrepaymentAmountInvoiced: Label 'Total prepayment amount invoiced greater than 0.';

    [ServiceEnabled]
    procedure ApplyPrepayment()
    var
        actionContext: WebServiceActionContext;
    begin
        // Create Prepayment Invoice
        CreatePrepaymentInvoice(Rec);

        // Create and Assign Prepayment Ledger Entry
        CreatePrepaymentLedgerEntry(Rec);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::Prepayments);
        actionContext.AddEntityKey(Rec.FieldNo("No."), Rec."No.");
        actionContext.SetResultCode(WebServiceActionResultCode::Created);
    end;

    local procedure CreatePrepaymentInvoice(var SalesHeader: Record "Sales Header")
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
        SalesHeader.TestField("Prices Including VAT", true);

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

    local procedure CreatePrepaymentLedgerEntry(var SalesHeader: Record "Sales Header")
    //https://github.com/StefanMaron/MSDyn365BC.Code.History/blob/ac07586666c093cf6c764cf034973e9b590ef203/BaseApp/Source/Base%20Application/O365SalesInvoicePayment.Codeunit.al
    var
        InvoiceHeader: Record "Sales Invoice Header";
        PaymentRegistrationBuffer: Record "Payment Registration Buffer";
        PaymentRegistrationMgt: Codeunit "Payment Registration Mgt.";
    begin
        if not InvoiceHeader.Get(SalesHeader."Last Prepayment No.") then
            Error(errTotalPrepaymentAmountInvoiced, SalesHeader."Last Prepayment No.");

        PaymentRegistrationBuffer.PopulateTable();
        PaymentRegistrationBuffer.SetRange("Document Type", PaymentRegistrationBuffer."Document Type"::Invoice);
        PaymentRegistrationBuffer.SetRange("Document No.", SalesHeader."Last Prepayment No.");
        if not PaymentRegistrationBuffer.FindFirst() then
            Error(errTotalPrepaymentAmountInvoiced, SalesHeader."Last Prepayment No.");
        PaymentRegistrationBuffer.Validate("Payment Made", true);
        PaymentRegistrationBuffer.Validate("Limit Amount Received", true);
        PaymentRegistrationBuffer.Modify(true);

        PostPaymentRegistration(PaymentRegistrationBuffer);
    end;

    local procedure PostPaymentRegistration(var TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary)
    //https://github.com/StefanMaron/MSDyn365BC.Code.History/blob/7d293ac633253d200547ad7aab98bfd557aa1e6d/BaseApp/Source/Base%20Application/PaymentRegistrationMgt.Codeunit.al
    var
        BankAcc: Record "Bank Account";
        PaymentRegistrationSetup: Record "Payment Registration Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlTemplate: Record "Gen. Journal Template";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        PaymentToleranceManagement: Codeunit "Payment Tolerance Management";
        EmptyDateReceivedErr: Label 'Date Received is missing for line with Document No. %1.';
    begin
        PaymentRegistrationSetup.Get(UserId);
        PaymentRegistrationSetup.ValidateMandatoryFields(true);
        GenJnlTemplate.Get(PaymentRegistrationSetup."Journal Template Name");
        GenJnlBatch.Get(PaymentRegistrationSetup."Journal Template Name", PaymentRegistrationSetup."Journal Batch Name");

        GenJournalLine.SetRange("Journal Template Name", PaymentRegistrationSetup."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", PaymentRegistrationSetup."Journal Batch Name");
        if GenJournalLine.FindLast() then
            GenJournalLine.SetFilter("Line No.", '>%1', GenJournalLine."Line No.");

        //PaymentToleranceManagement.SetSuppressCommit(PreviewMode);
        TempPaymentRegistrationBuffer.FindSet();
        repeat
            if TempPaymentRegistrationBuffer."Date Received" = 0D then
                Error(EmptyDateReceivedErr, TempPaymentRegistrationBuffer."Document No.");

            UpdatePmtDiscountDateOnCustLedgerEntry(TempPaymentRegistrationBuffer);

            GenJournalLine.Init();
            //GenJournalLine.SetSuppressCommit(PreviewMode);
            GenJournalLine."Journal Template Name" := PaymentRegistrationSetup."Journal Template Name";
            GenJournalLine."Journal Batch Name" := PaymentRegistrationSetup."Journal Batch Name";
            GenJournalLine."Line No." += 10000;

            GenJournalLine."Source Code" := GenJnlTemplate."Source Code";
            GenJournalLine."Reason Code" := GenJnlBatch."Reason Code";
            GenJournalLine."Posting No. Series" := GenJnlBatch."Posting No. Series";

            GenJournalLine.Validate("Posting Date", TempPaymentRegistrationBuffer."Date Received");
            GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::Customer);
            if TempPaymentRegistrationBuffer."Document Type" = TempPaymentRegistrationBuffer."Document Type"::"Credit Memo" then
                GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Refund)
            else
                GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
            GenJournalLine."Document No." := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series", "Posting Date", false);
            GenJournalLine.Validate("Bal. Account Type", PaymentRegistrationSetup.GetGLBalAccountType);
            GenJournalLine.Validate("Account No.", TempPaymentRegistrationBuffer."Source No.");
            GenJournalLine.Validate(Amount, -TempPaymentRegistrationBuffer."Amount Received");
            GenJournalLine.Validate("Bal. Account No.", PaymentRegistrationSetup."Bal. Account No.");
            GenJournalLine.Validate("Payment Method Code", TempPaymentRegistrationBuffer."Payment Method Code");
            if GenJournalLine."Bal. Account Type" = "Bal. Account Type"::"Bank Account" then begin
                BankAcc.Get("Bal. Account No.");
                GenJournalLine.Validate("Currency Code", BankAcc."Currency Code");
            end;
            CheckCurrencyCode(TempPaymentRegistrationBuffer, GenJournalLine, PaymentRegistrationSetup);
            GenJournalLine.Validate("Applies-to Doc. Type", TempPaymentRegistrationBuffer."Document Type");
            GenJournalLine.Validate("Applies-to Doc. No.", TempPaymentRegistrationBuffer."Document No.");
            GenJournalLine.Validate("External Document No.", TempPaymentRegistrationBuffer."External Document No.");
            GenJournalLine.Validate(Description, CopyStr(
                StrSubstNo('Prepayment, %1 %2.', TempPaymentRegistrationBuffer."Document Type", TempPaymentRegistrationBuffer."Document No."),
                1, MaxStrLen(GenJournalLine."Description")
            ));
            GenJournalLine.Insert(true);
        until TempPaymentRegistrationBuffer.Next() = 0;

        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJournalLine);
    end;

    local procedure UpdatePmtDiscountDateOnCustLedgerEntry(TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.LockTable();
        CustLedgerEntry.Get(TempPaymentRegistrationBuffer."Ledger Entry No.");
        if CustLedgerEntry."Pmt. Discount Date" <> TempPaymentRegistrationBuffer."Pmt. Discount Date" then begin
            CustLedgerEntry."Pmt. Discount Date" := TempPaymentRegistrationBuffer."Pmt. Discount Date";
            CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", CustLedgerEntry);
        end;
    end;

    local procedure CheckCurrencyCode(var TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary; GenJnlLine: Record "Gen. Journal Line"; PaymentRegistrationSetup: Record "Payment Registration Setup")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ForeignCurrNotSuportedErr: Label 'The document with type %1 and description %2 must have the same currency code as the payment you are registering.';
    begin
        CustLedgerEntry.SetRange("Entry No.", TempPaymentRegistrationBuffer."Ledger Entry No.");
        CustLedgerEntry.SetFilter("Currency Code", '<>%1', GenJnlLine."Currency Code");
        if not CustLedgerEntry.IsEmpty() then
            Error(ForeignCurrNotSuportedErr, TempPaymentRegistrationBuffer."Document Type", TempPaymentRegistrationBuffer.Description);
    end;
}