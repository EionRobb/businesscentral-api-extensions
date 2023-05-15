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
            field(tableName; Rec."Table Name")
            {
                ApplicationArea = All;
            }
            field(number; Rec."No.")
            {
                ApplicationArea = All;
            }
            field(lineNumber; Rec."Line No.")
            {
                ApplicationArea = All;
            }
            field(date; Rec.Date)
            {
                ApplicationArea = All;
            }
            field(code; Rec.Code)
            {
                ApplicationArea = All;
            }
            field(comment; Rec.Comment)
            {
                ApplicationArea = All;
            }
            field(id; Rec.SystemId)
            {
                ApplicationArea = All;
            }
            field(lastModifiedDateTime; Rec.SystemModifiedAt)
            {
                ApplicationArea = All;
            }
        }
    }
}