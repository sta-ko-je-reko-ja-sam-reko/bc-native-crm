namespace NBC.CRM.Process;

using NBC.Setup;

/// <summary>API page exposing CRM processes for integration, Power Platform and MCP tooling.</summary>
page 50116 "NBC CRM API Process"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'process';
    APIVersion = 'v1.0';
    EntityName = 'process';
    EntitySetName = 'processes';
    EntityCaption = 'CRM Process';
    EntitySetCaption = 'CRM Processes';
    DelayedInsert = true;
    SourceTable = "NBC CRM Process";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(code; Rec."Code") { Caption = 'Code'; }
                field(name; Rec.Name) { Caption = 'Name'; }
                field(tableNo; Rec."Table No.") { Caption = 'Table No.'; }
                field(active; Rec.Active) { Caption = 'Active'; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Process);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Process);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Process);
        exit(true);
    end;

    var
        FeatureGuard: Codeunit "NBC Feature Mgt.";
}
