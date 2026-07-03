namespace NBC.CRM.Pricing;

using Microsoft.Inventory.Item;
using Microsoft.Pricing.PriceList;
using Microsoft.Projects.Resources.Resource;

/// <summary>
/// Write side of CRM pricing: resolves the asset's list price/cost, runs the pure calc, applies rounding,
/// and writes Unit Price on the Price List Line. Invoked from the Recalculate CRM price action.
/// The pluggable Price Calculation Method (document-time resolution) is the documented next step.
/// </summary>
codeunit 50102 "NBC CRM Price Line Mgt."
{
    Access = Public;

    /// <summary>Recompute and store the line's Unit Price from its CRM pricing method + rounding rule.</summary>
    procedure RecalculatePrice(var PriceListLine: Record "Price List Line")
    var
        PricingCalc: Codeunit "NBC CRM Pricing Calc";
        ListPrice: Decimal;
        UnitCost: Decimal;
        NewPrice: Decimal;
    begin
        if PriceListLine."NBC CRM Pricing Method" = PriceListLine."NBC CRM Pricing Method"::"Currency Amount" then
            exit;

        GetAssetPriceAndCost(PriceListLine, ListPrice, UnitCost);
        NewPrice := PricingCalc.ComputeUnitPrice(
            PriceListLine."NBC CRM Pricing Method", PriceListLine."NBC CRM Pricing %", ListPrice, UnitCost, PriceListLine."Unit Price");
        NewPrice := PricingCalc.ApplyRounding(NewPrice, PriceListLine."NBC CRM Rounding Policy", PriceListLine."NBC CRM Rounding Precision");

        PriceListLine.Validate("Unit Price", NewPrice);
        PriceListLine.Modify(true);
    end;

    local procedure GetAssetPriceAndCost(PriceListLine: Record "Price List Line"; var ListPrice: Decimal; var UnitCost: Decimal)
    var
        Item: Record Item;
        Resource: Record Resource;
    begin
        ListPrice := 0;
        UnitCost := 0;
        case PriceListLine."Asset Type" of
            PriceListLine."Asset Type"::Item:
                if Item.Get(PriceListLine."Asset No.") then begin
                    ListPrice := Item."Unit Price";
                    UnitCost := Item."Unit Cost";
                end;
            PriceListLine."Asset Type"::Resource:
                if Resource.Get(PriceListLine."Asset No.") then begin
                    ListPrice := Resource."Unit Price";
                    UnitCost := Resource."Unit Cost";
                end;
        end;
    end;
}
