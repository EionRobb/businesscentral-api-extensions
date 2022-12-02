query 50137 ItemCategories
{
    QueryType = API;
    Caption = 'Item Categories Entity';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'itemCategories';
    EntitySetName = 'itemCategories';

    elements
    {
        dataitem(itemCategories; "Item Category")
        {
            column(id; Id) { }
            column(code; Code) { }
            column(displayName; "Description") { }
            column(parentCode; "Parent Category") { }
            column(lastModifiedDateTime; "Last Modified Date Time") { }
        }
    }
}