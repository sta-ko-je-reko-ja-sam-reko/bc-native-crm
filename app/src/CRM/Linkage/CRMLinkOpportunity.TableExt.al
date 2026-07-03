namespace NBC.CRM.Linkage;

using Microsoft.CRM.Opportunity;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

/// <summary>
/// Closes the pipeline loop on the Opportunity: FlowField counts of the sales orders and posted invoices that trace
/// back to this opportunity, so a salesperson sees realised transactions straight from the opportunity.
/// </summary>
tableextension 50142 "NBC CRM Link Opportunity" extends Opportunity
{
    fields
    {
        field(50044; "NBC CRM Linked Orders"; Integer)
        {
            Caption = 'CRM Linked Orders';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Order), "NBC CRM Opportunity No." = field("No.")));
            Editable = false;
            ToolTip = 'Specifies how many sales orders trace back to this opportunity.';
        }
        field(50045; "NBC CRM Linked Invoices"; Integer)
        {
            Caption = 'CRM Linked Invoices';
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header" where("NBC CRM Opportunity No." = field("No.")));
            Editable = false;
            ToolTip = 'Specifies how many posted sales invoices trace back to this opportunity.';
        }
    }
}
