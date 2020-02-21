query 50135 IncomingItems
{
    QueryType = API;
    Caption = 'Incoming Items Entity';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'incomingItem';
    EntitySetName = 'incomingItems';

    elements
    {
        dataitem(purchaseLines; "Purchase Line")
        {
            DataItemTableFilter = "Type" = CONST(Item);
            column(itemNumber; "No.") { }
            column(expectedDate; "Expected Receipt Date") { }

            column(outstandingQuantity; "Outstanding Quantity")
            {
                ColumnFilter = outstandingQuantity = FILTER(> 0);
            }
            column(locationCode; "Location Code") { }
            column(unitOfMeasure; "Unit of Measure") { }

        }
    }
}