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
                DataItemLink = SystemID = defaultDimensions.DimensionId;
                column(name; Name) { }

                dataitem(dimensionValues; "Dimension Value")
                {
                    DataItemLink = SystemID = defaultDimensions.DimensionValueId;
                    column(value; Name) { }
                }
            }
            column(id; SystemId) { }
            column(lastModifiedDateTime; SystemModifiedAt) { }
        }
    }
}