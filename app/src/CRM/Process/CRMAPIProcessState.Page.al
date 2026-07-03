namespace NBC.CRM.Process;

using NBC.Setup;

/// <summary>API page exposing per-record CRM process state for integration, Power Platform and MCP tooling.</summary>
page 50118 "NBC CRM API Process State"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'process';
    APIVersion = 'v1.0';
    EntityName = 'processState';
    EntitySetName = 'processStates';
    EntityCaption = 'CRM Process State';
    EntitySetCaption = 'CRM Process States';
    DelayedInsert = true;
    SourceTable = "NBC CRM Process State";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(tableNo; Rec."Table No.") { Caption = 'Table No.'; }
                field(recordSystemId; Rec."Record System ID") { Caption = 'Record System Id'; }
                field(processCode; Rec."Process Code") { Caption = 'Process Code'; }
                field(currentStageNo; Rec."Current Stage No.") { Caption = 'Current Stage No.'; }
                field(startedDateTime; Rec."Started DateTime") { Caption = 'Started Date-Time'; }
                field(completedDateTime; Rec."Completed DateTime") { Caption = 'Completed Date-Time'; }
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
