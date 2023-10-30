//https://github.com/YevgenKarpinka/Sprut_API_v16/blob/23b1af30e62f02283066330c23431de9757ed542/Codeunit/Codeunit50002.SalesPostPrepaymentsSprut.al
codeunit 50130 "Post Prepayments"
{
    Permissions = TableData "Sales Line" = imd,
                  TableData "Invoice Posting Buffer" = imd,
                  TableData "Sales Invoice Header" = imd,
                  TableData "Sales Invoice Line" = imd,
                  TableData "Sales Cr.Memo Header" = imd,
                  TableData "Sales Cr.Memo Line" = imd,
                  TableData "General Posting Setup" = imd;
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        Execute(Rec);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        GenPostingSetup: Record "General Posting Setup";
        TempGlobalPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer" temporary;
        PrepmtDocumentType: Enum "Sales Document Type";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        SuppressCommit: Boolean;
        PreviewMode: Boolean;
        Text000: Label 'is not within your range of allowed posting dates';
        Text001: Label 'There is nothing to post.';
        Text012: Label 'Prepayment %1, %2 %3.';
        Text018: Label 'must be positive when %1 is not 0';
        Text019: Label 'Invoice,Credit Memo';

    procedure PostPrepaymentInvoice(var SalesHeader2: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
    begin
        SalesHeader.Copy(SalesHeader2);
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        SetDocumentType(SalesHeader."Document Type"::Invoice);
        Commit();
        IF NOT Run(SalesHeader) THEN
            ErrorMessageHandler.ShowErrors;
        SalesHeader2 := SalesHeader;
    end;

    local procedure SetDocumentType(DocumentType: Enum "Sales Document Type")
    begin
        PrepmtDocumentType := DocumentType;
    end;

    local procedure Execute(var SalesHeader: Record "Sales Header")
    begin
        case PrepmtDocumentType of
            PrepmtDocumentType::Invoice:
                Invoice(SalesHeader);
            PrepmtDocumentType::"Credit Memo":
                CreditMemo(SalesHeader);
        end;
    end;

    local procedure Invoice(var SalesHeader: Record "Sales Header")
    var
        Handled: Boolean;
    begin
        if not Handled then
            Code(SalesHeader, 0);
    end;

    local procedure CreditMemo(var SalesHeader: Record "Sales Header")
    var
        Handled: Boolean;
    begin
        if not Handled then
            Code(SalesHeader, 1);
    end;

    local procedure "Code"(var SalesHeader2: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo")
    var
        SourceCodeSetup: Record "Source Code Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TempPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer" temporary;
        TotalPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer";
        TotalPrepmtInvLineBufferLCY: Record "Prepayment Inv. Line Buffer";
        GenJnlLine: Record "Gen. Journal Line";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        TempVATAmountLineDeduct: Record "VAT Amount Line" temporary;
        CustLedgEntry: Record "Cust. Ledger Entry";
        TempSalesLines: Record "Sales Line" temporary;
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        GenJnlLineDocNo: Code[20];
        GenJnlLineExtDocNo: Code[35];
        SrcCode: Code[10];
        PostingNoSeriesCode: Code[20];
        ModifyHeader: Boolean;
        CalcPmtDiscOnCrMemos: Boolean;
        PostingDescription: Text[100];
        GenJnlLineDocType: Enum "Gen. Journal Document Type";
        PrevLineNo: Integer;
        LineCount: Integer;
        PostedDocTabNo: Integer;
        LineNo: Integer;
    begin
        SalesHeader := SalesHeader2;
        GLSetup.Get();
        SalesSetup.Get();

        CheckPrepmtDoc(SalesHeader, DocumentType);

        UpdateDocNos(SalesHeader, DocumentType, GenJnlLineDocNo, PostingNoSeriesCode, ModifyHeader);

        if not PreviewMode and ModifyHeader then begin
            SalesHeader.Modify;
            if not SuppressCommit then
                Commit();
        end;

        SourceCodeSetup.Get();
        SrcCode := SourceCodeSetup.Sales;
        if SalesHeader."Prepmt. Posting Description" <> '' then
            PostingDescription := SalesHeader."Prepmt. Posting Description"
        else
            PostingDescription :=
              CopyStr(
                StrSubstNo(Text012, SelectStr(1 + DocumentType, Text019), SalesHeader."Document Type", SalesHeader."No."),
                1, MaxStrLen(SalesHeader."Posting Description"));

        // Create posted header
        if SalesSetup."Ext. Doc. No. Mandatory" then
            SalesHeader.TestField("External Document No.");
        case DocumentType of
            DocumentType::Invoice:
                begin
                    InsertSalesInvHeader(SalesInvHeader, SalesHeader, PostingDescription, GenJnlLineDocNo, SrcCode, PostingNoSeriesCode);
                    GenJnlLineDocType := GenJnlLine."Document Type"::Invoice;
                    PostedDocTabNo := DATABASE::"Sales Invoice Header";
                end;
            DocumentType::"Credit Memo":
                begin
                    CalcPmtDiscOnCrMemos := GetCalcPmtDiscOnCrMemos(SalesHeader."Prepmt. Payment Terms Code");
                    InsertSalesCrMemoHeader(
                      SalesCrMemoHeader, SalesHeader, PostingDescription, GenJnlLineDocNo, SrcCode, PostingNoSeriesCode,
                      CalcPmtDiscOnCrMemos);
                    GenJnlLineDocType := GenJnlLine."Document Type"::"Credit Memo";
                    PostedDocTabNo := DATABASE::"Sales Cr.Memo Header";
                end;
        end;
        GenJnlLineExtDocNo := SalesHeader."External Document No.";
        // Reverse old lines
        if DocumentType = DocumentType::Invoice then begin
            GetSalesLinesToDeduct(SalesHeader, TempSalesLines);
            if not TempSalesLines.IsEmpty then
                CalcVATAmountLines(SalesHeader, TempSalesLines, TempVATAmountLineDeduct, DocumentType::"Credit Memo");
        end;

        // Create Lines
        TempPrepmtInvLineBuffer.DeleteAll();
        CalcVATAmountLines(SalesHeader, SalesLine, TempVATAmountLine, DocumentType);
        TempVATAmountLine.DeductVATAmountLine(TempVATAmountLineDeduct);
        UpdateVATOnLines(SalesHeader, SalesLine, TempVATAmountLine, DocumentType);
        BuildInvLineBuffer(SalesHeader, SalesLine, DocumentType, TempPrepmtInvLineBuffer, true);
        TempPrepmtInvLineBuffer.FindSet();
        repeat
            LineCount := LineCount + 1;
            if TempPrepmtInvLineBuffer."Line No." <> 0 then
                LineNo := PrevLineNo + TempPrepmtInvLineBuffer."Line No."
            else
                LineNo := PrevLineNo + 10000;
            case DocumentType of
                DocumentType::Invoice:
                    begin
                        InsertSalesInvLine(SalesInvHeader, LineNo, TempPrepmtInvLineBuffer, SalesHeader);
                        PostedDocTabNo := DATABASE::"Sales Invoice Line";
                    end;
                DocumentType::"Credit Memo":
                    begin
                        InsertSalesCrMemoLine(SalesCrMemoHeader, LineNo, TempPrepmtInvLineBuffer, SalesHeader);
                        PostedDocTabNo := DATABASE::"Sales Cr.Memo Line";
                    end;
            end;
            PrevLineNo := LineNo;
            InsertExtendedText(
              PostedDocTabNo, GenJnlLineDocNo, TempPrepmtInvLineBuffer."G/L Account No.", SalesHeader."Document Date", SalesHeader."Language Code", PrevLineNo);
        until TempPrepmtInvLineBuffer.Next = 0;

        // G/L Posting
        LineCount := 0;
        if not SalesHeader."Compress Prepayment" then
            TempPrepmtInvLineBuffer.CompressBuffer;
        TempPrepmtInvLineBuffer.SetRange(Adjustment, false);
        TempPrepmtInvLineBuffer.FindSet(true);
        repeat
            if DocumentType = DocumentType::Invoice then
                TempPrepmtInvLineBuffer.ReverseAmounts;
            RoundAmounts(SalesHeader, TempPrepmtInvLineBuffer, TotalPrepmtInvLineBuffer, TotalPrepmtInvLineBufferLCY);
            if SalesHeader."Currency Code" = '' then begin
                AdjustInvLineBuffers(SalesHeader, TempPrepmtInvLineBuffer, TotalPrepmtInvLineBuffer, DocumentType);
                TotalPrepmtInvLineBufferLCY := TotalPrepmtInvLineBuffer;
            end else
                AdjustInvLineBuffers(SalesHeader, TempPrepmtInvLineBuffer, TotalPrepmtInvLineBufferLCY, DocumentType);
            TempPrepmtInvLineBuffer.Modify();
        until TempPrepmtInvLineBuffer.Next = 0;

        TempPrepmtInvLineBuffer.Reset();
        TempPrepmtInvLineBuffer.SetCurrentKey(Adjustment);
        TempPrepmtInvLineBuffer.FindLast();
        repeat
            LineCount := LineCount + 1;

            PostPrepmtInvLineBuffer(
              SalesHeader, TempPrepmtInvLineBuffer, DocumentType, PostingDescription,
              GenJnlLineDocType, GenJnlLineDocNo, GenJnlLineExtDocNo, SrcCode, PostingNoSeriesCode);
        until TempPrepmtInvLineBuffer.Next(-1) = 0;

        // Post customer entry
        PostCustomerEntry(
          SalesHeader, TotalPrepmtInvLineBuffer, TotalPrepmtInvLineBufferLCY, DocumentType, PostingDescription,
          GenJnlLineDocType, GenJnlLineDocNo, GenJnlLineExtDocNo, SrcCode, PostingNoSeriesCode, CalcPmtDiscOnCrMemos);

        UpdatePostedSalesDocument(DocumentType, GenJnlLineDocNo);

        // Balancing account
        if SalesHeader."Bal. Account No." <> '' then begin
            CustLedgEntry.FindLast;
            PostBalancingEntry(
              SalesHeader, TotalPrepmtInvLineBuffer, TotalPrepmtInvLineBufferLCY, CustLedgEntry, DocumentType,
              PostingDescription, GenJnlLineDocType, GenJnlLineDocNo, GenJnlLineExtDocNo, SrcCode, PostingNoSeriesCode);
        end;

        // Update lines & header
        UpdateSalesDocument(SalesHeader, SalesLine, DocumentType, GenJnlLineDocNo);
        if SalesHeader.TestStatusIsNotPendingPrepayment then
            SalesHeader.Status := SalesHeader.Status::"Pending Prepayment";
        SalesHeader.Modify;

        if PreviewMode then begin
            GenJnlPostPreview.ThrowError;
        end;

        SalesHeader2 := SalesHeader;
    end;

    procedure CheckPrepmtDoc(SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo")
    var
        Cust: Record Customer;
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        CheckDimensions: Codeunit "Check Dimensions";
        ErrorMessageMgt: Codeunit "Error Message Management";
    begin
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.TestField("Sell-to Customer No.");
        SalesHeader.TestField("Bill-to Customer No.");
        SalesHeader.TestField("Posting Date");
        SalesHeader.TestField("Document Date");
        if GenJnlCheckLine.DateNotAllowed(SalesHeader."Posting Date") then
            SalesHeader.FieldError("Posting Date", Text000);

        if not CheckOpenPrepaymentLines(SalesHeader, DocumentType) then
            Error(Text001);

        CheckDimensions.CheckSalesPrepmtDim(SalesHeader);
        ErrorMessageMgt.Finish(SalesHeader.RecordId);
        Cust.Get(SalesHeader."Sell-to Customer No.");
        Cust.CheckBlockedCustOnDocs(Cust, PrepmtDocTypeToDocType(DocumentType), false, true);
        if SalesHeader."Bill-to Customer No." <> SalesHeader."Sell-to Customer No." then begin
            Cust.Get(SalesHeader."Bill-to Customer No.");
            Cust.CheckBlockedCustOnDocs(Cust, PrepmtDocTypeToDocType(DocumentType), false, true);
        end;
    end;

    local procedure CheckOpenPrepaymentLines(SalesHeader: Record "Sales Header"; DocumentType: Option) Found: Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        ApplyFilter(SalesHeader, DocumentType, SalesLine);
        if SalesLine.FindSet(true) then
            repeat
                if not Found then
                    Found := PrepmtAmount(SalesLine, DocumentType) <> 0;
                if (SalesLine."Prepayment VAT Identifier" = '') and (SalesLine."Prepmt. Amt. Inv." = 0) then begin
                    SalesLine.UpdatePrepmtSetupFields;
                    SalesLine.Modify;
                end;
            until SalesLine.Next = 0;
        exit(Found);
    end;

    local procedure ApplyFilter(SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo",Statistic; var SalesLine: Record "Sales Line")
    begin
        SalesLine.Reset;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        if DocumentType in [DocumentType::Invoice, DocumentType::Statistic] then
            SalesLine.SetFilter("Prepmt. Line Amount", '<>0')
        else
            SalesLine.SetFilter("Prepmt. Amt. Inv.", '<>0');
    end;

    local procedure PrepmtAmount(SalesLine: Record "Sales Line"; DocumentType: Option Invoice,"Credit Memo",Statistic): Decimal
    begin
        case DocumentType of
            DocumentType::Statistic:
                exit(SalesLine."Prepmt. Line Amount");
            DocumentType::Invoice:
                exit(SalesLine."Prepmt. Line Amount" - SalesLine."Prepmt. Amt. Inv.");
            else
                exit(SalesLine."Prepmt. Amt. Inv." - SalesLine."Prepmt Amt Deducted");
        end;
    end;

    local procedure PrepmtDocTypeToDocType(DocumentType: Option Invoice,"Credit Memo"): Integer
    begin
        case DocumentType of
            DocumentType::Invoice:
                exit(2);
            DocumentType::"Credit Memo":
                exit(3);
        end;
        exit(2);
    end;

    local procedure UpdateDocNos(var SalesHeader: Record "Sales Header"; DocumentType: Option Invoice,"Credit Memo"; var DocNo: Code[20]; var NoSeriesCode: Code[20]; var ModifyHeader: Boolean)
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        ModifyHeader := false;
        case DocumentType of
            DocumentType::Invoice:
                begin
                    SalesHeader.TestField("Prepayment Due Date");
                    SalesHeader.TestField("Prepmt. Cr. Memo No.", '');
                    if SalesHeader."Prepayment No." = '' then
                        if not PreviewMode then begin
                            //TODO set the "Prepayment No. Series" if one hasn't yet been set, to allow capturing payments on old orders
                            SalesHeader.TestField("Prepayment No. Series");
                            SalesHeader."Prepayment No." := NoSeriesMgt.GetNextNo(SalesHeader."Prepayment No. Series", SalesHeader."Posting Date", true);
                            ModifyHeader := true;
                        end else
                            SalesHeader."Prepayment No." := '***';
                    DocNo := SalesHeader."Prepayment No.";
                    NoSeriesCode := SalesHeader."Prepayment No. Series";
                end;
            DocumentType::"Credit Memo":
                begin
                    SalesHeader.TestField("Prepayment No.", '');
                    if SalesHeader."Prepmt. Cr. Memo No." = '' then
                        if not PreviewMode then begin
                            SalesHeader.TestField("Prepmt. Cr. Memo No. Series");
                            SalesHeader."Prepmt. Cr. Memo No." := NoSeriesMgt.GetNextNo(SalesHeader."Prepmt. Cr. Memo No. Series", SalesHeader."Posting Date", true);
                            ModifyHeader := true;
                        end else
                            SalesHeader."Prepmt. Cr. Memo No." := '***';
                    DocNo := SalesHeader."Prepmt. Cr. Memo No.";
                    NoSeriesCode := SalesHeader."Prepmt. Cr. Memo No. Series";
                end;
        end;
    end;

    local procedure InsertSalesInvHeader(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; PostingDescription: Text[100]; GenJnlLineDocNo: Code[20]; SrcCode: Code[10]; PostingNoSeriesCode: Code[20])
    begin
        SalesInvHeader.Init();
        SalesInvHeader.TransferFields(SalesHeader);
        SalesInvHeader."Posting Description" := PostingDescription;
        SalesInvHeader."Payment Terms Code" := SalesHeader."Prepmt. Payment Terms Code";
        SalesInvHeader."Due Date" := SalesHeader."Prepayment Due Date";
        SalesInvHeader."Pmt. Discount Date" := SalesHeader."Prepmt. Pmt. Discount Date";
        SalesInvHeader."Payment Discount %" := SalesHeader."Prepmt. Payment Discount %";
        SalesInvHeader."No." := GenJnlLineDocNo;
        SalesInvHeader."Pre-Assigned No. Series" := '';
        SalesInvHeader."Source Code" := SrcCode;
        SalesInvHeader."User ID" := UserId;
        SalesInvHeader."No. Printed" := 0;
        SalesInvHeader."Prepayment Invoice" := true;
        SalesInvHeader."Prepayment Order No." := SalesHeader."No.";
        SalesInvHeader."No. Series" := PostingNoSeriesCode;
        SalesInvHeader.Insert();
        CopyHeaderCommentLines(SalesHeader."No.", DATABASE::"Sales Invoice Header", GenJnlLineDocNo);
    end;

    local procedure InsertSalesInvLine(SalesInvHeader: Record "Sales Invoice Header"; LineNo: Integer; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; SalesHeader: Record "Sales Header")
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.Init();
        SalesInvLine."Document No." := SalesInvHeader."No.";
        SalesInvLine."Line No." := LineNo;
        SalesInvLine."Sell-to Customer No." := SalesInvHeader."Sell-to Customer No.";
        SalesInvLine."Bill-to Customer No." := SalesInvHeader."Bill-to Customer No.";
        SalesInvLine.Type := SalesInvLine.Type::"G/L Account";
        SalesInvLine."No." := PrepmtInvLineBuffer."G/L Account No.";
        SalesInvLine."Posting Date" := SalesInvHeader."Posting Date";
        SalesInvLine."Shortcut Dimension 1 Code" := PrepmtInvLineBuffer."Global Dimension 1 Code";
        SalesInvLine."Shortcut Dimension 2 Code" := PrepmtInvLineBuffer."Global Dimension 2 Code";
        SalesInvLine."Dimension Set ID" := PrepmtInvLineBuffer."Dimension Set ID";
        SalesInvLine.Description := PrepmtInvLineBuffer.Description;
        SalesInvLine.Quantity := 1;
        if SalesInvHeader."Prices Including VAT" then begin
            SalesInvLine."Unit Price" := PrepmtInvLineBuffer."Amount Incl. VAT";
            SalesInvLine."Line Amount" := PrepmtInvLineBuffer."Amount Incl. VAT";
        end else begin
            SalesInvLine."Unit Price" := PrepmtInvLineBuffer.Amount;
            SalesInvLine."Line Amount" := PrepmtInvLineBuffer.Amount;
        end;
        SalesInvLine."Gen. Bus. Posting Group" := PrepmtInvLineBuffer."Gen. Bus. Posting Group";
        SalesInvLine."Gen. Prod. Posting Group" := PrepmtInvLineBuffer."Gen. Prod. Posting Group";
        SalesInvLine."VAT Bus. Posting Group" := PrepmtInvLineBuffer."VAT Bus. Posting Group";
        SalesInvLine."VAT Prod. Posting Group" := PrepmtInvLineBuffer."VAT Prod. Posting Group";
        SalesInvLine."VAT %" := PrepmtInvLineBuffer."VAT %";
        SalesInvLine.Amount := PrepmtInvLineBuffer.Amount;
        SalesInvLine."VAT Difference" := PrepmtInvLineBuffer."VAT Difference";
        SalesInvLine."Amount Including VAT" := PrepmtInvLineBuffer."Amount Incl. VAT";
        SalesInvLine."VAT Calculation Type" := PrepmtInvLineBuffer."VAT Calculation Type";
        SalesInvLine."VAT Base Amount" := PrepmtInvLineBuffer."VAT Base Amount";
        SalesInvLine."VAT Identifier" := PrepmtInvLineBuffer."VAT Identifier";
        SalesInvLine.Insert();
        CopyLineCommentLines(
          SalesHeader."No.", DATABASE::"Sales Invoice Header", SalesInvHeader."No.", PrepmtInvLineBuffer."Line No.", LineNo);
    end;

    local procedure InsertSalesCrMemoHeader(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header"; PostingDescription: Text[100]; GenJnlLineDocNo: Code[20]; SrcCode: Code[10]; PostingNoSeriesCode: Code[20]; CalcPmtDiscOnCrMemos: Boolean)
    begin
        SalesCrMemoHeader.Init();
        SalesCrMemoHeader.TransferFields(SalesHeader);
        SalesCrMemoHeader."Payment Terms Code" := SalesHeader."Prepmt. Payment Terms Code";
        SalesCrMemoHeader."Pmt. Discount Date" := SalesHeader."Prepmt. Pmt. Discount Date";
        SalesCrMemoHeader."Payment Discount %" := SalesHeader."Prepmt. Payment Discount %";
        if (SalesHeader."Prepmt. Payment Terms Code" <> '') and not CalcPmtDiscOnCrMemos then begin
            SalesCrMemoHeader."Payment Discount %" := 0;
            SalesCrMemoHeader."Pmt. Discount Date" := 0D;
        end;
        SalesCrMemoHeader."Posting Description" := PostingDescription;
        SalesCrMemoHeader."Due Date" := SalesHeader."Prepayment Due Date";
        SalesCrMemoHeader."No." := GenJnlLineDocNo;
        SalesCrMemoHeader."Pre-Assigned No. Series" := '';
        SalesCrMemoHeader."Source Code" := SrcCode;
        SalesCrMemoHeader."User ID" := UserId;
        SalesCrMemoHeader."No. Printed" := 0;
        SalesCrMemoHeader."Prepayment Credit Memo" := true;
        SalesCrMemoHeader."Prepayment Order No." := SalesHeader."No.";
        SalesCrMemoHeader.Correction := GLSetup."Mark Cr. Memos as Corrections";
        SalesCrMemoHeader."No. Series" := PostingNoSeriesCode;
        SalesCrMemoHeader.Insert();
        CopyHeaderCommentLines(SalesHeader."No.", DATABASE::"Sales Cr.Memo Header", GenJnlLineDocNo);
    end;

    local procedure InsertSalesCrMemoLine(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; LineNo: Integer; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; SalesHeader: Record "Sales Header")
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        SalesCrMemoLine.Init();
        SalesCrMemoLine."Document No." := SalesCrMemoHeader."No.";
        SalesCrMemoLine."Line No." := LineNo;
        SalesCrMemoLine."Sell-to Customer No." := SalesCrMemoHeader."Sell-to Customer No.";
        SalesCrMemoLine."Bill-to Customer No." := SalesCrMemoHeader."Bill-to Customer No.";
        SalesCrMemoLine.Type := SalesCrMemoLine.Type::"G/L Account";
        SalesCrMemoLine."No." := PrepmtInvLineBuffer."G/L Account No.";
        SalesCrMemoLine."Posting Date" := SalesCrMemoHeader."Posting Date";
        SalesCrMemoLine."Shortcut Dimension 1 Code" := PrepmtInvLineBuffer."Global Dimension 1 Code";
        SalesCrMemoLine."Shortcut Dimension 2 Code" := PrepmtInvLineBuffer."Global Dimension 2 Code";
        SalesCrMemoLine."Dimension Set ID" := PrepmtInvLineBuffer."Dimension Set ID";
        SalesCrMemoLine.Description := PrepmtInvLineBuffer.Description;
        SalesCrMemoLine.Quantity := 1;
        if SalesCrMemoHeader."Prices Including VAT" then begin
            SalesCrMemoLine."Unit Price" := PrepmtInvLineBuffer."Amount Incl. VAT";
            SalesCrMemoLine."Line Amount" := PrepmtInvLineBuffer."Amount Incl. VAT";
        end else begin
            SalesCrMemoLine."Unit Price" := PrepmtInvLineBuffer.Amount;
            SalesCrMemoLine."Line Amount" := PrepmtInvLineBuffer.Amount;
        end;
        SalesCrMemoLine."Gen. Bus. Posting Group" := PrepmtInvLineBuffer."Gen. Bus. Posting Group";
        SalesCrMemoLine."Gen. Prod. Posting Group" := PrepmtInvLineBuffer."Gen. Prod. Posting Group";
        SalesCrMemoLine."VAT Bus. Posting Group" := PrepmtInvLineBuffer."VAT Bus. Posting Group";
        SalesCrMemoLine."VAT Prod. Posting Group" := PrepmtInvLineBuffer."VAT Prod. Posting Group";
        SalesCrMemoLine."VAT %" := PrepmtInvLineBuffer."VAT %";
        SalesCrMemoLine.Amount := PrepmtInvLineBuffer.Amount;
        SalesCrMemoLine."VAT Difference" := PrepmtInvLineBuffer."VAT Difference";
        SalesCrMemoLine."Amount Including VAT" := PrepmtInvLineBuffer."Amount Incl. VAT";
        SalesCrMemoLine."VAT Calculation Type" := PrepmtInvLineBuffer."VAT Calculation Type";
        SalesCrMemoLine."VAT Base Amount" := PrepmtInvLineBuffer."VAT Base Amount";
        SalesCrMemoLine."VAT Identifier" := PrepmtInvLineBuffer."VAT Identifier";
        SalesCrMemoLine.Insert();
        CopyLineCommentLines(
          SalesHeader."No.", DATABASE::"Sales Cr.Memo Header", SalesCrMemoHeader."No.", PrepmtInvLineBuffer."Line No.", LineNo);
    end;

    local procedure GetCalcPmtDiscOnCrMemos(PrepmtPmtTermsCode: Code[10]): Boolean
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if PrepmtPmtTermsCode = '' then
            exit(false);
        PaymentTerms.Get(PrepmtPmtTermsCode);
        exit(PaymentTerms."Calc. Pmt. Disc. on Cr. Memos");
    end;

    local procedure CopyHeaderCommentLines(FromNumber: Code[20]; ToDocType: Integer; ToNumber: Code[20])
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        if not SalesSetup."Copy Comments Order to Invoice" then
            exit;

        case ToDocType of
            DATABASE::"Sales Invoice Header":
                SalesCommentLine.CopyHeaderComments(SalesCommentLine."Document Type"::Order, SalesCommentLine."Document Type"::"Posted Invoice", FromNumber, ToNumber);
            DATABASE::"Sales Cr.Memo Header":
                SalesCommentLine.CopyHeaderComments(SalesCommentLine."Document Type"::Order, SalesCommentLine."Document Type"::"Posted Credit Memo", FromNumber, ToNumber);
        end;
    end;

    local procedure CopyLineCommentLines(FromNumber: Code[20]; ToDocType: Integer; ToNumber: Code[20]; FromLineNo: Integer; ToLineNo: Integer)
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        if not SalesSetup."Copy Comments Order to Invoice" then
            exit;

        case ToDocType of
            DATABASE::"Sales Invoice Header":
                SalesCommentLine.CopyLineComments(SalesCommentLine."Document Type"::Order, SalesCommentLine."Document Type"::"Posted Invoice", FromNumber, ToNumber, FromLineNo, ToLineNo);
            DATABASE::"Sales Cr.Memo Header":
                SalesCommentLine.CopyLineComments(SalesCommentLine."Document Type"::Order, SalesCommentLine."Document Type"::"Posted Credit Memo", FromNumber, ToNumber, FromLineNo, ToLineNo);
        end;
    end;

    procedure GetSalesLinesToDeduct(SalesHeader: Record "Sales Header"; var SalesLines: Record "Sales Line")
    var
        SalesLine: Record "Sales Line";
    begin
        ApplyFilter(SalesHeader, 1, SalesLine);
        if SalesLine.FindSet then
            repeat
                if (PrepmtAmount(SalesLine, 0) <> 0) and (PrepmtAmount(SalesLine, 1) <> 0) then begin
                    SalesLines := SalesLine;
                    SalesLines.Insert();
                end;
            until SalesLine.Next = 0;
    end;

    procedure UpdateVATOnLines(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; DocumentType: Option Invoice,"Credit Memo",Statistic)
    var
        TempVATAmountLineRemainder: Record "VAT Amount Line" temporary;
        Currency: Record Currency;
        PrepmtAmt: Decimal;
        NewAmount: Decimal;
        NewAmountIncludingVAT: Decimal;
        NewVATBaseAmount: Decimal;
        VATAmount: Decimal;
        VATDifference: Decimal;
        PrepmtAmtToInvTotal: Decimal;
        RemainderExists: Boolean;
    begin
        Currency.Initialize(SalesHeader."Currency Code");

        ApplyFilter(SalesHeader, DocumentType, SalesLine);
        SalesLine.CalcSums("Prepmt. Line Amount", "Prepmt. Amt. Inv.");
        PrepmtAmtToInvTotal := SalesLine."Prepmt. Line Amount" - SalesLine."Prepmt. Amt. Inv.";
        if SalesLine.FindSet(true, false) then
            repeat
                PrepmtAmt := PrepmtAmount(SalesLine, DocumentType);
                if PrepmtAmt <> 0 then begin
                    VATAmountLine.Get(
                      SalesLine."Prepayment VAT Identifier", SalesLine."Prepmt. VAT Calc. Type", SalesLine."Prepayment Tax Group Code", false, PrepmtAmt >= 0);
                    if VATAmountLine.Modified then begin
                        RemainderExists :=
                          TempVATAmountLineRemainder.Get(
                            SalesLine."Prepayment VAT Identifier", SalesLine."Prepmt. VAT Calc. Type", SalesLine."Prepayment Tax Group Code", false, PrepmtAmt >= 0);
                        if not RemainderExists then begin
                            TempVATAmountLineRemainder := VATAmountLine;
                            TempVATAmountLineRemainder.Init();
                            TempVATAmountLineRemainder.Insert();
                        end;

                        if SalesHeader."Prices Including VAT" then begin
                            if PrepmtAmt = 0 then begin
                                VATAmount := 0;
                                NewAmountIncludingVAT := 0;
                            end else begin
                                VATAmount :=
                                  TempVATAmountLineRemainder."VAT Amount" +
                                  VATAmountLine."VAT Amount" * PrepmtAmt / VATAmountLine."Line Amount";
                                NewAmountIncludingVAT :=
                                  TempVATAmountLineRemainder."Amount Including VAT" +
                                  VATAmountLine."Amount Including VAT" * PrepmtAmt / VATAmountLine."Line Amount";
                            end;
                            NewAmount :=
                              Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision") -
                              Round(VATAmount, Currency."Amount Rounding Precision");
                            NewVATBaseAmount :=
                              Round(
                                NewAmount * (1 - SalesHeader."VAT Base Discount %" / 100),
                                Currency."Amount Rounding Precision");
                        end else begin
                            if SalesLine."VAT Calculation Type" = SalesLine."VAT Calculation Type"::"Full VAT" then begin
                                VATAmount := PrepmtAmt;
                                NewAmount := 0;
                                NewVATBaseAmount := 0;
                            end else begin
                                NewAmount := PrepmtAmt;
                                NewVATBaseAmount :=
                                  Round(
                                    NewAmount * (1 - SalesHeader."VAT Base Discount %" / 100),
                                    Currency."Amount Rounding Precision");
                                if VATAmountLine."VAT Base" = 0 then
                                    VATAmount := 0
                                else
                                    VATAmount :=
                                      TempVATAmountLineRemainder."VAT Amount" +
                                      VATAmountLine."VAT Amount" * NewAmount / VATAmountLine."VAT Base";
                            end;
                            NewAmountIncludingVAT := NewAmount + Round(VATAmount, Currency."Amount Rounding Precision");
                        end;

                        SalesLine."Prepayment Amount" := NewAmount;
                        SalesLine."Prepmt. Amt. Incl. VAT" :=
                          Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision");
                        SalesLine."Prepmt. VAT Base Amt." := NewVATBaseAmount;

                        if (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount") = 0 then
                            VATDifference := 0
                        else
                            if PrepmtAmtToInvTotal = 0 then
                                VATDifference :=
                                  VATAmountLine."VAT Difference" * (SalesLine."Prepmt. Line Amount" - SalesLine."Prepmt. Amt. Inv.") /
                                  (VATAmountLine."Line Amount" - VATAmountLine."Invoice Discount Amount")
                            else
                                VATDifference :=
                                  VATAmountLine."VAT Difference" * (SalesLine."Prepmt. Line Amount" - SalesLine."Prepmt. Amt. Inv.") /
                                  PrepmtAmtToInvTotal;

                        SalesLine."Prepayment VAT Difference" := Round(VATDifference, Currency."Amount Rounding Precision");

                        SalesLine.Modify;

                        TempVATAmountLineRemainder."Amount Including VAT" :=
                          NewAmountIncludingVAT - Round(NewAmountIncludingVAT, Currency."Amount Rounding Precision");
                        TempVATAmountLineRemainder."VAT Amount" := VATAmount - NewAmountIncludingVAT + NewAmount;
                        TempVATAmountLineRemainder."VAT Difference" := VATDifference - SalesLine."Prepayment VAT Difference";
                        TempVATAmountLineRemainder.Modify();
                    end;
                end;
            until SalesLine.Next = 0;

    end;

    procedure CalcVATAmountLines(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var VATAmountLine: Record "VAT Amount Line"; DocumentType: Option Invoice,"Credit Memo",Statistic)
    var
        Currency: Record Currency;
        NewAmount: Decimal;
        NewPrepmtVATDiffAmt: Decimal;
    begin
        Currency.Initialize(SalesHeader."Currency Code");

        VATAmountLine.DeleteAll();

        ApplyFilter(SalesHeader, DocumentType, SalesLine);
        if SalesLine.FindSet() then
            repeat
                NewAmount := PrepmtAmount(SalesLine, DocumentType);
                if NewAmount <> 0 then begin
                    if DocumentType = DocumentType::Invoice then
                        NewAmount := SalesLine."Prepmt. Line Amount";
                    if SalesLine."Prepmt. VAT Calc. Type" in
                       [SalesLine."VAT Calculation Type"::"Reverse Charge VAT", SalesLine."VAT Calculation Type"::"Sales Tax"]
                    then
                        SalesLine."VAT %" := 0;
                    if not VATAmountLine.Get(
                         SalesLine."Prepayment VAT Identifier", SalesLine."Prepmt. VAT Calc. Type", SalesLine."Prepayment Tax Group Code", false, NewAmount >= 0)
                    then begin
#if BUILD_REGION_AUNZ
                        VATAmountLine.InsertNewLine(
                          SalesLine."Prepayment VAT Identifier",
                          SalesLine."Prepmt. VAT Calc. Type",
                          SalesLine."Prepayment Tax Group Code",
                          false,
                          SalesLine."Prepayment VAT %",
                          NewAmount >= 0,
                          true,
                          /*
                           * Added to fix "There is no argument given that corresponds to the required formal parameter 'IsFullGST'"
                           */
                          false
                        );
#endif
                    end;

                    VATAmountLine."Line Amount" := VATAmountLine."Line Amount" + NewAmount;
                    NewPrepmtVATDiffAmt := PrepmtVATDiffAmount(SalesLine, DocumentType);
                    if DocumentType = DocumentType::Invoice then
                        NewPrepmtVATDiffAmt := SalesLine."Prepayment VAT Difference" + SalesLine."Prepmt VAT Diff. to Deduct" +
                          SalesLine."Prepmt VAT Diff. Deducted";
                    VATAmountLine."VAT Difference" := VATAmountLine."VAT Difference" + NewPrepmtVATDiffAmt;
                    VATAmountLine.Modify();
                end;
            until SalesLine.Next = 0;

        VATAmountLine.UpdateLines(
          NewAmount,
          Currency,
          SalesHeader."Currency Factor",
          SalesHeader."Prices Including VAT",
          SalesHeader."VAT Base Discount %",
          SalesHeader."Tax Area Code",
          SalesHeader."Tax Liable",
          SalesHeader."Posting Date"
        /*
         * Removed to fix  "No overload for method 'UpdateLines' takes 9 arguments"
         */
        //,false
        );

    end;

    local procedure PrepmtVATDiffAmount(SalesLine: Record "Sales Line"; DocumentType: Option Invoice,"Credit Memo",Statistic): Decimal
    begin
        case DocumentType of
            DocumentType::Statistic:
                exit(SalesLine."Prepayment VAT Difference");
            DocumentType::Invoice:
                exit(SalesLine."Prepayment VAT Difference");
            else
                exit(SalesLine."Prepmt VAT Diff. to Deduct");
        end;
    end;

    procedure BuildInvLineBuffer(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentType: Option Invoice,"Credit Memo",Statistic; var PrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer")
    begin
        BuildInvLineBuffer(SalesHeader, SalesLine, DocumentType, PrepmtInvLineBuf, false);
    end;

    local procedure BuildInvLineBuffer(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentType: Option; var TempPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer" temporary; UpdateLines: Boolean)
    var
        PrepmtInvLineBuf2: Record "Prepayment Inv. Line Buffer";
        TotalPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer";
        TotalPrepmtInvLineBufferDummy: Record "Prepayment Inv. Line Buffer";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        TempGlobalPrepmtInvLineBuf.Reset();
        TempGlobalPrepmtInvLineBuf.DeleteAll();
        SalesSetup.Get();
        ApplyFilter(SalesHeader, DocumentType, SalesLine);
        if SalesLine.FindSet() then
            repeat
                if PrepmtAmount(SalesLine, DocumentType) <> 0 then begin
                    if SalesLine.Quantity < 0 then
                        SalesLine.FieldError(Quantity, StrSubstNo(Text018, SalesHeader.FieldCaption("Prepayment %")));
                    if SalesLine."Unit Price" < 0 then
                        SalesLine.FieldError("Unit Price", StrSubstNo(Text018, SalesHeader.FieldCaption("Prepayment %")));

                    FillInvLineBuffer(SalesHeader, SalesLine, PrepmtInvLineBuf2);
                    if UpdateLines then
                        TempGlobalPrepmtInvLineBuf.CopyWithLineNo(PrepmtInvLineBuf2, SalesLine."Line No.");
                    TempPrepmtInvLineBuf.InsertInvLineBuffer(PrepmtInvLineBuf2);
                    if SalesSetup."Invoice Rounding" then
                        RoundAmounts(SalesHeader, PrepmtInvLineBuf2, TotalPrepmtInvLineBuffer, TotalPrepmtInvLineBufferDummy);
                end;
            until SalesLine.Next = 0;
        if SalesSetup."Invoice Rounding" then
            if InsertInvoiceRounding(
                 SalesHeader, PrepmtInvLineBuf2, TotalPrepmtInvLineBuffer, SalesLine."Line No.")
            then
                TempPrepmtInvLineBuf.InsertInvLineBuffer(PrepmtInvLineBuf2);
    end;

    procedure FillInvLineBuffer(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var PrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer")
    begin
        PrepmtInvLineBuf.Init;
        PrepmtInvLineBuf."G/L Account No." := GetPrepmtAccNo(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");

        if not SalesHeader."Compress Prepayment" then begin
            PrepmtInvLineBuf."Line No." := SalesLine."Line No.";
            PrepmtInvLineBuf.Description := SalesLine.Description;
        end;

        PrepmtInvLineBuf.CopyFromSalesLine(SalesLine);
        PrepmtInvLineBuf.FillFromGLAcc(SalesHeader."Compress Prepayment");

        PrepmtInvLineBuf.SetAmounts(
          SalesLine."Prepayment Amount", SalesLine."Prepmt. Amt. Incl. VAT", SalesLine."Prepayment Amount",
          SalesLine."Prepayment Amount", SalesLine."Prepayment Amount", SalesLine."Prepayment VAT Difference");

        PrepmtInvLineBuf."VAT Amount" := SalesLine."Prepmt. Amt. Incl. VAT" - SalesLine."Prepayment Amount";
        PrepmtInvLineBuf."VAT Amount (ACY)" := SalesLine."Prepmt. Amt. Incl. VAT" - SalesLine."Prepayment Amount";
        PrepmtInvLineBuf."VAT Base Before Pmt. Disc." := -SalesLine."Prepayment Amount";

    end;

    local procedure InsertInvoiceRounding(SalesHeader: Record "Sales Header"; var PrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; TotalPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; PrevLineNo: Integer): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        if InitInvoiceRoundingLine(SalesHeader, TotalPrepmtInvLineBuf."Amount Incl. VAT", SalesLine) then begin
            CreateDimensions(SalesLine);

            PrepmtInvLineBuf.Init;
            PrepmtInvLineBuf."Line No." := PrevLineNo + 10000;
            PrepmtInvLineBuf."Invoice Rounding" := true;
            PrepmtInvLineBuf."G/L Account No." := SalesLine."No.";

            PrepmtInvLineBuf.CopyFromSalesLine(SalesLine);
            PrepmtInvLineBuf."Gen. Bus. Posting Group" := SalesHeader."Gen. Bus. Posting Group";
            PrepmtInvLineBuf."VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";

            PrepmtInvLineBuf.SetAmounts(
              SalesLine."Line Amount", SalesLine."Amount Including VAT", SalesLine."Line Amount",
              SalesLine."Prepayment Amount", SalesLine."Line Amount", 0);

            PrepmtInvLineBuf."VAT Amount" := SalesLine."Amount Including VAT" - SalesLine."Line Amount";
            PrepmtInvLineBuf."VAT Amount (ACY)" := SalesLine."Amount Including VAT" - SalesLine."Line Amount";
            exit(true);
        end;
    end;

    local procedure InitInvoiceRoundingLine(SalesHeader: Record "Sales Header"; TotalAmount: Decimal; var SalesLine: Record "Sales Line"): Boolean
    var
        Currency: Record Currency;
        InvoiceRoundingAmount: Decimal;
    begin
        Currency.Initialize(SalesHeader."Currency Code");
        Currency.TestField("Invoice Rounding Precision");
        InvoiceRoundingAmount :=
          -Round(
            TotalAmount -
            Round(
              TotalAmount,
              Currency."Invoice Rounding Precision",
              Currency.InvoiceRoundingDirection),
            Currency."Amount Rounding Precision");

        if InvoiceRoundingAmount = 0 then
            exit(false);

        SalesLine.SetHideValidationDialog(true);
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."System-Created Entry" := true;
        SalesLine.Type := SalesLine.Type::"G/L Account";
        SalesLine.Validate("No.", GetInvRoundingAccNo(SalesHeader."Customer Posting Group"));
        SalesLine.Validate(Quantity, 1);
        if SalesHeader."Prices Including VAT" then
            SalesLine.Validate("Unit Price", InvoiceRoundingAmount)
        else
            SalesLine.Validate(
              SalesLine."Unit Price",
              Round(
                InvoiceRoundingAmount /
                (1 + (1 - SalesHeader."VAT Base Discount %" / 100) * SalesLine."VAT %" / 100),
                Currency."Amount Rounding Precision"));
        SalesLine."Prepayment Amount" := SalesLine."Unit Price";
        SalesLine.Validate("Amount Including VAT", InvoiceRoundingAmount);
        exit(true);
    end;

    local procedure RoundAmounts(SalesHeader: Record "Sales Header"; var PrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; var TotalPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; var TotalPrepmtInvLineBufLCY: Record "Prepayment Inv. Line Buffer")
    var
        VAT: Boolean;
    begin
        TotalPrepmtInvLineBuf.IncrAmounts(PrepmtInvLineBuf);

        if SalesHeader."Currency Code" <> '' then begin
            VAT := PrepmtInvLineBuf.Amount <> PrepmtInvLineBuf."Amount Incl. VAT";
            PrepmtInvLineBuf."Amount Incl. VAT" :=
              AmountToLCY(SalesHeader, TotalPrepmtInvLineBuf."Amount Incl. VAT", TotalPrepmtInvLineBufLCY."Amount Incl. VAT");
            if VAT then
                PrepmtInvLineBuf.Amount := AmountToLCY(SalesHeader, TotalPrepmtInvLineBuf.Amount, TotalPrepmtInvLineBufLCY.Amount)
            else
                PrepmtInvLineBuf.Amount := PrepmtInvLineBuf."Amount Incl. VAT";
            PrepmtInvLineBuf."VAT Amount" := PrepmtInvLineBuf."Amount Incl. VAT" - PrepmtInvLineBuf.Amount;
            if PrepmtInvLineBuf."VAT Base Amount" <> 0 then
                PrepmtInvLineBuf."VAT Base Amount" := PrepmtInvLineBuf.Amount;
        end;

        TotalPrepmtInvLineBufLCY.IncrAmounts(PrepmtInvLineBuf);
    end;

    local procedure AmountToLCY(SalesHeader: Record "Sales Header"; TotalAmt: Decimal; PrevTotalAmt: Decimal): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        CurrExchRate.Init();
        exit(
          Round(
            CurrExchRate.ExchangeAmtFCYToLCY(SalesHeader."Posting Date", SalesHeader."Currency Code", TotalAmt, SalesHeader."Currency Factor")) -
          PrevTotalAmt);
    end;

    procedure GetInvRoundingAccNo(CustomerPostingGroup: Code[20]): Code[20]
    var
        CustPostingGr: Record "Customer Posting Group";
        GLAcc: Record "G/L Account";
    begin
        CustPostingGr.Get(CustomerPostingGroup);
        GLAcc.Get(CustPostingGr.GetInvRoundingAccount);
        exit(CustPostingGr."Invoice Rounding Account");
    end;

    local procedure CreateDimensions(var SalesLine: Record "Sales Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        DimMgt: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
        // BC 23 Update                 
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        SourceCodeSetup.Get();
        TableID[1] := DATABASE::"G/L Account";
        No[1] := SalesLine."No.";
        TableID[2] := DATABASE::Job;
        No[2] := SalesLine."Job No.";
        TableID[3] := DATABASE::"Responsibility Center";
        No[3] := SalesLine."Responsibility Center";
        SalesLine."Shortcut Dimension 1 Code" := '';
        SalesLine."Shortcut Dimension 2 Code" := '';

        // Deprecated BC 23
        //  SalesLine."Dimension Set ID" :=
        //      DimMgt.GetRecDefaultDimID(
        //        SalesLine, 0, TableID, No, SourceCodeSetup.Sales,
        //      SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code", SalesLine."Dimension Set ID", DATABASE::Customer);                
        // BC 23 Update                         
        // https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/codeunit/base-application-codeunit-dimensionmanagement        
        // https://community.dynamics.com/forums/thread/details/?threadid=41e004d5-ff52-ee11-be6f-00224827ed7b
        DimMgt.AddDimSource(DefaultDimSource, TableID[1], No[1]);
        DimMgt.AddDimSource(DefaultDimSource, TableID[2], No[2]);
        DimMgt.AddDimSource(DefaultDimSource, TableID[3], No[3]);
        SalesLine."Dimension Set ID" := DimMgt.GetRecDefaultDimID(SalesLine, 0, DefaultDimSource, SourceCodeSetup.Sales, SalesLine."Shortcut Dimension 1 Code", SalesLine."Shortcut Dimension 2 Code", SalesLine."Dimension Set ID", DATABASE::Customer);
    end;

    local procedure GetPrepmtAccNo(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20]): Code[20]
    begin
        if (GenBusPostingGroup <> GenPostingSetup."Gen. Bus. Posting Group") or
           (GenProdPostingGroup <> GenPostingSetup."Gen. Prod. Posting Group")
        then
            GenPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup);
        exit(GenPostingSetup.GetSalesPrepmtAccount);
    end;

    local procedure InsertExtendedText(TabNo: Integer; DocNo: Code[20]; GLAccNo: Code[20]; DocDate: Date; LanguageCode: Code[10]; var PrevLineNo: Integer)
    var
        TempExtTextLine: Record "Extended Text Line" temporary;
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TransferExtText: Codeunit "Transfer Extended Text";
        NextLineNo: Integer;
    begin
        TransferExtText.PrepmtGetAnyExtText(GLAccNo, TabNo, DocDate, LanguageCode, TempExtTextLine);
        if TempExtTextLine.FindSet() then begin
            NextLineNo := PrevLineNo + 10000;
            repeat
                case TabNo of
                    DATABASE::"Sales Invoice Line":
                        begin
                            SalesInvLine.Init();
                            SalesInvLine."Document No." := DocNo;
                            SalesInvLine."Line No." := NextLineNo;
                            SalesInvLine.Description := TempExtTextLine.Text;
                            SalesInvLine.Insert();
                        end;
                    DATABASE::"Sales Cr.Memo Line":
                        begin
                            SalesCrMemoLine.Init();
                            SalesCrMemoLine."Document No." := DocNo;
                            SalesCrMemoLine."Line No." := NextLineNo;
                            SalesCrMemoLine.Description := TempExtTextLine.Text;
                            SalesCrMemoLine.Insert();
                        end;
                end;
                PrevLineNo := NextLineNo;
                NextLineNo := NextLineNo + 10000;
            until TempExtTextLine.Next = 0;
        end;
    end;

    local procedure AdjustInvLineBuffers(SalesHeader: Record "Sales Header"; var PrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; var TotalPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; DocumentType: Option Invoice,"Credit Memo")
    var
        VATAdjustment: array[2] of Decimal;
        VAT: Option ,Base,Amount;
    begin
        CalcPrepmtAmtInvLCYInLines(SalesHeader, PrepmtInvLineBuf, DocumentType, VATAdjustment);
        if Abs(VATAdjustment[VAT::Base]) > GLSetup."Amount Rounding Precision" then
            InsertCorrInvLineBuffer(PrepmtInvLineBuf, SalesHeader, VATAdjustment[VAT::Base])
        else
            if (VATAdjustment[VAT::Base] <> 0) or (VATAdjustment[VAT::Amount] <> 0) then begin
                PrepmtInvLineBuf.AdjustVATBase(VATAdjustment);
                TotalPrepmtInvLineBuf.AdjustVATBase(VATAdjustment);
            end;
    end;

    local procedure CalcPrepmtAmtInvLCYInLines(SalesHeader: Record "Sales Header"; var PrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; DocumentType: Option Invoice,"Credit Memo"; var VATAdjustment: array[2] of Decimal)
    var
        SalesLine: Record "Sales Line";
        PrepmtInvBufAmount: array[2] of Decimal;
        TotalAmount: array[2] of Decimal;
        LineAmount: array[2] of Decimal;
        Ratio: array[2] of Decimal;
        PrepmtAmtReminder: array[2] of Decimal;
        PrepmtAmountRnded: array[2] of Decimal;
        VAT: Option ,Base,Amount;
    begin
        PrepmtInvLineBuf.AmountsToArray(PrepmtInvBufAmount);
        if DocumentType = DocumentType::Invoice then
            ReverseDecArray(PrepmtInvBufAmount);

        TempGlobalPrepmtInvLineBuf.SetFilterOnPKey(PrepmtInvLineBuf);
        TempGlobalPrepmtInvLineBuf.CalcSums(Amount, "Amount Incl. VAT");
        TempGlobalPrepmtInvLineBuf.AmountsToArray(TotalAmount);
        for VAT := VAT::Base to VAT::Amount do
            if TotalAmount[VAT] = 0 then
                Ratio[VAT] := 0
            else
                Ratio[VAT] := PrepmtInvBufAmount[VAT] / TotalAmount[VAT];
        if TempGlobalPrepmtInvLineBuf.FindSet then
            repeat
                TempGlobalPrepmtInvLineBuf.AmountsToArray(LineAmount);
                PrepmtAmountRnded[VAT::Base] :=
                  CalcRoundedAmount(LineAmount[VAT::Base], Ratio[VAT::Base], PrepmtAmtReminder[VAT::Base]);
                PrepmtAmountRnded[VAT::Amount] :=
                  CalcRoundedAmount(LineAmount[VAT::Amount], Ratio[VAT::Amount], PrepmtAmtReminder[VAT::Amount]);

                SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", TempGlobalPrepmtInvLineBuf."Line No.");
                if DocumentType = DocumentType::"Credit Memo" then begin
                    VATAdjustment[VAT::Base] += SalesLine."Prepmt. Amount Inv. (LCY)" - PrepmtAmountRnded[VAT::Base];
                    SalesLine."Prepmt. Amount Inv. (LCY)" := 0;
                    VATAdjustment[VAT::Amount] += SalesLine."Prepmt. VAT Amount Inv. (LCY)" - PrepmtAmountRnded[VAT::Amount];
                    SalesLine."Prepmt. VAT Amount Inv. (LCY)" := 0;
                end else begin
                    SalesLine."Prepmt. Amount Inv. (LCY)" += PrepmtAmountRnded[VAT::Base];
                    SalesLine."Prepmt. VAT Amount Inv. (LCY)" += PrepmtAmountRnded[VAT::Amount];
                end;
                SalesLine.Modify();
            until TempGlobalPrepmtInvLineBuf.Next = 0;
        TempGlobalPrepmtInvLineBuf.DeleteAll();
    end;

    local procedure ReverseDecArray(var DecArray: array[2] of Decimal)
    var
        Idx: Integer;
    begin
        for Idx := 1 to ArrayLen(DecArray) do
            DecArray[Idx] := -DecArray[Idx];
    end;

    local procedure CalcRoundedAmount(LineAmount: Decimal; Ratio: Decimal; var Reminder: Decimal) RoundedAmount: Decimal
    var
        Amount: Decimal;
    begin
        Amount := Reminder + LineAmount * Ratio;
        RoundedAmount := Round(Amount);
        Reminder := Amount - RoundedAmount;
    end;

    local procedure InsertCorrInvLineBuffer(var PrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer"; SalesHeader: Record "Sales Header"; VATBaseAdjustment: Decimal)
    var
        NewPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer";
        SavedPrepmtInvLineBuf: Record "Prepayment Inv. Line Buffer";
        AdjmtAmountACY: Decimal;
    begin
        SavedPrepmtInvLineBuf := PrepmtInvLineBuf;

        if SalesHeader."Currency Code" = '' then
            AdjmtAmountACY := VATBaseAdjustment
        else
            AdjmtAmountACY := 0;

        NewPrepmtInvLineBuf.FillAdjInvLineBuffer(
          PrepmtInvLineBuf,
          GetPrepmtAccNo(PrepmtInvLineBuf."Gen. Bus. Posting Group", PrepmtInvLineBuf."Gen. Prod. Posting Group"),
          VATBaseAdjustment, AdjmtAmountACY);
        PrepmtInvLineBuf.InsertInvLineBuffer(NewPrepmtInvLineBuf);

        NewPrepmtInvLineBuf.FillAdjInvLineBuffer(
          PrepmtInvLineBuf,
          GetCorrBalAccNo(SalesHeader, VATBaseAdjustment > 0),
          -VATBaseAdjustment, -AdjmtAmountACY);
        PrepmtInvLineBuf.InsertInvLineBuffer(NewPrepmtInvLineBuf);

        PrepmtInvLineBuf := SavedPrepmtInvLineBuf;
    end;

    procedure GetCorrBalAccNo(SalesHeader: Record "Sales Header"; PositiveAmount: Boolean): Code[20]
    var
        BalAccNo: Code[20];
    begin
        if SalesHeader."Currency Code" = '' then
            BalAccNo := GetInvRoundingAccNo(SalesHeader."Customer Posting Group")
        else
            BalAccNo := GetGainLossGLAcc(SalesHeader."Currency Code", PositiveAmount);
        exit(BalAccNo);
    end;

    local procedure GetGainLossGLAcc(CurrencyCode: Code[10]; PositiveAmount: Boolean): Code[20]
    var
        Currency: Record Currency;
    begin
        Currency.Get(CurrencyCode);
        if PositiveAmount then
            exit(Currency.GetRealizedGainsAccount);
        exit(Currency.GetRealizedLossesAccount);
    end;

    local procedure PostPrepmtInvLineBuffer(SalesHeader: Record "Sales Header"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; DocumentType: Option Invoice,"Credit Memo"; PostingDescription: Text[100]; DocType: Enum "Gen. Journal Document Type"; DocNo: Code[20];
                                                                                                                                                                                                                                   ExtDocNo: Text[35];
                                                                                                                                                                                                                                   SrcCode: Code[10];
                                                                                                                                                                                                                                   PostingNoSeriesCode: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.InitNewLine(
          SalesHeader."Posting Date", SalesHeader."Document Date", PostingDescription,
          PrepmtInvLineBuffer."Global Dimension 1 Code", PrepmtInvLineBuffer."Global Dimension 2 Code",
          PrepmtInvLineBuffer."Dimension Set ID", SalesHeader."Reason Code");

        GenJnlLine.CopyDocumentFields(DocType, DocNo, ExtDocNo, SrcCode, PostingNoSeriesCode);
        GenJnlLine.CopyFromSalesHeaderPrepmt(SalesHeader);
        GenJnlLine.CopyFromPrepmtInvoiceBuffer(PrepmtInvLineBuffer);

        if not PrepmtInvLineBuffer.Adjustment then
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::Sale;
        GenJnlLine.Correction :=
          (DocumentType = DocumentType::"Credit Memo") and GLSetup."Mark Cr. Memos as Corrections";

        RunGenJnlPostLine(GenJnlLine);
    end;

    local procedure RunGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure PostCustomerEntry(SalesHeader: Record "Sales Header"; TotalPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; TotalPrepmtInvLineBufferLCY: Record "Prepayment Inv. Line Buffer"; DocumentType: Option Invoice,"Credit Memo"; PostingDescription: Text[100]; DocType: Enum "Gen. Journal Document Type"; DocNo: Code[20];
                                                                                                                                                                                                                                                                                                     ExtDocNo: Text[35];
                                                                                                                                                                                                                                                                                                     SrcCode: Code[10];
                                                                                                                                                                                                                                                                                                     PostingNoSeriesCode: Code[20];
                                                                                                                                                                                                                                                                                                     CalcPmtDisc: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.InitNewLine(
          SalesHeader."Posting Date", SalesHeader."Document Date", PostingDescription,
          SalesHeader."Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 2 Code",
          SalesHeader."Dimension Set ID", SalesHeader."Reason Code");

        GenJnlLine.CopyDocumentFields(DocType, DocNo, ExtDocNo, SrcCode, PostingNoSeriesCode);

        GenJnlLine.CopyFromSalesHeaderPrepmtPost(SalesHeader, (DocumentType = DocumentType::Invoice) or CalcPmtDisc);

        GenJnlLine.Amount := -TotalPrepmtInvLineBuffer."Amount Incl. VAT";
        GenJnlLine."Source Currency Amount" := -TotalPrepmtInvLineBuffer."Amount Incl. VAT";
        GenJnlLine."Amount (LCY)" := -TotalPrepmtInvLineBufferLCY."Amount Incl. VAT";
        GenJnlLine."Sales/Purch. (LCY)" := -TotalPrepmtInvLineBufferLCY.Amount;
        GenJnlLine."Profit (LCY)" := -TotalPrepmtInvLineBufferLCY.Amount;

        GenJnlLine.Correction := (DocumentType = DocumentType::"Credit Memo") and GLSetup."Mark Cr. Memos as Corrections";

        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure UpdatePostedSalesDocument(DocumentType: Option Invoice,"Credit Memo"; DocumentNo: Code[20])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case DocumentType of
            DocumentType::Invoice:
                begin
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
                    CustLedgerEntry.SetRange("Document No.", DocumentNo);
                    CustLedgerEntry.FindFirst;
                    SalesInvoiceHeader.Get(DocumentNo);
                    SalesInvoiceHeader."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
                    SalesInvoiceHeader.Modify();
                end;
            DocumentType::"Credit Memo":
                begin
                    CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                    CustLedgerEntry.SetRange("Document No.", DocumentNo);
                    CustLedgerEntry.FindFirst;
                    SalesCrMemoHeader.Get(DocumentNo);
                    SalesCrMemoHeader."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
                    SalesCrMemoHeader.Modify();
                end;
        end;
    end;

    local procedure PostBalancingEntry(SalesHeader: Record "Sales Header"; TotalPrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer"; TotalPrepmtInvLineBufferLCY: Record "Prepayment Inv. Line Buffer"; CustLedgEntry: Record "Cust. Ledger Entry"; DocumentType: Option Invoice,"Credit Memo"; PostingDescription: Text[100]; DocType: Enum "Gen. Journal Document Type"; DocNo: Code[20];
                                                                                                                                                                                                                                                                                                                                                  ExtDocNo: Text[35];
                                                                                                                                                                                                                                                                                                                                                  SrcCode: Code[10];
                                                                                                                                                                                                                                                                                                                                                  PostingNoSeriesCode: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.InitNewLine(
          SalesHeader."Posting Date", SalesHeader."Document Date", PostingDescription,
          SalesHeader."Shortcut Dimension 1 Code", SalesHeader."Shortcut Dimension 2 Code",
          SalesHeader."Dimension Set ID", SalesHeader."Reason Code");

        if DocType = GenJnlLine."Document Type"::"Credit Memo" then
            GenJnlLine.CopyDocumentFields(GenJnlLine."Document Type"::Refund, DocNo, ExtDocNo, SrcCode, PostingNoSeriesCode)
        else
            GenJnlLine.CopyDocumentFields(GenJnlLine."Document Type"::Payment, DocNo, ExtDocNo, SrcCode, PostingNoSeriesCode);

        GenJnlLine.CopyFromSalesHeaderPrepmtPost(SalesHeader, false);
        if SalesHeader."Bal. Account Type" = SalesHeader."Bal. Account Type"::"Bank Account" then
            GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
        GenJnlLine."Bal. Account No." := SalesHeader."Bal. Account No.";

        GenJnlLine.Amount := TotalPrepmtInvLineBuffer."Amount Incl. VAT" + CustLedgEntry."Remaining Pmt. Disc. Possible";
        GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
        CustLedgEntry.CalcFields(Amount);
        if CustLedgEntry.Amount = 0 then
            GenJnlLine."Amount (LCY)" := TotalPrepmtInvLineBufferLCY."Amount Incl. VAT"
        else
            GenJnlLine."Amount (LCY)" :=
              TotalPrepmtInvLineBufferLCY."Amount Incl. VAT" +
              Round(
                CustLedgEntry."Remaining Pmt. Disc. Possible" / CustLedgEntry."Adjusted Currency Factor");

        GenJnlLine.Correction := (DocumentType = DocumentType::"Credit Memo") and GLSetup."Mark Cr. Memos as Corrections";

        GenJnlLine."Applies-to Doc. Type" := DocType;
        GenJnlLine."Applies-to Doc. No." := DocNo;

        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure UpdateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; DocumentType: Option Invoice,"Credit Memo"; GenJnlLineDocNo: Code[20])
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if DocumentType = DocumentType::Invoice then begin
            SalesHeader."Last Prepayment No." := GenJnlLineDocNo;
            SalesHeader."Prepayment No." := '';
            SalesLine.SetFilter("Prepmt. Line Amount", '<>0');
            if SalesLine.FindSet(true) then
                repeat
                    if SalesLine."Prepmt. Line Amount" <> SalesLine."Prepmt. Amt. Inv." then begin
                        SalesLine."Prepmt. Amt. Inv." := SalesLine."Prepmt. Line Amount";
                        SalesLine."Prepmt. Amount Inv. Incl. VAT" := SalesLine."Prepmt. Amt. Incl. VAT";
                        SalesLine.CalcPrepaymentToDeduct;
                        SalesLine."Prepmt VAT Diff. to Deduct" :=
                          SalesLine."Prepmt VAT Diff. to Deduct" + SalesLine."Prepayment VAT Difference";
                        SalesLine."Prepayment VAT Difference" := 0;
                        SalesLine.Modify();
                    end;
                until SalesLine.Next = 0;
        end else begin
            SalesHeader."Last Prepmt. Cr. Memo No." := GenJnlLineDocNo;
            SalesHeader."Prepmt. Cr. Memo No." := '';
            SalesLine.SetFilter("Prepmt. Amt. Inv.", '<>0');
            if SalesLine.FindSet(true) then
                repeat
                    SalesLine."Prepmt. Amt. Inv." := SalesLine."Prepmt Amt Deducted";
                    if SalesHeader."Prices Including VAT" then
                        SalesLine."Prepmt. Amount Inv. Incl. VAT" := SalesLine."Prepmt. Amt. Inv."
                    else
                        SalesLine."Prepmt. Amount Inv. Incl. VAT" :=
                          Round(
                            SalesLine."Prepmt. Amt. Inv." * (100 + SalesLine."Prepayment VAT %") / 100,
                            GetCurrencyAmountRoundingPrecision(SalesLine."Currency Code"));
                    SalesLine."Prepmt. Amt. Incl. VAT" := SalesLine."Prepmt. Amount Inv. Incl. VAT";
                    SalesLine."Prepayment Amount" := SalesLine."Prepmt. Amt. Inv.";
                    SalesLine."Prepmt Amt to Deduct" := 0;
                    SalesLine."Prepmt VAT Diff. to Deduct" := 0;
                    SalesLine."Prepayment VAT Difference" := 0;
                    SalesLine.Modify();
                until SalesLine.Next = 0;
        end;
    end;

    local procedure GetCurrencyAmountRoundingPrecision(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
    begin
        Currency.Initialize(CurrencyCode);
        Currency.TestField("Amount Rounding Precision");
        exit(Currency."Amount Rounding Precision");
    end;
}