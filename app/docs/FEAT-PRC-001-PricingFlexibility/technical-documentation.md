# FEAT-PRC-001 - Pricing Flexibility

> **Source/legacy reference:** N/A (greenfield). Closes the gaps in
> [pricelevel-vs-bc-price-list.md](../../../.claude/skills/dataverse-crm-integration/pricelevel-vs-bc-price-list.md)
> (Tier 3, feature 12 in the skill [README.md](../../../.claude/skills/dataverse-crm-integration/README.md)).
> **Affected objects:** Price List Line (extend), Price List Lines (extend); new Discount List / Discount Tier.
> **Namespaces:** `NBC.CRM.Pricing`.

**Tier 3, feature 12.** This is the *inverse* of most gaps: BC's **modern unified Price List** is already
posting-anchored, source-typed (audience-aware), VAT-aware and calculation-pluggable — richer than Dataverse's flat
`pricelevel` (§2 of the gap analysis). So we **do not rebuild the price list**. We add only the narrow, specific
gaps from §5: per-line **pricing methods** (percent-of-list, markup/margin on cost — BC has only fixed price and
`Cost Factor`), reusable **discount-list tiers**, line-level **rounding rules**, and a **quantity-selling** control.

## Design decisions

1. **Extend the Price List Line, don't resurrect Sales Price** — a `tableextension` on **Price List Line** (7001,
   `Microsoft.Pricing.PriceList`) adds `NBC CRM Pricing Method`, `NBC CRM Pricing %`, `NBC CRM Discount List`,
   `NBC CRM Rounding Policy`, `NBC CRM Rounding Precision`, `NBC CRM Qty. Selling`. Per the design note in the gap
   doc: pricing method + rounding fit naturally as new Price List Line fields.
2. **Pricing computation is pure, swappable logic** — interface `NBC CRM IPricingCalc` + `NBC CRM Pricing Calc`:
   `ComputeUnitPrice(Method, Pct, ListPrice, UnitCost, CurrentAmount)` and `ApplyRounding(Amount, Policy, Precision)`
   are side-effect-free (unit-testable without a DB). Formulas: *Percent of List* = ListPrice × %/100; *Markup on
   Cost* = UnitCost × (1 + %/100); *Margin on Cost* = UnitCost ÷ (1 − %/100); *Currency Amount* keeps the entered
   amount.
3. **The write side is separate** — `NBC CRM Price Line Mgt.RecalculatePrice(var Line)` resolves the asset's list
   price/cost (Item/Resource), calls the calc, applies rounding, and writes `Unit Price`. Surfaced as a
   **Recalculate CRM price** action on the Price List Lines part. We do **not** replace BC's Price Calculation
   engine — productionizing as a pluggable `Price Calculation Method` is noted as the next step.
4. **Reusable discount tiers as a small entity** — `NBC CRM Discount List` (header, Percentage/Amount typed) +
   `NBC CRM Discount Tier` (quantity band + value). One list is reusable across many price-list lines via the
   `NBC CRM Discount List` code field. `NBC CRM Discount Mgt.ResolveDiscountValue(Code, Qty)` picks the tier;
   `ApplyDiscount(UnitPrice, Type, Value)` is the pure helper.
5. **Quantity-selling control** — `NBC CRM Qty. Selling` (None / Whole / Whole and Fractional) records the intent
   on the line; BC still enforces physical rounding via UoM precision.
6. **Ownership / row-level security on the price list (§5 gap 5)** — deferred; the ownership model (FEAT-OWN-001)
   exists and can be layered on later if CRM-style catalog ownership is required. Documented, not built.

## Business Process

1. On a Price List Line, choose a **Pricing Method** and **%**; **Recalculate CRM price** derives the `Unit Price`
   from the item's list price or cost and applies the **rounding** rule (e.g. always end in `.99`).
2. Attach a reusable **Discount List** to lines that share volume tiers; the tier resolves the discount at the
   sold quantity.
3. Set **Qty. Selling** where fractional selling must be constrained.

## Data Model

