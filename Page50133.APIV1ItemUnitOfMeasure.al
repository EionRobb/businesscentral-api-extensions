page 50133 "Item Unit Of Measure"
{
    PageType = API;
    Caption = 'Item Unit Of Measure';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'itemUnitOfMeasure';
    EntitySetName = 'itemUnitOfMeasures';
    DelayedInsert = true;

    SourceTable = "Item Unit of Measure";
    //SourceTable = 5404;

    layout
    {
        area(Content)
        {
            field("itemNumber"; Rec."Item No.")
            {
                ApplicationArea = All;
            }
            field("unitOfMeasureCode"; Rec."Code")
            {
                ApplicationArea = All;
            }
            field("quantityPerUnitOfMeasure"; Rec."Qty. per Unit of Measure")
            {
                ApplicationArea = All;
            }
            field("length"; Rec.Length)
            {
                ApplicationArea = All;
            }
            field("width"; Rec.Width)
            {
                ApplicationArea = All;
            }
            field("height"; Rec.Height)
            {
                ApplicationArea = All;
            }
            field("cubage"; Rec.Cubage)
            {
                ApplicationArea = All;
            }
            field("weight"; Rec.Weight)
            {
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