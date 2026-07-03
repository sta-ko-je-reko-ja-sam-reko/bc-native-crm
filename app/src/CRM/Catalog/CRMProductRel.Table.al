namespace NBC.CRM.Catalog;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

/// <summary>
/// Seller-facing relationship between two catalog products (cross-sell / up-sell / accessory / substitute).
/// BC's Item Substitution covers only the substitute leg; the net-new value is the cross/up-sell/accessory legs.
/// </summary>
table 50090 "NBC CRM Product Rel."
{
    Caption = 'CRM Product Relationship';
    DataClassification = CustomerContent;
    LookupPageId = "NBC CRM Product Relations";
    DrillDownPageId = "NBC CRM Product Relations";

    fields
    {
        field(1; "From Type"; Enum "NBC CRM Catalog Item Type")
        {
            Caption = 'From Type';
            ToolTip = 'Specifies whether the source product is an item or a resource.';
        }
        field(2; "From No."; Code[20])
        {
            Caption = 'From No.';
            NotBlank = true;
            TableRelation = if ("From Type" = const(Item)) Item
                            else if ("From Type" = const(Resource)) Resource;
            ToolTip = 'Specifies the source product the relationship starts from.';
        }
        field(3; "Relationship Type"; Enum "NBC CRM Product Rel. Type")
        {
            Caption = 'Relationship Type';
            ToolTip = 'Specifies the kind of relationship (cross-sell, up-sell, accessory or substitute).';
        }
        field(4; "To Type"; Enum "NBC CRM Catalog Item Type")
        {
            Caption = 'To Type';
            ToolTip = 'Specifies whether the related product is an item or a resource.';
        }
        field(5; "To No."; Code[20])
        {
            Caption = 'To No.';
            NotBlank = true;
            TableRelation = if ("To Type" = const(Item)) Item
                            else if ("To Type" = const(Resource)) Resource;
            ToolTip = 'Specifies the related product the relationship points to.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies a description of the relationship.';
        }
        field(20; Rank; Integer)
        {
            Caption = 'Rank';
            ToolTip = 'Specifies the ordering of suggestions (lower first).';
        }
    }

    keys
    {
        key(PK; "From Type", "From No.", "Relationship Type", "To Type", "To No.") { Clustered = true; }
        key(Suggestion; "From Type", "From No.", Rank) { }
    }
}
