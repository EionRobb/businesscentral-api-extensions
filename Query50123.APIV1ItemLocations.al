
query 50123 ItemLocations
{
    QueryType = API;
    Caption = 'Item Locations API';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'itemLocation';
    EntitySetName = 'itemLocations';

    elements
    {

        dataitem(items; "Item")
        {
            column(itemNumber; "No.") { }
            dataitem(locations; "Location")
            {
                SqlJoinType = CrossJoin;
                column(locationCode; "Code") { }
                dataitem(itemLocations; "Item Ledger Entry")
                {
                    DataItemLink = "Item No." = items."No.", "Location Code" = locations.Code;
                    SqlJoinType = InnerJoin;
                    column(locationQuantity; Quantity)
                    {
                        Method = Sum;
                    }
                }
            }
            column(id; SystemId) { }
            column(lastModifiedDateTime; SystemModifiedAt) { }
        }
    }


}