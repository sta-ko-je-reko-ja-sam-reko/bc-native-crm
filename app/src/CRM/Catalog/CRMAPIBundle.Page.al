namespace NBC.CRM.Catalog;

using NBC.Setup;

/// <summary>API page exposing CRM bundles for integration, Power Platform and MCP tooling.</summary>
page 50119 "NBC CRM API Bundle"
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'catalog';
    APIVersion = 'v1.0';
    EntityName = 'bundle';
    EntitySetName = 'bundles';
    EntityCaption = 'CRM Bundle';
    EntitySetCaption = 'CRM Bundles';
    DelayedInsert = true;
    SourceTable = "NBC CRM Bundle";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(no; Rec."No.") { Caption = 'No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; }
                field(catalogStatus; Rec."Catalog Status") { Caption = 'Catalog Status'; }
                field(componentTotal; Rec."Component Total") { Caption = 'Component Total'; Editable = false; }
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
