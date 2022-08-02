codeunit 00000 "?????"
{


    trigger OnRun()
    begin
    end;

    //PTKLibrarySales4PS.Codeunit.al
    procedure CreatePaymentAndApplytoInvoice(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: Code[20]; AppliesToDocNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
    begin
        CreateGeneralJournalBatch(GenJournalBatch);
        /*LibraryERM.*/
        CreateGLAccount(GLAccount);
        /*LibraryERM.*/
        CreateGeneralJnlLine(
GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
GenJournalLine."Account Type"::Customer, CustomerNo, Amount);

        // Value of Document No. is not important.
        GenJournalLine.Validate("Document No.", GenJournalLine."Journal Batch Name" + Format(GenJournalLine."Line No."));
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliesToDocNo);
        GenJournalLine.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalLine.Modify(true);
        /*LibraryERM.*/
        PostGeneralJnlLine(GenJournalLine);
    end;I8Q8FVACN
    
    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        /*LibraryERM.*/FindGenJournalTemplate(GenJournalTemplate);
        /*LibraryERM.*/CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    //PTKLibraryERM4PS.Codeunit.al
    procedure FindGenJournalTemplate(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        GenJournalTemplate.SetRange(Recurring, false);
        if not GenJournalTemplate.FindFirst then begin
            CreateGenJournalTemplate(GenJournalTemplate);
            if GenJournalTemplate.GetRangeMin(Type) = GenJournalTemplate.GetRangeMax(Type) then begin
                GenJournalTemplate.Validate(Type, GenJournalTemplate.GetRangeMin(Type));
                GenJournalTemplate.Modify(true);
            end;
        end;
    end;

    procedure CreateGenJournalTemplate(var GenJournalTemplate: Record "Gen. Journal Template")
    begin
        GenJournalTemplate.Init;
        GenJournalTemplate.Validate(
          Name,
          CopyStr(
            /*LibraryUtility.*/GenerateRandomCode(GenJournalTemplate.FieldNo(Name), DATABASE::"Gen. Journal Template"),
            1,
            /*LibraryUtility.*/GetFieldLength(DATABASE::"Gen. Journal Template", GenJournalTemplate.FieldNo(Name))));
        GenJournalTemplate.Validate(Description, GenJournalTemplate.Name);
        // Validating Name as Description because value is not important.
        GenJournalTemplate.Insert(true);

        if not GenJournalTemplate."Force Doc. Balance" then begin
            GenJournalTemplate.Validate("Force Doc. Balance", true);  // This field is FALSE by default in ES. Setting this to TRUE to match ES with W1.
            GenJournalTemplate.Modify(true);
        end;
    end;

    procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; JournalTemplateName: Code[10])
    begin
        // creates a new Gen. Journal Batch named with the next available number (if it does not yet exist), OR
        // returns the Gen. Journal batch named with the next available number
        // calling ConvertNumericToText to avoid auto-removal of the batch during posting by COD13
        GenJournalBatch.Init;
        GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        GenJournalBatch.Validate(
          Name,
          /*LibraryUtility.*/ConvertNumericToText(
            CopyStr(
              /*LibraryUtility.*/GenerateRandomCode(GenJournalBatch.FieldNo(Name), DATABASE::"Gen. Journal Batch"),
              1,
              /*LibraryUtility.*/GetFieldLength(DATABASE::"Gen. Journal Batch", GenJournalBatch.FieldNo(Name)))));
        GenJournalBatch.Validate(Description, GenJournalBatch.Name);  // Validating Name as Description because value is not important.
        if GenJournalBatch.Insert(true) then;
    end;

    procedure CreateGLAccount(var GLAccount: Record "G/L Account")
    begin
        GLAccount.Init;
        // Prefix a number to fix errors for local build.
        GLAccount.Validate(
          "No.",
          PadStr(
            '1' + /*LibraryUtility.*/GenerateRandomCode(GLAccount.FieldNo("No."), DATABASE::"G/L Account"), MaxStrLen(GLAccount."No."), '0'));
        GLAccount.Validate(Name, GLAccount."No.");  // Enter No. as Name because value is not important.
        GLAccount.Insert(true);
    end;

    procedure CreateGeneralJnlLine(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type";
                                                                                                                                                                AccountNo: Code[20];
                                                                                                                                                                Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);
        CreateGeneralJnlLineWithBalAcc(GenJournalLine, JournalTemplateName, JournalBatchName, DocumentType, AccountType, AccountNo,
          GenJournalBatch."Bal. Account Type", GenJournalBatch."Bal. Account No.", Amount);
    end;

    procedure CreateGeneralJnlLineWithBalAcc(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type";
                                                                                                                                                                          AccountNo: Code[20];
                                                                                                                                                                          BalAccountType: Enum "Gen. Journal Account Type";
                                                                                                                                                                          BalAccountNo: Code[20];
                                                                                                                                                                          Amount: Decimal)
    begin
        /*LibraryJournals.*/CreateGenJournalLine(GenJournalLine, JournalTemplateName, JournalBatchName, DocumentType, AccountType, AccountNo,
          BalAccountType, BalAccountNo, Amount);
    end;

    procedure PostGeneralJnlLine(GenJournalLine: Record "Gen. Journal Line")
    begin
        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post Batch", GenJournalLine);
    end;

    //PTKLibraryJournals4PS.Codeunit.al
    procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type";
                                                                                                                                                                AccountNo: Code[20];
                                                                                                                                                                BalAccountType: Enum "Gen. Journal Account Type";
                                                                                                                                                                BalAccountNo: Code[20];
                                                                                                                                                                Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
                                                                                                                                                                NoSeries: Record "No. Series";
                                                                                                                                                                NoSeriesMgt: Codeunit NoSeriesManagement;
                                                                                                                                                                RecRef: RecordRef;
    begin
        // Find a balanced template/batch pair.
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);

        // Create a General Journal Entry.
        GenJournalLine.Init;
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        RecRef.GetTable(GenJournalLine);
        GenJournalLine.Validate("Line No.", /*LibraryUtility.*/GetNewLineNo(RecRef, GenJournalLine.FieldNo("Line No.")));
        GenJournalLine.Insert(true);
        GenJournalLine.Validate("Posting Date", WorkDate);  // Defaults to work date.
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Account Type", AccountType);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Amount, Amount);
        if NoSeries.Get(GenJournalBatch."No. Series") then
            GenJournalLine.Validate("Document No.", NoSeriesMgt.GetNextNo(GenJournalBatch."No. Series", WorkDate, false)) // Unused but required field for posting.
        else
            GenJournalLine.Validate(
              "Document No.", /*LibraryUtility.*/GenerateRandomCode(GenJournalLine.FieldNo("Document No."), DATABASE::"Gen. Journal Line"));
        GenJournalLine.Validate("External Document No.", GenJournalLine."Document No.");  // Unused but required for vendor posting.
        GenJournalLine.Validate("Source Code", LibraryERM.FindGeneralJournalSourceCode);  // Unused but required for AU, NZ builds
        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        GenJournalLine.Modify(true);
    end;

    //PTKLibraryUtility4PS.Codeunit.al
    procedure GenerateRandomCode(FieldNo: Integer; TableNo: Integer): Code[10]
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        // Create a random and unique code for the any code field.
        RecRef.Open(TableNo, true, CompanyName);
        Clear(FieldRef);
        FieldRef := RecRef.Field(FieldNo);

        repeat
            if FieldRef.Length < 10 then
                FieldRef.SetRange(CopyStr(GenerateGUID, 10 - FieldRef.Length + 1)) // Cut characters on the left side.
            else
                FieldRef.SetRange(GenerateGUID);
        until RecRef.IsEmpty;

        exit(FieldRef.GetFilter)
    end;

    procedure GetFieldLength(TableNo: Integer; FieldNo: Integer): Integer
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.Open(TableNo);
        FieldRef := RecRef.Field(FieldNo);
        exit(FieldRef.Length);
    end;

    procedure ConvertNumericToText(NumericCode: Text): Text
    begin
        exit(ConvertStr(NumericCode, '0123456789', 'ABCDEFGHIJ'));
    end;
}