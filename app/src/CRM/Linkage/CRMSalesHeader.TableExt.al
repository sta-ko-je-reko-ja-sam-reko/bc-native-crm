namespace NBC.CRM.Linkage;

using Microsoft.CRM.Opportunity;
using Microsoft.Sales.Document;

/// <summary>
/// Pipeline linkage on the Sales Header: a back-reference to the originating CRM opportunity plus a sales-facing
/// lifecycle status and a "pricing locked" flag. These are CRM sell-cycle context; BC's own Status, posting and
/// fulfillment are untouched.
/// </summary>
tableextension 50140 "NBC CRM Sales Header" extends "Sales Header"
{
    fields
    {
        field(50140; "NBC CRM Opportunity No."; Code[20])
        {
            Caption = 'CRM Opportunity No.';
            DataClassification = CustomerContent;
            TableRelation = Opportunity;
            ToolTip = 'Specifies the CRM opportunity this order or quote originated from, linking the transaction back to the pipeline.';
        }
        field(50141; "NBC CRM Sales Status"; Enum "NBC CRM Sales Status")
        {
            Caption = 'CRM Sales Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the CRM sales lifecycle of the order (Active, Submitted, Fulfilled, Canceled). This is a sales-facing status and does not affect BC posting.';
        }
        field(50142; "NBC CRM Pricing Locked"; Boolean)
        {
            Caption = 'CRM Pricing Locked';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that the CRM prices on this order have been frozen (the "lock pricing" transition).';
        }
    }
}
