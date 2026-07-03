namespace NBC.CRM.Opportunity;

using NBC.Setup;

/// <summary>API page exposing CRM opportunity lines for integration, Power Platform and MCP tooling.</summary>
page 50113 "NBC CRM API Opp. Line"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'opportunity';
    APIVersion = 'v1.0';
    EntityName = 'opportunityLine';
    EntitySetName = 'opportunityLines';
    EntityCaption = 'CRM Opportunity Line';
    EntitySetCaption = 'CRM Opportunity Lines';
    DelayedInsert = true;
    SourceTable = "NBC CRM Opp. Line";
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
                field(type; Rec.Type) { Caption = 'Type'; }
                field(no; Rec."No.") { Caption = 'No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; }
                field(lineAmount; Rec."Line Amount") { Caption = 'Line Amount'; Editable = false; }
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
