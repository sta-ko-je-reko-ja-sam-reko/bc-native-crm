namespace NBC.Test;

using Microsoft.Pricing.PriceList;
using NBC.CRM.Pricing;
using NBC.Demo;

/// <summary>
/// Integration test for the demo-data layer: idempotency. Uses the Pricing seeder because its records (discount
/// lists/tiers) are self-contained (no CRONUS master-data dependency), so it runs in any test company. Relies on
/// the test runner's rollback.
/// </summary>
codeunit 50907 "NBC Demo Data Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure Pricing_ImportIsIdempotent()
    var
        DiscountList: Record "NBC CRM Discount List";
        DemoPricing: Codeunit "NBC Demo Pricing";
        CountAfterFirst: Integer;
        CountAfterSecond: Integer;
    begin
        // [WHEN] the pricing demo seeder runs once
        DemoPricing.Import();
        CountAfterFirst := DiscountList.Count();

        // [THEN] it created at least one discount list
        if CountAfterFirst < 1 then
            Error('Expected the pricing demo seeder to create at least one discount list.');

        // [WHEN] it runs a second time
        DemoPricing.Import();
        CountAfterSecond := DiscountList.Count();

        // [THEN] no duplicates were created (idempotent)
        if CountAfterSecond <> CountAfterFirst then
            Error('Demo seeder is not idempotent: %1 discount lists after first run, %2 after second.', CountAfterFirst, CountAfterSecond);
    end;
}
