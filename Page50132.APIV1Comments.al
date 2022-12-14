page 50132 "Comments"
{
    PageType = API;
    Caption = 'Comments';
    APIPublisher = 'Opmetrix';
    APIGroup = 'opmetrix';
    APIVersion = 'v1.0';
    EntityName = 'comment';
    EntitySetName = 'comments';
    DelayedInsert = true;

    SourceTable = "Comment Line";
    //SourceTable = 97;

    layout
    {
        area(Content)
        {
            field(tableName; "Table Name")
            {
                ApplicationArea = All;
            }
            field(number; "No.")
            {
                ApplicationArea = All;
            }
            field(lineNumber; "Line No.")
            {
                ApplicationArea = All;
            }
            field(date; Date)
            {
                ApplicationArea = All;
            }
            field(code; Code)
            {
                ApplicationArea = All;
            }
            field(comment; Comment)
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