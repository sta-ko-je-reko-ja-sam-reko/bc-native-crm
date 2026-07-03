namespace NBC.Test;

using NBC.CRM.Catalog;

/// <summary>Unit tests for CRM catalog logic — bundle amount calc and sellability gate (no DB).</summary>
codeunit 50904 "NBC CRM Catalog Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

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
        if BundleLine."Line Amount" <> 500 then
            Error('Expected 500, got %1.', BundleLine."Line Amount");
    end;

    [Test]
    procedure IsSellable_ActiveInsideWindow_True()
    var
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] an Active record with an open-ended window, asked on a date inside it
        if not CatalogMgt.IsSellable(Status::Active, 20240101D, 0D, 20250601D) then
            Error('Active record inside the window should be sellable.');
    end;

    [Test]
    procedure IsSellable_Draft_False()
    var
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] a Draft record — never sellable regardless of dates
        if CatalogMgt.IsSellable(Status::Draft, 0D, 0D, 20250601D) then
            Error('Draft record must not be sellable.');
    end;

    [Test]
    procedure IsSellable_ActiveBeforeValidFrom_False()
    var
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] an Active record asked before its sell window opens
        if CatalogMgt.IsSellable(Status::Active, 20250101D, 0D, 20241231D) then
            Error('Active record before Valid From must not be sellable.');
    end;

    [Test]
    procedure IsSellable_ActiveAfterValidTo_False()
    var
        CatalogMgt: Codeunit "NBC CRM Catalog Mgt.";
        Status: Enum "NBC CRM Catalog Status";
    begin
        // [GIVEN] an Active record asked after its sell window closes
        if CatalogMgt.IsSellable(Status::Active, 0D, 20241231D, 20250101D) then
            Error('Active record after Valid To must not be sellable.');
    end;
}
