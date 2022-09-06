query 50129 "Item Dimensions Extension"
{
    QueryType = API;
    Caption = 'Item Dimensions Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'itemDimension';
    EntitySetName = 'itemDimensions';

    elements
    {

        dataitem(defaultDimensions; "Default Dimension")
        {
            DataItemTableFilter = "Table ID" = const(27);
            column("itemNumber"; "No.") { }
            column("dimensionCode"; "Dimension Code") { }
            column("dimensionValueCode"; "Dimension Value Code") { }
            dataitem(dimensions; "Dimension")
            {
                DataItemLink = ID = defaultDimensions.DimensionId;
                column(name; Name) { }

                dataitem(dimensionValues; "Dimension Value")
                {
                    DataItemLink = ID = defaultDimensions.DimensionValueId;
                    column(value; Name) { }
                }
            }
        }
    }
}