namespace NBC.CRM.Catalog;

using NBC.Setup;

/// <summary>API page exposing CRM bundle component lines for integration, Power Platform and MCP tooling.</summary>
page 50120 "NBC CRM API Bundle Line"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'catalog';
    APIVersion = 'v1.0';
    EntityName = 'bundleLine';
    EntitySetName = 'bundleLines';
    EntityCaption = 'CRM Bundle Line';
    EntitySetCaption = 'CRM Bundle Lines';
    DelayedInsert = true;
    SourceTable = "NBC CRM Bundle Line";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(bundleNo; Rec."Bundle No.") { Caption = 'Bundle No.'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(componentType; Rec."Component Type") { Caption = 'Component Type'; }
                field(no; Rec."No.") { Caption = 'No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; }
                field(lineAmount; Rec."Line Amount") { Caption = 'Line Amount'; Editable = false; }
                field(required; Rec.Required) { Caption = 'Required'; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Catalog);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Catalog);
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        FeatureGuard.CheckEnabled(Enum::"NBC Feature"::Catalog);
        exit(true);
    end;

    var
        FeatureGuard: Codeunit "NBC Feature Mgt.";
}
