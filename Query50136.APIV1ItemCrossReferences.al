query 50136 ItemCrossReferences
{
    QueryType = API;
    Caption = 'Item Cross Referencess Entity';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'itemCrossReference';
    EntitySetName = 'itemCrossReferences';

    elements
    {
        dataitem(itemCrossReferences; "Item Reference")
        {
            DataItemTableFilter = "Discontinue Bar Code" = CONST(False);
            column(itemNumber; "Item No.") { }
            column(variantCode; "Variant Code") { }
            column(unitOfMeasure; "Unit of Measure") { }
            column("type"; "Reference Type") { }
            column("number"; "Reference No.") { }

            column(id; SystemId) { }
            column(lastModifiedDateTime; SystemModifiedAt) { }
        }
    }
}