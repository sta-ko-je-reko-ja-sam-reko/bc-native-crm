namespace NBC.CRM.Linkage;

using Microsoft.CRM.Opportunity;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using NBC.Setup;

/// <summary>
/// Public services for pipeline linkage: move an order's CRM sales status, lock its pricing, and drill from an
/// opportunity to its resulting orders/invoices. The mutating services re-check the feature flag so the toggle
/// gates every write path, not only the UI.
/// </summary>
codeunit 50141 "NBC CRM Linkage Mgt."
{
    Access = Public;

    /// <summary>Set the order's CRM sales status to Submitted.</summary>
    procedure SubmitOrder(var SalesHeader: Record "Sales Header")
    begin
        SetSalesStatus(SalesHeader, SalesHeader."NBC CRM Sales Status"::Submitted);
    end;

    /// <summary>Set the order's CRM sales status to Canceled.</summary>
    procedure CancelOrder(var SalesHeader: Record "Sales Header")
    begin
        SetSalesStatus(SalesHeader, SalesHeader."NBC CRM Sales Status"::Canceled);
    end;

    /// <summary>Set the order's CRM sales status to Fulfilled.</summary>
    procedure MarkOrderFulfilled(var SalesHeader: Record "Sales Header")
    begin
        SetSalesStatus(SalesHeader, SalesHeader."NBC CRM Sales Status"::Fulfilled);
    end;

    /// <summary>Set the order's CRM sales status, guarded by the feature toggle.</summary>
    procedure SetSalesStatus(var SalesHeader: Record "Sales Header"; NewStatus: Enum "NBC CRM Sales Status")
    var
        FeatureMgt: Codeunit "NBC Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"NBC Feature"::Linkage);
        SalesHeader."NBC CRM Sales Status" := NewStatus;
        SalesHeader.Modify(true);
    end;

    /// <summary>Freeze the CRM prices on the order (the "lock pricing" transition).</summary>
    procedure LockPricing(var SalesHeader: Record "Sales Header")
    var
        FeatureMgt: Codeunit "NBC Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"NBC Feature"::Linkage);
        SalesHeader."NBC CRM Pricing Locked" := true;
        SalesHeader.Modify(true);
    end;

    /// <summary>Open the sales orders that trace back to the given opportunity.</summary>
    procedure ShowLinkedOrders(Opportunity: Record Opportunity)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NBC CRM Opportunity No.", Opportunity."No.");
        Page.Run(Page::"Sales Order List", SalesHeader);
    end;

    /// <summary>Open the posted sales invoices that trace back to the given opportunity.</summary>
    procedure ShowLinkedInvoices(Opportunity: Record Opportunity)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("NBC CRM Opportunity No.", Opportunity."No.");
        Page.Run(Page::"Posted Sales Invoices", SalesInvoiceHeader);
    end;
}
