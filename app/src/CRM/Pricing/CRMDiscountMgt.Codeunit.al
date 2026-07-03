namespace NBC.CRM.Pricing;

/// <summary>Reusable discount-list tier resolution. ApplyDiscount is pure (unit-testable).</summary>
codeunit 50101 "NBC CRM Discount Mgt."
{
    Access = Public;

    /// <summary>Resolve the discount value for a quantity from a discount list's tiers (first match by ascending min qty).</summary>
    procedure ResolveDiscountValue(DiscountListCode: Code[20]; Quantity: Decimal): Decimal
    var
        DiscountTier: Record "NBC CRM Discount Tier";
    begin
        if DiscountListCode = '' then
            exit(0);
        DiscountTier.SetCurrentKey("Discount List Code", "Minimum Quantity");
        DiscountTier.SetRange("Discount List Code", DiscountListCode);
        DiscountTier.SetFilter("Minimum Quantity", '<=%1', Quantity);
        if DiscountTier.FindLast() then
            if (DiscountTier."Maximum Quantity" = 0) or (Quantity <= DiscountTier."Maximum Quantity") then
                exit(DiscountTier.Value);
        exit(0);
    end;

    /// <summary>Apply a discount value (percentage or amount) to a unit price.</summary>
    procedure ApplyDiscount(UnitPrice: Decimal; DiscountType: Enum "NBC CRM Discount Type"; Value: Decimal): Decimal
    var
        Result: Decimal;
    begin
        case DiscountType of
            DiscountType::Percentage:
                Result := UnitPrice * (1 - Value / 100);
            DiscountType::Amount:
                Result := UnitPrice - Value;
        end;
        if Result < 0 then
            exit(0);
        exit(Result);
    end;
}
