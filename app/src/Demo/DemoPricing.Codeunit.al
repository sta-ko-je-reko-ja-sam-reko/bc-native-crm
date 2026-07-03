namespace NBC.Demo;

using Microsoft.Pricing.PriceList;
using NBC.CRM.Pricing;

/// <summary>
/// Idempotent CRONUS-style demo seeder for the CRM Pricing Flexibility feature. Seeds two reusable
/// NBC CRM Discount List records (one Percentage, one Amount) with quantity-banded NBC CRM Discount Tier
/// rows that exercise the tier model, and optionally stamps the CRM pricing fields (method, discount list,
/// rounding, qty-selling enums) onto an existing CRONUS Price List Line.
/// Every insert is guarded by a fixed key and every reference to standard master data is Get-guarded,
/// so the seeder is safe to run repeatedly and skips gracefully on a non-CRONUS company.
/// </summary>
codeunit 50169 "NBC Demo Pricing"
{
    Access = Public;

    /// <summary>Seed demo discount lists, tiers and (optionally) CRM price-line fields. Idempotent and defensive.</summary>
    procedure Import()
    begin
        SeedVolumeDiscount();
        SeedRebateDiscount();
        StampDemoPriceListLine();
        CreateConfigPackage();
    end;

    /// <summary>A percentage volume discount list with three ascending quantity bands.</summary>
    local procedure SeedVolumeDiscount()
    begin
        if InsertDiscountList('VOL-STD', 'Standard volume discount', Enum::"NBC CRM Discount Type"::Percentage) then begin
            InsertTier('VOL-STD', 10000, 1, 9, 0);
            InsertTier('VOL-STD', 20000, 10, 49, 5);
            InsertTier('VOL-STD', 30000, 50, 99, 10);
            InsertTier('VOL-STD', 40000, 100, 0, 15);
        end;
    end;

    /// <summary>A fixed-amount rebate discount list with two quantity bands (second open-ended).</summary>
    local procedure SeedRebateDiscount()
    begin
        if InsertDiscountList('REBATE-A', 'Fixed-amount rebate', Enum::"NBC CRM Discount Type"::Amount) then begin
            InsertTier('REBATE-A', 10000, 1, 24, 2.5);
            InsertTier('REBATE-A', 20000, 25, 0, 5.0);
        end;
    end;

    /// <summary>Insert a discount list header. Returns true only when a new record was created.</summary>
    local procedure InsertDiscountList(ListCode: Code[20]; ListDescription: Text[100]; DiscountType: Enum "NBC CRM Discount Type"): Boolean
    var
        DiscountList: Record "NBC CRM Discount List";
    begin
        if DiscountList.Get(ListCode) then
            exit(false);
        DiscountList.Init();
        DiscountList.Validate(Code, ListCode);
        DiscountList.Validate(Description, ListDescription);
        DiscountList.Validate("Discount Type", DiscountType);
        DiscountList.Insert(true);
        exit(true);
    end;

    /// <summary>Insert one quantity band into a discount list, unless that line already exists.</summary>
    local procedure InsertTier(ListCode: Code[20]; LineNo: Integer; MinQty: Decimal; MaxQty: Decimal; TierValue: Decimal)
    var
        DiscountTier: Record "NBC CRM Discount Tier";
    begin
        if DiscountTier.Get(ListCode, LineNo) then
            exit;
        DiscountTier.Init();
        DiscountTier.Validate("Discount List Code", ListCode);
        DiscountTier.Validate("Line No.", LineNo);
        DiscountTier.Validate("Minimum Quantity", MinQty);
        DiscountTier.Validate("Maximum Quantity", MaxQty);
        DiscountTier.Validate(Value, TierValue);
        DiscountTier.Insert(true);
    end;

    /// <summary>
    /// Stamp CRM pricing fields onto the first existing CRONUS Price List Line, wiring it to a seeded
    /// discount list and exercising the pricing-method, rounding-policy and qty-selling enums.
    /// Fully Get-guarded: if no Price List Line exists, this part is skipped.
    /// </summary>
    local procedure StampDemoPriceListLine()
    var
        PriceListLine: Record "Price List Line";
        DiscountList: Record "NBC CRM Discount List";
    begin
        if PriceListLine.IsEmpty() then
            exit;
        PriceListLine.FindFirst();

        // Only overwrite once: skip if this line has already been stamped by a previous run.
        if PriceListLine."NBC CRM Pricing Method" <> PriceListLine."NBC CRM Pricing Method"::"Currency Amount" then
            exit;

        PriceListLine.Validate("NBC CRM Pricing Method", PriceListLine."NBC CRM Pricing Method"::"Percent of List");
        PriceListLine.Validate("NBC CRM Pricing %", 10);
        DiscountList.SetLoadFields(Code);
        if DiscountList.Get('VOL-STD') then
            PriceListLine.Validate("NBC CRM Discount List", DiscountList.Code);
        PriceListLine.Validate("NBC CRM Rounding Policy", PriceListLine."NBC CRM Rounding Policy"::Nearest);
        PriceListLine.Validate("NBC CRM Rounding Precision", 0.99);
        PriceListLine.Validate("NBC CRM Qty. Selling", PriceListLine."NBC CRM Qty. Selling"::"Whole and Fractional");
        PriceListLine.Modify(true);
    end;

    /// <summary>
    /// Build a RapidStart Config. Package bundling the two CRM discount tables and the CRM pricing
    /// affix fields on the standard Price List Line, so the demo pricing setup can be exported and
    /// replayed on another company. Skips silently if the package already exists.
    /// </summary>
    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
        AffixFieldNos: List of [Integer];
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Discount List");
        ConfigPkg.AddOwnTable(PackageCodeTok, Database::"NBC CRM Discount Tier");
        AffixFieldNos.Add(50100);
        AffixFieldNos.Add(50101);
        AffixFieldNos.Add(50102);
        AffixFieldNos.Add(50103);
        AffixFieldNos.Add(50104);
        AffixFieldNos.Add(50105);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::"Price List Line", AffixFieldNos);
    end;

    var
        PackageCodeTok: Label 'NBC-PRICING', Locked = true;
        PackageNameLbl: Label 'CRM Pricing Flexibility';
}
