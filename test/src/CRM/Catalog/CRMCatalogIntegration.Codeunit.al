namespace NBC.Test;

using Microsoft.Inventory.Item;
using Microsoft.Projects.Resources.Resource;
using NBC.CRM.Catalog;
using System.TestLibraries.Utilities;

/// <summary>
/// Product sales catalog (FEAT-CAT-001), DB-bound: bundle components pulling price/description from Item and
/// Resource, the component and required-component roll-ups (service and FlowField), ranked related-product
/// suggestions, and the publish/retire lifecycle on Item and Resource.
/// </summary>
codeunit 69014 "NBC CRM Catalog Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        LibraryUtility: Codeunit "Library - Utility";

    [Test]
    procedure ItemComponentPullsDescriptionAndPrice()
    var
        BundleLine: Record "NBC CRM Bundle Line";
        Item: Record Item;
    begin
        // [GIVEN] an item priced 40
        TestLibrary.Initialize();
        Item.Get(TestLibrary.CreateItem(40, 25));

        // [WHEN] a component line for 3 of it is given the item
        BundleLine."Component Type" := BundleLine."Component Type"::Item;
        BundleLine.Quantity := 3;
        BundleLine.Validate("No.", Item."No.");

        // [THEN] description, price and amount come from the item
        Assert.AreEqual(Item.Description, BundleLine.Description, 'Description');
        Assert.AreEqual(40, BundleLine."Unit Price", 'Unit price');
        Assert.AreEqual(120, BundleLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure ResourceComponentPullsNameAndPrice()
    var
        BundleLine: Record "NBC CRM Bundle Line";
        Resource: Record Resource;
    begin
        // [GIVEN] a resource priced 80
        TestLibrary.Initialize();
        Resource.Get(TestLibrary.CreateResource(80, 45));

        // [WHEN] a component line for 5 hours is given the resource
        BundleLine."Component Type" := BundleLine."Component Type"::Resource;
        BundleLine.Quantity := 5;
        BundleLine.Validate("No.", Resource."No.");

        // [THEN] name, price and amount come from the resource
        Assert.AreEqual(Resource.Name, BundleLine.Description, 'Description');
        Assert.AreEqual(80, BundleLine."Unit Price", 'Unit price');
        Assert.AreEqual(400, BundleLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure ComponentTotalsRollUpRequiredAndOptional()
    var
        Bundle: Record "NBC CRM Bundle";
        BundleMgt: Codeunit "NBC CRM Bundle Mgt.";
        BundleNo: Code[20];
        OtherBundleNo: Code[20];
    begin
        // [GIVEN] a bundle with a required 2 × 100 and an optional 1 × 50 component, and another bundle
        TestLibrary.Initialize();
        BundleNo := CreateBundle();
        OtherBundleNo := CreateBundle();
        InsertComponent(BundleNo, 10000, 2, 100, true);
        InsertComponent(BundleNo, 20000, 1, 50, false);
        InsertComponent(OtherBundleNo, 10000, 1, 999, true);

        // [THEN] the total is 250, the required total 200, and the FlowField agrees with the service
        Assert.AreEqual(250, BundleMgt.CalcComponentTotal(BundleNo), 'Component total');
        Assert.AreEqual(200, BundleMgt.CalcRequiredTotal(BundleNo), 'Required total');
        Bundle.Get(BundleNo);
        Bundle.CalcFields("Component Total");
        Assert.AreEqual(250, Bundle."Component Total", 'Component Total FlowField');
    end;

    [Test]
    procedure EmptyBundleTotalsAreZero()
    var
        BundleMgt: Codeunit "NBC CRM Bundle Mgt.";
        BundleNo: Code[20];
    begin
        // [GIVEN] a bundle without components  [THEN] both totals are 0
        TestLibrary.Initialize();
        BundleNo := CreateBundle();
        Assert.AreEqual(0, BundleMgt.CalcComponentTotal(BundleNo), 'Component total');
        Assert.AreEqual(0, BundleMgt.CalcRequiredTotal(BundleNo), 'Required total');
    end;

    [Test]
    procedure RelatedProductsAreFilteredAndRanked()
    var
        ProductRel: Record "NBC CRM Product Rel.";
        BundleMgt: Codeunit "NBC CRM Bundle Mgt.";
        SourceItemNo: Code[20];
        OtherItemNo: Code[20];
        BestNo: Code[20];
        SecondNo: Code[20];
    begin
        // [GIVEN] an item with an up-sell (rank 2) and a cross-sell (rank 1), and an unrelated item's relation
        TestLibrary.Initialize();
        SourceItemNo := TestLibrary.CreateItem(10, 5);
        OtherItemNo := TestLibrary.CreateItem(10, 5);
        SecondNo := TestLibrary.CreateItem(20, 10);
        BestNo := TestLibrary.CreateItem(30, 15);
        InsertRelation(SourceItemNo, Enum::"NBC CRM Product Rel. Type"::UpSell, SecondNo, 2);
        InsertRelation(SourceItemNo, Enum::"NBC CRM Product Rel. Type"::CrossSell, BestNo, 1);
        InsertRelation(OtherItemNo, Enum::"NBC CRM Product Rel. Type"::Accessory, BestNo, 1);

        // [WHEN] collecting the suggestions for the source item
        BundleMgt.GetRelatedProducts(Enum::"NBC CRM Catalog Item Type"::Item, SourceItemNo, ProductRel);

        // [THEN] only its two relations are returned, best rank first
        Assert.RecordCount(ProductRel, 2);
        ProductRel.FindSet();
        Assert.AreEqual(BestNo, ProductRel."To No.", 'Best ranked suggestion');
        ProductRel.Next();
        Assert.AreEqual(SecondNo, ProductRel."To No.", 'Second suggestion');
    end;

    [Test]
    procedure RelatedProductsResetCallerFilters()
    var
        ProductRel: Record "NBC CRM Product Rel.";
        BundleMgt: Codeunit "NBC CRM Bundle Mgt.";
        SourceItemNo: Code[20];
    begin
        // [GIVEN] an item with one relation, and a caller record carrying an unrelated filter
        TestLibrary.Initialize();
        SourceItemNo := TestLibrary.CreateItem(10, 5);
        InsertRelation(SourceItemNo, Enum::"NBC CRM Product Rel. Type"::Substitute, TestLibrary.CreateItem(10, 5), 1);
        ProductRel.SetRange(Rank, 99);

        // [WHEN] collecting the suggestions  [THEN] the stale filter is gone
        BundleMgt.GetRelatedProducts(Enum::"NBC CRM Catalog Item Type"::Item, SourceItemNo, ProductRel);
        Assert.RecordCount(ProductRel, 1);
    end;

    [Test]
    procedure PublishAndRetireItem()
    var
        Item: Record Item;
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
    begin
        // [GIVEN] a new item (Draft)
        TestLibrary.Initialize();
        Item.Get(TestLibrary.CreateItem(10, 5));
        Assert.AreEqual(Item."NBC CRM Catalog Status"::Draft, Item."NBC CRM Catalog Status", 'Initial status');

        // [WHEN] published  [THEN] Active and stored
        CatalogMgt.PublishItem(Item);
        Item.Get(Item."No.");
        Assert.AreEqual(Item."NBC CRM Catalog Status"::Active, Item."NBC CRM Catalog Status", 'After publish');

        // [WHEN] retired  [THEN] Retired and stored
        CatalogMgt.RetireItem(Item);
        Item.Get(Item."No.");
        Assert.AreEqual(Item."NBC CRM Catalog Status"::Retired, Item."NBC CRM Catalog Status", 'After retire');
    end;

    [Test]
    procedure PublishAndRetireResource()
    var
        Resource: Record Resource;
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
    begin
        // [GIVEN] a new resource
        TestLibrary.Initialize();
        Resource.Get(TestLibrary.CreateResource(10, 5));

        // [WHEN] published  [THEN] Active
        CatalogMgt.PublishResource(Resource);
        Resource.Get(Resource."No.");
        Assert.AreEqual(Resource."NBC CRM Catalog Status"::Active, Resource."NBC CRM Catalog Status", 'After publish');

        // [WHEN] retired  [THEN] Retired
        CatalogMgt.RetireResource(Resource);
        Resource.Get(Resource."No.");
        Assert.AreEqual(Resource."NBC CRM Catalog Status"::Retired, Resource."NBC CRM Catalog Status", 'After retire');
    end;

    [Test]
    procedure PublishedItemIsSellableInsideItsWindow()
    var
        Item: Record Item;
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
    begin
        // [GIVEN] a published item with a sell window around WorkDate
        TestLibrary.Initialize();
        Item.Get(TestLibrary.CreateItem(10, 5));
        Item."NBC CRM Valid From" := CalcDate('<-1M>', WorkDate());
        Item."NBC CRM Valid To" := CalcDate('<+1M>', WorkDate());
        Item.Modify();
        CatalogMgt.PublishItem(Item);

        // [THEN] it is sellable on WorkDate and not after the window
        Item.Get(Item."No.");
        Assert.IsTrue(CatalogMgt.IsSellable(Item."NBC CRM Catalog Status", Item."NBC CRM Valid From", Item."NBC CRM Valid To", WorkDate()), 'On WorkDate');
        Assert.IsFalse(CatalogMgt.IsSellable(Item."NBC CRM Catalog Status", Item."NBC CRM Valid From", Item."NBC CRM Valid To", CalcDate('<+2M>', WorkDate())), 'After the window');
    end;

    local procedure CreateBundle(): Code[20]
    var
        Bundle: Record "NBC CRM Bundle";
    begin
        Bundle.Init();
        Bundle."No." := LibraryUtility.GenerateRandomCode20(Bundle.FieldNo("No."), Database::"NBC CRM Bundle");
        Bundle.Description := Bundle."No.";
        Bundle.Insert(true);
        exit(Bundle."No.");
    end;

    local procedure InsertComponent(BundleNo: Code[20]; LineNo: Integer; Quantity: Decimal; UnitPrice: Decimal; IsRequired: Boolean)
    var
        BundleLine: Record "NBC CRM Bundle Line";
    begin
        BundleLine.Init();
        BundleLine."Bundle No." := BundleNo;
        BundleLine."Line No." := LineNo;
        BundleLine.Validate(Quantity, Quantity);
        BundleLine.Validate("Unit Price", UnitPrice);
        BundleLine.Required := IsRequired;
        BundleLine.Insert(true);
    end;

    local procedure InsertRelation(FromNo: Code[20]; RelationType: Enum "NBC CRM Product Rel. Type"; ToNo: Code[20]; Rank: Integer)
    var
        ProductRel: Record "NBC CRM Product Rel.";
    begin
        ProductRel.Init();
        ProductRel."From Type" := ProductRel."From Type"::Item;
        ProductRel."From No." := FromNo;
        ProductRel."Relationship Type" := RelationType;
        ProductRel."To Type" := ProductRel."To Type"::Item;
        ProductRel."To No." := ToNo;
        ProductRel.Rank := Rank;
        ProductRel.Insert(true);
    end;
}
