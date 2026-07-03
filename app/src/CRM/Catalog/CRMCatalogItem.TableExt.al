namespace NBC.CRM.Catalog;

using Microsoft.Inventory.Item;
using Microsoft.Pricing.PriceList;

/// <summary>CRM sales-catalog facets on the standard Item: selling lifecycle, sell window, default price list.</summary>
tableextension 50090 "NBC CRM Catalog Item" extends Item
{
    fields
    {
        field(50090; "NBC CRM Catalog Status"; Enum "NBC CRM Catalog Status")
        {
            Caption = 'CRM Catalog Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the selling lifecycle state (draft, active or retired) of the item.';
        }
        field(50091; "NBC CRM Valid From"; Date)
        {
            Caption = 'CRM Valid From';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the first date the item may be sold.';
        }
        field(50092; "NBC CRM Valid To"; Date)
        {
            Caption = 'CRM Valid To';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the last date the item may be sold.';
        }
        field(50093; "NBC CRM Default Price List"; Code[20])
        {
            Caption = 'CRM Default Price List';
            DataClassification = CustomerContent;
            TableRelation = "Price List Header" where("Price Type" = const(Sale));
            ToolTip = 'Specifies the price list used by default when selling the item.';
        }
    }
}
