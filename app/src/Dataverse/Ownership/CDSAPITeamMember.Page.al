namespace NBC.Dataverse.Ownership;

using NBC.Setup;

/// <summary>API page exposing CRM Team Members for integration, Power Platform and MCP tooling.</summary>
page 50111 "NBC CDS API Team Member"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'ownership';
    APIVersion = 'v1.0';
    EntityName = 'teamMember';
    EntitySetName = 'teamMembers';
    EntityCaption = 'CRM Team Member';
    EntitySetCaption = 'CRM Team Members';
    DelayedInsert = true;
    SourceTable = "NBC CDS Team Member";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(teamCode; Rec."Team Code") { Caption = 'Team Code'; }
                field(salespersonCode; Rec."Salesperson Code") { Caption = 'Salesperson Code'; }
                field(teamLead; Rec."Team Lead") { Caption = 'Team Lead'; }
                field(salespersonName; Rec."Salesperson Name") { Caption = 'Salesperson Name'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Ownership);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Ownership);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Ownership);
        exit(true);
    end;

    var
        FeatureGuard: Codeunit "NBC Feature Mgt.";
}
