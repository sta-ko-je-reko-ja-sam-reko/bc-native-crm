namespace NBC.Test;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using NBC.CRM.Linkage;

/// <summary>Spy for the linkage reactions: records each delegation from the sales-posting subscriber.</summary>
codeunit 69093 "NBC Spy Linkage Reactions" implements "NBC CRM ILinkageReactions"
{
    SingleInstance = true;

    var
        Calls: Integer;
        LastInvoiceNo: Code[20];

    /// <summary>Clears the recorded calls.</summary>
    procedure Reset()
    begin
        Calls := 0;
        LastInvoiceNo := '';
    end;

    /// <summary>How often OnAfterPostInvoice ran since the last Reset.</summary>
    /// <returns>The call count.</returns>
    procedure CallCount(): Integer
    begin
        exit(Calls);
    end;

    /// <summary>The posted invoice number of the last call.</summary>
    /// <returns>The invoice number.</returns>
    procedure LastPostedInvoiceNo(): Code[20]
    begin
        exit(LastInvoiceNo);
    end;

    procedure OnAfterPostInvoice(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header")
    begin
        Calls += 1;
        LastInvoiceNo := SalesInvHeader."No.";
    end;
}
