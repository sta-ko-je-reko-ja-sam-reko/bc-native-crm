namespace NBC.CRM.Opportunity;

using NBC.Setup;

/// <summary>API page exposing CRM opportunity stakeholders for integration, Power Platform and MCP tooling.</summary>
page 50115 "NBC CRM API Opp. Stakeholder"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'opportunity';
    APIVersion = 'v1.0';
    EntityName = 'opportunityStakeholder';
    EntitySetName = 'opportunityStakeholders';
    EntityCaption = 'CRM Opportunity Stakeholder';
    EntitySetCaption = 'CRM Opportunity Stakeholders';
    DelayedInsert = true;
    SourceTable = "NBC CRM Opp. Stakeholder";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(opportunityNo; Rec."Opportunity No.") { Caption = 'Opportunity No.'; }
                field(contactNo; Rec."Contact No.") { Caption = 'Contact No.'; }
                field(role; Rec.Role) { Caption = 'Role'; }
                field(roleDescription; Rec."Role Description") { Caption = 'Role Description'; }
                field(contactName; Rec."Contact Name") { Caption = 'Contact Name'; Editable = false; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Opportunity);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Opportunity);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Opportunity);
        exit(true);
    end;

    var
        FeatureGuard: Codeunit "NBC Feature Mgt.";
}
