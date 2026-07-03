namespace NBC.CRM.Catalog;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;

/// <summary>Bundle roll-up and cross/up-sell suggestion services.</summary>
codeunit 50092 "NBC CRM Bundle Mgt."
{
    Access = Public;

    /// <summary>Sum of the component line amounts of a bundle (required + optional).</summary>
    procedure CalcComponentTotal(BundleNo: Code[20]): Decimal
    var
        BundleLine: Record "NBC CRM Bundle Line";
    begin
        BundleLine.SetRange("Bundle No.", BundleNo);
        BundleLine.CalcSums("Line Amount");
        exit(BundleLine."Line Amount");
    end;

    /// <summary>Sum of only the required component line amounts of a bundle.</summary>
    procedure CalcRequiredTotal(BundleNo: Code[20]): Decimal
    var
        BundleLine: Record "NBC CRM Bundle Line";
    begin
        BundleLine.SetRange("Bundle No.", BundleNo);
        BundleLine.SetRange(Required, true);
        BundleLine.CalcSums("Line Amount");
        exit(BundleLine."Line Amount");
    end;

    /// <summary>Collect the products related to a source product (ranked suggestions for sellers).</summary>
    procedure GetRelatedProducts(FromType: Enum "NBC CRM Catalog Item Type"; FromNo: Code[20]; var ProductRel: Record "NBC CRM Product Rel.")
    begin
        ProductRel.Reset();
        ProductRel.SetCurrentKey("From Type", "From No.", Rank);
        ProductRel.SetRange("From Type", FromType);
        ProductRel.SetRange("From No.", FromNo);
    end;

    /// <summary>Open the related-products list for an item.</summary>
    procedure ShowRelatedProductsForItem(Item: Record Item)
    var
        ProductRel: Record "NBC CRM Product Rel.";
    begin
        GetRelatedProducts("NBC CRM Catalog Item Type"::Item, Item."No.", ProductRel);
        Page.Run(Page::"NBC CRM Product Relations", ProductRel);
    end;

    /// <summary>Open the related-products list for a resource.</summary>
    procedure ShowRelatedProductsForResource(Resource: Record Resource)
    var
        ProductRel: Record "NBC CRM Product Rel.";
    begin
        GetRelatedProducts("NBC CRM Catalog Item Type"::Resource, Resource."No.", ProductRel);
        Page.Run(Page::"NBC CRM Product Relations", ProductRel);
    end;
}
