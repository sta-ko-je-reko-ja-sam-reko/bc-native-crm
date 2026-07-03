namespace NBC.Test;

using NBC.CRM.Opportunity;

/// <summary>Unit tests for CRM Opportunity Line Logic — pure amount calculation (no DB).</summary>
codeunit 50902 "NBC CRM Opp. Line Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure LineAmount_IsQuantityTimesUnitPrice()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        LineLogic: Codeunit "NBC CRM Opp. Line Logic";
    begin
        // [GIVEN] a line with quantity and unit price
        OpportunityLine.Quantity := 3;
        OpportunityLine."Unit Price" := 250;

        // [WHEN] recalculating the amount
        LineLogic.Validate_Amounts(OpportunityLine);

        // [THEN] line amount = quantity × unit price
        if OpportunityLine."Line Amount" <> 750 then
            Error('Expected 750, got %1.', OpportunityLine."Line Amount");
    end;

    [Test]
    procedure LineAmount_ZeroQuantityGivesZero()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        LineLogic: Codeunit "NBC CRM Opp. Line Logic";
    begin
        OpportunityLine.Quantity := 0;
        OpportunityLine."Unit Price" := 999;
        LineLogic.Validate_Amounts(OpportunityLine);
        if OpportunityLine."Line Amount" <> 0 then
            Error('Expected 0, got %1.', OpportunityLine."Line Amount");
    end;
}
