namespace NBC.CRM.Pricing;

using NBC.Setup;

/// <summary>API page exposing CRM discount lists for integration, Power Platform and MCP tooling.</summary>
page 50122 "NBC CRM API Discount List"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'pricing';
    APIVersion = 'v1.0';
    EntityName = 'discountList';
    EntitySetName = 'discountLists';
    EntityCaption = 'CRM Discount List';
    EntitySetCaption = 'CRM Discount Lists';
    DelayedInsert = true;
    SourceTable = "NBC CRM Discount List";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(code; Rec."Code") { Caption = 'Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(discountType; Rec."Discount Type") { Caption = 'Discount Type'; }
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
