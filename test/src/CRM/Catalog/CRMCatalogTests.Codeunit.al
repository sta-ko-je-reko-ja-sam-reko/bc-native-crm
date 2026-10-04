namespace NBC.Test;

using NBC.CRM.Catalog;
using System.TestLibraries.Utilities;

/// <summary>Unit tests for CRM catalog logic (FEAT-CAT-001) — bundle amount calc, the logic seam and the sellability gate (no DB).</summary>
codeunit 69004 "NBC CRM Catalog Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";

    [Test]
    procedure BundleLine_AmountIsQuantityTimesUnitPrice()
    var
        BundleLine: Record "NBC CRM Bundle Line";
        BundleLogic: Codeunit "NBC CRM Bundle Logic";
    begin
        // [GIVEN] a component line with quantity and unit price
        BundleLine.Quantity := 4;
        BundleLine."Unit Price" := 125;

        // [WHEN] recalculating the amount
        BundleLogic.Validate_Amounts(BundleLine);

        // [THEN] line amount = quantity × unit price
        Assert.AreEqual(500, BundleLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure BundleLine_ValidationTriggersRecalculate()
    var
        BundleLine: Record "NBC CRM Bundle Line";
    begin
        // [WHEN] quantity and price are validated on the table (in memory)
        BundleLine.Validate(Quantity, 3);
        BundleLine.Validate("Unit Price", 19.99);

        // [THEN] the amount follows, rounded to 0.01
        Assert.AreEqual(59.97, BundleLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure BundleLine_UnknownComponentKeepsManualPrice()
    var
        BundleLine: Record "NBC CRM Bundle Line";
        BundleLogic: Codeunit "NBC CRM Bundle Logic";
    begin
        // [GIVEN] an item component that does not exist, with a manual price
        BundleLine."Component Type" := BundleLine."Component Type"::Item;
        BundleLine."No." := 'NBC-NO-SUCH-ITEM';
        BundleLine.Quantity := 2;
        BundleLine."Unit Price" := 7;

        // [WHEN] No. is validated through the logic
        BundleLogic.Validate_No(BundleLine);

        // [THEN] the manual price stays and the amount is recalculated
        Assert.AreEqual(7, BundleLine."Unit Price", 'Unit price');
        Assert.AreEqual(14, BundleLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure BundleLine_DelegatesToInjectedLogic()
    var
        BundleLine: Record "NBC CRM Bundle Line";
        SpyBundleLogic: Codeunit "NBC Spy Bundle Logic";
    begin
        // [GIVEN] the spy logic injected
        SpyBundleLogic.Reset();
        BundleLine.Define(SpyBundleLogic);

        // [WHEN] No., Quantity and Unit Price are validated
        BundleLine.Validate("No.", '');
        BundleLine.Validate(Quantity, 2);
        BundleLine.Validate("Unit Price", 5);

        // [THEN] the spy received every call and no amount was calculated
        Assert.AreEqual(1, SpyBundleLogic.NoCallCount(), 'Validate_No calls');
        Assert.AreEqual(2, SpyBundleLogic.AmountCallCount(), 'Validate_Amounts calls');
        Assert.AreEqual(0, BundleLine."Line Amount", 'The default calculation must not run.');
    end;

    [Test]
    procedure IsSellable_ActiveInsideWindow_True()
    var
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] an Active record with an open-ended window, asked on a date inside it
        Assert.IsTrue(CatalogMgt.IsSellable(Status::Active, 20240101D, 0D, 20250601D), 'Active inside the window');
    end;

    [Test]
    procedure IsSellable_ActiveWithoutWindow_True()
    var
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] an Active record without any sell window
        Assert.IsTrue(CatalogMgt.IsSellable(Status::Active, 0D, 0D, 20250601D), 'Active without a window');
    end;

    [Test]
    procedure IsSellable_WindowBoundsAreInclusive()
    var
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] a window 2025-01-01..2025-01-31  [THEN] both bounds are sellable
        Assert.IsTrue(CatalogMgt.IsSellable(Status::Active, 20250101D, 20250131D, 20250101D), 'First day');
        Assert.IsTrue(CatalogMgt.IsSellable(Status::Active, 20250101D, 20250131D, 20250131D), 'Last day');
    end;

    [Test]
    procedure IsSellable_Draft_False()
    var
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] a Draft record — never sellable regardless of dates
        Assert.IsFalse(CatalogMgt.IsSellable(Status::Draft, 0D, 0D, 20250601D), 'Draft');
    end;

    [Test]
    procedure IsSellable_Retired_False()
    var
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] a Retired record inside its window
        Assert.IsFalse(CatalogMgt.IsSellable(Status::Retired, 20240101D, 20261231D, 20250601D), 'Retired');
    end;

    [Test]
    procedure IsSellable_ActiveBeforeValidFrom_False()
    var
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] an Active record asked before its sell window opens
        Assert.IsFalse(CatalogMgt.IsSellable(Status::Active, 20250101D, 0D, 20241231D), 'Before Valid From');
    end;

    [Test]
    procedure IsSellable_ActiveAfterValidTo_False()
    var
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] an Active record asked after its sell window closes
        Assert.IsFalse(CatalogMgt.IsSellable(Status::Active, 0D, 20241231D, 20250101D), 'After Valid To');
    end;
}
