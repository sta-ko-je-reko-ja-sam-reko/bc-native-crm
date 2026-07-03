namespace NBC.CRM.Pricing;

/// <summary>Swappable, side-effect-free price-derivation and rounding logic.</summary>
interface "NBC CRM IPricingCalc"
{
    /// <summary>Derives a unit price from the method, percentage, list price and unit cost.</summary>
    procedure ComputeUnitPrice(Method: Enum "NBC CRM Pricing Method"; Percentage: Decimal; ListPrice: Decimal; UnitCost: Decimal; CurrentAmount: Decimal): Decimal;

    /// <summary>Applies a rounding policy at a given precision to an amount.</summary>
    procedure ApplyRounding(Amount: Decimal; Policy: Enum "NBC CRM Rounding Policy"; Precision: Decimal): Decimal;
}
