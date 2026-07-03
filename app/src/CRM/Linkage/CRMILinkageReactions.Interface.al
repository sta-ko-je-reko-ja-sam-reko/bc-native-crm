namespace NBC.CRM.Linkage;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;

/// <summary>
/// Swappable contract for the reactions the linkage feature runs off base-app posting. Resolved through the
/// Service Locator so downstream apps and tests can substitute the behaviour without touching the subscriber.
/// </summary>
interface "NBC CRM ILinkageReactions"
{
    /// <summary>Stamp the originating CRM opportunity from the source order onto the freshly posted invoice.</summary>
    /// <param name="SalesInvHeader">The posted invoice header just inserted.</param>
    /// <param name="SalesHeader">The source order/invoice document being posted.</param>
    procedure OnAfterPostInvoice(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header");
}
