namespace NBC.Demo;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.CRM.Catalog;

/// <summary>
/// Idempotent CRONUS-style demo seeder for the Product Sales Catalog feature: sample bundle packages with their
/// component lines, seller-facing product-relation rows covering every relationship type, and the CRM catalog
/// status/window facets stamped on standard CRONUS items and resources (covering every catalog-status value).
/// Every reference to standard CRONUS master data is Get-guarded, so the seeder skips gracefully (never errors)
/// on a non-CRONUS company. Safe to run repeatedly — fixed keys guard every insert.
/// </summary>
codeunit 50168 "NBC Demo Catalog"
{
    Access = Public;

    /// <summary>Seed demo bundles, bundle lines, product relations and catalog facets. Idempotent and defensive.</summary>
    procedure Import()
    begin
        SeedBundles();
        SeedBundleLines();
        SeedProductRelations();
        SeedItemFacets();
        SeedResourceFacets();
        CreateConfigPackage();
    end;

    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
        AffixFieldNos: List of [Integer];
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Bundle");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Bundle Line");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Product Rel.");
        AffixFieldNos.Add(50090);
        AffixFieldNos.Add(50091);
        AffixFieldNos.Add(50092);
        AffixFieldNos.Add(50093);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::Item, AffixFieldNos);
        Clear(AffixFieldNos);
        AffixFieldNos.Add(50090);
        AffixFieldNos.Add(50091);
        AffixFieldNos.Add(50092);
        AffixFieldNos.Add(50093);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::Resource, AffixFieldNos);
    end;

    local procedure SeedBundles()
    begin
        InsertBundle('BND-STARTER', 'Starter Package', 2500, "NBC CRM Catalog Status"::Active);
        InsertBundle('BND-PRO', 'Professional Package', 5000, "NBC CRM Catalog Status"::Draft);
    end;

    local procedure SeedBundleLines()
    begin
        // Starter Package — three CRONUS items (required core + optional add-ons).
        InsertItemLine('BND-STARTER', 10000, '1000', 1, true);
        InsertItemLine('BND-STARTER', 20000, '1100', 1, false);
        InsertItemLine('BND-STARTER', 30000, '1900', 2, false);

        // Professional Package — a core item plus a resource line (covers Component Type::Resource).
        InsertItemLine('BND-PRO', 10000, '1000', 1, true);
        InsertResourceLine('BND-PRO', 20000, ResourceA(), 8, false);
    end;

    local procedure SeedProductRelations()
    begin
        // One relation per "NBC CRM Product Rel. Type" value, between CRONUS items.
        InsertItemRelation('1000', "NBC CRM Product Rel. Type"::Substitute, '1100', 1);
        InsertItemRelation('1000', "NBC CRM Product Rel. Type"::CrossSell, '1900', 2);
        InsertItemRelation('1100', "NBC CRM Product Rel. Type"::UpSell, '1000', 1);
        InsertItemRelation('1900', "NBC CRM Product Rel. Type"::Accessory, '1100', 1);

        // Item -> resource accessory (covers "To Type"::Resource on the relation).
        InsertItemToResourceRelation('1000', "NBC CRM Product Rel. Type"::Accessory, ResourceA(), 3);
    end;

    local procedure SeedItemFacets()
    begin
        // Covers every "NBC CRM Catalog Status" value across three CRONUS items.
        StampItemFacet('1000', "NBC CRM Catalog Status"::Active, DMY2Date(1, 1, 2024), 0D);
        StampItemFacet('1100', "NBC CRM Catalog Status"::Draft, 0D, 0D);
        StampItemFacet('1900', "NBC CRM Catalog Status"::Retired, DMY2Date(1, 1, 2020), DMY2Date(31, 12, 2023));
    end;

    local procedure SeedResourceFacets()
    begin
        StampResourceFacet(ResourceA(), "NBC CRM Catalog Status"::Active, DMY2Date(1, 1, 2024), 0D);
        StampResourceFacet(ResourceB(), "NBC CRM Catalog Status"::Draft, 0D, 0D);
    end;

    local procedure InsertBundle(BundleNo: Code[20]; BundleDescription: Text[100]; UnitPrice: Decimal; Status: Enum "NBC CRM Catalog Status")
    var
        Bundle: Record "NBC CRM Bundle";
    begin
        if Bundle.Get(BundleNo) then
            exit;
        Bundle.Init();
        Bundle.Validate("No.", BundleNo);
        Bundle.Validate(Description, BundleDescription);
        Bundle.Validate("Unit Price", UnitPrice);
        Bundle.Validate("Catalog Status", Status);
        Bundle.Insert(true);
    end;

    local procedure InsertItemLine(BundleNo: Code[20]; LineNo: Integer; ItemNo: Code[20]; Qty: Decimal; IsRequired: Boolean)
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("No.");
        if not Item.Get(ItemNo) then
            exit;
        InsertBundleLine(BundleNo, LineNo, "NBC CRM Catalog Item Type"::Item, ItemNo, Qty, IsRequired);
    end;

    local procedure InsertResourceLine(BundleNo: Code[20]; LineNo: Integer; ResourceNo: Code[20]; Qty: Decimal; IsRequired: Boolean)
    var
        Resource: Record Resource;
    begin
        if ResourceNo = '' then
            exit;
        Resource.SetLoadFields("No.");
        if not Resource.Get(ResourceNo) then
            exit;
        InsertBundleLine(BundleNo, LineNo, "NBC CRM Catalog Item Type"::Resource, ResourceNo, Qty, IsRequired);
    end;

    local procedure InsertBundleLine(BundleNo: Code[20]; LineNo: Integer; ComponentType: Enum "NBC CRM Catalog Item Type"; ComponentNo: Code[20]; Qty: Decimal; IsRequired: Boolean)
    var
        BundleLine: Record "NBC CRM Bundle Line";
        Bundle: Record "NBC CRM Bundle";
    begin
        Bundle.SetLoadFields("No.");
        if not Bundle.Get(BundleNo) then
            exit;
        if BundleLine.Get(BundleNo, LineNo) then
            exit;
        BundleLine.Init();
        BundleLine.Validate("Bundle No.", BundleNo);
        BundleLine.Validate("Line No.", LineNo);
        BundleLine.Validate("Component Type", ComponentType);
        BundleLine.Validate("No.", ComponentNo);
        BundleLine.Validate(Quantity, Qty);
        BundleLine.Validate(Required, IsRequired);
        BundleLine.Insert(true);
    end;

    local procedure InsertItemRelation(FromNo: Code[20]; RelationType: Enum "NBC CRM Product Rel. Type"; ToNo: Code[20]; RelationRank: Integer)
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("No.");
        if not Item.Get(FromNo) then
            exit;
        Item.SetLoadFields("No.");
        if not Item.Get(ToNo) then
            exit;
        InsertRelation(
            "NBC CRM Catalog Item Type"::Item, FromNo, RelationType,
            "NBC CRM Catalog Item Type"::Item, ToNo, RelationRank);
    end;

    local procedure InsertItemToResourceRelation(FromNo: Code[20]; RelationType: Enum "NBC CRM Product Rel. Type"; ToNo: Code[20]; RelationRank: Integer)
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        Item.SetLoadFields("No.");
        if not Item.Get(FromNo) then
            exit;
        if ToNo = '' then
            exit;
        Resource.SetLoadFields("No.");
        if not Resource.Get(ToNo) then
            exit;
        InsertRelation(
            "NBC CRM Catalog Item Type"::Item, FromNo, RelationType,
            "NBC CRM Catalog Item Type"::Resource, ToNo, RelationRank);
    end;

    local procedure InsertRelation(FromType: Enum "NBC CRM Catalog Item Type"; FromNo: Code[20]; RelationType: Enum "NBC CRM Product Rel. Type"; ToType: Enum "NBC CRM Catalog Item Type"; ToNo: Code[20]; RelationRank: Integer)
    var
        ProductRel: Record "NBC CRM Product Rel.";
    begin
        if ProductRel.Get(FromType, FromNo, RelationType, ToType, ToNo) then
            exit;
        ProductRel.Init();
        ProductRel.Validate("From Type", FromType);
        ProductRel.Validate("From No.", FromNo);
        ProductRel.Validate("Relationship Type", RelationType);
        ProductRel.Validate("To Type", ToType);
        ProductRel.Validate("To No.", ToNo);
        ProductRel.Validate(Rank, RelationRank);
        ProductRel.Insert(true);
    end;

    local procedure StampItemFacet(ItemNo: Code[20]; Status: Enum "NBC CRM Catalog Status"; ValidFrom: Date; ValidTo: Date)
    var
        Item: Record Item;
    begin
        if not Item.Get(ItemNo) then
            exit;
        Item.Validate("NBC CRM Catalog Status", Status);
        Item.Validate("NBC CRM Valid From", ValidFrom);
        Item.Validate("NBC CRM Valid To", ValidTo);
        Item.Modify(true);
    end;

    local procedure StampResourceFacet(ResourceNo: Code[20]; Status: Enum "NBC CRM Catalog Status"; ValidFrom: Date; ValidTo: Date)
    var
        Resource: Record Resource;
    begin
        if ResourceNo = '' then
            exit;
        if not Resource.Get(ResourceNo) then
            exit;
        Resource.Validate("NBC CRM Catalog Status", Status);
        Resource.Validate("NBC CRM Valid From", ValidFrom);
        Resource.Validate("NBC CRM Valid To", ValidTo);
        Resource.Modify(true);
    end;

    /// <summary>Defensively resolve a primary CRONUS resource for demo lines/facets.</summary>
    local procedure ResourceA(): Code[20]
    var
        Resource: Record Resource;
    begin
        Resource.SetLoadFields("No.");
        if Resource.Get('TIMBASIC') then
            exit(Resource."No.");
        Resource.SetLoadFields("No.");
        if Resource.FindFirst() then
            exit(Resource."No.");
        exit('');
    end;

    /// <summary>Defensively resolve a second, distinct CRONUS resource for demo facets.</summary>
    local procedure ResourceB(): Code[20]
    var
        Resource: Record Resource;
    begin
        Resource.SetLoadFields("No.");
        if Resource.Get('LINA') then
            exit(Resource."No.");
        Resource.SetFilter("No.", '<>%1', ResourceA());
        Resource.SetLoadFields("No.");
        if Resource.FindFirst() then
            exit(Resource."No.");
        exit('');
    end;

    var
        PackageCodeTok: Label 'NBC-CATALOG', Locked = true;
        PackageNameLbl: Label 'CRM Product Catalog';
}
