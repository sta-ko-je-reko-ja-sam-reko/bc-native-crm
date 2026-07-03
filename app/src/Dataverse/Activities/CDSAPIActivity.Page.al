namespace NBC.Dataverse.Activities;

using NBC.Setup;

/// <summary>API page exposing CRM Activities for integration, Power Platform and MCP tooling.</summary>
page 50112 "NBC CDS API Activity"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'activities';
    APIVersion = 'v1.0';
    EntityName = 'activity';
    EntitySetName = 'activities';
    EntityCaption = 'CRM Activity';
    EntitySetCaption = 'CRM Activities';
    DelayedInsert = true;
    SourceTable = "NBC CDS Activity";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(entryNo; Rec."Entry No.") { Caption = 'Entry No.'; Editable = false; }
                field(activityType; Rec."Activity Type") { Caption = 'Activity Type'; }
                field(subject; Rec.Subject) { Caption = 'Subject'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(regardingTableNo; Rec."Regarding Table No.") { Caption = 'Regarding Table No.'; }
                field(regardingSystemId; Rec."Regarding System ID") { Caption = 'Regarding System Id'; }
                field(regardingDescription; Rec."Regarding Description") { Caption = 'Regarding'; }
                field(ownerType; Rec."Owner Type") { Caption = 'Owner Type'; }
                field(ownerCode; Rec."Owner Code") { Caption = 'Owner'; }
                field(status; Rec.Status) { Caption = 'Status'; }
                field(priority; Rec.Priority) { Caption = 'Priority'; }
                field(direction; Rec.Direction) { Caption = 'Direction'; }
                field(activityDate; Rec."Activity Date") { Caption = 'Activity Date'; }
                field(dueDate; Rec."Due Date") { Caption = 'Due Date'; }
                field(closedDateTime; Rec."Closed DateTime") { Caption = 'Closed Date-Time'; Editable = false; }
                field(createdBy; Rec."Created By") { Caption = 'Created By'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Activities);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Activities);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Activities);
        exit(true);
    end;

    var
        FeatureGuard: Codeunit "NBC Feature Mgt.";
}
