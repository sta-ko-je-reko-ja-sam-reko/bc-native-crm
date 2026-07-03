namespace NBC.CRM.Pricing;

using NBC.Setup;

/// <summary>API page exposing CRM discount tiers for integration, Power Platform and MCP tooling.</summary>
page 50123 "NBC CRM API Discount Tier"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'pricing';
    APIVersion = 'v1.0';
    EntityName = 'discountTier';
    EntitySetName = 'discountTiers';
    EntityCaption = 'CRM Discount Tier';
    EntitySetCaption = 'CRM Discount Tiers';
    DelayedInsert = true;
    SourceTable = "NBC CRM Discount Tier";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(discountListCode; Rec."Discount List Code") { Caption = 'Discount List Code'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(minimumQuantity; Rec."Minimum Quantity") { Caption = 'Minimum Quantity'; }
                field(maximumQuantity; Rec."Maximum Quantity") { Caption = 'Maximum Quantity'; }
                field(value; Rec.Value) { Caption = 'Value'; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Pricing);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Pricing);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Pricing);
        exit(true);
    end;

    var
        FeatureGuard: Codeunit "NBC Feature Mgt.";
}
