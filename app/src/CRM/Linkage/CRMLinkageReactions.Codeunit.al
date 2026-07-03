namespace NBC.CRM.Linkage;

using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using NBC.Setup;

/// <summary>
/// Default linkage reactions. The feature <c>Enabled</c> flag is the first guard, so a disabled (or unentitled)
/// feature does nothing during posting. Only the pipeline pointer is copied — no accounting data is touched.
/// </summary>
codeunit 50142 "NBC CRM Linkage Reactions" implements "NBC CRM ILinkageReactions"
{
    Access = Public;

    procedure OnAfterPostInvoice(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header")
    var
        FeatureMgt: Codeunit "NBC Feature Mgt.";
    begin
        if not FeatureMgt.IsEnabled(Enum::"NBC Feature"::Linkage) then
            exit;
        if not ShouldStamp(SalesHeader) then
            exit;
        CopyPipelineLink(SalesInvHeader, SalesHeader);
        SalesInvHeader.Modify();
    end;

    /// <summary>Pure decision: the invoice is stamped only when the source order carries an opportunity link.</summary>
    procedure ShouldStamp(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(SalesHeader."NBC CRM Opportunity No." <> '');
    end;

    /// <summary>Pure copy of the pipeline link from the source order to the invoice (no DB access).</summary>
    procedure CopyPipelineLink(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header")
    begin
        SalesInvHeader."NBC CRM Opportunity No." := SalesHeader."NBC CRM Opportunity No.";
    end;
}
