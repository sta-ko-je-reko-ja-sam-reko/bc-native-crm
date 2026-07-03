namespace NBC.Demo;

using Microsoft.CRM.Opportunity;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using NBC.CRM.Linkage;

/// <summary>
/// Idempotent CRONUS-style demo seeder for the Transaction Pipeline Linkage feature. Creates a couple of
/// Sales Orders for a standard CRONUS customer, each with one item line, and stamps them with the demo
/// opportunity back-reference (NBC CRM Opportunity No.) and a spread of NBC CRM Sales Status values.
/// The orders are created but never posted. Re-running is safe: the whole Import is guarded by the demo
/// opportunity number, so the orders are seeded at most once.
/// </summary>
codeunit 50170 "NBC Demo Linkage"
{
    Access = Public;

    /// <summary>
    /// Seed demo linked sales orders. A Sales Order gets its No. from a no-series, so the whole Import is
    /// guarded on the demo opportunity number: if any order already carries it, we exit without seeding.
    /// </summary>
    procedure Import()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        OpportunityNo: Code[20];
    begin
        // Idempotency: a no-series order has no stable natural key, so guard the whole seed on the demo
        // opportunity stamp. If a prior run already created these orders, do nothing.
        SalesHeader.SetRange("NBC CRM Opportunity No.", DemoOpportunityNo());
        if not SalesHeader.IsEmpty() then
            exit;

        // Defensive: without the CRONUS customer there is nothing to sell to.
        Customer.SetLoadFields("No.");
        if not Customer.Get(CronusCustomerNo()) then
            exit;

        // Resolve the demo opportunity if present; otherwise seed without the link (blank stamp).
        OpportunityNo := ResolveDemoOpportunity();

        // Order 1: linked and Submitted.
        SeedLinkedOrder(Customer, OpportunityNo, Enum::"NBC CRM Sales Status"::Submitted);
        // Order 2: linked and Fulfilled.
        SeedLinkedOrder(Customer, OpportunityNo, Enum::"NBC CRM Sales Status"::Fulfilled);

        CreateConfigPackage();
    end;

    /// <summary>Build a RapidStart config package covering the linkage affix fields on the sales documents.</summary>
    local procedure CreateConfigPackage()
    var
        ConfigPkg: Codeunit "NBC Demo Config Package";
        AffixFieldNos: List of [Integer];
    begin
        if not ConfigPkg.StartPackage(PackageCodeTok, PackageNameLbl) then
            exit;
        AffixFieldNos.Add(50140);
        AffixFieldNos.Add(50141);
        AffixFieldNos.Add(50142);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::"Sales Header", AffixFieldNos);
        Clear(AffixFieldNos);
        AffixFieldNos.Add(50140);
        ConfigPkg.AddExtendedTable(PackageCodeTok, Database::"Sales Invoice Header", AffixFieldNos);
    end;

    /// <summary>Create one Sales Order for the customer with a single item line, stamped for the pipeline.</summary>
    local procedure SeedLinkedOrder(var Customer: Record Customer; OpportunityNo: Code[20]; SalesStatus: Enum "NBC CRM Sales Status")
    var
        SalesHeader: Record "Sales Header";
    begin
        // Insert(true) assigns the document No. from the sales-order no-series.
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Modify(true);

        AddItemLine(SalesHeader);

        // Stamp the CRM pipeline context. OpportunityNo may be blank if the demo opportunity is absent.
        SalesHeader."NBC CRM Opportunity No." := OpportunityNo;
        SalesHeader."NBC CRM Sales Status" := SalesStatus;
        SalesHeader.Modify(true);
    end;

    /// <summary>Add a single demo item line, defensively guarded on the CRONUS item existing.</summary>
    local procedure AddItemLine(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        LineNo: Integer;
    begin
        if not DemoItemExists() then
            exit;

        LineNo := 10000;
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", LineNo);
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", CronusItemNo());
        SalesLine.Validate(Quantity, 5);
        SalesLine.Modify(true);
    end;

    /// <summary>Resolve the demo opportunity number, or blank if it is not present in this company.</summary>
    local procedure ResolveDemoOpportunity(): Code[20]
    var
        Opportunity: Record Opportunity;
    begin
        Opportunity.SetLoadFields("No.");
        if Opportunity.Get(DemoOpportunityNo()) then
            exit(Opportunity."No.");
        exit('');
    end;

    /// <summary>True when the CRONUS demo item is present in this company.</summary>
    local procedure DemoItemExists(): Boolean
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("No.");
        exit(Item.Get(CronusItemNo()));
    end;

    local procedure DemoOpportunityNo(): Code[20]
    begin
        exit('NBC-OPP-001');
    end;

    local procedure CronusCustomerNo(): Code[20]
    begin
        exit('10000');
    end;

    local procedure CronusItemNo(): Code[20]
    begin
        exit('1000');
    end;

    var
        PackageCodeTok: Label 'NBC-LINKAGE', Locked = true;
        PackageNameLbl: Label 'CRM Pipeline Linkage';
}
