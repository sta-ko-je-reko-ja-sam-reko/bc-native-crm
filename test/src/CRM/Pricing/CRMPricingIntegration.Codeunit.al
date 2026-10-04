namespace NBC.Test;

using Microsoft.Pricing.Asset;
using Microsoft.Pricing.Calculation;
using Microsoft.Pricing.PriceList;
using Microsoft.Pricing.Source;
using NBC.CRM.Pricing;
using System.TestLibraries.Utilities;

/// <summary>
/// Pricing flexibility (FEAT-PRC-001), DB-bound: quantity-banded discount tiers resolved from a discount list, and
/// the CRM pricing method + rounding rule written back to a standard sales Price List Line from the asset's
/// list price / unit cost (Item and Resource).
/// </summary>
codeunit 69015 "NBC CRM Pricing Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        DiscountMgt: Codeunit "NBC CRM Discount Mgt.";

    [Test]
    procedure DiscountTierResolvedByQuantityBand()
    var
        DiscountListCode: Code[20];
    begin
        // [GIVEN] bands 1-9 = 0, 10-49 = 5, 50-99 = 10, 100+ = 15
        TestLibrary.Initialize();
        DiscountListCode := CreateVolumeDiscount();

        // [THEN] each quantity resolves to its band, bounds inclusive
        Assert.AreEqual(0, DiscountMgt.ResolveDiscountValue(DiscountListCode, 5), 'Qty 5');
        Assert.AreEqual(5, DiscountMgt.ResolveDiscountValue(DiscountListCode, 10), 'Qty 10 (lower bound)');
        Assert.AreEqual(5, DiscountMgt.ResolveDiscountValue(DiscountListCode, 49), 'Qty 49 (upper bound)');
        Assert.AreEqual(10, DiscountMgt.ResolveDiscountValue(DiscountListCode, 75), 'Qty 75');
        Assert.AreEqual(15, DiscountMgt.ResolveDiscountValue(DiscountListCode, 100), 'Qty 100');
        Assert.AreEqual(15, DiscountMgt.ResolveDiscountValue(DiscountListCode, 100000), 'Open-ended top band');
    end;

    [Test]
    procedure QuantityBelowFirstBandGetsNoDiscount()
    var
        DiscountListCode: Code[20];
    begin
        // [GIVEN] the volume discount, first band starting at 1
        TestLibrary.Initialize();
        DiscountListCode := CreateVolumeDiscount();

        // [THEN] a quantity of 0.5 gets nothing
        Assert.AreEqual(0, DiscountMgt.ResolveDiscountValue(DiscountListCode, 0.5), 'Qty below the first band');
    end;

    [Test]
    procedure QuantityInGapBetweenBandsGetsNoDiscount()
    var
        DiscountListCode: Code[20];
    begin
        // [GIVEN] bands 1-10 = 3 and 20-30 = 6 (a gap 10..20)
        TestLibrary.Initialize();
        DiscountListCode := TestLibrary.CreateDiscountList(Enum::"NBC CRM Discount Type"::Amount);
        TestLibrary.AddDiscountTier(DiscountListCode, 10000, 1, 10, 3);
        TestLibrary.AddDiscountTier(DiscountListCode, 20000, 20, 30, 6);

        // [THEN] 15 falls in the gap, 31 above the bounded last band
        Assert.AreEqual(0, DiscountMgt.ResolveDiscountValue(DiscountListCode, 15), 'Qty in the gap');
        Assert.AreEqual(0, DiscountMgt.ResolveDiscountValue(DiscountListCode, 31), 'Qty above the last bounded band');
        Assert.AreEqual(6, DiscountMgt.ResolveDiscountValue(DiscountListCode, 25), 'Qty in the second band');
    end;

    [Test]
    procedure BlankOrUnknownDiscountListGivesZero()
    begin
        // [THEN] no list, or a list without tiers, resolves to 0
        TestLibrary.Initialize();
        Assert.AreEqual(0, DiscountMgt.ResolveDiscountValue('', 10), 'Blank list');
        Assert.AreEqual(0, DiscountMgt.ResolveDiscountValue(TestLibrary.CreateDiscountList(Enum::"NBC CRM Discount Type"::Percentage), 10), 'List without tiers');
    end;

    [Test]
    procedure ResolvedTierAppliedToPrice()
    var
        DiscountListCode: Code[20];
    begin
        // [GIVEN] the volume discount (percentage)
        TestLibrary.Initialize();
        DiscountListCode := CreateVolumeDiscount();

        // [WHEN] 60 units at 200 are priced  [THEN] 10% band -> 180
        Assert.AreEqual(180,
            DiscountMgt.ApplyDiscount(200, Enum::"NBC CRM Discount Type"::Percentage, DiscountMgt.ResolveDiscountValue(DiscountListCode, 60)),
            'Discounted unit price');
    end;

    [Test]
    procedure PercentOfListPriceWrittenToItemPriceLine()
    var
        PriceListLine: Record "Price List Line";
    begin
        // [GIVEN] an item listed at 200, and a sales price line for it at 90% of list
        TestLibrary.Initialize();
        CreateItemPriceLine(PriceListLine, TestLibrary.CreateItem(200, 120));
        SetCrmPricing(PriceListLine, Enum::"NBC CRM Pricing Method"::"Percent of List", 90, Enum::"NBC CRM Rounding Policy"::"None", 0);

        // [WHEN] the CRM price is recalculated
        RecalculatePrice(PriceListLine);

        // [THEN] the line's unit price is 180 and stored
        Assert.AreEqual(180, PriceListLine."Unit Price", 'Unit price');
    end;

    [Test]
    procedure MarkupWithRoundingWrittenToItemPriceLine()
    var
        PriceListLine: Record "Price List Line";
    begin
        // [GIVEN] an item costing 83, a 25% markup (103.75) rounded up to whole units
        TestLibrary.Initialize();
        CreateItemPriceLine(PriceListLine, TestLibrary.CreateItem(150, 83));
        SetCrmPricing(PriceListLine, Enum::"NBC CRM Pricing Method"::"Markup on Cost", 25, Enum::"NBC CRM Rounding Policy"::Up, 1);

        // [WHEN] the CRM price is recalculated  [THEN] 104
        RecalculatePrice(PriceListLine);
        Assert.AreEqual(104, PriceListLine."Unit Price", 'Unit price');
    end;

    [Test]
    procedure MarginOnCostWrittenToResourcePriceLine()
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
    begin
        // [GIVEN] a resource costing 60 and a 40% margin -> 100
        TestLibrary.Initialize();
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::"All Customers", '');
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Resource, TestLibrary.CreateResource(90, 60));
        SetCrmPricing(PriceListLine, Enum::"NBC CRM Pricing Method"::"Margin on Cost", 40, Enum::"NBC CRM Rounding Policy"::Nearest, 0.01);

        // [WHEN] the CRM price is recalculated  [THEN] 100
        RecalculatePrice(PriceListLine);
        Assert.AreEqual(100, PriceListLine."Unit Price", 'Unit price');
    end;

    [Test]
    procedure CurrencyAmountLineIsLeftAlone()
    var
        PriceListLine: Record "Price List Line";
    begin
        // [GIVEN] a price line with a manual unit price and the default Currency Amount method
        TestLibrary.Initialize();
        CreateItemPriceLine(PriceListLine, TestLibrary.CreateItem(200, 120));
        PriceListLine.Validate("Unit Price", 149);
        PriceListLine.Modify(true);

        // [WHEN] the CRM price is recalculated  [THEN] the manual price is kept
        RecalculatePrice(PriceListLine);
        Assert.AreEqual(149, PriceListLine."Unit Price", 'Unit price');
    end;

    local procedure CreateVolumeDiscount() DiscountListCode: Code[20]
    begin
        DiscountListCode := TestLibrary.CreateDiscountList(Enum::"NBC CRM Discount Type"::Percentage);
        TestLibrary.AddDiscountTier(DiscountListCode, 10000, 1, 9, 0);
        TestLibrary.AddDiscountTier(DiscountListCode, 20000, 10, 49, 5);
        TestLibrary.AddDiscountTier(DiscountListCode, 30000, 50, 99, 10);
        TestLibrary.AddDiscountTier(DiscountListCode, 40000, 100, 0, 15);
    end;

    local procedure CreateItemPriceLine(var PriceListLine: Record "Price List Line"; ItemNo: Code[20])
    var
        PriceListHeader: Record "Price List Header";
    begin
        LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, "Price Type"::Sale, "Price Source Type"::"All Customers", '');
        LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, "Price Amount Type"::Price, "Price Asset Type"::Item, ItemNo);
    end;

    local procedure SetCrmPricing(var PriceListLine: Record "Price List Line"; Method: Enum "NBC CRM Pricing Method"; Percentage: Decimal; Policy: Enum "NBC CRM Rounding Policy"; Precision: Decimal)
    begin
        PriceListLine.Validate("NBC CRM Pricing Method", Method);
        PriceListLine.Validate("NBC CRM Pricing %", Percentage);
        PriceListLine.Validate("NBC CRM Rounding Policy", Policy);
        PriceListLine.Validate("NBC CRM Rounding Precision", Precision);
        PriceListLine.Modify(true);
    end;

    local procedure RecalculatePrice(var PriceListLine: Record "Price List Line")
    var
        PriceLineMgt: Codeunit "NBC CRM Price Line Mgt.";
    begin
        PriceLineMgt.RecalculatePrice(PriceListLine);
        PriceListLine.Get(PriceListLine."Price List Code", PriceListLine."Line No.");
    end;
}
