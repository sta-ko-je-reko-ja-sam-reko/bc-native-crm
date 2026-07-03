namespace NBC.CRM.Pricing;

/// <summary>
/// Default implementation of CRM IPricingCalc — pure price-derivation and rounding (no DB, unit-testable).
/// Fills the Dataverse pricing-method gap BC's price list lacks (percent-of-list, markup/margin on cost).
/// </summary>
codeunit 50100 "NBC CRM Pricing Calc" implements "NBC CRM IPricingCalc"
{
    Access = Public;

    procedure ComputeUnitPrice(Method: Enum "NBC CRM Pricing Method"; Percentage: Decimal; ListPrice: Decimal; UnitCost: Decimal; CurrentAmount: Decimal): Decimal
    begin
        case Method of
            Method::"Currency Amount":
                exit(CurrentAmount);
            Method::"Percent of List":
                exit(ListPrice * Percentage / 100);
            Method::"Markup on Cost":
                exit(UnitCost * (1 + Percentage / 100));
            Method::"Margin on Cost":
                begin
                    if Percentage >= 100 then
                        exit(0);
                    exit(UnitCost / (1 - Percentage / 100));
                end;
        end;
    end;

    procedure ApplyRounding(Amount: Decimal; Policy: Enum "NBC CRM Rounding Policy"; Precision: Decimal): Decimal
    begin
        if Precision <= 0 then
            exit(Amount);
        case Policy of
            Policy::"None":
                exit(Amount);
            Policy::Up:
                exit(Round(Amount, Precision, '>'));
            Policy::Down:
                exit(Round(Amount, Precision, '<'));
            Policy::Nearest:
                exit(Round(Amount, Precision, '='));
        end;
        exit(Amount);
    end;
}
