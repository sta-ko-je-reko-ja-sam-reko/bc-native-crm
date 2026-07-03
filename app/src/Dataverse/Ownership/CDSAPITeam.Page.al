namespace NBC.Dataverse.Ownership;

using NBC.Setup;

/// <summary>API page exposing CRM Teams for integration, Power Platform and MCP tooling.</summary>
page 50110 "NBC CDS API Team"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'ownership';
    APIVersion = 'v1.0';
    EntityName = 'team';
    EntitySetName = 'teams';
    EntityCaption = 'CRM Team';
    EntitySetCaption = 'CRM Teams';
    DelayedInsert = true;
    SourceTable = "NBC CDS Team";
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
                field(description; Rec.Description) { Caption = 'Description'; }
                field(teamLeadSalespersonCode; Rec."Team Lead Salesp. Code") { Caption = 'Team Lead Salesperson Code'; }
                field(memberCount; Rec."Member Count") { Caption = 'Member Count'; Editable = false; }
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
