namespace NBC.CRM.Process;

using NBC.Setup;

/// <summary>API page exposing CRM process stages for integration, Power Platform and MCP tooling.</summary>
page 50117 "NBC CRM API Process Stage"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'process';
    APIVersion = 'v1.0';
    EntityName = 'processStage';
    EntitySetName = 'processStages';
    EntityCaption = 'CRM Process Stage';
    EntitySetCaption = 'CRM Process Stages';
    DelayedInsert = true;
    SourceTable = "NBC CRM Process Stage";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(processCode; Rec."Process Code") { Caption = 'Process Code'; }
                field(stageNo; Rec."Stage No.") { Caption = 'Stage No.'; }
                field(name; Rec.Name) { Caption = 'Name'; }
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
