namespace NBC.Test;

using NBC.CRM.Opportunity;
using System.TestLibraries.Utilities;

/// <summary>Unit tests for CRM Opportunity Line Logic (FEAT-OPP-001) — amount calculation and the logic seam (no DB).</summary>
codeunit 69002 "NBC CRM Opp. Line Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";

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
        Assert.AreEqual(750, OpportunityLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure LineAmount_ZeroQuantityGivesZero()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        LineLogic: Codeunit "NBC CRM Opp. Line Logic";
    begin
        // [GIVEN] quantity 0  [WHEN] recalculating  [THEN] amount 0
        OpportunityLine.Quantity := 0;
        OpportunityLine."Unit Price" := 999;
        LineLogic.Validate_Amounts(OpportunityLine);
        Assert.AreEqual(0, OpportunityLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure LineAmount_RoundsToAmountPrecision()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        LineLogic: Codeunit "NBC CRM Opp. Line Logic";
    begin
        // [GIVEN] 3 × 3.335 = 10.005
        OpportunityLine.Quantity := 3;
        OpportunityLine."Unit Price" := 3.335;

        // [WHEN] recalculating  [THEN] rounded to 0.01
        LineLogic.Validate_Amounts(OpportunityLine);
        Assert.AreEqual(10.01, OpportunityLine."Line Amount", 'Rounded line amount');
    end;

    [Test]
    procedure ValidatingQuantityAndPriceRecalculatesAmount()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
    begin
        // [WHEN] quantity and unit price are validated on the table (in memory)
        OpportunityLine.Validate(Quantity, 4);
        OpportunityLine.Validate("Unit Price", 12.5);

        // [THEN] the table triggers recalculated the amount
        Assert.AreEqual(50, OpportunityLine."Line Amount", 'Line amount after validation');
    end;

    [Test]
    procedure CommentLineNoPullsNothing()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        LineLogic: Codeunit "NBC CRM Opp. Line Logic";
    begin
        // [GIVEN] a comment line with a manual description and price
        OpportunityLine.Type := OpportunityLine.Type::Comment;
        OpportunityLine."No." := 'ANY';
        OpportunityLine.Description := 'Manual text';
        OpportunityLine.Quantity := 2;
        OpportunityLine."Unit Price" := 10;

        // [WHEN] No. is validated
        LineLogic.Validate_No(OpportunityLine);

        // [THEN] the description stays and the amount is recalculated
        Assert.AreEqual('Manual text', OpportunityLine.Description, 'Description');
        Assert.AreEqual(20, OpportunityLine."Line Amount", 'Line amount');
    end;

    [Test]
    procedure TableDelegatesToInjectedLogic()
    var
        OpportunityLine: Record "NBC CRM Opp. Line";
        SpyOppLineLogic: Codeunit "NBC Spy Opp. Line Logic";
    begin
        // [GIVEN] the spy logic injected
        SpyOppLineLogic.Reset();
        OpportunityLine.Define(SpyOppLineLogic);

        // [WHEN] No., Quantity and Unit Price are validated
        OpportunityLine.Validate("No.", '');
        OpportunityLine.Validate(Quantity, 2);
        OpportunityLine.Validate("Unit Price", 5);

        // [THEN] every validation reached the spy and the default calculation did not run
        Assert.AreEqual(1, SpyOppLineLogic.NoCallCount(), 'Validate_No calls');
        Assert.AreEqual(2, SpyOppLineLogic.AmountCallCount(), 'Validate_Amounts calls');
        Assert.AreEqual(0, OpportunityLine."Line Amount", 'The default calculation must not run.');
    end;
}
