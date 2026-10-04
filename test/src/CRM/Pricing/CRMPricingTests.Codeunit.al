namespace NBC.Test;

using NBC.CRM.Pricing;

/// <summary>Unit tests for CRM pricing logic — method derivation, rounding and discounts (no DB).</summary>
codeunit 69005 "NBC CRM Pricing Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure Compute_PercentOfList()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] 90% of a 200 list price
        // [THEN] price = 180
        if PricingCalc.ComputeUnitPrice(Method::"Percent of List", 90, 200, 50, 0) <> 180 then
            Error('Percent of List should give 180.');
    end;

    [Test]
    procedure Compute_MarkupOnCost()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] 20% markup on a cost of 100
        // [THEN] price = 120
        if PricingCalc.ComputeUnitPrice(Method::"Markup on Cost", 20, 0, 100, 0) <> 120 then
            Error('Markup on Cost should give 120.');
    end;

    [Test]
    procedure Compute_MarginOnCost()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] 20% target margin on a cost of 80 → 80 / 0.8 = 100
        if PricingCalc.ComputeUnitPrice(Method::"Margin on Cost", 20, 0, 80, 0) <> 100 then
            Error('Margin on Cost should give 100.');
    end;

    [Test]
    procedure Compute_MarginGuardsAtHundredPercent()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] a 100% margin would divide by zero → guarded to 0
        if PricingCalc.ComputeUnitPrice(Method::"Margin on Cost", 100, 0, 80, 0) <> 0 then
            Error('Margin of 100% must be guarded to 0.');
    end;

    [Test]
    procedure Compute_CurrencyAmountKeepsEntered()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] Currency Amount returns the entered amount unchanged
        if PricingCalc.ComputeUnitPrice(Method::"Currency Amount", 0, 500, 300, 149) <> 149 then
            Error('Currency Amount should keep the entered amount.');
    end;

    [Test]
    procedure Rounding_UpToEndIn99()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Policy: Enum "NBC CRM Rounding Policy";
    begin
        // [GIVEN] rounding 118.30 up to a 0.99-ending precision
        if PricingCalc.ApplyRounding(118.30, Policy::Up, 1) <> 119 then
            Error('Round up at precision 1 should give 119.');
    end;

    [Test]
    procedure Rounding_NoneReturnsInput()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Policy: Enum "NBC CRM Rounding Policy";
    begin
        if PricingCalc.ApplyRounding(118.37, Policy::"None", 1) <> 118.37 then
            Error('Policy None must return the input unchanged.');
    end;

    [Test]
    procedure Rounding_ZeroPrecisionReturnsInput()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Policy: Enum "NBC CRM Rounding Policy";
    begin
        if PricingCalc.ApplyRounding(118.37, Policy::Nearest, 0) <> 118.37 then
            Error('Precision 0 must return the input unchanged.');
    end;

    [Test]
    procedure Discount_PercentageApplied()
    var
        DiscountMgt: Codeunit "NBC CRM Discount Mgt.";
        DiscountType: Enum "NBC CRM Discount Type";
    begin
        // [GIVEN] 10% off 200 → 180
        if DiscountMgt.ApplyDiscount(200, DiscountType::Percentage, 10) <> 180 then
            Error('10%% off 200 should be 180.');
    end;

    [Test]
    procedure Discount_AmountApplied()
    var
        DiscountMgt: Codeunit "NBC CRM Discount Mgt.";
        DiscountType: Enum "NBC CRM Discount Type";
    begin
        // [GIVEN] 30 off 200 → 170
        if DiscountMgt.ApplyDiscount(200, DiscountType::Amount, 30) <> 170 then
            Error('30 off 200 should be 170.');
    end;

    [Test]
    procedure Discount_NeverNegative()
    var
        DiscountMgt: Codeunit "NBC CRM Discount Mgt.";
        DiscountType: Enum "NBC CRM Discount Type";
    begin
        // [GIVEN] an amount discount larger than the price → clamped to 0
        if DiscountMgt.ApplyDiscount(50, DiscountType::Amount, 80) <> 0 then
            Error('Discounted price must never go below 0.');
    end;

    [Test]
    procedure Compute_PercentOfListZeroGivesZero()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] 0% of a 200 list price  [THEN] price = 0
        if PricingCalc.ComputeUnitPrice(Method::"Percent of List", 0, 200, 50, 75) <> 0 then
            Error('0%% of list should give 0.');
    end;

    [Test]
    procedure Compute_MarginAboveHundredGuarded()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] a 150% margin (impossible) is guarded to 0 instead of a negative price
        if PricingCalc.ComputeUnitPrice(Method::"Margin on Cost", 150, 0, 80, 0) <> 0 then
            Error('A margin above 100%% must be guarded to 0.');
    end;

    [Test]
    procedure Compute_MarkupIgnoresListPrice()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Method: Enum "NBC CRM Pricing Method";
    begin
        // [GIVEN] 50% markup on cost 40 with an unrelated list price  [THEN] 60
        if PricingCalc.ComputeUnitPrice(Method::"Markup on Cost", 50, 1000, 40, 0) <> 60 then
            Error('Markup must be based on cost only.');
    end;

    [Test]
    procedure Rounding_DownToPrecision()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Policy: Enum "NBC CRM Rounding Policy";
    begin
        // [GIVEN] 118.95 rounded down at precision 1  [THEN] 118
        if PricingCalc.ApplyRounding(118.95, Policy::Down, 1) <> 118 then
            Error('Round down at precision 1 should give 118.');
    end;

    [Test]
    procedure Rounding_NearestToPrecision()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Policy: Enum "NBC CRM Rounding Policy";
    begin
        // [GIVEN] nearest 0.05  [THEN] 12.33 -> 12.35 and 12.32 -> 12.30
        if PricingCalc.ApplyRounding(12.33, Policy::Nearest, 0.05) <> 12.35 then
            Error('12.33 to the nearest 0.05 should give 12.35.');
        if PricingCalc.ApplyRounding(12.32, Policy::Nearest, 0.05) <> 12.3 then
            Error('12.32 to the nearest 0.05 should give 12.30.');
    end;

    [Test]
    procedure Rounding_NegativePrecisionReturnsInput()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        Policy: Enum "NBC CRM Rounding Policy";
    begin
        if PricingCalc.ApplyRounding(118.37, Policy::Up, -1) <> 118.37 then
            Error('A negative precision must return the input unchanged.');
    end;

    [Test]
    procedure Discount_FullPercentageGivesZero()
    var
        DiscountMgt: Codeunit "NBC CRM Discount Mgt.";
        DiscountType: Enum "NBC CRM Discount Type";
    begin
        // [GIVEN] 100% off  [THEN] free
        if DiscountMgt.ApplyDiscount(200, DiscountType::Percentage, 100) <> 0 then
            Error('100%% off should be 0.');
    end;

    [Test]
    procedure Discount_ZeroValueKeepsPrice()
    var
        DiscountMgt: Codeunit "NBC CRM Discount Mgt.";
        DiscountType: Enum "NBC CRM Discount Type";
    begin
        if DiscountMgt.ApplyDiscount(200, DiscountType::Percentage, 0) <> 200 then
            Error('0%% off must keep the price.');
        if DiscountMgt.ApplyDiscount(200, DiscountType::Amount, 0) <> 200 then
            Error('An amount of 0 off must keep the price.');
    end;

    [Test]
    procedure PricingCalcIsUsableThroughItsInterface()
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        IPricingCalc: Interface "NBC CRM IPricingCalc";
        Method: Enum "NBC CRM Pricing Method";
        Policy: Enum "NBC CRM Rounding Policy";
    begin
        // [GIVEN] the default implementation behind the swappable interface
        IPricingCalc := PricingCalc;

        // [THEN] it derives and rounds like the codeunit: 90% of 133 = 119.70 -> up to 120
        if IPricingCalc.ApplyRounding(IPricingCalc.ComputeUnitPrice(Method::"Percent of List", 90, 133, 0, 0), Policy::Up, 1) <> 120 then
            Error('Interface call should give 120.');
    end;
}
