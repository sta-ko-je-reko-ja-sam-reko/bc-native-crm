namespace NBC.Test;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using NBC.CRM.Linkage;
using NBC.Setup;

/// <summary>Unit tests for CRM pipeline-linkage reaction logic — pure, in-memory (no DB).</summary>
codeunit 69006 "NBC CRM Linkage Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure ShouldStamp_TrueWhenOpportunitySet()
    var
        SalesHeader: Record "Sales Header";
        Reactions: Codeunit "NBC CRM Linkage Reactions";
    begin
        // [GIVEN] a source order that carries an opportunity link
        SalesHeader."NBC CRM Opportunity No." := 'OPP001';

        // [THEN] the invoice should be stamped
        if not Reactions.ShouldStamp(SalesHeader) then
            Error('Expected ShouldStamp = true when the order has an opportunity.');
    end;

    [Test]
    procedure ShouldStamp_FalseWhenOpportunityBlank()
    var
        SalesHeader: Record "Sales Header";
        Reactions: Codeunit "NBC CRM Linkage Reactions";
    begin
        // [GIVEN] a source order with no opportunity link
        SalesHeader."NBC CRM Opportunity No." := '';

        // [THEN] the invoice should not be stamped
        if Reactions.ShouldStamp(SalesHeader) then
            Error('Expected ShouldStamp = false when the order has no opportunity.');
    end;

    [Test]
    procedure CopyPipelineLink_CopiesOpportunityToInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Reactions: Codeunit "NBC CRM Linkage Reactions";
    begin
        // [GIVEN] a source order linked to an opportunity
        SalesHeader."NBC CRM Opportunity No." := 'OPP042';

        // [WHEN] copying the pipeline link to the posted invoice
        Reactions.CopyPipelineLink(SalesInvoiceHeader, SalesHeader);

        // [THEN] the invoice carries the same opportunity
        if SalesInvoiceHeader."NBC CRM Opportunity No." <> 'OPP042' then
            Error('Expected OPP042 on the invoice, got %1.', SalesInvoiceHeader."NBC CRM Opportunity No.");
    end;

    [Test]
    procedure StatusChangeBlockedWhileLinkageDisabled()
    var
        SalesHeader: Record "Sales Header";
        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
        TestLibrary: Codeunit "NBC Test Library";
    begin
        // [GIVEN] Linkage disabled and an (in-memory) order
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, false);

        // [WHEN] any status transition or the pricing lock is attempted  [THEN] the feature guard stops it first
        asserterror LinkageMgt.SubmitOrder(SalesHeader);
        if StrPos(GetLastErrorText(), 'is not enabled') = 0 then
            Error('SubmitOrder must be blocked by the feature guard, got: %1', GetLastErrorText());
        asserterror LinkageMgt.CancelOrder(SalesHeader);
        if StrPos(GetLastErrorText(), 'is not enabled') = 0 then
            Error('CancelOrder must be blocked by the feature guard, got: %1', GetLastErrorText());
        asserterror LinkageMgt.MarkOrderFulfilled(SalesHeader);
        if StrPos(GetLastErrorText(), 'is not enabled') = 0 then
            Error('MarkOrderFulfilled must be blocked by the feature guard, got: %1', GetLastErrorText());
        asserterror LinkageMgt.LockPricing(SalesHeader);
        if StrPos(GetLastErrorText(), 'is not enabled') = 0 then
            Error('LockPricing must be blocked by the feature guard, got: %1', GetLastErrorText());
    end;

    [Test]
    procedure CopyPipelineLink_BlankOpportunityClearsInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Reactions: Codeunit "NBC CRM Linkage Reactions";
    begin
        // [GIVEN] an invoice buffer that already carries a value, and an unlinked order
        SalesInvoiceHeader."NBC CRM Opportunity No." := 'STALE';

        // [WHEN] copying  [THEN] the invoice mirrors the order exactly
        Reactions.CopyPipelineLink(SalesInvoiceHeader, SalesHeader);
        if SalesInvoiceHeader."NBC CRM Opportunity No." <> '' then
            Error('Expected a blank opportunity, got %1.', SalesInvoiceHeader."NBC CRM Opportunity No.");
    end;
}
