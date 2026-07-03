namespace NBC.Test;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using NBC.CRM.Linkage;

/// <summary>Unit tests for CRM pipeline-linkage reaction logic — pure, in-memory (no DB).</summary>
codeunit 50906 "NBC CRM Linkage Tests"
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
}
