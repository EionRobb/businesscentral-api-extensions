query 50138 "ItemAttributes"
{

    QueryType = API;
    Caption = 'Item Attributes Entity';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'itemAttributes';
    EntitySetName = 'itemAttributes';

    elements
    {
        dataitem(Item; Item)
        {
            column(itemNumber; "No.")
            {
            }

            dataitem(Item_Attribute_Value_Mapping; "Item Attribute Value Mapping")
            {
                DataItemLink = "No." = Item."No.";

                column(dimensionCode; "Item Attribute ID")
                {
                }

                column(Item_Attribute_Value_ID; "Item Attribute Value ID")
                {
                }
                dataitem(QueryElement6; "Item Attribute")
                {
                    DataItemLink = ID = Item_Attribute_Value_Mapping."Item Attribute ID";
                    column(Name; Name)
                    {
                    }
                    dataItem(Queryelement10; "Item Attribute Value")
                    {
                        DataItemLink = "Attribute ID" = Item_Attribute_Value_Mapping."Item Attribute ID",
                        ID = Item_Attribute_Value_Mapping."Item Attribute Value ID";
                        column(dimensionValueCode; Value)
                        {
                        }
                        column(Numeric_Value; "Numeric Value")
                        {
                        }
                    }
                }
            }

        }
    }
}