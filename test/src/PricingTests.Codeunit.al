namespace NBC.Test;

using NBC.CRM.Pricing;

/// <summary>Unit tests for CRM pricing logic — method derivation, rounding and discounts (no DB).</summary>
codeunit 50905 "NBC CRM Pricing Tests"
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
}
