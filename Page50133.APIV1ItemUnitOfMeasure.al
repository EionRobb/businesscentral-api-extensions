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
            field("itemNumber"; "Item No.")
            {
                ApplicationArea = All;
            }
            field("unitOfMeasureCode"; "Code")
            {
                ApplicationArea = All;
            }
            field("quantityPerUnitOfMeasure"; "Qty. per Unit of Measure")
            {
                ApplicationArea = All;
            }
            field("length"; Length)
            {
                ApplicationArea = All;
            }
            field("width"; Width)
            {
                ApplicationArea = All;
            }
            field("height"; Height)
            {
                ApplicationArea = All;
            }
            field("cubage"; Cubage)
            {
                ApplicationArea = All;
            }
            field("weight"; Weight)
            {
                ApplicationArea = All;
            }
            field(id; SystemId)
            {
                ApplicationArea = All;
            }
            field(lastModifiedDateTime; SystemModifiedAt)
            {
                ApplicationArea = All;
            }
        }
    }
}