### New Tables
| # | Table | Field | Type | Notes |
|---|---|---|---|---|
| 50100 | NBC CRM Discount List | Code | Code[20] | PK |
| | | Description | Text[100] | |
| | | Discount Type | Enum "NBC CRM Discount Type" | Percentage/Amount |
| 50101 | NBC CRM Discount Tier | Discount List Code | Code[20] | PK1, TableRelation Discount List |
| | | Line No. | Integer | PK2 |
| | | Minimum Quantity | Decimal | band start |
| | | Maximum Quantity | Decimal | band end (0 = open) |
| | | Value | Decimal | percent or amount per Discount Type |

### New Fields on Existing Tables
| Object | Field ID | Field | Type |
|---|---|---|---|
| Price List Line (7001) | 50100 | NBC CRM Pricing Method | Enum "NBC CRM Pricing Method" |
| Price List Line (7001) | 50101 | NBC CRM Pricing % | Decimal |
| Price List Line (7001) | 50102 | NBC CRM Discount List | Code[20] (TableRelation) |
| Price List Line (7001) | 50103 | NBC CRM Rounding Policy | Enum "NBC CRM Rounding Policy" |
| Price List Line (7001) | 50104 | NBC CRM Rounding Precision | Decimal |
| Price List Line (7001) | 50105 | NBC CRM Qty. Selling | Enum "NBC CRM Qty. Selling" |

## Objects

| Type | ID | Name |
|---|---|---|
| enum | 50100 | NBC CRM Pricing Method |
| enum | 50101 | NBC CRM Rounding Policy |
| enum | 50102 | NBC CRM Discount Type |
| enum | 50103 | NBC CRM Qty. Selling |
| table | 50100 | NBC CRM Discount List |
| table | 50101 | NBC CRM Discount Tier |
| interface | — | NBC CRM IPricingCalc |
| codeunit | 50100 | NBC CRM Pricing Calc |
| codeunit | 50101 | NBC CRM Discount Mgt. |
| codeunit | 50102 | NBC CRM Price Line Mgt. |
| tableextension | 50100 | NBC CRM Price List Line |
| pageextension | 50100 | NBC CRM Price List Lines |
| page | 50100 | NBC CRM Discount Lists |
| page | 50101 | NBC CRM Discount List Card |
| page | 50102 | NBC CRM Discount Tiers |
| permissionset | 50100 | NBC CRM Pricing |

## Integration Points

| Point | Procedure / Event | Usage |
|---|---|---|
| Price derivation | `NBC CRM Pricing Calc.ComputeUnitPrice` | percent-of-list / markup / margin |
| Rounding | `NBC CRM Pricing Calc.ApplyRounding` | policy + precision (end-in / multiple-of) |
| Recalc action | `NBC CRM Price Line Mgt.RecalculatePrice(var Line)` | writes Unit Price on the line |
| Discount tiers | `NBC CRM Discount Mgt.ResolveDiscountValue(Code, Qty)` + `ApplyDiscount` | volume discount |

## Files

```
app/src/CRM/Pricing/
├── PricingMethod.Enum.al  RoundingPolicy.Enum.al  DiscountType.Enum.al  QtySelling.Enum.al
├── DiscountList.Table.al  DiscountTier.Table.al
├── IPricingCalc.Interface.al  PricingCalc.Codeunit.al  DiscountMgt.Codeunit.al  PriceLineMgt.Codeunit.al
├── PriceListLine.TableExt.al  PriceListLines.PageExt.al
├── DiscountLists.Page.al  DiscountListCard.Page.al  DiscountTiers.Page.al  Pricing.PermissionSet.al
test/src/PricingTests.Codeunit.al
```

## Known Limitations

- **Not wired into the live Price Calculation engine** — the method computes and writes `Unit Price` on demand
  (action), it is not yet a pluggable `Price Calculation Method` resolved at document time. Documented next step.
- **Price-list ownership / row-level security** (§5 gap 5) deferred.
- Discount tiers resolve a single value; overlapping bands are resolved first-match by ascending minimum quantity.
- Margin method guards `% >= 100` (returns 0 to avoid divide-by-zero / negative price).
