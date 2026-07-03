namespace NBC.CRM.Linkage;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using NBC.Core;

/// <summary>
/// Pure-proxy subscriber on the standard sales posting flow. Fires whenever any user posts a sales invoice, so it is
/// skip-safe for unentitled users ('', true, true) and forwards a single line to the swappable reaction via the
/// Service Locator. The reaction's first line re-checks the feature flag.
/// </summary>
codeunit 50143 "NBC CRM Linkage Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterSalesInvHeaderInsert, '', true, true)]
    local procedure OnAfterSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header")
    var
        ServiceLocator: Codeunit "NBC Service Locator";
    begin
        ServiceLocator.LinkageReactions().OnAfterPostInvoice(SalesInvHeader, SalesHeader);
    end;
}
