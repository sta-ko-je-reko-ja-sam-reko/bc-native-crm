namespace NBC.CRM.Linkage;

using Microsoft.Sales.History;
using NBC.Setup;

/// <summary>
/// Surfaces the read-only pipeline link on the Posted Sales Invoice, gated by the Linkage feature. The posted
/// document stays immutable; this only shows the opportunity stamped at posting.
/// </summary>
pageextension 50144 "NBC CRM Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addlast(content)
        {
            group(NBCPipeline)
            {
                Caption = 'CRM';
                field("NBC CRM Opportunity No."; Rec."NBC CRM Opportunity No.")
                {
                    ApplicationArea = NBCLinkage;
                    AccessByPermission = tabledata "NBC Linkage Setup" = R;
                    Editable = false;
                }
            }
        }
    }
}
