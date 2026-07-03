namespace NBC.CRM.Catalog;

using NBC.Setup;

/// <summary>API page exposing CRM product relationships for integration, Power Platform and MCP tooling.</summary>
page 50121 "NBC CRM API Product Rel."
{
    PageType = API;
    APIPublisher = 'nbc';
    APIGroup = 'catalog';
    APIVersion = 'v1.0';
    EntityName = 'productRelation';
    EntitySetName = 'productRelations';
    EntityCaption = 'CRM Product Relation';
    EntitySetCaption = 'CRM Product Relations';
    DelayedInsert = true;
    SourceTable = "NBC CRM Product Rel.";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { Caption = 'System Id'; Editable = false; }
                field(fromType; Rec."From Type") { Caption = 'From Type'; }
                field(fromNo; Rec."From No.") { Caption = 'From No.'; }
                field(relationshipType; Rec."Relationship Type") { Caption = 'Relationship Type'; }
                field(toType; Rec."To Type") { Caption = 'To Type'; }
                field(toNo; Rec."To No.") { Caption = 'To No.'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(rank; Rec.Rank) { Caption = 'Rank'; }
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
