namespace NBC.CRM.Opportunity;

using NBC.Setup;

/// <summary>API page exposing CRM opportunity competitors for integration, Power Platform and MCP tooling.</summary>
page 50114 "NBC CRM API Opp. Competitor"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'opportunity';
    APIVersion = 'v1.0';
    EntityName = 'opportunityCompetitor';
    EntitySetName = 'opportunityCompetitors';
    EntityCaption = 'CRM Opportunity Competitor';
    EntitySetCaption = 'CRM Opportunity Competitors';
    DelayedInsert = true;
    SourceTable = "NBC CRM Opp. Competitor";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(opportunityNo; Rec."Opportunity No.") { Caption = 'Opportunity No.'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(name; Rec.Name) { Caption = 'Name'; }
                field(threatLevel; Rec."Threat Level") { Caption = 'Threat Level'; }
                field(strengths; Rec.Strengths) { Caption = 'Strengths'; }
                field(weaknesses; Rec.Weaknesses) { Caption = 'Weaknesses'; }
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
