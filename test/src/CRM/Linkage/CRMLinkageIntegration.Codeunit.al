namespace NBC.Test;

using Microsoft.CRM.Opportunity;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using NBC.Core;
using NBC.CRM.Linkage;
using NBC.Setup;
using System.TestLibraries.Utilities;

/// <summary>
/// Transaction pipeline linkage (FEAT-LNK-001), DB-bound — the integration test plan of the feature: an order linked
/// to an opportunity stamps the opportunity on the posted invoice (only when the feature is enabled and the order is
/// linked), the opportunity rolls up its linked orders and invoices, the CRM sales status / pricing lock transitions
/// persist, and the posting subscriber delegates to the swappable reaction exactly once per invoice.
/// </summary>
codeunit 69016 "NBC CRM Linkage Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        TestLibrary: Codeunit "NBC Test Library";
        LibrarySales: Codeunit "Library - Sales";

    [Test]
    procedure PostedInvoiceIsStampedWithOpportunity()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        OpportunityNo: Code[20];
    begin
        // [GIVEN] Linkage enabled and an order linked to an opportunity
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, true);
        OpportunityNo := TestLibrary.CreateOpportunity('');
        TestLibrary.CreateSalesOrder(SalesHeader, OpportunityNo);

        // [WHEN] the order is shipped and invoiced
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [THEN] the posted invoice carries the opportunity
        Assert.AreEqual(OpportunityNo, SalesInvoiceHeader."NBC CRM Opportunity No.", 'Opportunity on the posted invoice');
    end;

    [Test]
    procedure NoStampWhileLinkageDisabled()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [GIVEN] Linkage disabled and an order linked to an opportunity
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, false);
        TestLibrary.CreateSalesOrder(SalesHeader, TestLibrary.CreateOpportunity(''));

        // [WHEN] it is posted
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [THEN] the invoice is not stamped
        Assert.AreEqual('', SalesInvoiceHeader."NBC CRM Opportunity No.", 'Opportunity on the posted invoice');
    end;

    [Test]
    procedure NoStampForUnlinkedOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [GIVEN] Linkage enabled and an order without an opportunity
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, true);
        TestLibrary.CreateSalesOrder(SalesHeader, '');

        // [WHEN] it is posted
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));

        // [THEN] the invoice is not stamped
        Assert.AreEqual('', SalesInvoiceHeader."NBC CRM Opportunity No.", 'Opportunity on the posted invoice');
    end;

    [Test]
    procedure OpportunityRollsUpLinkedOrdersAndInvoices()
    var
        Opportunity: Record Opportunity;
        SalesHeader: Record "Sales Header";
        SecondOrder: Record "Sales Header";
        UnrelatedOrder: Record "Sales Header";
        OpportunityNo: Code[20];
    begin
        // [GIVEN] Linkage enabled, two orders linked to one opportunity and one order linked elsewhere
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, true);
        OpportunityNo := TestLibrary.CreateOpportunity('');
        TestLibrary.CreateSalesOrder(SalesHeader, OpportunityNo);
        TestLibrary.CreateSalesOrder(SecondOrder, OpportunityNo);
        TestLibrary.CreateSalesOrder(UnrelatedOrder, TestLibrary.CreateOpportunity(''));

        // [THEN] the opportunity counts 2 linked orders and no invoices yet
        Opportunity.Get(OpportunityNo);
        Opportunity.CalcFields("NBC CRM Linked Orders", "NBC CRM Linked Invoices");
        Assert.AreEqual(2, Opportunity."NBC CRM Linked Orders", 'Linked orders before posting');
        Assert.AreEqual(0, Opportunity."NBC CRM Linked Invoices", 'Linked invoices before posting');

        // [WHEN] one order is fully posted (and therefore deleted)
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] the opportunity counts 1 order and 1 invoice
        Opportunity.CalcFields("NBC CRM Linked Orders", "NBC CRM Linked Invoices");
        Assert.AreEqual(1, Opportunity."NBC CRM Linked Orders", 'Linked orders after posting');
        Assert.AreEqual(1, Opportunity."NBC CRM Linked Invoices", 'Linked invoices after posting');
    end;

    [Test]
    procedure LinkedOrdersCountOnlyOrders()
    var
        Opportunity: Record Opportunity;
        SalesHeader: Record "Sales Header";
        Quote: Record "Sales Header";
        OpportunityNo: Code[20];
    begin
        // [GIVEN] an opportunity with one linked order and one linked quote
        TestLibrary.Initialize();
        OpportunityNo := TestLibrary.CreateOpportunity('');
        TestLibrary.CreateSalesOrder(SalesHeader, OpportunityNo);
        LibrarySales.CreateSalesHeader(Quote, Quote."Document Type"::Quote, SalesHeader."Sell-to Customer No.");
        Quote."NBC CRM Opportunity No." := OpportunityNo;
        Quote.Modify();

        // [THEN] only the order is counted
        Opportunity.Get(OpportunityNo);
        Opportunity.CalcFields("NBC CRM Linked Orders");
        Assert.AreEqual(1, Opportunity."NBC CRM Linked Orders", 'Linked orders');
    end;

    [Test]
    procedure SalesStatusTransitionsPersist()
    var
        SalesHeader: Record "Sales Header";
        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
    begin
        // [GIVEN] Linkage enabled and an order (Active)
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, true);
        TestLibrary.CreateSalesOrder(SalesHeader, '');
        Assert.AreEqual(SalesHeader."NBC CRM Sales Status"::Active, SalesHeader."NBC CRM Sales Status", 'Initial status');

        // [WHEN/THEN] submit, fulfil and cancel each persist
        LinkageMgt.SubmitOrder(SalesHeader);
        VerifyStoredStatus(SalesHeader, SalesHeader."NBC CRM Sales Status"::Submitted);
        LinkageMgt.MarkOrderFulfilled(SalesHeader);
        VerifyStoredStatus(SalesHeader, SalesHeader."NBC CRM Sales Status"::Fulfilled);
        LinkageMgt.CancelOrder(SalesHeader);
        VerifyStoredStatus(SalesHeader, SalesHeader."NBC CRM Sales Status"::Canceled);
    end;

    [Test]
    procedure LockPricingPersists()
    var
        SalesHeader: Record "Sales Header";
        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
    begin
        // [GIVEN] Linkage enabled and an order
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, true);
        TestLibrary.CreateSalesOrder(SalesHeader, '');

        // [WHEN] pricing is locked
        LinkageMgt.LockPricing(SalesHeader);

        // [THEN] the flag is stored
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.IsTrue(SalesHeader."NBC CRM Pricing Locked", 'Pricing locked');
    end;

    [Test]
    procedure StatusChangeOnRealOrderBlockedWhileDisabled()
    var
        SalesHeader: Record "Sales Header";
        LinkageMgt: Codeunit "NBC CRM Linkage Mgt.";
    begin
        // [GIVEN] Linkage disabled and an order
        TestLibrary.Initialize();
        TestLibrary.SetFeatureEnabled(Enum::"NBC Feature"::Linkage, false);
        TestLibrary.CreateSalesOrder(SalesHeader, '');

        // [WHEN] the order is submitted  [THEN] it errors and the status is unchanged
        asserterror LinkageMgt.SubmitOrder(SalesHeader);
        Assert.ExpectedError('is not enabled');
        VerifyStoredStatus(SalesHeader, SalesHeader."NBC CRM Sales Status"::Active);
    end;

    [Test]
    procedure PostingSubscriberDelegatesOncePerInvoice()
    var
        SalesHeader: Record "Sales Header";
        SpyLinkageReactions: Codeunit "NBC Spy Linkage Reactions";
        ServiceLocator: Codeunit "NBC Service Locator";
        InvoiceNo: Code[20];
    begin
        // [GIVEN] the spy reaction injected into the Service Locator, and a linked order
        TestLibrary.Initialize();
        SpyLinkageReactions.Reset();
        ServiceLocator.ImplementLinkageReactions(SpyLinkageReactions);
        TestLibrary.CreateSalesOrder(SalesHeader, TestLibrary.CreateOpportunity(''));

        // [WHEN] the order is posted
        InvoiceNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        TestLibrary.RestoreDefaultReactions();

        // [THEN] the subscriber called the reaction once, for that invoice
        Assert.AreEqual(1, SpyLinkageReactions.CallCount(), 'Reaction calls');
        Assert.AreEqual(InvoiceNo, SpyLinkageReactions.LastPostedInvoiceNo(), 'Invoice passed to the reaction');
    end;

    local procedure VerifyStoredStatus(SalesHeader: Record "Sales Header"; Expected: Enum "NBC CRM Sales Status")
    var
        StoredHeader: Record "Sales Header";
    begin
        StoredHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        Assert.AreEqual(Expected, StoredHeader."NBC CRM Sales Status", 'Stored CRM sales status');
    end;
}
