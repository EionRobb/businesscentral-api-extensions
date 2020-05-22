
query 50124 ItemWarehouseLocations
{
    QueryType = API;
    Caption = 'Item Warehouse Locations API';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'itemWarehouseLocation';
    EntitySetName = 'itemWarehouseLocations';

    elements
    {

        dataitem(items; "Item")
        {
            column(itemNumber; "No.") { }
            dataitem(locations; "Location")
            {
                SqlJoinType = CrossJoin;
                column(locationCode; "Code") { }
                dataitem(binContent; "Bin Content")
                {
                    DataItemLink = "Item No." = items."No.", "Location Code" = locations.Code;
                    SqlJoinType = InnerJoin;
                    column(locationQuantity; "Quantity")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }


}