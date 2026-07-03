namespace NBC.CRM.Linkage;

using Microsoft.CRM.Opportunity;
using Microsoft.Sales.History;

/// <summary>
/// Pipeline linkage on the posted Sales Invoice: the originating CRM opportunity, stamped at posting time from the
/// source order by the linkage reaction. The posted document is immutable, so the field is read-only — a downstream
/// mirror that keeps billing visible along the pipeline without originating any accounting data.
/// </summary>
tableextension 50141 "NBC CRM Sales Inv. Header" extends "Sales Invoice Header"
{
    fields
    {
        field(50140; "NBC CRM Opportunity No."; Code[20])
        {
            Caption = 'CRM Opportunity No.';
            DataClassification = CustomerContent;
            TableRelation = Opportunity;
            Editable = false;
            ToolTip = 'Specifies the CRM opportunity this posted invoice traces back to, carried forward from the source order at posting.';
        }
    }
}
