page 50138 "Sales Invoice Line Extension"
{
    PageType = ListPart;
    Caption = 'Sales Invoice Line Extension';
    DelayedInsert = true;

    //SourceTable = 5476;
    SourceTable = "Sales Invoice Line Aggregate";
    SourceTableTemporary = true;
    ODataKeyFields = "Id";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    ApplicationArea = All;
                }
                field(documentId; "Document Id")
                {
                    ApplicationArea = All;
                }
                field(sequence; "Line No.")
                {
                    ApplicationArea = All;
                }
                field(unitCost; "Unit Cost")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        LinesLoaded: Boolean;
        //CalculatedFields
        "Unit Cost": Decimal;

    trigger OnAfterGetRecord()
    var
        SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate";
        CannotFindSalesInvoiceEntityAggregateErr: Label 'Sales Invoice Entity Aggregate with Id %1 cannot be found.';
    begin
        SalesInvoiceEntityAggregate.Reset();
        SalesInvoiceEntityAggregate.SetRange(Id, Rec."Document Id");
        IF NOT SalesInvoiceEntityAggregate.FINDFIRST() THEN
            Error(CannotFindSalesInvoiceEntityAggregateErr, Rec."Document Id");

        IF SalesInvoiceEntityAggregate.Posted THEN
            LoadSalesInvoiceLineCalculatedFields(SalesInvoiceEntityAggregate, Rec)
        ELSE
            LoadSalesLineCalculatedFields(SalesInvoiceEntityAggregate, Rec);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
        DocumentIdFilter: Text;
        IdFilter: Text;
        FilterView: Text;
        IDOrDocumentIdShouldBeSpecifiedForLinesErr: Label 'You must specify an Id or a Document Id to get the lines.', Locked = true;
    begin
        IF NOT LinesLoaded THEN BEGIN
            FilterView := GETVIEW();
            IdFilter := GETFILTER(Id);
            DocumentIdFilter := GETFILTER("Document Id");
            IF (IdFilter = '') AND (DocumentIdFilter = '') THEN
                ERROR(IDOrDocumentIdShouldBeSpecifiedForLinesErr);
            IF IdFilter <> '' THEN
                DocumentIdFilter := GraphMgtSalesInvLines.GetDocumentIdFilterFromIdFilter(IdFilter)
            ELSE
                DocumentIdFilter := GETFILTER("Document Id");
            SalesInvoiceAggregator.LoadLines(Rec, DocumentIdFilter);
            SETVIEW(FilterView);
            IF NOT FINDFIRST() THEN
                EXIT(FALSE);
            LinesLoaded := TRUE;
        END;

        EXIT(TRUE);
    end;

    local procedure LoadSalesInvoiceLineCalculatedFields(SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate"; SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        CannotFindSalesInvoiceLineErr: Label 'Sales Invoice Line with Document No %1 and Line No %2 cannot be found.';
    begin
        SalesInvoiceLine.Reset();
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceEntityAggregate."No.");
        SalesInvoiceLine.SetRange("Line No.", SalesInvoiceLineAggregate."Line No.");
        IF NOT SalesInvoiceLine.FINDFIRST() THEN
            Error(CannotFindSalesInvoiceLineErr, SalesInvoiceEntityAggregate."No.", SalesInvoiceLineAggregate."Line No.");

        SetCalculatedFields(
            SalesInvoiceLine."Unit Cost"
        );
    end;

    local procedure LoadSalesLineCalculatedFields(SalesInvoiceEntityAggregate: Record "Sales Invoice Entity Aggregate"; SalesInvoiceLineAggregate: Record "Sales Invoice Line Aggregate")
    var
        SalesLine: Record "Sales Line";
        CannotFindSalesLineErr: Label 'Sales Line with Document No %1 and Line No %2 cannot be found.';
    begin
        SalesLine.Reset();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesInvoiceEntityAggregate."No.");
        SalesLine.SetRange("Line No.", SalesInvoiceLineAggregate."Line No.");
        IF NOT SalesLine.FINDFIRST() THEN
            Error(CannotFindSalesLineErr, SalesInvoiceEntityAggregate."No.", SalesInvoiceLineAggregate."Line No.");

        SetCalculatedFields(
            SalesLine."Unit Cost"
        );
    end;

    local procedure SetCalculatedFields(UnitCost: Decimal)
    begin
        "Unit Cost" := UnitCost;
    end;
}