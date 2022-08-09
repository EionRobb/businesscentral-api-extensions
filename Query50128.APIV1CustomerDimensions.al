query 50128 "Customer Dimensions Extension"
{
    QueryType = API;
    Caption = 'Customer Dimensions Extension';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'customerDimension';
    EntitySetName = 'customerDimensions';

    elements
    {

        dataitem(defaultDimensions; "Default Dimension")
        {
            DataItemTableFilter = "Table ID" = const (18);
            column("customerNumber"; "No.") { }
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